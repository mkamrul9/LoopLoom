import http.client
import importlib.util
from pathlib import Path
import tempfile
import threading
import unittest
from unittest.mock import patch
from http.server import ThreadingHTTPServer

spec = importlib.util.spec_from_file_location('preview', Path(__file__).with_name('serve-preview.py'))
preview = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preview)


class PreviewTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.root = Path(self.directory.name) / 'web'
        self.root.mkdir()
        (self.root / 'index.html').write_text('<script src="flutter_bootstrap.js" async></script>')
        (self.root / 'flutter_bootstrap.js').write_text('{"mainJsPath":"main.dart.js"}')
        (self.root / 'main.dart.js').write_text('first build')
        (self.root.parent / 'private.txt').write_text('outside the compiled app')
        self.root_patch = patch.object(preview, 'WEB_ROOT', self.root)
        self.root_patch.start()
        self.server = ThreadingHTTPServer(('127.0.0.1', 0), preview.PreviewHandler)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()

    def tearDown(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join()
        self.root_patch.stop()
        self.directory.cleanup()

    def fetch(self, path, method='GET'):
        connection = http.client.HTTPConnection('127.0.0.1', self.server.server_port, timeout=3)
        connection.request(method, path)
        response = connection.getresponse()
        result = response.status, dict(response.getheaders()), response.read().decode()
        connection.close()
        return result

    def test_rebuild_changes_asset_urls_without_changing_origin(self):
        first = self.fetch('/')[2]
        self.assertIn('flutter_bootstrap.js?v=', first)
        bootstrap = self.fetch('/flutter_bootstrap.js?v=old')[2]
        self.assertIn('main.dart.js?v=', bootstrap)
        (self.root / 'main.dart.js').write_text('second build')
        self.assertNotEqual(first, self.fetch('/')[2])
        self.assertNotEqual(bootstrap, self.fetch('/flutter_bootstrap.js')[2])

    def test_query_assets_and_head_requests_disable_caching(self):
        status, headers, body = self.fetch('/main.dart.js?v=old')
        self.assertEqual((status, headers['Cache-Control'], body), (200, 'no-store', 'first build'))
        status, headers, body = self.fetch('/', method='HEAD')
        self.assertEqual((status, headers['Cache-Control'], body), (200, 'no-store', ''))
        self.assertGreater(int(headers['Content-Length']), 0)

    def test_files_outside_compiled_root_are_not_served(self):
        self.assertEqual(self.fetch('/../private.txt')[0], 404)
        self.assertEqual(self.fetch('/%2e%2e/private.txt')[0], 404)


if __name__ == '__main__':
    unittest.main()
