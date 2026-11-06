"""Explicitly opt-in loopback HTTP boundary for the development reference runner."""
import argparse
import json
import hmac
import ipaddress
import os
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from runner import RunnerUnavailable, available_languages, review

ORIGINS = {'http://127.0.0.1:8123', 'http://localhost:8123'}


def handler(reviewer=review, readiness=available_languages, listen_host='127.0.0.1', token=''):
    slot = threading.BoundedSemaphore(1)

    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_args):
            pass

        def allowed(self):
            hosts = {f'{h}:{self.server.server_port}' for h in ('127.0.0.1', 'localhost', '10.0.2.2', listen_host)}
            return self.headers.get('Host') in hosts and self.headers.get('Origin') in (None, *ORIGINS)

        def authorized(self):
            return not token or hmac.compare_digest(self.headers.get('Authorization', ''), f'Bearer {token}')

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
            self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
            self.end_headers()

        def do_GET(self):
            if not self.allowed() or not self.authorized():
                return self.reply(403, {'error':'Origin not allowed'})
            if self.path != '/health':
                return self.reply(404, {'error':'Not found'})
            try:
                languages = readiness()
                return self.reply(200, {'ready':bool(languages),'languages':languages,'development_only':True})
            except Exception:
                return self.reply(200, {'ready':False,'languages':[],'development_only':True})

        def do_POST(self):
            self.connection.settimeout(5)
            if not self.allowed() or not self.authorized():
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
    parser.add_argument('--listen', default='127.0.0.1',
                        help='Bind to a private IPv4 address only when the phone must connect over trusted Wi-Fi')
    args = parser.parse_args()
    address = ipaddress.ip_address(args.listen)
    networks = [ipaddress.ip_network(range_) for range_ in ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16')]
    if args.listen != '127.0.0.1' and not any(address in network for network in networks):
        parser.error('--listen must be 127.0.0.1 or a private LAN IPv4 address')
    token = os.environ.get('LOOPLOOM_RUNNER_TOKEN', '')
    if args.listen != '127.0.0.1' and len(token) < 32:
        parser.error('Set LOOPLOOM_RUNNER_TOKEN to at least 32 random characters before LAN binding')
    if not available_languages():
        raise RunnerUnavailable('No local runtime is ready')
    service = ThreadingHTTPServer((args.listen, 8766), handler(listen_host=args.listen, token=token))
    print(f'Development reference runner on {args.listen}:8766', flush=True)
    try:
        service.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        service.server_close()
