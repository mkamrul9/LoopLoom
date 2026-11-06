"""Check all authored sprint examples in the available trusted host runtimes."""
import json
import re
import subprocess
import unittest

from build_sprint_content import SLUG_IDS
from live_check import SOLUTIONS as EXISTING_JS
from live_check_python import SOLUTIONS as EXISTING_PY
from live_check_typescript import SOLUTIONS as EXISTING_TS
from runner import CASES, matches
from sprint_content import CASES as NEW_CASES, JAVASCRIPT, PYTHON, TS_SIGNATURES


class SprintContentTests(unittest.TestCase):
    def test_all_sprint_problems_have_three_cases_and_four_reference_sources(self):
        self.assertEqual(len(SLUG_IDS), 25)
        for lesson in SLUG_IDS.values():
            self.assertEqual(len(CASES[lesson]), 3, lesson)

    def test_python_reference_solutions_match_every_case(self):
        for lesson in SLUG_IDS.values():
            scope = {}
            exec(PYTHON.get(lesson, EXISTING_PY.get(lesson)), scope)
            for case in CASES[lesson]:
                args = json.loads(json.dumps(case['args']))
                actual = scope['solve'](*args)
                self.assertTrue(matches(lesson, case, actual), f'{lesson}: {case["label"]}: {actual}')

    def test_javascript_and_typescript_references_match_every_case(self):
        rows = []
        for lesson in SLUG_IDS.values():
            js = JAVASCRIPT.get(lesson, EXISTING_JS.get(lesson))
            ts = (re.sub(r'^function solve\([^)]*\)',
                         'function solve(' + TS_SIGNATURES[lesson], js, count=1)
                  if lesson in NEW_CASES else EXISTING_TS[lesson])
            for language, source in [('javascript', js), ('typescript', ts)]:
                for case in CASES[lesson]:
                    rows.append({'lesson':lesson,'language':language,'source':source,'args':case['args']})
        script = '''const {stripTypeScriptTypes} = require('node:module');
const fs = require('node:fs');
const rows = JSON.parse(fs.readFileSync(0, 'utf8'));
for (const row of rows) {
  try {
    const source = row.language === 'typescript' ? stripTypeScriptTypes(row.source, {mode:'strip'}) : row.source;
    const solve = new Function(source + '; return solve;')();
    process.stdout.write(JSON.stringify({result:solve(...row.args)}) + '\\n');
  } catch (error) { process.stdout.write(JSON.stringify({error:String(error)}) + '\\n'); }
}'''
        output = subprocess.run(['node', '-e', script], input=json.dumps(rows),
                                text=True, capture_output=True, timeout=30, check=True)
        results = [json.loads(line) for line in output.stdout.splitlines()]
        self.assertEqual(len(results), len(rows))
        for row, result in zip(rows, results):
            self.assertNotIn('error', result, f'{row["lesson"]}: {result}')
            case = next(c for c in CASES[row['lesson']] if c['args'] == row['args'])
            self.assertTrue(matches(row['lesson'], case, result['result']),
                            f'{row["lesson"]} {row["language"]} {case["label"]}: {result}')


if __name__ == '__main__':
    unittest.main()
