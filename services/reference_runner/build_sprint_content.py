"""Publish one-week sprint reference code and cases for Flutter and the runner."""
import json
import re
from pathlib import Path

from live_check import SOLUTIONS as EXISTING_JS
from live_check_cpp import SOLUTIONS as EXISTING_CPP
from live_check_python import SOLUTIONS as EXISTING_PY
from live_check_typescript import SOLUTIONS as EXISTING_TS
from sprint_content import CASES, CPP, EDGE_CASES, JAVASCRIPT, PYTHON, TS_SIGNATURES

ROOT = Path(__file__).resolve().parent
DART = ROOT.parent.parent / 'apps' / 'solveit' / 'lib' / 'data' / 'sprint_references.dart'
SLUG_IDS = {
 'two-sum':'supply-pair-v1',
 'valid-anagram':'anagram-pair-v1',
 'contains-duplicate':'blind75-contains-duplicate-v1',
 'ransom-note':'mastery300-ransom-note-v1',
 'best-time-to-buy-and-sell-stock':'single-trade-v1',
 'valid-palindrome':'blind75-valid-palindrome-v1',
 'valid-parentheses':'blind75-valid-parentheses-v1',
 'product-of-array-except-self':'products-except-self-v1',
 'merge-two-sorted-lists':'blind75-merge-two-sorted-lists-v1',
 'reverse-linked-list':'blind75-reverse-linked-list-v1',
 'linked-list-cycle':'list-cycle-v1',
 'longest-substring-without-repeating-characters':'distinct-letter-window-v1',
 'binary-search':'mastery300-binary-search-v1',
 'first-bad-version':'mastery300-first-bad-version-v1',
 'invert-binary-tree':'blind75-invert-binary-tree-v1',
 'maximum-depth-of-binary-tree':'tree-depth-v1',
 'balanced-binary-tree':'mastery300-balanced-binary-tree-v1',
 'lowest-common-ancestor-of-a-binary-search-tree':'blind75-lowest-common-ancestor-of-a-binary-search-tree-v1',
 'diameter-of-binary-tree':'mastery300-diameter-of-binary-tree-v1',
 'maximum-subarray':'max-subarray-v1',
 'majority-element':'mastery300-majority-element-v1',
 'climbing-stairs':'blind75-climbing-stairs-v1',
 'single-number':'mastery300-single-number-v1',
 'number-of-islands':'island-count-v1',
 'merge-intervals':'blind75-merge-intervals-v1',
}

# Existing foundation lessons reused by Blind 75. Their four implementations
# and case suites predate the sprint, so publishing them needs no new runner API.
ADDITIONAL_REFERENCES = {
 'rotated-index-v1': [
  'Either side of the midpoint may be sorted after rotation.',
  'An absent target and an empty array return -1.',
  'This workbook case assumes distinct values.'],
 'longest-run-v1': [
  'Duplicates must not increase the run length.',
  'Start counting only where the preceding value is absent.',
  'An empty input has a longest run of zero.'],
 'list-nth-from-end-v1': [
  'Move the lead pointer n links before moving both pointers.',
  'n can equal the full chain length.',
  'This workbook returns a node index; the official site uses list nodes.'],
 'top-frequency-v1': [
  'The workbook sorts equal-frequency values numerically for a stable answer.',
  'k may be zero.',
  'Count occurrences before selecting the top k values.'],
 'merge-streams-v1': [
  'Individual streams are sorted, but their first values may differ.',
  'Empty streams should contribute no values.',
  'Negative values and duplicate values keep their order in the merged output.'],
 'graph-components-v1': [
  'An isolated vertex forms its own component.',
  'Mark a vertex before adding neighbors to the traversal queue or stack.',
  'An empty graph has zero components.'],
}


def dart_string(value):
    return json.dumps(value, ensure_ascii=False).replace('$', r'\$')


def starter(language, source):
    if language == 'python':
        signature = source.split('\n', 1)[0]
        return signature + '\n    # TODO: implement your approach.\n    raise NotImplementedError("TODO")\n'
    signature = source.split('{', 1)[0].strip()
    if language == 'cpp':
        return '#include <bits/stdc++.h>\nusing namespace std;\n\n' + signature + '{\n    // TODO: implement your approach.\n    throw logic_error("TODO");\n}\n'
    return signature + '{\n    // TODO: implement your approach.\n    throw new Error("TODO");\n}\n'


