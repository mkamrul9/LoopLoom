"""Opt-in local development reference runner. Never execute source on the host."""
import json
from pathlib import Path
import subprocess
import threading
import time
import uuid
from sprint_content import CPP_TYPES

ROOT = Path(__file__).resolve().parent
IMAGE = 'node@sha256:c86ecead9e55a5210ac1727de38a4ca840bf03dcaf34dc9749addbf383b1920c'
CPP_IMAGE = 'gcc@sha256:20eec427045c47d0aad1bd28c81d435916c327cd992240aa78350f755d04d04a'
CASES = json.loads((ROOT / 'cases.json').read_text())
WORKER = (ROOT / 'worker.js').read_text()
RUNTIMES = {
    'cpp': (CPP_IMAGE, []),
    'javascript': (IMAGE, ['node', '--jitless', '-e', WORKER]),
    # Node's TypeScript parser requires WebAssembly, unavailable with --jitless.
    # All Docker controls remain identical; this is erasable syntax, not tsc.
    'typescript': (IMAGE, ['node', '--max-old-space-size=64', '-e', WORKER, 'typescript']),
    'python': ('python@sha256:516b51cb9db2ef061e465c803e50f64361b82cefd91e525b889b967b83e83527',
               ['python', '-I', '-B', '-u', '-c', (ROOT / 'worker.py').read_text()]),
}
SUITE_VERSION = 'reference-v1'
OUTPUT_LIMIT = 32768
WALL_SECONDS = 4
CPP_WALL_SECONDS = 12
IMMUTABLE_INPUT_LESSONS = {
    'busy-periods-v1', 'rotated-index-v1', 'products-except-self-v1', 'longest-run-v1', 'island-count-v1',
    'graph-components-v1', 'kth-score-v1', 'top-frequency-v1', 'merge-streams-v1', 'tree-depth-v1',
    'tree-width-v1', 'tree-path-sum-v1', 'list-middle-v1', 'list-cycle-v1', 'list-nth-from-end-v1',
    'subset-sum-v1', 'combination-count-v1', 'target-sum-ways-v1',
}
IMMUTABLE_INPUT_LESSONS.update(CPP_TYPES)
NESTED_INPUT_LESSONS = {
    'busy-periods-v1', 'island-count-v1', 'graph-components-v1', 'merge-streams-v1',
    'tree-depth-v1', 'tree-width-v1', 'tree-path-sum-v1', 'list-middle-v1', 'list-cycle-v1',
    'list-nth-from-end-v1',
}
CPP_STRING_INPUT_LESSONS = {'first-signal-v1', 'anagram-pair-v1', 'distinct-letter-window-v1'}
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
        raise ValueError('This development runner supports C++, JavaScript, TypeScript and Python')
    if not isinstance(payload['source'], str) or not 1 <= len(payload['source'].encode('utf-8')) <= 32000:
        raise ValueError('Source must be between 1 and 32000 bytes')


def command(name, language='javascript'):
    image, entrypoint = RUNTIMES[language]
    options = [*DOCKER, 'run', '--pull=never', '--name', name, '--label', 'dev.solveit.reference=true',
            '--network=none', '--read-only', '--user=65534:65534', '--cap-drop=ALL',
            '--security-opt=no-new-privileges', '--ulimit=nofile=64:64', '--ulimit=core=0',
            '--log-driver=none', '--tmpfs=/tmp:rw,noexec,nosuid,size=16m',
    ]
    if language == 'cpp':
        options.remove('--tmpfs=/tmp:rw,noexec,nosuid,size=16m')
        options.extend(['--tmpfs=/tmp:rw,exec,nosuid,nodev,size=64m', '--pids-limit=64',
                        '--memory=512m', '--memory-swap=512m', '--cpus=1', '--entrypoint=/bin/sh'])
        return [*options, '-i', image, '-c',
                'if g++ -std=c++17 -O0 -pipe -x c++ -o /tmp/solveit - 2>/dev/null; then exec /tmp/solveit; else printf \'\\n__SOLVEIT_CPP__:{"compile_error":true}\\n\'; fi']
    options.extend(['--pids-limit=32', '--memory=128m', '--memory-swap=128m', '--cpus=0.5'])
    return [*options, '-i', image, *entrypoint]


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
            if not isinstance(result, dict) or result.get('status') not in ('returned', 'syntax_error', 'unsupported_syntax', 'runtime_error', 'memory_limit'):
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


