import http.client
import json
import threading
import unittest
from http.server import ThreadingHTTPServer
from server import handler
from runner import RunnerUnavailable, validate


class HttpTests(unittest.TestCase):
    def setUp(self):
        self.calls=[]
        def fake(payload):
            validate(payload)
            self.calls.append(payload)
            return {'verified_solve':False,'passed':0}
        self.ready_languages=None
        def offline():
            if self.ready_languages is None: raise RunnerUnavailable('offline')
            return self.ready_languages
        self.server=ThreadingHTTPServer(('127.0.0.1',0),handler(fake,offline))
        self.thread=threading.Thread(target=self.server.serve_forever,daemon=True)
        self.thread.start()
    def tearDown(self):
        self.server.shutdown(); self.server.server_close(); self.thread.join()
    def request(self,method,path,body=None,headers=None):
        connection=http.client.HTTPConnection('127.0.0.1',self.server.server_port,timeout=3)
        connection.request(method,path,body,headers or {})
        reply=connection.getresponse(); result=reply.status,json.loads(reply.read())
        connection.close(); return result
    def test_native_submission_and_unavailable_health(self):
        body=json.dumps({'lesson_id':'signal-ranges-v1','language':'javascript','source':'function solve(){return 0;}'})
        self.assertEqual(self.request('POST','/run',body,{'Content-Type':'application/json'})[0],200)
        self.assertEqual(len(self.calls),1)
        self.assertFalse(self.request('GET','/health')[1]['ready'])
    def test_health_and_submission_support_python_independently(self):
        self.ready_languages=['python']
        health=self.request('GET','/health')[1]
        self.assertTrue(health['ready'])
        self.assertEqual(health['languages'],['python'])
        body=json.dumps({'lesson_id':'signal-ranges-v1','language':'python','source':'def solve(a,t):return 0'})
        self.assertEqual(self.request('POST','/run',body,{'Content-Type':'application/json'})[0],200)
        self.assertEqual(self.calls[0]['language'],'python')
    def test_cross_origin_and_rebound_hosts_do_not_reach_runner(self):
        self.assertEqual(self.request('GET','/health',headers={'Origin':'https://external.invalid'})[0],403)
        self.assertEqual(self.request('GET','/health',headers={'Host':'rebound.invalid'})[0],403)
        self.assertEqual(self.calls,[])
    def test_oversized_headers_and_invalid_payload_are_rejected(self):
        self.assertEqual(self.request('POST','/run',headers={'Content-Length':'65537','Content-Type':'application/json'})[0],400)
        self.assertEqual(self.request('POST','/run','{}',{'Content-Type':'application/json'})[0],400)
        self.assertEqual(self.calls,[])

if __name__ == '__main__': unittest.main()
