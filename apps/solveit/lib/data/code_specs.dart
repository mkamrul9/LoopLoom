import '../domain/lesson.dart';

class ReferenceCase {
  const ReferenceCase(this.label, this.input, this.expected);
  final String label, input, expected;
}

class CodeSpec {
  const CodeSpec(
    this.names,
    this.returnsList,
    this.intervals,
    this.cases, {
    this.matrix = false,
  });
  final List<String> names;
  final bool returnsList, intervals;
  final bool matrix;
  final List<ReferenceCase> cases;

  String starter(CodeLanguage language) {
    final array = names.first;
    final scalar = names.length > 1 ? names[1] : null;
    switch (language) {
      case CodeLanguage.cpp:
        final result = intervals
            ? 'std::vector<std::vector<int>>'
            : returnsList
            ? 'std::vector<int>'
            : 'int';
        final input = intervals || matrix
            ? 'std::vector<std::vector<int>>'
            : 'std::vector<int>';
        return '#include <vector>\n#include <stdexcept>\n\n$result solve(const $input& $array${scalar == null ? '' : ', int $scalar'}) {\n    // TODO: implement your approach.\n    throw std::logic_error("TODO");\n}\n';
      case CodeLanguage.python:
        final result = intervals
            ? 'list[list[int]]'
            : returnsList
            ? 'list[int]'
            : 'int';
        final input = intervals || matrix ? 'list[list[int]]' : 'list[int]';
        return 'def solve($array: $input${scalar == null ? '' : ', $scalar: int'}) -> $result:\n    # TODO: implement your approach.\n    raise NotImplementedError("TODO")\n';
      case CodeLanguage.javascript:
        return 'function solve($array${scalar == null ? '' : ', $scalar'}) {\n    // TODO: implement your approach.\n    throw new Error("TODO");\n}\n';
      case CodeLanguage.typescript:
        final result = intervals
            ? 'Array<[number, number]>'
            : returnsList
            ? 'number[]'
            : 'number';
        final input = intervals
            ? 'ReadonlyArray<readonly [number, number]>'
            : matrix
            ? 'ReadonlyArray<readonly number[]>'
            : 'readonly number[]';
        return 'function solve($array: $input${scalar == null ? '' : ', $scalar: number'}): $result {\n    // TODO: implement your approach.\n    throw new Error("TODO");\n}\n';
    }
  }
}