def _cpp_literal(value):
    if type(value) is int:
        return str(value)
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, list):
        return '{' + ','.join(_cpp_literal(item) for item in value) + '}'
    raise ValueError('Unsupported C++ reference input')


def _cpp_translation_unit(source, cases, lesson):
    """Compile once and evaluate all public examples using their lesson signature."""
    lines = ['#include <bits/stdc++.h>', 'using namespace std;', source, '',
             'template<class T> void emitJson(ostream& out, const T& value);',
             'template<class T> void emitJson(ostream& out, const vector<T>& value) {',
             '  out << "[";',
             '  for (size_t i = 0; i < value.size(); ++i) { if (i) out << ","; emitJson(out, value[i]); }',
             '  out << "]";', '}',
             'template<class T> void emitJson(ostream& out, const T& value) {',
             '  if constexpr (is_same_v<T, bool>) out << (value ? "true" : "false"); else out << value;',
             '}', 'int main() {', '  ostringstream result;', '  result << "__SOLVEIT_CPP__:{\\"cases\\":[";',
             '  bool first = true;']
    for index, case in enumerate(cases):
        args = case['args']
        if lesson in CPP_TYPES:
            arg_types = CPP_TYPES[lesson]
            if len(args) != len(arg_types):
                raise ValueError('Invalid C++ lesson signature')
            declarations = [f'  {arg_type} input_{index}_{offset} = {_cpp_literal(value)};'
                            for offset, (arg_type, value) in enumerate(zip(arg_types, args))]
            before = [f'  const auto before_{index}_{offset} = input_{index}_{offset};'
                      for offset in range(len(args))]
            call = ', '.join(f'input_{index}_{offset}' for offset in range(len(args)))
            unchanged = ' && '.join(f'input_{index}_{offset} == before_{index}_{offset}'
                                    for offset in range(len(args)))
            lines += declarations + before + [
                '  if (!first) result << ","; first = false;',
                f'  try {{ auto answer = solve({call});',
                '    result << "{\\"status\\":\\"returned\\",\\"result\\":";',
                '    emitJson(result, answer);',
                f'    result << ",\\"mutated\\":" << ({unchanged} ? "false" : "true") << "}}";',
                '  } catch (...) { result << "{\\"status\\":\\"runtime_error\\"}"; }']
            continue
        nested = lesson in NESTED_INPUT_LESSONS
        array_type = 'vector<vector<int>>' if nested else 'vector<int>'
        if lesson in CPP_STRING_INPUT_LESSONS:
            input_declaration = f'  string input_{index} = {_cpp_literal(args[0])};'
        else:
            input_declaration = f'  {array_type} input_{index}{_cpp_literal(args[0])};'
        extra = ''
        if len(args) > 1:
            extra_value = _cpp_literal(args[1]) if lesson in CPP_STRING_INPUT_LESSONS else str(args[1])
            extra = ', ' + extra_value
        lines += [input_declaration,
                  f'  const auto before_{index} = input_{index};',
                  '  if (!first) result << ","; first = false;',
                  f'  try {{ auto answer = solve(input_{index}{extra});',
                  '    result << "{\\"status\\":\\"returned\\",\\"result\\":";',
                  '    emitJson(result, answer);',
                  f'    result << ",\\"mutated\\":" << (input_{index} == before_{index} ? "false" : "true") << "}}";',
                  '  } catch (...) { result << "{\\"status\\":\\"runtime_error\\"}"; }']
    lines += ['  result << "]}";', '  cout << result.str() << "\\n";', '  return 0;', '}']
    return '\n'.join(lines).encode('utf-8')