def main():
    assert len(SLUG_IDS) == 25 and len(set(SLUG_IDS.values())) == 25
    assert set(EDGE_CASES) == set(SLUG_IDS)
    current_cases = json.loads((ROOT / 'cases.json').read_text())
    current_cases.update(CASES)
    all_solutions = {}
    for slug, lesson in SLUG_IDS.items():
        if lesson in CASES:
            js, py, cpp = JAVASCRIPT[lesson], PYTHON[lesson], CPP[lesson]
            ts = re.sub(r'^function solve\([^)]*\)',
                        'function solve(' + TS_SIGNATURES[lesson], js, count=1)
        else:
            js, py, cpp, ts = (EXISTING_JS[lesson], EXISTING_PY[lesson],
                               EXISTING_CPP[lesson], EXISTING_TS[lesson])
        assert lesson in current_cases and len(current_cases[lesson]) >= 3
        all_solutions[lesson] = {'cpp':cpp, 'python':py, 'javascript':js,
                                 'typescript':ts, 'edgeCases':EDGE_CASES[slug]}
    for lesson, edge_cases in ADDITIONAL_REFERENCES.items():
        assert lesson not in all_solutions
        assert lesson in current_cases and len(current_cases[lesson]) >= 3
        all_solutions[lesson] = {
            'cpp': EXISTING_CPP[lesson], 'python': EXISTING_PY[lesson],
            'javascript': EXISTING_JS[lesson], 'typescript': EXISTING_TS[lesson],
            'edgeCases': edge_cases,
        }
    lines = ["// Generated by services/reference_runner/build_sprint_content.py.",
             "// Original LoopLoom workbook code for the sprint and selected Blind 75 lessons.",
             "// The local point gate is for study pacing.",
             "import '../domain/lesson.dart';",
             "import 'code_specs.dart';", "",
             "class SprintReference {",
             "  const SprintReference(this.edgeCases, this.code);",
             "  final List<String> edgeCases;",
             "  final Map<CodeLanguage, String> code;", "}", "",
             "const sprintReferences = <String, SprintReference>{"]
    for lesson, row in all_solutions.items():
        lines += [f'  {dart_string(lesson)}: SprintReference(',
                  '    <String>[' + ', '.join(map(dart_string, row['edgeCases'])) + '],',
                  '    <CodeLanguage, String>{']
        for language in ('cpp','python','javascript','typescript'):
            lines.append(f'      CodeLanguage.{language}: {dart_string(row[language])},')
        lines += ['    },', '  ),']
    lines += ['};', '', 'const sprintCodeSpecs = <String, CodeSpec>{']
    for lesson, cases in CASES.items():
        row = all_solutions[lesson]
        names = [name.strip() for name in re.search(r'function solve\(([^)]*)\)', row['javascript']).group(1).split(',')]
        lines += [f'  {dart_string(lesson)}: CodeSpec(',
                  '    <String>[' + ', '.join(map(dart_string, names)) + '], false, false, <ReferenceCase>[']
        for case in cases:
            input_text = ','.join(f'{name}={json.dumps(a, ensure_ascii=False, separators=(",",":"))}'
                                  for name, a in zip(names, case['args']))
            expected = json.dumps(case['expected'], ensure_ascii=False)
            lines.append(f'      ReferenceCase({dart_string(case["label"])}, {dart_string(input_text)}, {dart_string(expected)}),')
        lines += ['    ], customStarters: <CodeLanguage, String>{']
        for language in ('cpp','python','javascript','typescript'):
            lines.append(f'      CodeLanguage.{language}: {dart_string(starter(language, row[language]))},')
        lines += ['    },', '  ),']
    lines += ['};', '']
    DART.write_text('\n'.join(lines), encoding='utf-8')
    (ROOT / 'cases.json').write_text(json.dumps(current_cases, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(f'Published {len(all_solutions)} solutions × 4 languages and {len(CASES)} new case suites')


if __name__ == '__main__':
    main()
