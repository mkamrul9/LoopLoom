import '../domain/lesson.dart';
import 'code_specs.dart';
import 'interview_lessons.dart';
import 'pilot_lessons.dart';

/// SolveIt's independently written learning prompts for the community Blind 75
/// question set. External challenge links point to LeetCode; statements and
/// editorials here are authored for SolveIt.
enum BlindValueKind {
  integer,
  boolean,
  integerList,
  text,
  textList,
  integerMatrix,
  textMatrix,
  textListMatrix,
  decimalList,
}

class BlindArgument {
  const BlindArgument(this.name, this.kind);
  final String name;
  final BlindValueKind kind;
}

class Blind75Entry {
  const Blind75Entry({
    required this.number,
    required this.title,
    required this.slug,
    required this.pattern,
    required this.phase,
    required this.difficulty,
    required this.lesson,
    this.arguments = const [],
    this.result = BlindValueKind.integer,
  });

  final int number;
  final String title, slug, pattern, phase, difficulty;
  final Lesson lesson;
  final List<BlindArgument> arguments;
  final BlindValueKind result;

  Uri get challengeUri => Uri.https('leetcode.com', '/problems/$slug/');

  bool get hasReferenceCases => codeSpecs.containsKey(lesson.id);

  String starter(CodeLanguage language) {
    final spec = codeSpecs[lesson.id];
    if (spec != null) return spec.starter(language);

    String type(BlindValueKind kind) => switch ((language, kind)) {
      (CodeLanguage.cpp, BlindValueKind.integer) => 'int',
      (CodeLanguage.cpp, BlindValueKind.boolean) => 'bool',
      (CodeLanguage.cpp, BlindValueKind.integerList) => 'vector<int>',
      (CodeLanguage.cpp, BlindValueKind.text) => 'string',
      (CodeLanguage.cpp, BlindValueKind.textList) => 'vector<string>',
      (CodeLanguage.cpp, BlindValueKind.integerMatrix) => 'vector<vector<int>>',
      (CodeLanguage.cpp, BlindValueKind.textMatrix) => 'vector<string>',
      (CodeLanguage.cpp, BlindValueKind.textListMatrix) =>
        'vector<vector<string>>',
      (CodeLanguage.cpp, BlindValueKind.decimalList) => 'vector<double>',
      (CodeLanguage.python, BlindValueKind.integer) => 'int',
      (CodeLanguage.python, BlindValueKind.boolean) => 'bool',
      (CodeLanguage.python, BlindValueKind.integerList) => 'list[int]',
      (CodeLanguage.python, BlindValueKind.text) => 'str',
      (CodeLanguage.python, BlindValueKind.textList) => 'list[str]',
      (CodeLanguage.python, BlindValueKind.integerMatrix) => 'list[list[int]]',
      (CodeLanguage.python, BlindValueKind.textMatrix) => 'list[str]',
      (CodeLanguage.python, BlindValueKind.textListMatrix) => 'list[list[str]]',
      (CodeLanguage.python, BlindValueKind.decimalList) => 'list[float]',
      (CodeLanguage.typescript, BlindValueKind.integer) => 'number',
      (CodeLanguage.typescript, BlindValueKind.boolean) => 'boolean',
      (CodeLanguage.typescript, BlindValueKind.integerList) =>
        'readonly number[]',
      (CodeLanguage.typescript, BlindValueKind.text) => 'string',
      (CodeLanguage.typescript, BlindValueKind.textList) => 'readonly string[]',
      (CodeLanguage.typescript, BlindValueKind.integerMatrix) =>
        'readonly (readonly number[])[]',
      (CodeLanguage.typescript, BlindValueKind.textMatrix) =>
        'readonly string[]',
      (CodeLanguage.typescript, BlindValueKind.textListMatrix) =>
        'readonly (readonly string[])[]',
      (CodeLanguage.typescript, BlindValueKind.decimalList) =>
        'readonly number[]',
      (CodeLanguage.javascript, _) => '',
    };
    String cppType(BlindValueKind kind) => switch (kind) {
      BlindValueKind.integer => 'int',
      BlindValueKind.boolean => 'bool',
      BlindValueKind.integerList => 'const vector<int>&',
      BlindValueKind.text => 'const string&',
      BlindValueKind.textList => 'const vector<string>&',
      BlindValueKind.integerMatrix => 'const vector<vector<int>>&',
      BlindValueKind.textMatrix => 'const vector<string>&',
      BlindValueKind.textListMatrix => 'const vector<vector<string>>&',
      BlindValueKind.decimalList => 'const vector<double>&',
    };
    String cppResult(BlindValueKind kind) => switch (kind) {
      BlindValueKind.integer => 'long long',
      BlindValueKind.boolean => 'bool',
      BlindValueKind.integerList => 'vector<int>',
      BlindValueKind.text => 'string',
      BlindValueKind.textList => 'vector<string>',
      BlindValueKind.integerMatrix => 'vector<vector<int>>',
      BlindValueKind.textMatrix => 'vector<string>',
      BlindValueKind.textListMatrix => 'vector<vector<string>>',
      BlindValueKind.decimalList => 'vector<double>',
    };
    final names = arguments.map((arg) => arg.name).toList();
    switch (language) {
      case CodeLanguage.cpp:
        final parameters = arguments
            .map((arg) => '${cppType(arg.kind)} ${arg.name}')
            .join(', ');
        return '#include <string>\n#include <vector>\n#include <stdexcept>\nusing namespace std;\n\n'
            '${cppResult(result)} solve($parameters) {\n'
            '    // TODO: implement the approach you explained.\n'
            '    throw std::logic_error("TODO");\n}\n';
      case CodeLanguage.python:
        final parameters = arguments
            .map((arg) => '${arg.name}: ${type(arg.kind)}')
            .join(', ');
        return 'def solve($parameters) -> ${type(result)}:\n'
            '    # TODO: implement the approach you explained.\n'
            '    raise NotImplementedError("TODO")\n';
      case CodeLanguage.javascript:
        return 'function solve(${names.join(', ')}) {\n'
            '    // TODO: implement the approach you explained.\n'
            '    throw new Error("TODO");\n}\n';
      case CodeLanguage.typescript:
        final parameters = arguments
            .map((arg) => '${arg.name}: ${type(arg.kind)}')
            .join(', ');
        return 'function solve($parameters): ${type(result)} {\n'
            '    // TODO: implement the approach you explained.\n'
            '    throw new Error("TODO");\n}\n';
    }
  }
}

class _BlindDraft {
  const _BlindDraft({
    required this.number,
    required this.title,
    required this.slug,
    required this.pattern,
    required this.difficulty,
    required this.summary,
    required this.statement,
    required this.example,
    required this.constraints,
    required this.edgeCase,
    required this.approachQuestion,
    required this.hints,
    required this.explanation,
    required this.arguments,
    required this.result,
  });

  final int number;
  final String title, slug, pattern, difficulty;
  final String summary, statement, example, constraints, edgeCase;
  final String approachQuestion, explanation;
  final List<String> hints;
  final List<BlindArgument> arguments;
  final BlindValueKind result;

  Blind75Entry build() {
    final phase = switch (pattern) {
      'Array scans & hashing' ||
      'Two pointers' ||
      'Sliding window' ||
      'Stacks' ||
      'Binary search' => 'Phase 1 · Sequences and search',
      'Linked lists' ||
      'Trees' ||
      'Heaps' => 'Phase 2 · Linked structures and trees',
      'Backtracking' || 'Tries' || 'Graphs' => 'Phase 3 · Search and networks',
      _ => 'Phase 4 · Optimization and boundaries',
    };
    final lesson = Lesson(
      id: 'blind75-$slug-v1',
      title: title,
      pattern: pattern,
      summary: summary,
      statement: statement,
      example: example,
      constraints: constraints,
      questions: [
        'Restate what $title must return. What should happen for $edgeCase?',
        approachQuestion,
        'Trace this example: $example Show the key state after each move, then estimate total time and extra space.',
        codeQuestion,
        'State the invariant behind your $pattern approach. How does it protect the answer when $edgeCase?',
      ],
      checks: [
        'I can state the input, exact output, and the boundary rule for $edgeCase.',
        'I can give a correct baseline and explain why my chosen approach preserves the needed information.',
        'My trace matches the example and accounts for the whole input, total time, and extra memory.',
        codeCheck,
        'I can explain the invariant, a likely failure case, and the tradeoff in my own words.',
      ],
      hints: hints,
      explanation: explanation,
    );
    return Blind75Entry(
      number: number,
      title: title,
      slug: slug,
      pattern: pattern,
      phase: phase,
      difficulty: difficulty,
      lesson: lesson,
      arguments: arguments,
      result: result,
    );
  }
}

Blind75Entry _reuse({
  required int number,
  required String title,
  required String slug,
  required String pattern,
  required String phase,
  required String difficulty,
  required String lessonId,
}) => Blind75Entry(
  number: number,
  title: title,
  slug: slug,
  pattern: pattern,
  phase: phase,
  difficulty: difficulty,
  lesson: [
    ...pilotLessons,
    ...interviewLessons,
  ].singleWhere((lesson) => lesson.id == lessonId),
);