def run_cpp_suite(source, cases, lesson):
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
        process = subprocess.Popen(command(name, 'cpp'), stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        for stream, target in zip((process.stdout, process.stderr), chunks):
            thread = threading.Thread(target=read, args=(stream, target), daemon=True)
            thread.start()
            readers.append(thread)
        process.stdin.write(_cpp_translation_unit(source, cases, lesson))
        process.stdin.close()
        deadline = time.monotonic() + CPP_WALL_SECONDS
        while process.poll() is None and not overflow.is_set() and time.monotonic() < deadline:
            time.sleep(0.02)
        if overflow.is_set():
            return [{'status': 'output_limit'} for _ in cases]
        if process.poll() is None:
            return [{'status': 'time_limit'} for _ in cases]
        for thread in readers:
            thread.join(timeout=1)
        if overflow.is_set():
            return [{'status': 'output_limit'} for _ in cases]
        if process.returncode in (125, 126, 127):
            raise RunnerUnavailable('C++ container could not start')
        if process.returncode != 0:
            oom = docker('inspect', '--format', '{{.State.OOMKilled}}', name)
            return [{'status': 'memory_limit' if oom == 'true' else 'runtime_error'} for _ in cases]
        marker = b'__SOLVEIT_CPP__:'
        rows = [line[len(marker):] for line in chunks[0].splitlines() if line.startswith(marker)]
        if not rows:
            return [{'status': 'runtime_error'} for _ in cases]
        try:
            result = json.loads(rows[-1])
            if result == {'compile_error': True}:
                return [{'status': 'compile_error'} for _ in cases]
            values = result['cases']
            if not isinstance(values, list) or len(values) != len(cases):
                raise ValueError()
            if any(not isinstance(value, dict) or value.get('status') not in ('returned', 'runtime_error') for value in values):
                raise ValueError()
            return values
        except (ValueError, KeyError, TypeError, UnicodeError):
            return [{'status': 'runtime_error'} for _ in cases]
    except (OSError, subprocess.SubprocessError) as error:
        raise RunnerUnavailable('C++ compilation or execution is unavailable') from error
    finally:
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
    if language == 'cpp' and execute is None:
        results = run_cpp_suite(payload['source'], CASES[payload['lesson_id']], payload['lesson_id'])
        rows = []
        for case, result in zip(CASES[payload['lesson_id']], results):
            status = result['status']
            if status == 'returned':
                status = 'matched' if matches(payload['lesson_id'], case, result.get('result')) else 'wrong_answer'
                if payload['lesson_id'] in IMMUTABLE_INPUT_LESSONS and result.get('mutated') is not False:
                    status = 'input_modified'
            rows.append({'label': case['label'], 'status': status})
        return {'suite': SUITE_VERSION, 'language': language, 'passed': sum(r['status'] == 'matched' for r in rows),
                'total': len(rows), 'cases': rows, 'verified_solve': False}
    if execute is None:
        execute = lambda source, args: run_case(source, args, language)
    rows = []
    for case in CASES[payload['lesson_id']]:
        result = execute(payload['source'], case['args'])
        status = result['status']
        if status == 'returned':
            status = 'matched' if matches(payload['lesson_id'], case, result.get('result')) else 'wrong_answer'
            if payload['lesson_id'] in IMMUTABLE_INPUT_LESSONS and result.get('mutated') is not False:
                status = 'input_modified'
        rows.append({'label': case['label'], 'status': status})
    return {'suite': SUITE_VERSION, 'language': language, 'passed': sum(r['status'] == 'matched' for r in rows),
            'total': len(rows), 'cases': rows, 'verified_solve': False}
