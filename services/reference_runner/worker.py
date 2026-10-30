"""Container-only protocol wrapper. Python exec is not an isolation boundary."""
import json
import sys
from contextlib import redirect_stdout

request = json.load(sys.stdin)
namespace = {'__name__': '__solveit_submission__'}
try:
    compiled = compile(request['source'], '<submission>', 'exec')
except SyntaxError:
    print(json.dumps({'status': 'syntax_error'}))
    sys.exit(0)

try:
    with redirect_stdout(sys.stderr):
        exec(compiled, namespace)
        solve = namespace.get('solve')
        if not callable(solve):
            raise TypeError('Missing solve')
        before = json.dumps(request['args'], allow_nan=False)
        result = solve(*request['args'])
    print(json.dumps({'status': 'returned', 'result': result,
                      'mutated': json.dumps(request['args'], allow_nan=False) != before}, allow_nan=False))
except MemoryError:
    print(json.dumps({'status': 'memory_limit'}))
except BaseException:
    print(json.dumps({'status': 'runtime_error'}))