const codeSpecs = <String, CodeSpec>{
  'supply-pair-v1': CodeSpec(
    ['prices', 'budget'],
    true,
    false,
    [
      ReferenceCase(
        'A matching pair',
        'prices = [4, 11, 6, 2], budget = 8',
        'One valid result: [2, 3]. Either index order is accepted.',
      ),
      ReferenceCase(
        'Duplicates',
        'prices = [4, 4], budget = 8',
        '[0, 1] or [1, 0]; the indices must differ.',
      ),
      ReferenceCase('No partner', 'prices = [4], budget = 8', '[]'),
    ],
  ),
  'sorted-crates-v1': CodeSpec(
    ['weights', 'target'],
    true,
    false,
    [
      ReferenceCase(
        'Sorted search',
        'weights = [1, 3, 5, 8, 12], target = 11',
        '[1, 3] or [3, 1]',
      ),
      ReferenceCase(
        'Equal weights',
        'weights = [3, 3], target = 6',
        '[0, 1] or [1, 0]',
      ),
      ReferenceCase('Empty input', 'weights = [], target = 5', '[]'),
    ],
  ),
  'focus-block-v1': CodeSpec(
    ['scores', 'k'],
    false,
    false,
    [
      ReferenceCase(
        'Consecutive block',
        'scores = [3, -2, 5, 4, -1], k = 3',
        '8',
      ),
      ReferenceCase('All negative', 'scores = [-5, -2, -4], k = 2', '-6'),
      ReferenceCase('Whole input', 'scores = [2, -3, 4], k = 3', '3'),
    ],
  ),
  'signal-ranges-v1': CodeSpec(
    ['changes', 'target'],
    false,
    false,
    [
      ReferenceCase(
        'Overlapping ranges',
        'changes = [2, -2, 2], target = 2',
        '3',
      ),
      ReferenceCase('Repeated totals', 'changes = [0, 0, 0], target = 0', '6'),
      ReferenceCase('Empty input', 'changes = [], target = 0', '0'),
    ],
  ),
  'warmer-readings-v1': CodeSpec(
    ['temperatures'],
    true,
    false,
    [
      ReferenceCase(
        'Waiting distances',
        'temperatures = [20, 20, 19, 23, 21]',
        '[3, 2, 1, 0, 0]',
      ),
      ReferenceCase(
        'Equal is not warmer',
        'temperatures = [7, 7, 7]',
        '[0, 0, 0]',
      ),
      ReferenceCase('No future day', 'temperatures = [8]', '[0]'),
    ],
  ),
  'busy-periods-v1': CodeSpec(
    ['bookings'],
    true,
    true,
    [
      ReferenceCase(
        'Nested and touching',
        'bookings = [[1, 6], [2, 4], [6, 8], [7, 9]]',
        '[[1, 6], [6, 9]]',
      ),
      ReferenceCase(
        'Touching stays separate',
        'bookings = [[3, 5], [1, 3]]',
        '[[1, 3], [3, 5]]',
      ),
      ReferenceCase('Empty input', 'bookings = []', '[]'),
    ],
  ),
  'rotated-index-v1': CodeSpec(
    ['values', 'target'],
    false,
    false,
    [
      ReferenceCase(
        'Value after the rotation',
        'values = [6, 7, 9, 1, 3, 5], target = 3',
        '4',
      ),
      ReferenceCase(
        'Target is absent',
        'values = [4, 5, 6, 7, 0, 1, 2], target = 8',
        '-1',
      ),
      ReferenceCase('Empty shelf', 'values = [], target = 4', '-1'),
    ],
  ),
  'products-except-self-v1': CodeSpec(
    ['values'],
    true,
    false,
    [
      ReferenceCase(
        'A zero in the middle',
        'values = [1, 2, 0, 4]',
        '[0, 0, 8, 0]',
      ),
      ReferenceCase(
        'Two zeros',
        'values = [0, 2, 0]',
        '[0, 0, 0]',
      ),
      ReferenceCase('Empty input', 'values = []', '[]'),
    ],
  ),
  'longest-run-v1': CodeSpec(
    ['values'],
    false,
    false,
    [
      ReferenceCase(
        'Unordered consecutive values',
        'values = [100, 4, 200, 1, 3, 2]',
        '4',
      ),
      ReferenceCase(
        'Duplicates count once',
        'values = [5, 5, 6, 7]',
        '3',
      ),
      ReferenceCase('Empty input', 'values = []', '0'),
    ],
  ),
  'budget-window-v1': CodeSpec(
    ['costs', 'budget'],
    false,
    false,
    [
      ReferenceCase(
        'Longest affordable block',
        'costs = [2, 1, 1, 1, 4], budget = 5',
        '4',
      ),
      ReferenceCase(
        'Only zero-cost days fit',
        'costs = [0, 0, 3, 0], budget = 0',
        '2',
      ),
      ReferenceCase('Empty input', 'costs = [], budget = 3', '0'),
    ],
  ),
  'lower-bound-v1': CodeSpec(
    ['values', 'target'],
    false,
    false,
    [
      ReferenceCase(
        'First duplicate',
        'values = [1, 3, 3, 8], target = 3',
        '1',
      ),
      ReferenceCase(
        'Between values',
        'values = [1, 3, 5, 8], target = 4',
        '2',
      ),
      ReferenceCase('Empty input', 'values = [], target = 7', '0'),
    ],
  ),
  'island-count-v1': CodeSpec(
    ['map'],
    false,
    false,
    [
      ReferenceCase(
        'Four-direction groups',
        'map = [[1, 1, 0], [0, 1, 0], [1, 0, 1]]',
        '3',
      ),
      ReferenceCase(
        'Diagonal contact stays separate',
        'map = [[1, 0], [0, 1]]',
        '2',
      ),
      ReferenceCase('Empty map', 'map = []', '0'),
    ],
    matrix: true,
  ),
};
