"""Explicitly opt-in loopback HTTP boundary for the development reference runner."""
import argparse
import json
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from runner import RunnerUnavailable, preflight, review

ORIGINS = {'http://127.0.0.1:8123', 'http://localhost:8123'}


def handler(reviewer=review, readiness=preflight):
    slot = threading.BoundedSemaphore(1)

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_args):
            pass

        def allowed(self):
            return self.headers.get('Host') in {f'{h}:{self.server.server_port}' for h in ('127.0.0.1', 'localhost', '10.0.2.2')} and self.headers.get('Origin') in (None, *ORIGINS)

        def reply(self, status, data):
            body = json.dumps(data).encode()
            self.send_response(status)
            if self.headers.get('Origin') in ORIGINS:
                self.send_header('Access-Control-Allow-Origin', self.headers['Origin'])
                self.send_header('Vary', 'Origin')
            self.send_header('Content-Type', 'application/json')
            self.send_header('Cache-Control', 'no-store')
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_OPTIONS(self):
            if not self.allowed() or self.headers.get('Origin') not in ORIGINS:
                return self.reply(403, {'error':'Origin not allowed'})
            self.send_response(204)
            self.send_header('Access-Control-Allow-Origin', self.headers['Origin'])
            self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
            self.send_header('Access-Control-Allow-Headers', 'Content-Type')
            self.end_headers()

        def do_GET(self):
            if not self.allowed():
                return self.reply(403, {'error':'Origin not allowed'})
            if self.path != '/health':
                return self.reply(404, {'error':'Not found'})
            try:
                readiness()
                return self.reply(200, {'ready':True,'languages':['javascript'],'development_only':True})
            except Exception:
                return self.reply(200, {'ready':False,'languages':['javascript'],'development_only':True})

        def do_POST(self):
            self.connection.settimeout(5)
            if not self.allowed():
                return self.reply(403, {'error':'Origin not allowed'})
            if self.path != '/run':
                return self.reply(404, {'error':'Not found'})
            try:
                size = int(self.headers.get('Content-Length','0'))
                if not 0 < size <= 65536 or self.headers.get_content_type() != 'application/json':
                    return self.reply(400, {'error':'Bounded JSON required'})
            except ValueError:
                return self.reply(400, {'error':'Invalid size'})
            if not slot.acquire(blocking=False):
                return self.reply(429, {'error':'Runner busy'})
            try:
                return self.reply(200, reviewer(json.loads(self.rfile.read(size))))
            except (ValueError, UnicodeError):
                return self.reply(400, {'error':'Invalid lesson, language, or source'})
            except Exception:
                return self.reply(503, {'error':'Local runner unavailable; draft preserved'})
            finally:
                slot.release()
    return Handler


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--development', action='store_true', required=True,
                        help='Acknowledge this local experiment is not a public arbitrary-code service')
    args = parser.parse_args()
    preflight()
    service = ThreadingHTTPServer(('127.0.0.1', 8766), handler())
    print('Development JavaScript reference runner on 127.0.0.1:8766', flush=True)
    try:
        service.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        service.server_close()
