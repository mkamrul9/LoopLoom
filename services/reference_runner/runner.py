"""Opt-in local development reference runner. Never execute source on the host."""
import json
from pathlib import Path
import subprocess
import threading
import time
import uuid

ROOT = Path(__file__).resolve().parent
IMAGE = 'node@sha256:c86ecead9e55a5210ac1727de38a4ca840bf03dcaf34dc9749addbf383b1920c'
CASES = json.loads((ROOT / 'cases.json').read_text())
WORKER = (ROOT / 'worker.js').read_text()
RUNTIMES = {
    'javascript': (IMAGE, ['node', '--jitless', '-e', WORKER]),
    'python': ('python@sha256:516b51cb9db2ef061e465c803e50f64361b82cefd91e525b889b967b83e83527',
               ['python', '-I', '-B', '-u', '-c', (ROOT / 'worker.py').read_text()]),
}
SUITE_VERSION = 'reference-v1'
OUTPUT_LIMIT = 32768
WALL_SECONDS = 4
DOCKER = ['docker', '--context', 'desktop-linux']


class RunnerUnavailable(Exception):
    pass


def docker(*args, timeout=5):
    return subprocess.run([*DOCKER, *args], capture_output=True, timeout=timeout, check=True).stdout.decode().strip()


def preflight(language='javascript'):
    if language not in RUNTIMES:
        raise RunnerUnavailable('Unsupported runtime')
    try:
        endpoint = docker('context', 'inspect', 'desktop-linux', '--format', '{{.Endpoints.docker.Host}}')
        if not endpoint.startswith(('npipe://', 'unix://')):
            raise RunnerUnavailable('Only a local Docker engine is supported')
        info = json.loads(docker('info', '--format', '{{json .}}'))
        if info.get('OSType') != 'linux' or not any('seccomp' in x for x in info.get('SecurityOptions', [])):
            raise RunnerUnavailable('Linux Docker with seccomp is required')
        docker('image', 'inspect', RUNTIMES[language][0], '--format', '{{.Id}}')
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        raise RunnerUnavailable('Local Docker or the selected pinned image is unavailable') from error


def available_languages():
    available = []
    for language in RUNTIMES:
        try:
            preflight(language)
            available.append(language)
        except RunnerUnavailable:
            pass
    return available


def validate(payload):
    if not isinstance(payload, dict) or set(payload) != {'lesson_id', 'language', 'source'}:
        raise ValueError('Invalid request')
    if not isinstance(payload['lesson_id'], str) or payload['lesson_id'] not in CASES:
        raise ValueError('Unknown lesson')
    if not isinstance(payload['language'], str) or payload['language'] not in RUNTIMES:
        raise ValueError('This development runner supports JavaScript and Python')
    if not isinstance(payload['source'], str) or not 1 <= len(payload['source'].encode('utf-8')) <= 32000:
        raise ValueError('Source must be between 1 and 32000 bytes')


def command(name, language='javascript'):
    image, entrypoint = RUNTIMES[language]
    return [*DOCKER, 'run', '--pull=never', '--name', name, '--label', 'dev.solveit.reference=true',
            '--network=none', '--read-only', '--user=65534:65534', '--cap-drop=ALL',
            '--security-opt=no-new-privileges', '--pids-limit=32', '--memory=128m',
            '--memory-swap=128m', '--cpus=0.5', '--ulimit=nofile=64:64', '--ulimit=core=0',
            '--log-driver=none', '--tmpfs=/tmp:rw,noexec,nosuid,size=16m',
            '-i', image, *entrypoint]


def run_case(source, args, language='javascript'):
    name = 'solveit-reference-' + uuid.uuid4().hex
    process = None
    readers = []
    chunks = [bytearray(), bytearray()]
    overflow = threading.Event()

    def read(stream, target):
        while True:
            block = stream.read(1024)
            if not block:
                break
            remaining = OUTPUT_LIMIT - len(target)
            target.extend(block[:max(0, remaining)])
            if len(block) > remaining:
                overflow.set()

    try:
        process = subprocess.Popen(command(name, language), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for stream, target in zip((process.stdout, process.stderr), chunks):
            thread = threading.Thread(target=read, args=(stream, target), daemon=True)
            thread.start()
            readers.append(thread)
        process.stdin.write(json.dumps({'source': source, 'args': args}).encode())
        process.stdin.close()
        deadline = time.monotonic() + WALL_SECONDS
        while process.poll() is None and not overflow.is_set() and time.monotonic() < deadline:
            time.sleep(0.02)
        if overflow.is_set():
            return {'status': 'output_limit'}
        if process.poll() is None:
            return {'status': 'time_limit'}
        for thread in readers:
            thread.join(timeout=1)
        if overflow.is_set():
            return {'status': 'output_limit'}
        if process.returncode in (125, 126, 127):
            raise RunnerUnavailable('Container could not start')
        if process.returncode != 0:
            oom = docker('inspect', '--format', '{{.State.OOMKilled}}', name)
            return {'status': 'memory_limit' if oom == 'true' else 'runtime_error'}
        try:
            result = json.loads(chunks[0])
            if not isinstance(result, dict) or result.get('status') not in ('returned', 'syntax_error', 'runtime_error', 'memory_limit'):
                raise ValueError()
            return result
        except (ValueError, UnicodeError):
            return {'status': 'runtime_error'}
    except (OSError, subprocess.SubprocessError) as error:
        raise RunnerUnavailable('Container execution unavailable') from error
    finally:
        # Only our unpredictable per-request container is removed. No global prune.
        cleanup = subprocess.run([*DOCKER, 'rm', '-f', name], capture_output=True, timeout=8)
        if process is not None:
            if process.poll() is None:
                process.kill()
            process.wait(timeout=5)
            for thread in readers:
                thread.join(timeout=1)
            process.stdout.close()
            process.stderr.close()
        if cleanup.returncode and b'No such container' not in cleanup.stderr:
            raise RunnerUnavailable('Container cleanup failed; stop the runner and inspect its labeled containers')


def matches(lesson, case, actual):
    expected = case['expected']
    if lesson in ('supply-pair-v1', 'sorted-crates-v1'):
        if not expected:
            return actual == []
        if not isinstance(actual, list) or len(actual) != 2 or any(type(i) is not int for i in actual):
            return False
        a, target = case['args']
        i, j = actual
        return i != j and 0 <= i < len(a) and 0 <= j < len(a) and a[i] + a[j] == target
    return type(actual) is type(expected) and json.dumps(actual, separators=(',', ':')) == json.dumps(expected, separators=(',', ':'))


def review(payload, execute=None, check=None):
    validate(payload)
    language = payload['language']
    if check is None:
        preflight(language)
    else:
        check()
    if execute is None:
        execute = lambda source, args: run_case(source, args, language)
    rows = []
    for case in CASES[payload['lesson_id']]:
        result = execute(payload['source'], case['args'])
        status = result['status']
        if status == 'returned':
            status = 'matched' if matches(payload['lesson_id'], case, result.get('result')) else 'wrong_answer'
            if payload['lesson_id'] == 'busy-periods-v1' and result.get('mutated') is not False:
                status = 'input_modified'
        rows.append({'label': case['label'], 'status': status})
    return {'suite': SUITE_VERSION, 'language': language, 'passed': sum(r['status'] == 'matched' for r in rows),
            'total': len(rows), 'cases': rows, 'verified_solve': False}