final blind75Entries = <Blind75Entry>[
  _BlindDraft(
    number: 1,
    title: 'Contains Duplicate',
    slug: 'contains-duplicate',
    pattern: 'Array scans & hashing',
    difficulty: 'Easy',
    summary: 'Detect a repeated value without comparing every pair.',
    statement:
        'Given an integer list, return true when any value occurs at least twice; otherwise return false.',
    example: 'values = [4, 1, 8, 4]\nOutput: true',
    constraints:
        'The list may be empty and values may be negative. Do not change the input.',
    edgeCase: 'an empty or one-element list',
    approachQuestion:
        'A pairwise scan is correct. What small record of earlier values lets you notice a repeat in one pass?',
    hints: [
      'What must be true the second time a value appears?',
      'Keep the values already visited in a set.',
      'If insertion says a value was already present, return true; return false after the scan.',
    ],
    explanation:
        'Insert each value into a set. If it is already present, a duplicate exists; otherwise continue. If the scan ends, all values were distinct. This is expected O(n) time and O(n) additional space. Sorting is also correct in O(n log n) time, but it either mutates the input or needs a copy.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.boolean,
  ).build(),
  _reuse(
    number: 2,
    title: 'Valid Anagram',
    slug: 'valid-anagram',
    pattern: 'Array scans & hashing',
    phase: 'Phase 1 · Sequences and search',
    difficulty: 'Easy',
    lessonId: 'anagram-pair-v1',
  ),
  _reuse(
    number: 3,
    title: 'Two Sum',
    slug: 'two-sum',
    pattern: 'Array scans & hashing',
    phase: 'Phase 1 · Sequences and search',
    difficulty: 'Easy',
    lessonId: 'supply-pair-v1',
  ),
  _BlindDraft(
    number: 4,
    title: 'Group Anagrams',
    slug: 'group-anagrams',
    pattern: 'Array scans & hashing',
    difficulty: 'Medium',
    summary: 'Place words together when they share the same letter counts.',
    statement:
        'Group strings that can be rearranged into one another. Return groups in any order; words inside a group may also be in any order.',
    example:
        'words = ["tea", "tan", "ate", "eat", "bat"]\nOne valid grouping: [["tea", "ate", "eat"], ["tan"], ["bat"]]',
    constraints:
        'Strings contain lowercase English letters. Empty strings and an empty list are allowed.',
    edgeCase: 'empty strings and repeated words',
    approachQuestion:
        'What canonical key can represent a word so every rearrangement reaches the same group?',
    hints: [
      'Compare letter counts rather than character order.',
      'A 26-count vector is a key for lowercase letters.',
      'Build a count key for each word and append it to the matching group.',
    ],
    explanation:
        'For every word, count each of the 26 letters and use that fixed-length count vector as a key in a map. Append the word to that key’s group. Equal count vectors characterize anagrams. Counting all characters costs O(total characters); the grouped output uses O(total characters) space. Sorting each word is another valid key and costs O(sum of m log m).',
    arguments: [BlindArgument('words', BlindValueKind.textList)],
    result: BlindValueKind.textListMatrix,
  ).build(),
  _reuse(
    number: 5,
    title: 'Product of Array Except Self',
    slug: 'product-of-array-except-self',
    pattern: 'Array scans & hashing',
    phase: 'Phase 1 · Sequences and search',
    difficulty: 'Medium',
    lessonId: 'products-except-self-v1',
  ),
  _BlindDraft(
    number: 6,
    title: 'Encode and Decode Strings',
    slug: 'encode-and-decode-strings',
    pattern: 'Array scans & hashing',
    difficulty: 'Medium',
    summary:
        'Design a reversible format that preserves arbitrary string boundaries.',
    statement:
        'Design a reversible encoding for a list of strings. Your round-trip function must recover every original string exactly, including empty strings and delimiter-like characters.',
    example:
        'items = ["red", "", "a|b"]\nRound trip output: ["red", "", "a|b"]',
    constraints:
        'The list and strings may be empty. Strings may contain any ordinary text character, including punctuation used by your encoding.',
    edgeCase: 'empty strings and delimiter characters inside a value',
    approachQuestion:
        'Why can a separator alone be ambiguous? What framing rule tells a decoder exactly how many characters to consume?',
    hints: [
      'A delimiter can appear as data, so it must be escaped or made unambiguous.',
      'Try storing each string length before its contents.',
      'Use a length prefix and a delimiter with a parse rule; decode exactly the declared number of characters.',
    ],
    explanation:
        'Use length-prefix framing, for example length, a separator, then exactly that many characters. The decoder parses the length and consumes that fixed count, so separators inside data do not cause ambiguity. Repeat until the encoded input is exhausted. Encoding and decoding each take O(total characters + number of strings) time; the output uses O(total characters) space. This lesson’s function should return the result of encoding and then decoding its input so visible behavior checks round-trip preservation.',
    arguments: [BlindArgument('items', BlindValueKind.textList)],
    result: BlindValueKind.textList,
  ).build(),
  _reuse(
    number: 7,
    title: 'Longest Consecutive Sequence',
    slug: 'longest-consecutive-sequence',
    pattern: 'Array scans & hashing',
    phase: 'Phase 1 · Sequences and search',
    difficulty: 'Medium',
    lessonId: 'longest-run-v1',
  ),
  _BlindDraft(
    number: 8,
    title: 'Valid Palindrome',
    slug: 'valid-palindrome',
    pattern: 'Two pointers',
    difficulty: 'Easy',
    summary: 'Compare only letters and digits while moving inward.',
    statement:
        'Return true if the text reads the same forward and backward after ignoring non-alphanumeric characters and letter case.',
    example: 'text = "A man, a plan, a canal: Panama!"\nOutput: true',
    constraints:
        'The input may be empty. Treat ASCII letters and digits as significant; ignore punctuation and spaces.',
    edgeCase: 'text with no significant characters or mixed punctuation',
    approachQuestion:
        'How can two indices compare the significant characters without constructing a reversed copy?',
    hints: [
      'Start at both ends.',
      'Skip characters that are not letters or digits.',
      'Normalize case, compare the current pair, then move both pointers inward.',
    ],
    explanation:
        'Move a left and right pointer toward one another. Skip any non-alphanumeric character at either end, compare the remaining characters without case, and fail on the first mismatch. If the pointers cross, the normalized sequence is a palindrome. O(n) time and O(1) extra space.',
    arguments: [BlindArgument('text', BlindValueKind.text)],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 9,
    title: 'Container With Most Water',
    slug: 'container-with-most-water',
    pattern: 'Two pointers',
    difficulty: 'Medium',
    summary:
        'Choose two boundary lines that maximize width times the shorter height.',
    statement:
        'Each nonnegative height stands at its array index. Choose two different indices; the contained amount is their distance multiplied by the shorter height. Return the maximum amount.',
    example: 'heights = [1, 8, 6, 2, 5, 4, 8, 3, 7]\nOutput: 49',
    constraints:
        'There are at least two heights. Heights are nonnegative integers.',
    edgeCase: 'two lines or a short line at one boundary',
    approachQuestion:
        'With the current width fixed by two endpoints, which endpoint can possibly improve the area after the width shrinks?',
    hints: [
      'The shorter endpoint limits the water height.',
      'Moving the taller endpoint only narrows the container without raising its limiting height.',
      'Evaluate the current area, then move the shorter endpoint inward.',
    ],
    explanation:
        'Start with the widest pair and track the best area. The shorter line is the height limit. Moving the taller line inward cannot improve that limit and also reduces width, so discard the shorter endpoint; a taller line may appear inside. Each pointer moves at most n times, giving O(n) time and O(1) extra space.',
    arguments: [BlindArgument('heights', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 10,
    title: '3Sum',
    slug: '3sum',
    pattern: 'Two pointers',
    difficulty: 'Medium',
    summary: 'Find every distinct value triplet that totals zero.',
    statement:
        'Return all distinct triplets of values whose sum is zero. A triplet is distinct by its values, not by which duplicate input positions supplied them.',
    example:
        'values = [-1, 0, 1, 2, -1, -4]\nOutput: [[-1, -1, 2], [-1, 0, 1]]',
    constraints:
        'The input may be empty and may contain duplicate or negative integers. Do not return duplicate triplets.',
    edgeCase: 'duplicate values and inputs with no valid triplet',
    approachQuestion:
        'After sorting, how can one fixed value reduce the remaining search to a two-sum scan while skipping duplicate answers?',
    hints: [
      'Sort a copy and fix the first position.',
      'For each fixed value, use pointers at both ends of the remaining suffix.',
      'Move the pointer that makes the sum closer to zero; after a match, skip equal values on both sides.',
    ],
    explanation:
        'Sort a copy of the input. Fix index i, then scan left and right pointers across the suffix. A negative total needs a larger value, so move left; a positive total needs a smaller value, so move right. Record zero totals and skip equal fixed and pointer values to avoid duplicate triplets. Sorting dominates at O(n log n); the two-pointer scans take O(n²) total, with O(1) working space beyond sorting and output.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _reuse(
    number: 11,
    title: 'Longest Substring Without Repeating Characters',
    slug: 'longest-substring-without-repeating-characters',
    pattern: 'Sliding window',
    phase: 'Phase 1 · Sequences and search',
    difficulty: 'Medium',
    lessonId: 'distinct-letter-window-v1',
  ),
  _BlindDraft(
    number: 12,
    title: 'Longest Repeating Character Replacement',
    slug: 'longest-repeating-character-replacement',
    pattern: 'Sliding window',
    difficulty: 'Medium',
    summary:
        'Find the longest window that can become one repeated letter with at most k edits.',
    statement:
        'Given an uppercase string and a nonnegative edit budget k, return the longest substring that can be changed into one repeated character using at most k replacements.',
    example: 'text = "AABABBA", k = 1\nOutput: 4',
    constraints:
        'The string contains uppercase English letters. Empty text returns 0.',
    edgeCase: 'k = 0 and a window whose most common letter changes',
    approachQuestion:
        'For a window of length L, how many edits are needed if you keep its most frequent character?',
    hints: [
      'Only characters other than the most common one need replacement.',
      'A window is feasible when length minus its maximum frequency is at most k.',
      'Expand right, update counts, and shrink while the window needs more than k edits.',
    ],
    explanation:
        'Maintain character frequencies in a sliding window and its highest frequency. A window is feasible when windowLength − maxFrequency ≤ k. Expand one character at a time and shrink the left edge until feasible; record the greatest valid length. The maximum frequency can be kept as a historical upper bound without shrinking repeatedly for every change; this remains correct for the maximum-length answer. O(n) time for a fixed alphabet and O(1) extra space.',
    arguments: [
      BlindArgument('text', BlindValueKind.text),
      BlindArgument('k', BlindValueKind.integer),
    ],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 13,
    title: 'Minimum Window Substring',
    slug: 'minimum-window-substring',
    pattern: 'Sliding window',
    difficulty: 'Hard',
    summary:
        'Find the shortest substring that covers all required character counts.',
    statement:
        'Return the shortest substring of source that contains every character of target with its required multiplicity. Return an empty string when no such window exists.',
    example: 'source = "ADOBECODEBANC", target = "ABC"\nOutput: "BANC"',
    constraints:
        'Inputs may be empty. A target may contain repeated characters; matching only distinct character presence is insufficient.',
    edgeCase: 'repeated target characters or an impossible target',
    approachQuestion:
        'What count condition makes a window valid, and how can you keep shrinking it while that condition remains true?',
    hints: [
      'Count required characters including duplicates.',
      'Grow the right edge until every required count is covered.',
      'Then move left forward while coverage remains valid, saving each shorter window.',
    ],
    explanation:
        'Count target requirements. Expand a right pointer while tracking relevant source counts and how many required character kinds have reached their needed frequencies. Once all are satisfied, advance left while validity remains, recording the shortest valid range. Then continue expanding. Each pointer advances at most n positions, so time is O(|source| + |target|) and extra space is bounded by the character set. Return empty if no valid range appears.',
    arguments: [
      BlindArgument('source', BlindValueKind.text),
      BlindArgument('target', BlindValueKind.text),
    ],
    result: BlindValueKind.text,
  ).build(),
  _BlindDraft(
    number: 14,
    title: 'Valid Parentheses',
    slug: 'valid-parentheses',
    pattern: 'Stacks',
    difficulty: 'Easy',
    summary: 'Match closing brackets with the most recently opened bracket.',
    statement:
        'Return true when every bracket opener is closed by the same bracket type in the correct nested order, and no unmatched bracket remains.',
    example: 'text = "{[()]}"\nOutput: true',
    constraints:
        'The input contains only (), [], and {}. Empty input is valid.',
    edgeCase: 'a closing bracket with no opener or a leftover opener',
    approachQuestion:
        'When a closing bracket arrives, which unmatched opener must it pair with?',
    hints: [
      'Nested brackets close in reverse order from how they open.',
      'Keep unmatched opening brackets in a stack.',
      'For each closer, require the stack top to be its matching opener; finish with an empty stack.',
    ],
    explanation:
        'Push each opening bracket. For a closer, the stack must be nonempty and its top must be the corresponding opener; then pop it. Any mismatch fails immediately. The string is valid only when the scan ends with an empty stack. O(n) time and O(n) worst-case space.',
    arguments: [BlindArgument('text', BlindValueKind.text)],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 15,
    title: 'Find Minimum in Rotated Sorted Array',
    slug: 'find-minimum-in-rotated-sorted-array',
    pattern: 'Binary search',
    difficulty: 'Medium',
    summary: 'Locate the rotation boundary in logarithmic time.',
    statement:
        'A strictly increasing array has been rotated at an unknown position. Return its minimum value. The array may have no rotation.',
    example: 'values = [4, 5, 6, 7, 0, 1, 2]\nOutput: 0',
    constraints: 'The array is nonempty and contains distinct values.',
    edgeCase: 'a one-element or unrotated array',
    approachQuestion:
        'How does the midpoint compare with the right endpoint tell you which half still contains the minimum?',
    hints: [
      'One side of the range is still sorted.',
      'Compare middle to the rightmost value.',
      'If middle is greater, the minimum is to the right; otherwise keep middle and search left.',
    ],
    explanation:
        'Keep a closed search interval. If values[mid] is greater than values[right], the minimum lies strictly to the right of mid; otherwise the minimum is at mid or to its left. Continue until left equals right and return that value. Each step halves the range: O(log n) time and O(1) extra space.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _reuse(
    number: 16,
    title: 'Search in Rotated Sorted Array',
    slug: 'search-in-rotated-sorted-array',
    pattern: 'Binary search',
    phase: 'Phase 1 · Sequences and search',
    difficulty: 'Medium',
    lessonId: 'rotated-index-v1',
  ),
  _BlindDraft(
    number: 17,
    title: 'Reverse Linked List',
    slug: 'reverse-linked-list',
    pattern: 'Linked lists',
    difficulty: 'Easy',
    summary: 'Reverse the order of a singly linked chain in place.',
    statement:
        'A singly linked chain is represented by its values from head to tail. Return those values in the order produced by reversing every next link. Empty input stays empty.',
    example: 'values = [1, 2, 3, 4]\nOutput: [4, 3, 2, 1]',
    constraints:
        'Values may repeat or be negative. The node order, not the value order, defines the chain.',
    edgeCase: 'an empty chain or a one-node chain',
    approachQuestion:
        'When reversing one link, which pointer must be saved before the link changes?',
    hints: [
      'Walk from the head while keeping the already reversed prefix.',
      'Save the next node, redirect the current link to the previous node, then advance.',
      'Maintain previous, current, and next; each link is reversed once.',
    ],
    explanation:
        'For node-based code, keep previous = null and current = head. Before changing current.next, save the next node. Point current.next to previous, then advance previous and current. The final previous node is the new head. Each node is visited once: O(n) time and O(1) extra space. The value-list form in this workbook returns the reversed traversal order.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integerList,
  ).build(),
  _BlindDraft(
    number: 18,
    title: 'Merge Two Sorted Lists',
    slug: 'merge-two-sorted-lists',
    pattern: 'Linked lists',
    difficulty: 'Easy',
    summary: 'Stitch two increasing chains into one increasing chain.',
    statement:
        'Given two nondecreasing lists of values, return one nondecreasing list containing every value from both inputs.',
    example:
        'first = [1, 2, 4], second = [1, 3, 4]\nOutput: [1, 1, 2, 3, 4, 4]',
    constraints:
        'Either input may be empty. Values may repeat. Preserve all occurrences.',
    edgeCase: 'one empty list or equal current values',
    approachQuestion:
        'Which value is safe to append next when both remaining lists are sorted?',
    hints: [
      'Compare only the first unconsumed value of each list.',
      'Appending the smaller head cannot skip an earlier value.',
      'Advance the list whose head you append; then append the other remainder.',
    ],
    explanation:
        'Use a dummy head and a tail pointer. Compare the two current values, attach the smaller node, and advance that input. When one list ends, attach the other remainder. Every node is used once, so time is O(n + m); a node-relinking implementation uses O(1) auxiliary space. The workbook represents the resulting order as a value list.',
    arguments: [
      BlindArgument('first', BlindValueKind.integerList),
      BlindArgument('second', BlindValueKind.integerList),
    ],
    result: BlindValueKind.integerList,
  ).build(),
  _BlindDraft(
    number: 19,
    title: 'Reorder List',
    slug: 'reorder-list',
    pattern: 'Linked lists',
    difficulty: 'Medium',
    summary: 'Interleave the front half with the reversed back half.',
    statement:
        'Rearrange a chain with values L0 through Ln−1 into L0, Ln−1, L1, Ln−2, and so on. Return the resulting value order.',
    example: 'values = [1, 2, 3, 4, 5]\nOutput: [1, 5, 2, 4, 3]',
    constraints:
        'The chain may be empty or contain one node. Do not duplicate or lose a node.',
    edgeCase: 'odd versus even list length',
    approachQuestion:
        'How can you find the midpoint, reverse the second half, then weave the two chains without losing either remainder?',
    hints: [
      'Find the middle with slow and fast pointers.',
      'Reverse the half after the middle.',
      'Alternately splice one node from each half; stop when the second half is exhausted.',
    ],
    explanation:
        'Find the midpoint with slow/fast pointers. Split after the middle, reverse the second half, then alternate nodes from the first half and reversed half. Save each next pointer before rewiring. Each node participates in a constant number of operations: O(n) time and O(1) extra space. For odd lengths the first half keeps the center node.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integerList,
  ).build(),
  _reuse(
    number: 20,
    title: 'Remove Nth Node From End of List',
    slug: 'remove-nth-node-from-end-of-list',
    pattern: 'Linked lists',
    phase: 'Phase 2 · Linked structures and trees',
    difficulty: 'Medium',
    lessonId: 'list-nth-from-end-v1',
  ),
  _reuse(
    number: 21,
    title: 'Linked List Cycle',
    slug: 'linked-list-cycle',
    pattern: 'Linked lists',
    phase: 'Phase 2 · Linked structures and trees',
    difficulty: 'Easy',
    lessonId: 'list-cycle-v1',
  ),
  _BlindDraft(
    number: 22,
    title: 'Invert Binary Tree',
    slug: 'invert-binary-tree',
    pattern: 'Trees',
    difficulty: 'Easy',
    summary: 'Swap the left and right subtree at every node.',
    statement:
        'A binary tree is supplied in level order, using null markers for missing children. Return its level-order encoding after every node’s left and right subtrees are exchanged.',
    example: 'tree = [4, 2, 7, 1, 3, 6, 9]\nOutput: [4, 7, 2, 9, 6, 3, 1]',
    constraints:
        'The input represents a valid tree and may be empty. Node values are distinct for this exercise.',
    edgeCase: 'an empty tree and a missing child',
    approachQuestion:
        'What local action at each node is enough to invert both of its subtrees?',
    hints: [
      'The root stays the root.',
      'Exchange its children, then repeat for each non-null child.',
      'A DFS or BFS can visit every node and swap its two child links.',
    ],
    explanation:
        'For each node, swap its left and right children, then invert both resulting subtrees. DFS recursion or an explicit BFS queue both visit each node exactly once. Time is O(n); recursive stack space is O(h), where h is tree height, while iterative traversal uses up to O(w) queue space for maximum width. The input contract uses level-order values only to keep examples readable.',
    arguments: [BlindArgument('levelOrder', BlindValueKind.integerList)],
    result: BlindValueKind.integerList,
  ).build(),
  _reuse(
    number: 23,
    title: 'Maximum Depth of Binary Tree',
    slug: 'maximum-depth-of-binary-tree',
    pattern: 'Trees',
    phase: 'Phase 2 · Linked structures and trees',
    difficulty: 'Easy',
    lessonId: 'tree-depth-v1',
  ),
  _BlindDraft(
    number: 24,
    title: 'Same Tree',
    slug: 'same-tree',
    pattern: 'Trees',
    difficulty: 'Easy',
    summary: 'Compare tree shape and values at corresponding positions.',
    statement:
        'Given two binary trees, return true only if they have identical structure and every corresponding node has the same value.',
    example: 'first = [1, 2, 3], second = [1, 2, 3]\nOutput: true',
    constraints:
        'Either tree may be empty. Equal values in different positions do not make two trees the same.',
    edgeCase: 'one empty tree or equal roots with different child shape',
    approachQuestion:
        'Which pair of conditions can decide equality at a node before comparing its children?',
    hints: [
      'Two null nodes match; exactly one null node does not.',
      'For non-null nodes, compare values.',
      'Recursively compare both left children and both right children.',
    ],
    explanation:
        'At each pair of positions, return true if both nodes are null; return false if exactly one is null or their values differ. Otherwise both left subtrees and both right subtrees must match. Every node is visited once: O(n) time, O(h) recursion space for tree height h.',
    arguments: [
      BlindArgument('first', BlindValueKind.integerList),
      BlindArgument('second', BlindValueKind.integerList),
    ],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 25,
    title: 'Subtree of Another Tree',
    slug: 'subtree-of-another-tree',
    pattern: 'Trees',
    difficulty: 'Easy',
    summary: 'Find a root whose entire remaining tree matches the candidate.',
    statement:
        'Return true when the candidate tree appears as a node-aligned subtree of the main tree. A matching root value alone is not sufficient; all descendants and null positions must match.',
    example: 'tree = [3, 4, 5, 1, 2], candidate = [4, 1, 2]\nOutput: true',
    constraints:
        'The candidate may be empty. Both encodings describe valid binary trees.',
    edgeCase: 'the candidate is empty or a value matches with the wrong shape',
    approachQuestion:
        'How can the same-tree check help test each possible root in the larger tree?',
    hints: [
      'An empty candidate is contained.',
      'Visit every node in the main tree as a possible matching root.',
      'At each candidate root, run a structural equality check; otherwise search its children.',
    ],
    explanation:
        'If the candidate is empty, it is a subtree. Otherwise traverse the main tree. At each node whose value equals the candidate root, compare the two trees using structural equality. If that fails, continue into the main node’s children. The straightforward method takes O(nm) time in the worst case for n and m nodes and O(h) recursive space. Serialization with unambiguous null markers can offer linear matching but needs careful delimiters.',
    arguments: [
      BlindArgument('tree', BlindValueKind.integerList),
      BlindArgument('candidate', BlindValueKind.integerList),
    ],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 26,
    title: 'Lowest Common Ancestor of a Binary Search Tree',
    slug: 'lowest-common-ancestor-of-a-binary-search-tree',
    pattern: 'Trees',
    difficulty: 'Medium',
    summary: 'Use the BST ordering to find where two root paths split.',
    statement:
        'In a BST containing both requested values, return the value at their lowest shared ancestor. The ancestor may be one of the requested nodes.',
    example:
        'BST level order = [6, 2, 8, 0, 4, 7, 9, null, null, 3, 5], p = 2, q = 8\nOutput: 6',
    constraints:
        'Values are unique and both requested nodes occur in the tree.',
    edgeCase: 'one requested value is an ancestor of the other',
    approachQuestion:
        'What does a node’s value tell you when both targets are smaller, both are larger, or they lie on opposite sides?',
    hints: [
      'A BST partitions smaller values left and larger values right.',
      'Move down while both targets are in the same strict side.',
      'The first node not strictly on the same side is the lowest common ancestor.',
    ],
    explanation:
        'Start at the root. If both target values are smaller, move left; if both are larger, move right. Otherwise the current node lies between them or equals one target, so it is their lowest common ancestor. The search follows one root-to-leaf path: O(h) time and O(1) iterative extra space, where h is tree height.',
    arguments: [
      BlindArgument('levelOrder', BlindValueKind.integerList),
      BlindArgument('p', BlindValueKind.integer),
      BlindArgument('q', BlindValueKind.integer),
    ],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 27,
    title: 'Binary Tree Level Order Traversal',
    slug: 'binary-tree-level-order-traversal',
    pattern: 'Trees',
    difficulty: 'Medium',
    summary: 'Collect nodes one depth at a time with breadth-first traversal.',
    statement:
        'Return one list of values per tree depth, from the root level downward and left to right within each level.',
    example:
        'tree = [3, 9, 20, null, null, 15, 7]\nOutput: [[3], [9, 20], [15, 7]]',
    constraints:
        'The tree may be empty. Missing children are skipped; they do not create output entries.',
    edgeCase: 'an empty tree or a level with only one real node',
    approachQuestion:
        'How can a queue snapshot separate the current depth from nodes discovered for the next depth?',
    hints: [
      'BFS processes nodes in increasing depth.',
      'Record the queue size before processing a level.',
      'Pop exactly that many nodes, append their values, and enqueue their non-null children.',
    ],
    explanation:
        'Put the root in a queue. At each iteration, capture the current queue length; those nodes make up exactly one level. Process that many nodes, recording values and enqueuing existing children. Append the level, then repeat. Every node is processed once: O(n) time and O(w) queue space, where w is maximum level width.',
    arguments: [BlindArgument('levelOrder', BlindValueKind.integerList)],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _BlindDraft(
    number: 28,
    title: 'Validate Binary Search Tree',
    slug: 'validate-binary-search-tree',
    pattern: 'Trees',
    difficulty: 'Medium',
    summary: 'Carry legal lower and upper bounds through the entire tree.',
    statement:
        'Return true when every node obeys the strict BST rule: all values in its left subtree are smaller and all values in its right subtree are larger.',
    example: 'tree = [5, 1, 7, null, null, 6, 8]\nOutput: false',
    constraints: 'Node values are unique integers. The tree may be empty.',
    edgeCase: 'a deep descendant violates an ancestor bound',
    approachQuestion:
        'Why is checking only each node against its direct children insufficient?',
    hints: [
      'A node inherits limits from every ancestor.',
      'Pass an exclusive lower and upper bound down the traversal.',
      'Left recursion narrows the upper bound to the node value; right recursion raises the lower bound.',
    ],
    explanation:
        'Recursively validate a node inside an exclusive interval (low, high). Its value must be strictly inside; then validate the left subtree with high = value and the right subtree with low = value. Null trees are valid. Every node is visited once: O(n) time and O(h) recursion space. A local parent-child comparison misses violations by deeper descendants.',
    arguments: [BlindArgument('levelOrder', BlindValueKind.integerList)],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 29,
    title: 'Kth Smallest Element in a BST',
    slug: 'kth-smallest-element-in-a-bst',
    pattern: 'Trees',
    difficulty: 'Medium',
    summary: 'Inorder traversal visits BST values in sorted order.',
    statement:
        'Return the value at one-based rank k in a BST with distinct values.',
    example: 'tree = [3, 1, 4, null, 2], k = 1\nOutput: 1',
    constraints: 'The tree is nonempty and 1 ≤ k ≤ node count.',
    edgeCase: 'k = 1 and k equals the number of nodes',
    approachQuestion:
        'Which traversal of a BST emits values from smallest to largest, and when can you stop?',
    hints: [
      'Use the ordering invariant of a BST.',
      'Inorder visits left subtree, node, then right subtree.',
      'Count visits and return as soon as the counter reaches k.',
    ],
    explanation:
        'Perform inorder traversal. The BST invariant makes the visited values strictly increasing. Count each visited node; the kth visit is the answer, so traversal may stop early. O(h + k) time when traversal stops at rank k, O(h) stack space; a full traversal is O(n). An iterative stack avoids language recursion limits.',
    arguments: [
      BlindArgument('levelOrder', BlindValueKind.integerList),
      BlindArgument('k', BlindValueKind.integer),
    ],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 30,
    title: 'Construct Binary Tree from Preorder and Inorder Traversal',
    slug: 'construct-binary-tree-from-preorder-and-inorder-traversal',
    pattern: 'Trees',
    difficulty: 'Medium',
    summary:
        'Use preorder to find each root and inorder to divide its subtree.',
    statement:
        'Given preorder and inorder traversals of a tree with unique values, reconstruct it and return its level-order encoding with null child markers.',
    example:
        'preorder = [3, 9, 20, 15, 7], inorder = [9, 3, 15, 20, 7]\nOutput: [3, 9, 20, null, null, 15, 7]',
    constraints:
        'Both traversals have equal length and contain the same unique values. Empty traversals describe an empty tree.',
    edgeCase: 'an empty subtree while preorder still has later nodes',
    approachQuestion:
        'What does the next preorder value identify, and where does its inorder position divide left from right?',
    hints: [
      'Preorder lists a subtree root before its descendants.',
      'Find that root in inorder to determine the left-subtree size.',
      'Recursively build the left and right ranges; use a value-to-inorder-index map to avoid repeated scans.',
    ],
    explanation:
        'The next preorder value is the root. Locate it in inorder; values before it in the current inorder range form the left subtree, and values after form the right. Recurse on those matching ranges. A hash map of inorder positions avoids repeated search. Construction is O(n) time and O(n) space for the map and output tree, plus O(h) recursion. Serialize the result in level order with explicit null markers.',
    arguments: [
      BlindArgument('preorder', BlindValueKind.integerList),
      BlindArgument('inorder', BlindValueKind.integerList),
    ],
    result: BlindValueKind.integerList,
  ).build(),
  _BlindDraft(
    number: 31,
    title: 'Binary Tree Maximum Path Sum',
    slug: 'binary-tree-maximum-path-sum',
    pattern: 'Trees',
    difficulty: 'Hard',
    summary:
        'Combine two positive subtree gains at a pivot while returning one branch upward.',
    statement:
        'Return the largest sum along any nonempty path in a binary tree. A path may begin and end at any nodes but cannot revisit a node.',
    example: 'tree = [-10, 9, 20, null, null, 15, 7]\nOutput: 42',
    constraints:
        'The tree is nonempty. Values may be negative, so a path must include at least one node.',
    edgeCase: 'all node values are negative',
    approachQuestion:
        'At a node, what path value can be extended to its parent, and what different value can update the global best?',
    hints: [
      'A path continuing upward can choose only one child branch.',
      'Ignore negative gains because taking them makes the sum smaller.',
      'Return node value plus the larger positive child gain; update best with both positive gains meeting at the node.',
    ],
    explanation:
        'A postorder helper returns the maximum downward gain starting at a node. Clamp each child gain at zero because a negative branch is harmful. A path using this node as its highest point may combine both positive child gains plus the node value; update a global best with that sum. Return the node plus the larger child gain upward. O(n) time and O(h) recursion space. Initialize the global best to negative infinity so all-negative trees work.',
    arguments: [BlindArgument('levelOrder', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 32,
    title: 'Serialize and Deserialize Binary Tree',
    slug: 'serialize-and-deserialize-binary-tree',
    pattern: 'Trees',
    difficulty: 'Hard',
    summary:
        'Choose a format that preserves both values and missing-child positions.',
    statement:
        'Design a serialization and its inverse for a binary tree. The required function performs both operations and returns a normalized level-order encoding; it must preserve the exact tree shape.',
    example:
        'tree = [1, 2, 3, null, null, 4, 5]\nRound trip output: [1, 2, 3, null, null, 4, 5]',
    constraints:
        'The tree may be empty and values may be negative. Missing children must be represented unambiguously.',
    edgeCase: 'an empty tree and a missing child before a later node',
    approachQuestion:
        'What information must the serialized stream retain so the decoder can restore every left/right position?',
    hints: [
      'Values alone lose the shape.',
      'Include an explicit null marker or use a self-delimiting format.',
      'Decode in the same traversal order, consuming child markers as parent nodes are restored.',
    ],
    explanation:
        'A preorder format that writes a value or null marker for every child slot is unambiguous. Serialize recursively: null emits a marker; a node emits its value, then both subtrees. Deserialize by consuming the same stream order and rebuilding a node before its children. Both passes are O(n) time and O(n) serialized/output space, with O(h) recursive stack. This lesson’s contract returns the normalized tree after a full round trip.',
    arguments: [BlindArgument('levelOrder', BlindValueKind.integerList)],
    result: BlindValueKind.integerList,
  ).build(),
  _reuse(
    number: 33,
    title: 'Top K Frequent Elements',
    slug: 'top-k-frequent-elements',
    pattern: 'Heaps',
    phase: 'Phase 2 · Linked structures and trees',
    difficulty: 'Medium',
    lessonId: 'top-frequency-v1',
  ),
  _reuse(
    number: 34,
    title: 'Merge K Sorted Lists',
    slug: 'merge-k-sorted-lists',
    pattern: 'Heaps',
    phase: 'Phase 2 · Linked structures and trees',
    difficulty: 'Hard',
    lessonId: 'merge-streams-v1',
  ),
  _BlindDraft(
    number: 35,
    title: 'Find Median from Data Stream',
    slug: 'find-median-from-data-stream',
    pattern: 'Heaps',
    difficulty: 'Hard',
    summary: 'Maintain the lower and upper halves as values arrive.',
    statement:
        'Process the supplied stream in order and return the median after each insertion. For an even number of values, average the two middle values.',
    example: 'stream = [5, 2, 10]\nOutput: [5.0, 3.5, 5.0]',
    constraints:
        'The stream may be empty. Values are integers; report medians as numbers.',
    edgeCase: 'the first insertion and an even-sized prefix',
    approachQuestion:
        'How can two heaps keep exactly the values around the middle available after every insertion?',
    hints: [
      'Keep a max-heap for the lower half and a min-heap for the upper half.',
      'Balance their sizes so they differ by at most one.',
      'The top of the larger heap is the median; equal sizes use the average of both tops.',
    ],
    explanation:
        'Maintain a max-heap for the lower half and a min-heap for the upper half. Insert into the correct half, then rebalance so sizes differ by at most one and every lower value is at most every upper value. Read the middle from heap tops. Each insertion costs O(log n), each median O(1); storing the stream costs O(n). The function returns medians for each prefix.',
    arguments: [BlindArgument('stream', BlindValueKind.integerList)],
    result: BlindValueKind.decimalList,
  ).build(),
  _BlindDraft(
    number: 36,
    title: 'Word Search',
    slug: 'word-search',
    pattern: 'Backtracking',
    difficulty: 'Medium',
    summary:
        'Search neighboring cells while preventing a path from reusing a cell.',
    statement:
        'Return true if the word can be formed by horizontally or vertically adjacent board cells. A cell may appear at most once in a single path.',
    example: 'board = ["ABCE", "SFCS", "ADEE"], word = "ABCCED"\nOutput: true',
    constraints:
        'The board may be empty. An empty word is considered found. Diagonal moves are not allowed.',
    edgeCase: 'a repeated letter that would require reusing one cell',
    approachQuestion:
        'What state must a recursive search carry so it can backtrack without reusing a board cell?',
    hints: [
      'Try every board position that matches the first letter.',
      'Search four neighbors for the next character.',
      'Mark the current cell for this path, explore, then restore it before returning.',
    ],
    explanation:
        'Start a DFS from every cell matching the first character. Each recursive call matches the next character among four in-bounds neighbors, while tracking cells already used on the current path. Restore the mark after exploring so other paths can reuse the cell. The worst case is O(RC·4^L) for word length L; recursion space is O(L), plus visited state if not marked in-place.',
    arguments: [
      BlindArgument('board', BlindValueKind.textMatrix),
      BlindArgument('word', BlindValueKind.text),
    ],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 37,
    title: 'Implement Trie (Prefix Tree)',
    slug: 'implement-trie-prefix-tree',
    pattern: 'Tries',
    difficulty: 'Medium',
    summary: 'Store words by character paths to support prefix lookup.',
    statement:
        'Process commands encoded as insert:word, search:word, and startsWith:prefix. Return 1 or 0 for each search and startsWith command, in command order.',
    example:
        'commands = ["insert:apple", "search:apple", "search:app", "startsWith:app"]\nOutput: [1, 0, 1]',
    constraints:
        'Words contain lowercase English letters. The command list may be empty.',
    edgeCase: 'a prefix that is present but is not itself a complete word',
    approachQuestion:
        'What information must a trie node store separately from its child links?',
    hints: [
      'A shared prefix should share the same path.',
      'Mark the final node of an inserted word.',
      'Search follows every character; startsWith only needs the path to exist.',
    ],
    explanation:
        'Each trie node maps characters to child nodes and has an end-of-word flag. Insert creates missing links and marks the final node. Search follows the full word and checks the flag; startsWith follows only the prefix and checks that the path exists. An operation on a word of length L takes O(L); storage is proportional to the total inserted characters. The command-function form returns booleans as 1/0.',
    arguments: [BlindArgument('commands', BlindValueKind.textList)],
    result: BlindValueKind.integerList,
  ).build(),
  _BlindDraft(
    number: 38,
    title: 'Design Add and Search Words Data Structure',
    slug: 'design-add-and-search-words-data-structure',
    pattern: 'Tries',
    difficulty: 'Medium',
    summary: 'Extend trie lookup so a dot can branch across any one letter.',
    statement:
        'Process add:word and search:pattern commands. In a search pattern, a dot matches any single lowercase letter. Return 1/0 for each search in command order.',
    example:
        'commands = ["add:bad", "add:dad", "search:.ad", "search:b.."]\nOutput: [1, 1]',
    constraints:
        'Added words are lowercase and nonempty. Search patterns may contain lowercase letters and dots.',
    edgeCase:
        'a wildcard at the first character or a prefix with no complete word',
    approachQuestion:
        'When a wildcard appears, which trie branches are still possible, and when can the search stop early?',
    hints: [
      'Literal letters follow one child.',
      'A dot must explore each existing child at that depth.',
      'Return true if any wildcard branch reaches a terminal node after consuming the whole pattern.',
    ],
    explanation:
        'Store added words in a trie. For a literal pattern character, follow its one child. For a dot, recursively try each child and succeed if any branch matches the rest. A match is valid only when the entire pattern is consumed at an end-of-word node. Literal search takes O(L); wildcard search can visit O(26^L) nodes in the worst case. Trie storage is proportional to inserted characters.',
    arguments: [BlindArgument('commands', BlindValueKind.textList)],
    result: BlindValueKind.integerList,
  ).build(),
  _BlindDraft(
    number: 39,
    title: 'Word Search II',
    slug: 'word-search-ii',
    pattern: 'Tries',
    difficulty: 'Hard',
    summary:
        'Share prefixes across word searches and prune paths with no remaining words.',
    statement:
        'Return every distinct dictionary word that can be formed from adjacent board cells without reusing a cell within a word. A word may be found only once in the output.',
    example:
        'board = ["oaan", "etae", "ihkr", "iflv"], words = ["oath", "pea", "eat", "rain"]\nOutput: ["eat", "oath"]',
    constraints:
        'The board and word list may be empty. Only horizontal and vertical neighbors connect.',
    edgeCase: 'many words share a prefix or the same word can be reached twice',
    approachQuestion:
        'How can a trie avoid restarting a full dictionary scan for every cell path?',
    hints: [
      'Build one trie from all candidate words.',
      'During DFS, stop when the current path is not a trie prefix.',
      'Mark cells during a path and remove a found word or exhausted trie branch to prevent duplicate work.',
    ],
    explanation:
        'Build a trie containing the dictionary, with terminal nodes storing the completed word. Start DFS from each board cell and follow only trie edges matching the next letter. Stop immediately when no trie edge exists. Track used cells for the current path. When a word is found, record it once and clear its terminal marker; prune trie nodes with no remaining children. Complexity depends on board size and shared-prefix structure; worst-case search remains exponential in path length, while the trie greatly prunes common cases.',
    arguments: [
      BlindArgument('board', BlindValueKind.textMatrix),
      BlindArgument('words', BlindValueKind.textList),
    ],
    result: BlindValueKind.textList,
  ).build(),
  _reuse(
    number: 40,
    title: 'Number of Islands',
    slug: 'number-of-islands',
    pattern: 'Graphs',
    phase: 'Phase 3 · Search and networks',
    difficulty: 'Medium',
    lessonId: 'island-count-v1',
  ),
  _BlindDraft(
    number: 41,
    title: 'Clone Graph',
    slug: 'clone-graph',
    pattern: 'Graphs',
    difficulty: 'Medium',
    summary: 'Copy each reachable node once while preserving every edge.',
    statement:
        'A connected undirected graph is represented by an adjacency list. Return a structurally separate copy with the same nodes and neighbor relationships.',
    example:
        'adjacency = [[1, 2], [0, 2], [0, 1]]\nOutput adjacency: [[1, 2], [0, 2], [0, 1]]',
    constraints:
        'The graph may be empty and may contain cycles. Node labels are unique but need not be consecutive in the general problem.',
    edgeCase: 'a cycle that reaches an already discovered node',
    approachQuestion:
        'What map lets a traversal reuse the same clone whenever an original node is encountered again?',
    hints: [
      'A visited set prevents infinite traversal but is not enough to build a clone.',
      'Map each original node identity to its copied node.',
      'Create and record a clone before recursively cloning neighbors.',
    ],
    explanation:
        'Traverse with DFS or BFS and maintain original-node → clone-node mapping. Create a clone the first time a node is seen, record it immediately, then connect its cloned neighbors. Recording before traversal handles cycles. O(V + E) time and O(V) additional space. The workbook expresses nodes as adjacency rows with row indices as stable IDs.',
    arguments: [BlindArgument('adjacency', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _BlindDraft(
    number: 42,
    title: 'Pacific Atlantic Water Flow',
    slug: 'pacific-atlantic-water-flow',
    pattern: 'Graphs',
    difficulty: 'Medium',
    summary:
        'Search uphill from both oceans and intersect the reachable cells.',
    statement:
        'In a height grid, water moves from a cell to a neighboring cell of equal or lower height. Return coordinates from which water can reach both the top/left boundary and the bottom/right boundary.',
    example:
        'heights = [[1,2,2],[3,2,3],[2,4,5]]\nOutput: [[0,2],[1,1],[1,2],[2,0],[2,1],[2,2]]',
    constraints:
        'The grid may be empty. Movement is only up, down, left, or right.',
    edgeCase: 'a one-cell grid or a plateau of equal heights',
    approachQuestion:
        'Why is it easier to search backward from each ocean, moving to cells at least as high?',
    hints: [
      'Forward search asks whether every cell can reach a border.',
      'Reverse the direction: from a border, climb to equal-or-higher neighbors.',
      'Compute two reachability sets from the ocean borders and return their intersection.',
    ],
    explanation:
        'Run a multi-source BFS or DFS from each ocean’s boundary. In reverse, a move is allowed from height h to a neighbor with height at least h, because that neighbor could have flowed down to the current cell. Intersect the two visited sets. Every cell and edge is processed a constant number of times: O(RC) time and O(RC) space.',
    arguments: [BlindArgument('heights', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _BlindDraft(
    number: 43,
    title: 'Course Schedule',
    slug: 'course-schedule',
    pattern: 'Graphs',
    difficulty: 'Medium',
    summary: 'Check whether prerequisite dependencies contain a cycle.',
    statement:
        'There are courseCount courses numbered from 0. Each pair [course, prerequisite] is a directed dependency. Return true if every course can be completed.',
    example: 'courseCount = 2, prerequisites = [[1,0]]\nOutput: true',
    constraints:
        'There may be no prerequisites or multiple paths between courses. A directed cycle makes completion impossible.',
    edgeCase: 'a self-dependency or a longer directed cycle',
    approachQuestion:
        'Which traversal state distinguishes a node not visited yet from a node currently on the DFS path?',
    hints: [
      'A cycle in the dependency graph is the blocker.',
      'Use three DFS states: unseen, active, and finished.',
      'Reaching an active node proves a cycle; finishing every node without that event is acyclic.',
    ],
    explanation:
        'Build edges from each prerequisite to the course that depends on it. Detect a directed cycle using DFS with unseen/active/finished states; an edge to an active node closes a cycle. Alternatively, Kahn’s algorithm removes zero-indegree nodes and succeeds when all courses are removed. Both take O(V + E) time and O(V + E) space.',
    arguments: [
      BlindArgument('courseCount', BlindValueKind.integer),
      BlindArgument('prerequisites', BlindValueKind.integerMatrix),
    ],
    result: BlindValueKind.boolean,
  ).build(),
  _reuse(
    number: 44,
    title: 'Number of Connected Components in an Undirected Graph',
    slug: 'number-of-connected-components-in-an-undirected-graph',
    pattern: 'Graphs',
    phase: 'Phase 3 · Search and networks',
    difficulty: 'Medium',
    lessonId: 'graph-components-v1',
  ),
  _BlindDraft(
    number: 45,
    title: 'Graph Valid Tree',
    slug: 'graph-valid-tree',
    pattern: 'Graphs',
    difficulty: 'Medium',
    summary: 'A tree must connect every node and contain no cycle.',
    statement:
        'Given an undirected graph with nodeCount labeled nodes, return true only if it is connected and acyclic.',
    example: 'nodeCount = 5, edges = [[0,1],[0,2],[0,3],[1,4]]\nOutput: true',
    constraints:
        'A tree with n nodes has n−1 edges. Duplicate edges and self-edges, if supplied, must not be mistaken for a valid tree.',
    edgeCase: 'zero nodes, a disconnected graph, or an extra cycle edge',
    approachQuestion:
        'How can the n−1 edge condition plus a cycle/connectivity check establish the tree property?',
    hints: [
      'A tree has exactly one fewer edge than nodes.',
      'With n−1 edges, proving connectedness is enough; union-find can detect a cycle while joining.',
      'Reject the wrong edge count, then reject any edge whose endpoints are already connected.',
    ],
    explanation:
        'A valid undirected tree has n−1 edges and is connected. With that exact edge count, a cycle would force disconnection, so use union-find to reject any edge that joins vertices already in one component; if none does, the graph is a tree. DFS can instead verify connectivity and detect back-edges. Time is near O(E α(V)) with union-find; space O(V). Handle n = 0 according to the contract, here false.',
    arguments: [
      BlindArgument('nodeCount', BlindValueKind.integer),
      BlindArgument('edges', BlindValueKind.integerMatrix),
    ],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 46,
    title: 'Alien Dictionary',
    slug: 'alien-dictionary',
    pattern: 'Graphs',
    difficulty: 'Hard',
    summary: 'Infer character ordering constraints from adjacent sorted words.',
    statement:
        'Words are sorted under an unknown alphabet. Return one character order consistent with the first differing character of every adjacent pair, or an empty string if no valid order exists.',
    example:
        'words = ["wrt", "wrf", "er", "ett", "rftt"]\nOne valid order: "wertf"',
    constraints:
        'Characters are lowercase English letters. A longer word cannot precede its own exact prefix.',
    edgeCase: 'a prefix-order contradiction or a character cycle',
    approachQuestion:
        'How does the first differing position between adjacent words create one directed ordering edge?',
    hints: [
      'Later matching characters add no new constraint.',
      'A shorter word placed after its longer prefix is invalid.',
      'Topologically sort the inferred graph and compare emitted characters with the set of all present characters.',
    ],
    explanation:
        'Compare adjacent words and add a directed edge from the first differing character in the earlier word to the one in the later word. If the later word is a strict prefix of the earlier one, the input order is impossible. Topologically sort all present characters, including isolated ones. A cycle means no valid order. O(total characters + distinct-character edges) time and O(V + E) space.',
    arguments: [BlindArgument('words', BlindValueKind.textList)],
    result: BlindValueKind.text,
  ).build(),
  _BlindDraft(
    number: 47,
    title: 'Climbing Stairs',
    slug: 'climbing-stairs',
    pattern: 'Dynamic programming',
    difficulty: 'Easy',
    summary: 'Count ways by combining the one-step and two-step final moves.',
    statement:
        'A staircase has n steps. Each move climbs one or two steps. Return the number of distinct move sequences that reach the top.',
    example: 'n = 4\nOutput: 5',
    constraints:
        'n is a positive integer. Return an exact integer within the supported result range.',
    edgeCase: 'n = 1 and the smallest valid staircase',
    approachQuestion:
        'Which earlier staircase sizes can lead to a final move onto step n?',
    hints: [
      'The last move is either one step or two.',
      'The count at n depends on counts for n−1 and n−2.',
      'Set the first two base counts, then update them iteratively.',
    ],
    explanation:
        'Let ways[i] be the number of sequences to reach step i. The final move comes from i−1 or i−2, so ways[i] = ways[i−1] + ways[i−2]. Use base values ways[1] = 1 and ways[2] = 2, then iterate while retaining only the last two counts. O(n) time and O(1) extra space.',
    arguments: [BlindArgument('n', BlindValueKind.integer)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 48,
    title: 'House Robber',
    slug: 'house-robber',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary: 'At each house, choose between taking it and skipping it.',
    statement:
        'Given nonnegative values in a row of houses, choose a set with no adjacent positions and return its maximum total. Choosing no house is allowed.',
    example: 'values = [2, 7, 9, 3, 1]\nOutput: 12',
    constraints: 'The input may be empty. Values are nonnegative integers.',
    edgeCase: 'an empty row or one house',
    approachQuestion:
        'What two prior decisions are enough to compare taking the current house with skipping it?',
    hints: [
      'Taking i excludes i−1; skipping i keeps the best result through i−1.',
      'Use best[i] = max(best[i−1], best[i−2] + values[i]).',
      'Iterate with two rolling values rather than storing the full table.',
    ],
    explanation:
        'For each position, the best result is the maximum of skipping it (best through the previous house) and taking it (value plus best through the house before that). Initialize both rolling states to zero so the empty choice is available. O(n) time and O(1) extra space.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 49,
    title: 'House Robber II',
    slug: 'house-robber-ii',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary:
        'Split a circular row into two linear cases to handle the wraparound.',
    statement:
        'Houses form a circle, so the first and last positions are adjacent. Return the largest sum from nonadjacent houses; selecting none is allowed.',
    example: 'values = [2, 3, 2]\nOutput: 3',
    constraints: 'The input may be empty. Handle a single house separately.',
    edgeCase: 'one house and the conflict between first and last',
    approachQuestion:
        'How can excluding either endpoint turn the remaining circular choices into ordinary linear robber problems?',
    hints: [
      'The first and last cannot both be chosen.',
      'Solve ranges [0, n−2] and [1, n−1].',
      'Return the larger range result; for one item, return its value.',
    ],
    explanation:
        'For n = 1, return that value. Otherwise any valid selection excludes either the first or last house. Solve the linear House Robber recurrence on [0, n−2] and on [1, n−1], then take the maximum. Each pass is O(n), so total time is O(n), with O(1) rolling space.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 50,
    title: 'Longest Palindromic Substring',
    slug: 'longest-palindromic-substring',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary: 'Expand around every possible palindrome center.',
    statement:
        'Return a longest contiguous substring that reads identically in both directions. If several are longest, return the leftmost one.',
    example: 'text = "babad"\nOutput: "bab"',
    constraints: 'The string may be empty and is case-sensitive.',
    edgeCase: 'even-length palindromes and tied longest answers',
    approachQuestion:
        'Why are there two center types for a palindrome, and how do they cover every possibility?',
    hints: [
      'A center may be on one character or between two characters.',
      'Expand outward while the two characters match.',
      'Try both centers at every position and update only for a longer result or a leftward tie.',
    ],
    explanation:
        'Every palindrome has an odd center at a character or an even center between characters. Expand outward from both centers at each position while characters match. Track the longest range; on equal lengths keep the smaller start to satisfy the leftmost tie rule. There are O(n) centers and each expansion can cost O(n), yielding O(n²) time and O(1) extra space.',
    arguments: [BlindArgument('text', BlindValueKind.text)],
    result: BlindValueKind.text,
  ).build(),
  _BlindDraft(
    number: 51,
    title: 'Palindromic Substrings',
    slug: 'palindromic-substrings',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary:
        'Count every palindrome by expanding around all odd and even centers.',
    statement:
        'Return the number of nonempty contiguous substrings that read identically in both directions. Different index ranges count separately, even when their text is equal.',
    example: 'text = "aaa"\nOutput: 6',
    constraints: 'The string may be empty and is case-sensitive.',
    edgeCase: 'repeated letters create several distinct index ranges',
    approachQuestion:
        'How can each palindrome center contribute all of its nested palindromic ranges?',
    hints: [
      'Use the same odd and even center cases as longest-palindrome search.',
      'Every successful outward expansion discovers one substring.',
      'Increment the count at every matching expansion, not just when a center finishes.',
    ],
    explanation:
        'Expand from each odd and even center. Every time the boundary characters match, increment the count and continue outward; each successful expansion corresponds to one distinct substring range. O(n²) time in the worst case and O(1) extra space.',
    arguments: [BlindArgument('text', BlindValueKind.text)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 52,
    title: 'Decode Ways',
    slug: 'decode-ways',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary: 'Count valid one-digit and two-digit decodings at each position.',
    statement:
        'Digits map 1 through 26 to letters. Return the number of ways to decode the full string. A leading zero or any zero not paired into a value from 10 through 26 cannot decode.',
    example: 'digits = "226"\nOutput: 3',
    constraints:
        'The input contains digits only and may be empty. Empty input has zero decodings.',
    edgeCase:
        'a zero at the beginning or after a digit that cannot pair with it',
    approachQuestion:
        'At position i, when can the last one digit contribute and when can the last two digits contribute?',
    hints: [
      'A nonzero digit can decode alone.',
      'A two-character value from 10 to 26 can combine the previous two positions.',
      'Sum only the valid one-digit and two-digit predecessor counts; a zero has no single-digit branch.',
    ],
    explanation:
        'Let ways[i] count decodings of the first i digits. A nonzero final digit contributes ways[i−1]. If the last two digits form 10 through 26, they contribute ways[i−2]. Add only valid branches. Initialize the empty prefix with one way for recurrence purposes, but return zero for empty input by this contract. O(n) time and O(1) rolling space.',
    arguments: [BlindArgument('digits', BlindValueKind.text)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 53,
    title: 'Coin Change',
    slug: 'coin-change',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary: 'Build the fewest-coin answer from smaller amounts.',
    statement:
        'Given positive coin denominations and an amount, return the fewest coins needed for an exact total, or −1 if it cannot be formed. Each denomination may be reused.',
    example: 'coins = [1, 2, 5], amount = 11\nOutput: 3',
    constraints:
        'The amount is nonnegative; denominations are positive. Amount zero requires zero coins.',
    edgeCase: 'an unreachable amount and amount zero',
    approachQuestion:
        'If the final coin has denomination c, which smaller amount must already have a best answer?',
    hints: [
      'Define the best count for every subtotal from zero to amount.',
      'For each subtotal, try each coin that does not exceed it.',
      'Use one plus the best count at subtotal minus coin; leave impossible states unreachable.',
    ],
    explanation:
        'Set best[0] = 0 and every other amount to infinity. For each subtotal x, try every coin c ≤ x and minimize best[x] with best[x−c] + 1 when reachable. Return −1 if the target remains unreachable. O(amount × number of coin types) time and O(amount) space.',
    arguments: [
      BlindArgument('coins', BlindValueKind.integerList),
      BlindArgument('amount', BlindValueKind.integer),
    ],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 54,
    title: 'Maximum Product Subarray',
    slug: 'maximum-product-subarray',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary:
        'Track both maximum and minimum products because negatives can swap them.',
    statement:
        'Return the largest product of any nonempty contiguous subarray.',
    example: 'values = [2, 3, -2, 4]\nOutput: 6',
    constraints:
        'The input is nonempty and may contain negative values and zero.',
    edgeCase: 'a negative value flips the best and worst product',
    approachQuestion:
        'Why must the smallest product ending here be remembered as well as the largest?',
    hints: [
      'Multiplying by a negative swaps high and low.',
      'At each value, compare starting fresh with extending the old max and old min.',
      'Save the previous max/min before updating both; zero naturally resets a subarray.',
    ],
    explanation:
        'For each value x, the maximum product ending here is the maximum of x, x·previousMax, and x·previousMin; the minimum uses the same three candidates’ minimum. Save old values before updating. Track the best maximum over all positions. O(n) time and O(1) extra space.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 55,
    title: 'Word Break',
    slug: 'word-break',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary:
        'Mark string prefixes that can be segmented using dictionary words.',
    statement:
        'Return true if the entire string can be split into one or more dictionary words. A dictionary entry may be reused.',
    example: 'text = "leetcode", words = ["leet", "code"]\nOutput: true',
    constraints:
        'The string may be empty. Words are nonempty lowercase strings; reusing a word is allowed.',
    edgeCase: 'a prefix is segmentable but the remaining suffix is not',
    approachQuestion:
        'What prefix state lets you decide whether a dictionary word can finish a segmentation at the current index?',
    hints: [
      'A word ending at i matters only if the prefix before it is reachable.',
      'Let reachable[i] describe the first i characters.',
      'For each end position, try earlier reachable boundaries whose substring is in the word set.',
    ],
    explanation:
        'Let reachable[i] mean the prefix ending before index i can be segmented; seed reachable[0] = true. For each end, look for a start with reachable[start] and text[start:end] in a hash set of words. Return reachable[n]. With substring checks, time is O(n²) expected plus substring/hash costs; space is O(n + dictionary size). A trie can reduce repeated substring work.',
    arguments: [
      BlindArgument('text', BlindValueKind.text),
      BlindArgument('words', BlindValueKind.textList),
    ],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 56,
    title: 'Longest Increasing Subsequence',
    slug: 'longest-increasing-subsequence',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary:
        'Maintain the smallest possible tail for each increasing subsequence length.',
    statement:
        'Return the length of the longest strictly increasing subsequence. Chosen positions need not be adjacent.',
    example: 'values = [10, 9, 2, 5, 3, 7, 101, 18]\nOutput: 4',
    constraints:
        'The input may be empty. Equal values do not extend a strictly increasing subsequence.',
    edgeCase: 'equal values and a strictly decreasing sequence',
    approachQuestion:
        'For a fixed subsequence length, why is a smaller ending value more useful for future extensions?',
    hints: [
      'Keep a list of best tail values by length.',
      'Place each value at its lower-bound position in that list.',
      'Replace an existing tail or extend the list when the position is at its end.',
    ],
    explanation:
        'Maintain tails where tails[k] is the smallest ending value found for an increasing subsequence of length k+1. For each value, binary-search the first tail ≥ it and replace that tail; if none exists, append. The tails array is not necessarily an actual subsequence, but its length is the answer. O(n log n) time and O(n) space. A simpler O(n²) DP is also valid.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 57,
    title: 'Unique Paths',
    slug: 'unique-paths',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary: 'Count paths by combining the ways arriving from above and left.',
    statement:
        'A robot starts at the upper-left of an rows-by-columns grid and moves only right or down. Return the number of paths to the lower-right.',
    example: 'rows = 3, columns = 7\nOutput: 28',
    constraints: 'Both dimensions are positive. There are no blocked cells.',
    edgeCase: 'a one-row or one-column grid',
    approachQuestion:
        'Which two neighboring cells can contribute paths to a cell?',
    hints: [
      'Every route to a cell enters from above or from the left.',
      'Initialize the first row and column to one.',
      'Fill each cell as the sum of the cell above and the cell to its left.',
    ],
    explanation:
        'Let paths[r][c] count routes to a cell. The first row and column each have one route; every other cell gets paths from above plus left. A one-row rolling array stores the previous row and updates left to right. O(rows × columns) time and O(columns) extra space.',
    arguments: [BlindArgument('dimensions', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 58,
    title: 'Longest Common Subsequence',
    slug: 'longest-common-subsequence',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary: 'Compare prefixes and reuse the best common subsequence lengths.',
    statement:
        'Return the length of the longest sequence of characters appearing in both strings in the same relative order; characters need not be adjacent.',
    example: 'first = "abcde", second = "ace"\nOutput: 3',
    constraints: 'Strings may be empty. Matching is case-sensitive.',
    edgeCase: 'one string is empty or characters match only at the end',
    approachQuestion:
        'When the final characters match, how does the best prefix solution extend; when they differ, which two subproblems compete?',
    hints: [
      'Use a table for pairs of prefixes.',
      'A matching pair adds one to the diagonal state.',
      'For a mismatch, take the larger result from dropping one character from either string.',
    ],
    explanation:
        'For prefixes ending at i and j, a character match gives 1 + dp[i−1][j−1]. Otherwise use max(dp[i−1][j], dp[i][j−1]). Empty prefixes have length zero. The full table costs O(mn) time and space; a rolling row reduces space to O(min(m,n)) while preserving the recurrence.',
    arguments: [
      BlindArgument('first', BlindValueKind.text),
      BlindArgument('second', BlindValueKind.text),
    ],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 59,
    title: 'Combination Sum IV',
    slug: 'combination-sum-iv',
    pattern: 'Dynamic programming',
    difficulty: 'Medium',
    summary:
        'Count ordered sequences by choosing the final value of each total.',
    statement:
        'Given distinct positive values and a target, return the number of ordered sequences that sum to the target. Different orders count as different sequences.',
    example: 'values = [1, 2, 3], target = 4\nOutput: 7',
    constraints:
        'The target is nonnegative. Values are distinct positive integers; the result fits a signed 32-bit integer.',
    edgeCase: 'target zero and order-sensitive combinations',
    approachQuestion:
        'What does it mean for two sequences with the same values in a different order to count separately?',
    hints: [
      'Define ways[t] as the count for total t.',
      'The final value can be any candidate no larger than t.',
      'Set ways[0] = 1, then for each total sum ways[t − value] over candidates.',
    ],
    explanation:
        'Let ways[t] be the number of ordered sequences totaling t. Seed ways[0] = 1. For every total t from 1 through target, add ways[t−x] for each candidate x ≤ t. The total-outer loop makes order matter: choosing a different last item creates a distinct sequence. O(target × number of values) time and O(target) space.',
    arguments: [
      BlindArgument('values', BlindValueKind.integerList),
      BlindArgument('target', BlindValueKind.integer),
    ],
    result: BlindValueKind.integer,
  ).build(),
  _reuse(
    number: 60,
    title: 'Best Time to Buy and Sell Stock',
    slug: 'best-time-to-buy-and-sell-stock',
    pattern: 'Greedy',
    phase: 'Phase 4 · Optimization and boundaries',
    difficulty: 'Easy',
    lessonId: 'single-trade-v1',
  ),
  _reuse(
    number: 61,
    title: 'Maximum Subarray',
    slug: 'maximum-subarray',
    pattern: 'Greedy',
    phase: 'Phase 4 · Optimization and boundaries',
    difficulty: 'Easy',
    lessonId: 'max-subarray-v1',
  ),
  _BlindDraft(
    number: 62,
    title: 'Jump Game',
    slug: 'jump-game',
    pattern: 'Greedy',
    difficulty: 'Medium',
    summary: 'Track the farthest index reachable from the prefix seen so far.',
    statement:
        'Each value is the maximum forward jump length from that index. Return whether the final index is reachable from index zero.',
    example: 'jumps = [2, 3, 1, 1, 4]\nOutput: true',
    constraints: 'The list is nonempty and values are nonnegative.',
    edgeCase: 'a zero that blocks progress before the final index',
    approachQuestion:
        'What single boundary summarizes every position reachable from the prefix processed so far?',
    hints: [
      'Track the farthest reachable index.',
      'If the current index is beyond that boundary, it cannot be reached.',
      'Update farthest with max(farthest, i + jumps[i]) and stop once it covers the last index.',
    ],
    explanation:
        'Scan indices from left to right while maintaining the farthest reachable position. If i exceeds it, the goal is unreachable. Otherwise extend the boundary with i + jumps[i]. The final position is reachable when the boundary reaches it. O(n) time and O(1) space.',
    arguments: [BlindArgument('jumps', BlindValueKind.integerList)],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 63,
    title: 'Insert Interval',
    slug: 'insert-interval',
    pattern: 'Intervals',
    difficulty: 'Medium',
    summary:
        'Copy earlier intervals, merge every overlap, then append the remainder.',
    statement:
        'Given nonoverlapping intervals sorted by start and one new interval, insert it while preserving order and merging all overlaps. Intervals are closed, so sharing an endpoint counts as overlap.',
    example:
        'intervals = [[1,3],[6,9]], newInterval = [2,5]\nOutput: [[1,5],[6,9]]',
    constraints:
        'Input intervals are valid, sorted, and nonoverlapping. The input must remain unchanged.',
    edgeCase: 'the new interval belongs at either end or touches an endpoint',
    approachQuestion:
        'How can ordering divide intervals into those strictly before, overlapping, and strictly after the new interval?',
    hints: [
      'Append intervals ending before the new start.',
      'Expand the new interval over every interval whose start is no later than its end.',
      'Append the merged interval once, followed by all untouched intervals.',
    ],
    explanation:
        'Copy intervals that end before the new interval begins. Merge while the next interval starts at or before the current end, expanding both boundaries. Append the merged interval, then copy the rest. The scan is O(n) time and O(n) output space. Endpoint equality merges under closed-interval semantics.',
    arguments: [
      BlindArgument('intervals', BlindValueKind.integerMatrix),
      BlindArgument('newInterval', BlindValueKind.integerList),
    ],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _BlindDraft(
    number: 64,
    title: 'Merge Intervals',
    slug: 'merge-intervals',
    pattern: 'Intervals',
    difficulty: 'Medium',
    summary: 'Sort by start and extend the current interval through overlaps.',
    statement:
        'Merge every pair of overlapping closed intervals and return disjoint intervals in increasing order. Intervals that share an endpoint overlap.',
    example:
        'intervals = [[1,3],[2,6],[8,10],[15,18]]\nOutput: [[1,6],[8,10],[15,18]]',
    constraints:
        'Intervals are valid; input order is arbitrary. Do not mutate the input.',
    edgeCase: 'nested or duplicate intervals and shared endpoints',
    approachQuestion:
        'Why does sorting by start mean only the most recently emitted interval can still overlap the next one?',
    hints: [
      'Sort a copy by start.',
      'Compare the next start to the current end.',
      'Merge when next.start <= current.end; otherwise emit current and begin another.',
    ],
    explanation:
        'Sort a copy by start. Keep a current interval; if the next start is at most its end, extend the end to the larger endpoint. Otherwise emit current and begin a new one. Emit the last interval after the scan. O(n log n) time for sorting and O(n) space for output/copying. Closed intervals with equal endpoints overlap.',
    arguments: [BlindArgument('intervals', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _BlindDraft(
    number: 65,
    title: 'Non-overlapping Intervals',
    slug: 'non-overlapping-intervals',
    pattern: 'Intervals',
    difficulty: 'Medium',
    summary: 'Keep the interval that ends first to leave the most room ahead.',
    statement:
        'Return the minimum number of intervals to remove so the remaining closed intervals are pairwise nonoverlapping. Touching endpoints overlap.',
    example: 'intervals = [[1,2],[2,3],[3,4],[1,3]]\nOutput: 2',
    constraints:
        'Intervals are valid and may be in any order. Empty input requires zero removals.',
    edgeCase: 'equal end points and endpoint-touching intervals',
    approachQuestion:
        'When two intervals overlap, why is retaining the one with the earlier end a safe greedy choice?',
    hints: [
      'Sort by end time.',
      'An earlier finish leaves at least as much room for later intervals.',
      'Keep a compatible interval when start > keptEnd; otherwise remove one.',
    ],
    explanation:
        'Sort by end. Keep the first interval, then keep a later interval only when its start is strictly greater than the last kept end under closed-interval semantics. On overlap, discard the interval with the later end, because it cannot allow more future choices. Return n minus the number kept. O(n log n) time and O(n) sorting workspace depending on implementation.',
    arguments: [BlindArgument('intervals', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 66,
    title: 'Meeting Rooms',
    slug: 'meeting-rooms',
    pattern: 'Intervals',
    difficulty: 'Easy',
    summary: 'Check whether any two meeting intervals overlap.',
    statement:
        'Return true if one person can attend every meeting. Meeting intervals are closed for this exercise, so equal end/start times count as overlap.',
    example: 'meetings = [[0,30],[5,10],[15,20]]\nOutput: false',
    constraints:
        'Meetings may be empty and may appear in any order. The input must not be changed.',
    edgeCase: 'an empty schedule or two intervals sharing an endpoint',
    approachQuestion:
        'After sorting by start, which adjacent comparison is sufficient to detect a conflict?',
    hints: [
      'Sort a copy by start time.',
      'A conflict exists when the next start is at most the previous end.',
      'Scan neighboring sorted meetings and stop at the first overlap.',
    ],
    explanation:
        'Sort a copy by start time. Compare each meeting’s start with the previous meeting’s end; under this closed-interval contract, start ≤ previous end is a conflict. If no adjacent pair overlaps, the schedule is attendable. O(n log n) time and O(n) copy space.',
    arguments: [BlindArgument('meetings', BlindValueKind.integerMatrix)],
    result: BlindValueKind.boolean,
  ).build(),
  _BlindDraft(
    number: 67,
    title: 'Meeting Rooms II',
    slug: 'meeting-rooms-ii',
    pattern: 'Intervals',
    difficulty: 'Medium',
    summary: 'Track the active meeting with the earliest finishing time.',
    statement:
        'Return the minimum number of rooms needed for all meetings. Intervals are closed, so meetings sharing an endpoint require separate rooms.',
    example: 'meetings = [[0,30],[5,10],[15,20]]\nOutput: 2',
    constraints:
        'Intervals are valid and may be unordered. Empty input needs zero rooms.',
    edgeCase: 'several meetings begin before any current meeting ends',
    approachQuestion:
        'What does the smallest active end time tell you about whether a room can be reused?',
    hints: [
      'Sort meetings by start.',
      'Keep active end times in a min-heap.',
      'Free every room whose end is strictly before the next start; the heap size is concurrent room demand.',
    ],
    explanation:
        'Sort meetings by start time and maintain active end times in a min-heap. Before assigning the next meeting, remove every end strictly less than its start because endpoint-touching meetings overlap here. Add its end; the maximum heap size is the room count. O(n log n) time and O(n) space. A sweep over separate start/end events also works with carefully defined tie order.',
    arguments: [BlindArgument('meetings', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 68,
    title: 'Rotate Image',
    slug: 'rotate-image',
    pattern: 'Matrix',
    difficulty: 'Medium',
    summary: 'Transpose a square matrix and reverse each row.',
    statement:
        'Return a new matrix representing the input square image rotated 90 degrees clockwise. Preserve the original input.',
    example:
        'image = [[1,2,3],[4,5,6],[7,8,9]]\nOutput: [[7,4,1],[8,5,2],[9,6,3]]',
    constraints: 'The matrix is square and may have size zero or one.',
    edgeCase: 'size zero/one and preserving the input',
    approachQuestion:
        'Which two simple transformations compose into a clockwise quarter-turn?',
    hints: [
      'Map old row/column coordinates to new ones.',
      'Transpose across the main diagonal.',
      'Reverse each transposed row, writing into a copy if mutation is not allowed.',
    ],
    explanation:
        'A clockwise rotation maps old [r][c] to new [c][n−1−r]. One in-place derivation transposes across the main diagonal and reverses each row. This workbook returns a copy to keep inputs unchanged. O(n²) time and O(n²) result space, or O(1) auxiliary space if mutation is permitted.',
    arguments: [BlindArgument('image', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _BlindDraft(
    number: 69,
    title: 'Spiral Matrix',
    slug: 'spiral-matrix',
    pattern: 'Matrix',
    difficulty: 'Medium',
    summary: 'Shrink four boundaries after traversing each side.',
    statement:
        'Return every matrix value in clockwise spiral order, starting at the upper-left corner.',
    example: 'matrix = [[1,2,3],[4,5,6],[7,8,9]]\nOutput: [1,2,3,6,9,8,7,4,5]',
    constraints:
        'The matrix may have zero rows or columns and need not be square.',
    edgeCase: 'a single remaining row or column after a boundary shrinks',
    approachQuestion:
        'Which four boundaries describe the unvisited rectangle, and when must a second pass be skipped?',
    hints: [
      'Track top, bottom, left, and right.',
      'Traverse top, right, bottom, then left.',
      'After each side, move its boundary inward and check that top ≤ bottom or left ≤ right before the opposite pass.',
    ],
    explanation:
        'Keep top, bottom, left, and right bounds. Traverse the top row, right column, bottom row if one remains, then left column if one remains; shrink the corresponding boundary after each pass. Continue while the rectangle is nonempty. Every cell is visited once: O(rows × columns) time and O(1) extra space beyond the output.',
    arguments: [BlindArgument('matrix', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integerList,
  ).build(),
  _BlindDraft(
    number: 70,
    title: 'Set Matrix Zeroes',
    slug: 'set-matrix-zeroes',
    pattern: 'Matrix',
    difficulty: 'Medium',
    summary: 'Use the first row and column as marker storage for zeroed lines.',
    statement:
        'Return a copy where every row and column containing an original zero has been set entirely to zero. Newly written zeros must not trigger additional rows or columns.',
    example:
        'matrix = [[1,1,1],[1,0,1],[1,1,1]]\nOutput: [[1,0,1],[0,0,0],[1,0,1]]',
    constraints:
        'The matrix may be empty. Decisions must use original zero positions, not zeros written during the transformation.',
    edgeCase: 'a zero in the first row or first column',
    approachQuestion:
        'How can marker rows and columns record original zero positions without allowing newly written zeros to spread?',
    hints: [
      'A separate set of affected rows/columns is easy but uses extra space.',
      'The first row and column can hold markers for the rest of the matrix.',
      'Record whether the first row/column originally contained zero, then use markers and apply those two boundaries last.',
    ],
    explanation:
        'Use the first cell of each row and column as markers for zeros found in the interior. Separately remember whether the first row and first column originally contain zero. Apply markers to interior cells, then zero the first row/column as needed. O(rows × columns) time and O(1) auxiliary space in-place; this workbook returns a copy, requiring O(rows × columns) result space.',
    arguments: [BlindArgument('matrix', BlindValueKind.integerMatrix)],
    result: BlindValueKind.integerMatrix,
  ).build(),
  _BlindDraft(
    number: 71,
    title: 'Number of 1 Bits',
    slug: 'number-of-1-bits',
    pattern: 'Bit manipulation',
    difficulty: 'Easy',
    summary: 'Count set bits in a 32-bit unsigned representation.',
    statement:
        'Return how many of the 32 bits are set to one in the input’s unsigned 32-bit representation.',
    example: 'value = 11 (binary 1011)\nOutput: 3',
    constraints:
        'Treat the input as exactly 32 bits, including when its signed representation is negative.',
    edgeCase: 'zero and a value with the top bit set',
    approachQuestion: 'Which bit trick removes one set bit per iteration?',
    hints: [
      'A mask can inspect the least significant bit.',
      'The expression n & (n−1) clears the lowest set bit.',
      'Repeat until the unsigned value becomes zero and count iterations.',
    ],
    explanation:
        'Interpret the input as unsigned 32-bit data. Repeatedly apply n = n & (n−1), which removes exactly the least significant set bit; count iterations until n is zero. At most 32 iterations are needed, so time is O(number of set bits) and extra space is O(1). A fixed 32-step mask scan is another constant-time option.',
    arguments: [BlindArgument('value', BlindValueKind.integer)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 72,
    title: 'Counting Bits',
    slug: 'counting-bits',
    pattern: 'Bit manipulation',
    difficulty: 'Easy',
    summary: 'Reuse a smaller number’s bit count to build the full answer.',
    statement:
        'For every integer from 0 through n, return its number of set bits.',
    example: 'n = 5\nOutput: [0, 1, 1, 2, 1, 2]',
    constraints: 'n is nonnegative. The result includes an entry for zero.',
    edgeCase: 'n = 0 and powers of two',
    approachQuestion:
        'How does clearing the lowest set bit relate the answer for x to an already computed smaller number?',
    hints: [
      'The lowest set bit can be removed with x & (x−1).',
      'That result is smaller than x.',
      'bits[x] = bits[x & (x−1)] + 1.',
    ],
    explanation:
        'Build answers from 0 upward. For x > 0, clearing its lowest set bit produces a smaller number whose count is already known, so bits[x] = bits[x & (x−1)] + 1. Each entry takes O(1), for O(n) total time and O(n) output/space.',
    arguments: [BlindArgument('n', BlindValueKind.integer)],
    result: BlindValueKind.integerList,
  ).build(),
  _BlindDraft(
    number: 73,
    title: 'Reverse Bits',
    slug: 'reverse-bits',
    pattern: 'Bit manipulation',
    difficulty: 'Easy',
    summary: 'Move each of 32 bits into its mirrored position.',
    statement:
        'Reverse the order of all 32 bits and return the resulting unsigned 32-bit value.',
    example: 'value = 00000010100101000001111010011100₂\nOutput: 964176192',
    constraints:
        'Always process exactly 32 bits; leading zeros are significant positions.',
    edgeCase: 'leading zero bits and a set top bit',
    approachQuestion:
        'How can you repeatedly take the input’s lowest bit and append it to a result being built from left to right?',
    hints: [
      'The result shifts left to make room.',
      'Read value & 1, append it, then shift the input right.',
      'Repeat for exactly 32 iterations so leading zeros are retained.',
    ],
    explanation:
        'Initialize result to zero. Repeat 32 times: shift result left, append the input’s least significant bit, then shift the input right. Exactly 32 iterations preserve leading zero positions. O(32) time and O(1) space. Ensure the language’s bitwise operations use 32-bit unsigned semantics.',
    arguments: [BlindArgument('value', BlindValueKind.integer)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 74,
    title: 'Missing Number',
    slug: 'missing-number',
    pattern: 'Bit manipulation',
    difficulty: 'Easy',
    summary: 'Recover the absent value from a complete zero-based range.',
    statement:
        'The list contains n distinct values drawn from 0 through n, with exactly one value missing. Return the missing value.',
    example: 'values = [3, 0, 1]\nOutput: 2',
    constraints:
        'The input may be empty. Values are distinct and within the stated range.',
    edgeCase: 'zero or n is the missing value',
    approachQuestion:
        'How can the expected range total reveal the absent value, or how can XOR cancel the present pairs?',
    hints: [
      'The full range has a known sum.',
      'Subtract the observed sum from n(n+1)/2.',
      'Alternatively XOR all values and all integers 0 through n; equal values cancel.',
    ],
    explanation:
        'Use the arithmetic-series total n(n+1)/2 minus the sum of the input, or XOR all values together with every integer in 0..n. In XOR, equal values cancel, leaving only the missing one. The sum method risks overflow in narrow integer types; XOR avoids that. Both take O(n) time and O(1) extra space.',
    arguments: [BlindArgument('values', BlindValueKind.integerList)],
    result: BlindValueKind.integer,
  ).build(),
  _BlindDraft(
    number: 75,
    title: 'Sum of Two Integers',
    slug: 'sum-of-two-integers',
    pattern: 'Bit manipulation',
    difficulty: 'Medium',
    summary: 'Separate bitwise addition from the carry bits and repeat.',
    statement:
        'Return the sum of two signed 32-bit integers without using the arithmetic addition or subtraction operators in the algorithm.',
    example: 'a = 19, b = 23\nOutput: 42',
    constraints:
        'Operands and result fit signed 32-bit integers. Language-specific bitwise width and overflow behavior must be considered.',
    edgeCase: 'negative operands and a carry that propagates across many bits',
    approachQuestion:
        'Which bitwise operation gives the partial sum without carry, and which computes carry positions?',
    hints: [
      'XOR adds each bit when no carry is involved.',
      'AND identifies positions where both bits produce a carry; shift it left.',
      'Repeat sum = a XOR b and carry = (a AND b) shifted left until carry is zero.',
    ],
    explanation:
        'For fixed-width two’s-complement arithmetic, XOR produces the sum bits without carries. (a AND b) shifted left produces the carry bits. Reassign a to the partial sum and b to the carry until b becomes zero, masking or normalizing to the language’s 32-bit semantics where needed. At most 32 bit positions propagate, so time is O(1) for fixed width and space O(1).',
    arguments: [
      BlindArgument('a', BlindValueKind.integer),
      BlindArgument('b', BlindValueKind.integer),
    ],
    result: BlindValueKind.integer,
  ).build(),
];

final blind75ByLessonId = <String, Blind75Entry>{
  for (final entry in blind75Entries) entry.lesson.id: entry,
};
