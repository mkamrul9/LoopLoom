"""Serve the compiled Flutter preview on loopback with current build assets."""
import argparse
import hashlib
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

WEB_ROOT = Path(__file__).resolve().parent.parent / "apps" / "solveit" / "build" / "web"


class PreviewHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEB_ROOT), **kwargs)

    def end_headers(self):
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def log_message(self, *_args):
        pass

    def send_head(self):
        route = urlsplit(self.path).path
        if route not in ("/", "/index.html", "/flutter_bootstrap.js"):
            return super().send_head()
        filename = "flutter_bootstrap.js" if route.endswith(".js") else "index.html"
        try:
            version = hashlib.sha256((WEB_ROOT / "main.dart.js").read_bytes()).hexdigest()[:16]
            data = (WEB_ROOT / filename).read_bytes()
        except FileNotFoundError:
            self.send_error(503, "Build Flutter web before starting the preview")
            return None
        # Preserve origin/IndexedDB while bypassing previously cached JS URLs.
        if filename == "index.html":
            data = data.replace(b'src="flutter_bootstrap.js"',
                                f'src="flutter_bootstrap.js?v={version}"'.encode())
        else:
            data = data.replace(b'"mainJsPath":"main.dart.js"',
                                f'"mainJsPath":"main.dart.js?v={version}"'.encode())
        self.send_response(200)
        self.send_header("Content-Type", "text/javascript; charset=utf-8" if filename.endswith(".js") else "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        from io import BytesIO
        return BytesIO(data)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=8123)
    args = parser.parse_args()
    if not 1 <= args.port <= 65535:
        parser.error("Port must be between 1 and 65535")
    if not (WEB_ROOT / "main.dart.js").is_file():
        parser.error("Run flutter build web from apps/solveit first")
    server = ThreadingHTTPServer(("127.0.0.1", args.port), PreviewHandler)
    print(f"SolveIt guided/development preview: http://127.0.0.1:{args.port}/", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
