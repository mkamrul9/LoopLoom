import '../domain/lesson.dart';
import 'blind75_curriculum.dart';

/// Additional curated interview problems that extend the stable Blind 75.
/// SolveIt uses original coaching prompts and links to the external challenge;
/// it does not reproduce LeetCode statements or claim affiliation.
class MasteryProblemSeed {
  const MasteryProblemSeed(
    this.title,
    this.slug,
    this.pattern,
    this.difficulty,
  );

  final String title;
  final String slug;
  final String pattern;
  final String difficulty;

  Blind75Entry build(int number) {
    final phase = switch (pattern) {
      'Arrays & hashing' ||
      'Two pointers' ||
      'Sliding window' ||
      'Binary search' ||
      'Stacks' => 'Phase 1 · Core patterns',
      'Linked lists' ||
      'Trees' ||
      'Heaps' ||
      'Tries' => 'Phase 2 · Data structures',
      'Backtracking' ||
      'Graphs' ||
      'Advanced graphs' => 'Phase 3 · Search and networks',
      _ => 'Phase 4 · Optimization and transfer',
    };
    final cue = _patternCue(pattern);
    final guide = masteryProblemGuides[slug];
    final lesson = Lesson(
      id: 'mastery300-$slug-v1',
      title: title,
      pattern: pattern,
      summary: guide?.summary ?? 'Practice $cue through $title.',
      statement:
          guide?.statement ??
          'Open the linked challenge and restate its input, required output, and constraints in your own words. Then solve $title by identifying when $cue is useful. SolveIt’s guided prompts help you reason through the external challenge; the challenge page supplies its full statement and examples.',
      example:
          guide?.example ??
          'Use one official example from the linked challenge. Before coding, write the expected result and the intermediate state that best tests $cue.',
      constraints:
          guide?.edgeCase ??
          'Read the challenge constraints before choosing a data structure or complexity target. Clarify empty, minimal, duplicate, and boundary inputs where the contract allows them.',
      questions: [
        guide?.contractQuestion ??
            'Restate $title: what are the inputs, exact output, and important constraints?',
        guide?.approachQuestion ??
            'What simple baseline would work? What repeated work can $cue avoid?',
        'Trace one official example from the challenge page. What is the key state after each step?',
        'Write the solution in your selected language. Which edge case would you test first?',
        'State the invariant that makes the approach correct, its time and space costs, and one alternative.',
      ],
      checks: [
        'I can explain the contract and constraints without relying on the title alone.',
        'I can describe a baseline and why $cue improves or structures it.',
        'My trace matches the external example and tracks the needed state.',
        'I tested a boundary case and can explain the complexity.',
        'I can state the correctness invariant and when this pattern applies.',
      ],
      hints: guide?.hints ?? _patternHints(pattern),
      explanation:
          guide?.explanation ??
          'For $title, first derive the contract from the linked challenge. Consider $cue, define the state that must remain true after each step, and test the invariant against a boundary case. Compare the resulting complexity with the simplest baseline before choosing the implementation.',
    );
    return Blind75Entry(
      number: number,
      title: title,
      slug: slug,
      pattern: pattern,
      phase: phase,
      difficulty: difficulty,
      lesson: lesson,
    );
  }
}

class MasteryProblemGuide {
  const MasteryProblemGuide({
    required this.summary,
    required this.statement,
    required this.example,
    required this.edgeCase,
    required this.contractQuestion,
    required this.approachQuestion,
    required this.hints,
    required this.explanation,
  });

  final String summary, statement, example, edgeCase;
  final String contractQuestion, approachQuestion, explanation;
  final List<String> hints;
}

MasteryProblemGuide _guide(
  String summary,
  String statement,
  String example,
  String edgeCase,
  String contractQuestion,
  String approachQuestion,
  List<String> hints,
  String explanation,
) => MasteryProblemGuide(
  summary: summary,
  statement: statement,
  example: example,
  edgeCase: edgeCase,
  contractQuestion: contractQuestion,
  approachQuestion: approachQuestion,
  hints: hints,
  explanation: explanation,
);

/// Original, problem-specific coaching for the first high-priority extension
/// batch. Remaining challenges still use the family-level scaffold below.
final masteryProblemGuides = <String, MasteryProblemGuide>{
  'ransom-note': MasteryProblemGuide(
    summary:
        'Check whether a target string can be assembled from a character supply.',
    statement:
        'Given a target string and a source string, decide whether the source contains enough copies of every character required by the target. Each source character can be used once.',
    example:
        'target = "aab", source = "ababa"\nOutput: true\nThe target needs two a characters and one b.',
    edgeCase:
        'A target character may be missing or appear more times in the target than in the source. An empty target needs no characters.',
    contractQuestion:
        'Which character counts must the source satisfy for the target to be constructible?',
    approachQuestion:
        'How can one pass over the source record available characters so each target lookup is constant time?',
    hints: [
      'Count the required characters or the available characters.',
      'A fixed-size frequency table is enough when the alphabet is constrained.',
      'Consume one count per target character; fail as soon as a count is exhausted.',
    ],
    explanation:
        'Count available characters, then consume one for each required target character. The invariant is that remaining counts equal unused source characters. This is linear in the two string lengths and uses space proportional to the alphabet.',
  ),
  'majority-element': MasteryProblemGuide(
    summary: 'Find the value that occupies more than half of an array.',
    statement:
        'Given a nonempty integer array with one value occurring strictly more than half the time, return that value.',
    example: 'values = [3, 3, 4, 3, 2, 3, 3]\nOutput: 3',
    edgeCase:
        'The majority may be the only element. Equal values can appear far apart, so adjacency alone is not enough.',
    contractQuestion:
        'What does “more than half” guarantee about the number of other values combined?',
    approachQuestion:
        'Can competing values cancel in pairs while a strict majority remains?',
    hints: [
      'A frequency map is a simple baseline.',
      'Try keeping a candidate and a balance rather than storing every count.',
      'When the balance reaches zero, choose the next value as candidate.',
    ],
    explanation:
        'Boyer–Moore voting maintains a candidate and cancellation balance. Every non-majority value can cancel at most one majority occurrence; because the majority exceeds all others combined, it survives. The prompt guarantees a majority, so a verification pass is unnecessary.',
  ),
  'subarray-sum-equals-k': MasteryProblemGuide(
    summary: 'Count contiguous ranges whose sum equals a target.',
    statement:
        'Given an integer array and target k, count the nonempty contiguous subarrays with sum exactly k.',
    example:
        'values = [1, 2, 1, 2], k = 3\nOutput: 3\nMatching ranges are [1,2], [2,1], and [1,2].',
    edgeCase:
        'Values may be negative or zero, so extending a range does not move its sum in one direction.',
    contractQuestion:
        'Why must the counted elements be contiguous, and are empty ranges allowed?',
    approachQuestion:
        'If the running prefix is p, which earlier prefix would make the intervening range sum to k?',
    hints: [
      'A quadratic scan is a useful correctness baseline.',
      'Store how often each prefix sum has appeared.',
      'Seed the frequency table with prefix 0 occurring once.',
    ],
    explanation:
        'For current prefix p, every earlier prefix p-k identifies a range ending here. Add its frequency before recording p. This supports negative numbers and counts all ranges in O(n) expected time with O(n) extra space.',
  ),
  'two-sum-ii-input-array-is-sorted': MasteryProblemGuide(
    summary:
        'Use sorted order to find two distinct positions with a target sum.',
    statement:
        'Given a nondecreasing integer array and a target, return the two one-based positions whose values sum to the target. The input has exactly one valid pair.',
    example: 'values = [1, 3, 4, 8], target = 7\nOutput: [2, 3]',
    edgeCase:
        'The answer uses two different positions even when both values are equal.',
    contractQuestion:
        'What indexing convention does the returned pair use, and why must the positions differ?',
    approachQuestion:
        'How does the sorted order tell you which pointer to move when the current sum is too small or too large?',
    hints: [
      'A hash-map solution is a useful baseline.',
      'Place one pointer at each end of the sorted range.',
      'Moving the left pointer increases the sum; moving the right pointer decreases it.',
    ],
    explanation:
        'With left < right, compare their sum to the target. Sorted order proves which side cannot participate in a solution at the current value. Each move shrinks the range, yielding O(n) time and O(1) extra space.',
  ),
  'remove-duplicates-from-sorted-array': MasteryProblemGuide(
    summary: 'Compact a sorted array in place so each value appears once.',
    statement:
        'Given a nondecreasing array, overwrite its prefix so that every distinct value appears once in sorted order. Return the length of that prefix.',
    example: 'values = [1, 1, 2, 2, 4]\nReturn: 3\nKept prefix: [1, 2, 4]',
    edgeCase:
        'An empty array has a kept length of zero; a one-value array is already compact.',
    contractQuestion:
        'Which part of the array is meaningful after the operation, and what does the returned length describe?',
    approachQuestion:
        'How can a write index track the next new value while a read index scans the sorted input?',
    hints: [
      'The sorted order puts duplicates next to each other.',
      'Compare each read value with the last value written.',
      'Write only when the value changes.',
    ],
    explanation:
        'The prefix before the write index contains exactly the distinct values seen so far. Since reads never move behind writes, the array can be compacted in place in O(n) time and O(1) extra space.',
  ),
  'sort-colors': MasteryProblemGuide(
    summary: 'Partition three known values in one pass.',
    statement:
        'Sort an array containing only 0, 1, and 2 in place, without using a comparison sort.',
    example: 'values = [2, 0, 1, 2, 0]\nOutput: [0, 0, 1, 2, 2]',
    edgeCase:
        'The scan can shrink from the right while processing a 2; that swapped-in value has not been examined yet.',
    contractQuestion:
        'What three regions can the array be divided into while scanning?',
    approachQuestion:
        'How can low, scan, and high boundaries keep the 0, 1, and 2 regions ordered?',
    hints: [
      'Counting each value and rewriting is a simple baseline.',
      'Maintain a finished 0 region, unknown region, and finished 2 region.',
      'After swapping a 2 with the right boundary, recheck the incoming value.',
    ],
    explanation:
        'The Dutch-national-flag invariant keeps values before low equal to 0 and values after high equal to 2. The middle region is already known to be 1; scan it once, carefully reprocessing a swapped-in value from the right.',
  ),
  'binary-search': MasteryProblemGuide(
    summary: 'Locate a target in a sorted array in logarithmic time.',
    statement:
        'Given a sorted integer array and a target, return its index when present or -1 otherwise. Aim for logarithmic time.',
    example: 'values = [-4, 0, 5, 9, 13], target = 9\nOutput: 3',
    edgeCase:
        'The target may be absent or at either endpoint; an empty range must terminate safely.',
    contractQuestion:
        'What must remain true about the search interval after each comparison?',
    approachQuestion:
        'Which half can be discarded when the midpoint value is below or above the target?',
    hints: [
      'Use two boundaries around the remaining candidate range.',
      'Calculate a midpoint without adding both endpoints directly.',
      'Update a boundary so the interval gets strictly smaller every iteration.',
    ],
    explanation:
        'The invariant is that any possible target remains inside the active sorted interval. Each midpoint comparison discards half, giving O(log n) time and O(1) extra space.',
  ),
  'first-bad-version': MasteryProblemGuide(
    summary: 'Find the first true value in a monotone yes/no sequence.',
    statement:
        'Versions are numbered from 1 to n. A predicate is false before the first bad version and true from that version onward. Return the first version for which the predicate is true.',
    example: 'n = 6, first bad = 4\nPredicate: F, F, F, T, T, T\nOutput: 4',
    edgeCase:
        'The first bad version may be 1 or n; never assume both a good and bad version are present.',
    contractQuestion:
        'What monotonic property does the bad-version predicate guarantee?',
    approachQuestion:
        'How can you keep the first true version inside a shrinking interval without querying every version?',
    hints: [
      'The answer is a lower boundary, not any true version.',
      'When mid is bad, keep mid as a possible answer and search left.',
      'Use a range convention that still works when only one candidate remains.',
    ],
    explanation:
        'Binary search the first true predicate value. Keeping mid when it is bad preserves the earliest candidate; when it is good, every version through mid can be excluded. The answer is found in O(log n) predicate calls.',
  ),
  'add-two-numbers': MasteryProblemGuide(
    summary: 'Add two integers represented by reverse-order linked digits.',
    statement:
        'Each linked list stores a nonnegative integer one decimal digit per node, least significant digit first. Return a new list representing their sum in the same order.',
    example:
        'first = 2 → 4 → 3 (342)\nsecond = 5 → 6 → 4 (465)\nOutput: 7 → 0 → 8 (807)',
    edgeCase:
        'The lists may have different lengths, and a final carry may create a new node.',
    contractQuestion:
        'Why are the least significant digits visited first, and what does each node represent?',
    approachQuestion:
        'What state is needed to add one pair of digits and pass overflow to the next position?',
    hints: [
      'Use a sentinel node to simplify the result head.',
      'Treat a missing node as digit zero.',
      'Continue while either input remains or carry is nonzero.',
    ],
    explanation:
        'Add corresponding digits plus carry, append sum modulo 10, and carry the quotient. A sentinel simplifies construction. Each node is processed once, so time is O(max(m,n)) and result space is O(max(m,n)).',
  ),
  'copy-list-with-random-pointer': MasteryProblemGuide(
    summary: 'Deep-copy a list whose nodes also have arbitrary links.',
    statement:
        'Each node has a next pointer and a random pointer that may target any node in the list or null. Return a separate list with the same values and pointer relationships.',
    example:
        'For nodes A → B with A.random = B and B.random = A, the copy must contain A′ → B′ with matching cross-links.',
    edgeCase:
        'A random pointer can be null, point to the same node, or point backward; copied pointers must never point into the original list.',
    contractQuestion:
        'What does “deep copy” require for both next and random references?',
    approachQuestion:
        'How can a mapping from each original node to its clone preserve arbitrary links?',
    hints: [
      'Create all clone nodes before assigning random links.',
      'Use an original-to-clone map, or interleave clones temporarily.',
      'Restore the original list if you use the interleaving method.',
    ],
    explanation:
        'A node map gives a direct correspondence for both pointers in two passes. Interleaving clones can reduce auxiliary mapping space but requires careful detachment. In either approach, copied random links must resolve through the clone correspondence.',
  ),
  'min-stack': MasteryProblemGuide(
    summary: 'Design a stack that reports its minimum in constant time.',
    statement:
        'Support push, pop, top, and retrieving the minimum value, each in O(1) time.',
    example: 'push(3), push(1), getMin() → 1, pop(), top() → 3, getMin() → 3',
    edgeCase:
        'The same minimum value may be pushed multiple times; removing one copy must not lose the remaining minimum.',
    contractQuestion:
        'Which stack operations must be constant time, and what should getMin return after a pop?',
    approachQuestion:
        'What extra state can track the minimum corresponding to every stack depth?',
    hints: [
      'A single global minimum fails when the minimum is popped.',
      'Store a minimum alongside each pushed value.',
      'Alternatively store only values that set a new minimum, including duplicates.',
    ],
    explanation:
        'A parallel minimum stack stores the minimum at each depth. Then push, pop, top, and getMin are all O(1); extra space is O(n). Retaining duplicate minima ensures a pop restores the correct value.',
  ),
  'evaluate-reverse-polish-notation': MasteryProblemGuide(
    summary: 'Evaluate an arithmetic expression written in postfix order.',
    statement:
        'Tokens contain integers or binary operators +, -, *, and /. Evaluate the valid reverse-Polish expression and return its integer result.',
    example: 'tokens = ["4", "13", "5", "/", "+"]\nOutput: 6',
    edgeCase:
        'Subtraction and division are not commutative; integer division truncates toward zero.',
    contractQuestion:
        'When an operator appears, which two operands should be removed first from the stack?',
    approachQuestion: 'Why can each token be processed once with a stack?',
    hints: [
      'Push numbers as they appear.',
      'For an operator, pop the right operand before the left operand.',
      'Apply the operator in left/right order and push the result.',
    ],
    explanation:
        'Postfix order places both operands before their operator. A stack holds the unfinished values; each operator combines the top two. Operand order matters for subtraction and division. The evaluation takes O(n) time and O(n) space.',
  ),
  'daily-temperatures': MasteryProblemGuide(
    summary: 'For each day, find how long until a warmer temperature.',
    statement:
        'Given daily temperatures, return for each index the number of days until a strictly warmer day, or zero if none exists later.',
    example: 'temps = [70, 72, 71, 75]\nOutput: [1, 2, 1, 0]',
    edgeCase:
        'Equal temperatures are not warmer, and unresolved days at the end keep answer zero.',
    contractQuestion:
        'Does the next day need to be warmer or merely equal, and what value represents no future answer?',
    approachQuestion:
        'How can a decreasing stack of unresolved day indices be resolved when a warmer day appears?',
    hints: [
      'A nested scan is a baseline but repeats comparisons.',
      'Keep indices whose next warmer day is not known yet.',
      'When current temperature exceeds the stack top, fill that earlier day’s distance.',
    ],
    explanation:
        'The stack holds unresolved indices in nonincreasing temperature order. A warmer current day resolves all smaller temperatures at the top. Every index is pushed and popped once, for O(n) time and O(n) space.',
  ),
  'subsets': MasteryProblemGuide(
    summary: 'Generate every subset of a set of distinct values.',
    statement:
        'Given distinct integers, return the collection of all subsets, including the empty subset and the full set.',
    example: 'values = [4, 7]\nOutput: [[], [4], [7], [4,7]]',
    edgeCase: 'The empty input has exactly one subset: the empty set.',
    contractQuestion:
        'How many subsets should n distinct values produce, and is the empty subset included?',
    approachQuestion:
        'For each value, how can the existing subsets be extended with and without it?',
    hints: [
      'Each value creates a binary include/exclude choice.',
      'A backtracking call can decide one index at a time.',
      'Copy the current selection when all decisions have been made.',
    ],
    explanation:
        'Every element has two independent choices, giving 2^n subsets. Backtracking records a subset at each complete decision path; the total output size is necessarily exponential.',
  ),
  'permutations': MasteryProblemGuide(
    summary: 'Generate every ordering of distinct input values.',
    statement:
        'Given distinct integers, return all possible permutations, with each input value used exactly once in every output.',
    example:
        'values = [1, 2, 3]\nThere are 6 permutations, including [1,2,3] and [3,2,1].',
    edgeCase: 'The empty input has one permutation: the empty ordering.',
    contractQuestion:
        'What makes a partial ordering valid, and when is it complete?',
    approachQuestion:
        'How can a used marker or remaining-choice set prevent reusing a value?',
    hints: [
      'Choose one unused value for the next position.',
      'Recurse, then undo the choice before trying another.',
      'A complete path has the same length as the input.',
    ],
    explanation:
        'Backtracking fills positions by choosing an unused element and undoing the choice afterward. For n distinct values there are n! outputs; time is O(n·n!) when copying each result.',
  ),
  'kth-largest-element-in-an-array': MasteryProblemGuide(
    summary: 'Select the k-th value in descending order without fully sorting.',
    statement:
        'Given an unsorted integer array and valid k, return the element that would occupy position k when values are ordered from largest to smallest.',
    example: 'values = [3, 1, 5, 2, 4], k = 2\nOutput: 4',
    edgeCase:
        'Repeated values occupy repeated ranks; selection is by position in sorted order, not distinct value.',
    contractQuestion:
        'How do duplicates contribute to rank, and is k one-based?',
    approachQuestion:
        'Would a bounded heap or partition-based selection fit the input and expected complexity?',
    hints: [
      'Sorting gives a simple O(n log n) baseline.',
      'A min-heap of size k keeps only the k largest values seen.',
      'The heap root is the smallest among those retained k values.',
    ],
    explanation:
        'A size-k min-heap maintains the k largest values seen so far; its root is the k-th largest. This takes O(n log k) time and O(k) space. Quickselect can be expected O(n) with in-place partitioning.',
  ),
  'rotting-oranges': MasteryProblemGuide(
    summary:
        'Find how many simultaneous time steps are needed for infection to spread on a grid.',
    statement:
        'In a grid, empty cells stay empty, fresh cells become rotten when adjacent to a rotten cell, and all changes in a minute happen simultaneously. Return the minutes until no fresh orange remains, or -1 if some can never be reached.',
    example: 'grid = [[2,1,1],[1,1,0],[0,1,1]]\nOutput: 4',
    edgeCase:
        'If there are no fresh cells initially, return zero; isolated fresh cells make completion impossible.',
    contractQuestion:
        'Which cells are adjacent, and why must one minute process a full current frontier together?',
    approachQuestion:
        'How can multi-source BFS start from every initially rotten cell at time zero?',
    hints: [
      'Count fresh cells and enqueue all rotten cells first.',
      'Process the queue in layers so each layer represents one minute.',
      'Return elapsed layers only if the fresh count reaches zero.',
    ],
    explanation:
        'Multi-source BFS expands one layer per minute from all rotten cells. Decrement the fresh count only when a fresh neighbor is first infected. The result is the final layer count, zero for no fresh cells, or -1 if fresh cells remain.',
  ),
  'course-schedule-ii': MasteryProblemGuide(
    summary: 'Return a valid order that respects course prerequisites.',
    statement:
        'Given course IDs and prerequisite pairs, return any ordering that places every prerequisite before its dependent course. Return an empty list if no such ordering exists.',
    example:
        'courses = 3, prerequisites = [[1,0],[2,0]]\nOne valid output: [0,1,2]',
    edgeCase:
        'A directed cycle makes completion impossible; courses with no dependencies still belong in the order.',
    contractQuestion:
        'Which direction should each prerequisite edge point, and what output signals a cycle?',
    approachQuestion:
        'How can indegrees and a queue produce a topological ordering?',
    hints: [
      'Build adjacency lists and count incoming prerequisite edges.',
      'Start with every course whose indegree is zero.',
      'If fewer than all courses are emitted, a cycle remains.',
    ],
    explanation:
        'Kahn’s algorithm repeatedly emits a zero-indegree course and removes its outgoing edges. The order is valid by construction. If fewer than n nodes are emitted, the graph contains a cycle. Time and space are O(V+E).',
  ),
  'continuous-subarray-sum': _guide(
    'Detect a length-two-or-more range whose sum is divisible by k.',
    'Given integers and a nonzero divisor k, decide whether a contiguous range of at least two elements has a sum that is a multiple of k.',
    'values = [23, 2, 4, 6, 7], k = 6\nOutput: true\nThe range [2,4] sums to 6.',
    'A one-element range never qualifies. Zero-sum ranges also qualify when the divisor is nonzero.',
    'What minimum range length is required, and does “multiple” include a sum of zero?',
    'Which prefix remainder must repeat for the intervening sum to be divisible by k?',
    [
      'Track prefix sums modulo k.',
      'Remember the earliest index for each remainder.',
      'Accept a repeated remainder only when the indices are at least two apart.',
    ],
    'Equal prefix remainders imply their difference is divisible by k. Keeping the earliest index maximizes the range length; check the required distance. This is O(n) time and O(min(n,|k|)) stored remainders.',
  ),
  'first-missing-positive': _guide(
    'Find the smallest positive integer absent from an unsorted array.',
    'Given an unsorted integer array, return the smallest positive integer that does not occur in it, using linear time and constant extra space.',
    'values = [3, 4, -1, 1]\nOutput: 2',
    'Values at or below zero and values larger than the array length cannot be the answer.',
    'Why must the answer lie between 1 and n+1 for an array of length n?',
    'Can each in-range value be placed at the index matching its value?',
    [
      'Ignore values outside 1..n.',
      'Swap a value x toward index x-1 while that target does not already contain x.',
      'The first index i not holding i+1 identifies the answer.',
    ],
    'In-place cyclic placement puts every present value x in slot x-1. The first mismatch reveals the smallest missing positive; if all n slots match, return n+1. Runtime is O(n) because each successful swap places a value permanently.',
  ),
  'find-the-duplicate-number': _guide(
    'Find the repeated value while preserving the input and using constant space.',
    'The array has n+1 values drawn from 1..n, so at least one value repeats. Return a duplicate without modifying the array or using extra storage proportional to n.',
    'values = [1, 3, 4, 2, 2]\nOutput: 2',
    'There may be more than one repeated occurrence; the task asks for a repeated value, not its positions.',
    'How can the value range and array length be viewed as a functional graph?',
    'What does Floyd cycle detection find if each array value points to the next index?',
    [
      'Treat index i as pointing to values[i].',
      'The duplicate creates a cycle in this linked traversal.',
      'Use slow/fast pointers, then reset one pointer to find the cycle entrance.',
    ],
    'Following values creates a functional graph with a cycle whose entrance corresponds to a repeated value. Floyd’s algorithm finds that entrance in O(n) time and O(1) space without changing the array.',
  ),
  '4sum': _guide(
    'Find unique quadruplets whose values sum to a target.',
    'Return every distinct value quadruplet from the input whose four values sum to target. The output must not repeat the same value combination.',
    'values = [1, 0, -1, 0, -2, 2], target = 0\nExample outputs include [-2,-1,1,2] and [-2,0,0,2].',
    'Duplicate input values can create repeated index choices but should not duplicate value quadruplets.',
    'How will sorting make both duplicate skipping and the remaining two-value search easier?',
    'After fixing two values, what pointer rule follows from the sorted two-pointer sum?',
    [
      'Sort once, then choose the first two positions.',
      'Use two pointers for the remaining pair.',
      'Skip equal choices at each fixed position and after recording a match.',
    ],
    'Sorting enables O(n^3) enumeration with a linear two-pointer inner scan. Skipping equal fixed values and equal matched endpoints prevents duplicate quadruplets; use a wider sum type if input bounds require it.',
  ),
  'next-permutation': _guide(
    'Transform a sequence into its next lexicographic ordering in place.',
    'Rearrange the values into the smallest ordering that is strictly larger lexicographically. If no larger ordering exists, rearrange to the smallest ordering.',
    'values = [1, 3, 2]\nOutput: [2, 1, 3]',
    'A fully nonincreasing sequence is the final ordering and must wrap to ascending order.',
    'What suffix property tells you the sequence has reached its last permutation?',
    'How can the rightmost ascent locate the smallest change that makes the sequence larger?',
    [
      'Scan from the right to find the first index i with values[i] < values[i+1].',
      'Swap it with the rightmost larger value.',
      'Reverse the suffix, which is already in descending order.',
    ],
    'The suffix after the rightmost ascent is descending. Swapping the pivot with the smallest larger suffix value and reversing the suffix creates the next lexicographic sequence. The work is O(n) time and O(1) extra space.',
  ),
  'search-a-2d-matrix': _guide(
    'Search a row-major sorted matrix without scanning every cell.',
    'Each matrix row is sorted, and each row begins after the previous row ends. Return whether target occurs in the matrix.',
    'matrix = [[1, 4, 7], [10, 13, 18]], target = 13\nOutput: true',
    'An empty matrix or empty row contains no target.',
    'How can the matrix be treated as one sorted sequence of rows × columns elements?',
    'Which row and column correspond to a virtual one-dimensional midpoint?',
    [
      'Binary-search indices from 0 to rows*columns-1.',
      'Map index mid to row mid/columns and column mid%columns.',
      'Guard empty dimensions before computing bounds.',
    ],
    'The row-order guarantee makes the flattened matrix globally sorted. Binary search uses O(log(rows·columns)) time and O(1) space; the index mapping avoids allocating a flattened copy.',
  ),
  'find-first-and-last-position-of-element-in-sorted-array': _guide(
    'Return the inclusive boundaries of a target’s run in a sorted array.',
    'Given a sorted array that may contain duplicates, return the first and last target indices, or [-1,-1] when the target is absent.',
    'values = [1, 2, 2, 2, 5], target = 2\nOutput: [1, 3]',
    'The target may occur once, many times, at either edge, or not at all.',
    'Why are two boundary searches more reliable than expanding from an arbitrary match?',
    'How do lower-bound and upper-bound searches differ when mid equals target?',
    [
      'Find the first index whose value is at least target.',
      'Find the first index whose value is greater than target.',
      'Verify the lower bound is in range and equals target.',
    ],
    'Two binary searches find the lower bound and the first value greater than target. The last target is one position before the upper bound. Runtime is O(log n), with constant extra space.',
  ),
  'koko-eating-bananas': _guide(
    'Find the minimum integer processing rate that meets a deadline.',
    'Each pile is processed by one worker at a fixed positive integer rate; a partially processed pile still consumes a whole hour. Return the smallest rate that finishes all piles within h hours.',
    'piles = [3, 6, 7, 11], h = 8\nOutput: 4',
    'The slowest possible rate is 1; the fastest useful rate is the largest pile size.',
    'As the rate increases, can the required number of hours ever increase?',
    'What feasibility check lets binary search search over candidate rates?',
    [
      'The answer lies between 1 and max(piles).',
      'For rate r, sum ceil(pile/r) hours.',
      'Keep a rate if total hours are at most h; otherwise search faster.',
    ],
    'The required hours are monotone nonincreasing with rate. Binary-search the first feasible rate; each check is O(n), for O(n log maxPile) time and O(1) extra space.',
  ),
  'swap-nodes-in-pairs': _guide(
    'Swap adjacent linked-list nodes by relinking them.',
    'Given a singly linked list, swap each neighboring pair and return the new head. Node values must remain attached to their original nodes.',
    'list = 1 → 2 → 3 → 4 → 5\nOutput: 2 → 1 → 4 → 3 → 5',
    'An odd final node has no partner and remains in place; a one-node list is unchanged.',
    'Why must this operation change links rather than simply exchange values?',
    'What references connect the node before a pair, the pair itself, and the remaining suffix?',
    [
      'Use a sentinel before the head.',
      'Save the first node, second node, and suffix before rewiring.',
      'Reconnect the previous pair tail to the new pair head.',
    ],
    'A sentinel handles swapping the original head. For each pair, connect predecessor→second→first→suffix, then advance predecessor to first. Every link is changed once: O(n) time and O(1) space.',
  ),
  'reverse-nodes-in-k-group': _guide(
    'Reverse complete groups of k linked nodes while preserving a short tail.',
    'Reverse each consecutive group of exactly k nodes. If fewer than k nodes remain at the end, leave that suffix in its original order.',
    'list = 1 → 2 → 3 → 4 → 5, k = 2\nOutput: 2 → 1 → 4 → 3 → 5',
    'Do not reverse a final group with fewer than k nodes.',
    'How can you confirm a full group exists before changing any of its links?',
    'Which node becomes the group tail after reversal, and where should it point?',
    [
      'Use a sentinel and find the kth node from the group predecessor.',
      'Save the node after the group before reversing.',
      'Reverse links only after the group is known to be complete.',
    ],
    'Find each complete group boundary first, reverse links within that segment, then connect the old head (new tail) to the saved suffix. Each node is processed once; iterative reversal uses O(1) extra space.',
  ),
  'balanced-binary-tree': _guide(
    'Check whether every subtree has heights differing by at most one.',
    'A binary tree is height-balanced if at every node the left and right subtree heights differ by no more than one. Return whether the whole tree satisfies that rule.',
    'A root with left and right leaf children is balanced. A chain of three nodes is not.',
    'A locally balanced root can still contain an unbalanced deeper subtree.',
    'What information can one postorder traversal return to detect failure below and compute height above?',
    'How can a sentinel height represent an already-unbalanced subtree?',
    [
      'Compute child heights after visiting both children.',
      'Return an unbalanced marker immediately when a child fails.',
      'Otherwise return one plus the larger child height.',
    ],
    'Postorder computes each subtree height once. Return a sentinel on imbalance and propagate it upward; this avoids repeated height scans and runs in O(n) time with O(h) recursion space.',
  ),
  'diameter-of-binary-tree': _guide(
    'Find the longest path between any two nodes in a binary tree.',
    'Return the maximum number of edges on a path between any two nodes. The path need not pass through the root.',
    'For a root with left and right two-edge branches, the diameter is 4 edges.',
    'A one-node tree has diameter zero; the longest path may lie entirely inside one subtree.',
    'What child information lets a node compute both its height and a path passing through it?',
    'How can the best global diameter be updated while returning only height to the parent?',
    [
      'Use a postorder height function.',
      'At each node, combine left height + right height as an edge count.',
      'Return one plus the larger height to the parent.',
    ],
    'A postorder traversal returns subtree height while updating the best left-height plus right-height path at every node. Each node is visited once: O(n) time and O(h) recursion space.',
  ),
  'path-sum-iii': _guide(
    'Count downward paths that total a target, starting at any node.',
    'Count paths that follow parent-to-child links and sum to target. A path may start and end anywhere, but it cannot move upward.',
    'For root 10 with children 5 and -3, target 7 has path 10→-3 only if values sum to 7; trace each downward path from each start.',
    'Values may be negative, so a running sum above target can later decrease back to it.',
    'How can prefix sums along the current root path count paths ending at this node?',
    'Which earlier prefix value would leave a suffix sum equal to target?',
    [
      'Maintain frequencies of prefix sums on the active DFS path.',
      'At running sum s, add frequency[s-target].',
      'Remove s from the map when backtracking to the parent.',
    ],
    'For each node, prior prefix s-target identifies a downward path ending here. The map must represent only the current root-to-node path, so decrement on backtracking. Expected O(n) time and O(h) active state.',
  ),
  'subsets-ii': _guide(
    'Generate unique subsets when input values can repeat.',
    'Return every distinct subset of a multiset of integers. The input may contain duplicates, but equal value selections should appear only once.',
    'values = [1, 2, 2]\nThere are 6 distinct subsets.',
    'Repeated equal values at the same decision depth must not create duplicate branches.',
    'How does sorting make equal choices adjacent, and at which recursion depth should duplicates be skipped?',
    'Why is it valid to skip an equal value only when its previous copy was not chosen at this depth?',
    [
      'Sort the values first.',
      'At each recursion level, skip a value equal to the previous value.',
      'Do not globally forbid choosing both equal copies in the same subset.',
    ],
    'Sorting groups equal values. Skipping duplicates among sibling choices removes repeated subsets while still allowing multiple copies along one branch. Backtracking output size is exponential in input length.',
  ),
  'combination-sum-ii': _guide(
    'Find unique value combinations that use each candidate at most once.',
    'Return unique combinations of positive candidate values that sum to target. Each input position can be used at most once; equal values may occur at different positions.',
    'candidates = [1, 1, 2, 5], target = 3\nOutput: [[1, 2]]',
    'Do not reuse a candidate position; duplicate values must not duplicate the same output combination.',
    'How do sorting and advancing the recursive start index enforce uniqueness and one-use choices?',
    'When should a repeated value be skipped, and how does the next recursion avoid reusing it?',
    [
      'Sort candidates and carry a start index.',
      'After choosing index i, recurse from i+1.',
      'Skip equal siblings at the same depth; stop when a sorted value exceeds the remaining sum.',
    ],
    'Sorting enables sibling duplicate pruning and early termination. Recursing from i+1 enforces one-use positions. Each path builds a combination without regard to order, preventing permutation duplicates.',
  ),
  'k-closest-points-to-origin': _guide(
    'Select the k points with the smallest squared distance to the origin.',
    'Given 2D points, return any k points with minimum Euclidean distance to (0,0). Ties may be returned in any order.',
    'points = [[1,3],[-2,2],[2,-2]], k = 2\nOne valid output: [[-2,2],[2,-2]]',
    'Equal distances are allowed; compare squared distances to avoid unnecessary square roots.',
    'When should a size-k max-heap retain the closest points seen so far?',
    'What should the heap root represent so it is the first candidate to evict?',
    [
      'Use x*x + y*y as the ordering key.',
      'Keep a max-heap of at most k selected points.',
      'If a new point is closer than the farthest retained point, replace the root.',
    ],
    'A max-heap keeps the k smallest distances while exposing the farthest selected point for eviction. This is O(n log k) time and O(k) extra space; quickselect can improve expected time.',
  ),
  'task-scheduler': _guide(
    'Schedule repeated task types with a required cooldown between equal types.',
    'Each task takes one unit of time. Identical task types need at least n idle or task slots between executions. Return the minimum total schedule length.',
    'tasks = [A,A,A,B,B,B], cooldown = 2\nOutput: 8',
    'A schedule may end with no idle slots if the final task blocks are filled by other types.',
    'Which frequency creates the schedule lower bound, and how can other tasks fill its cooldown gaps?',
    'How many gaps exist between the most frequent task’s occurrences?',
    [
      'Count each task type.',
      'The maximum frequency determines the number of frames.',
      'Compare the frame length with total task count; the answer cannot be smaller than either.',
    ],
    'If f tasks share the maximum count and there are m such task types, the frame lower bound is (f-1)(n+1)+m. The answer is max(taskCount, frameBound), since other tasks fill gaps whenever possible.',
  ),
  'max-area-of-island': _guide(
    'Find the largest connected land component in a binary grid.',
    'Land cells connect orthogonally. Return the number of cells in the largest connected land region, or zero when the grid has no land.',
    'grid = [[1,1,0],[0,1,0],[1,0,1]]\nOutput: 3',
    'Diagonal contact does not connect land. Mark a cell visited before exploring neighbors to avoid counting it twice.',
    'What counts as adjacency, and where should visited state be recorded?',
    'How can a DFS or BFS return one component’s cell count while preventing revisits?',
    [
      'Scan every cell as a possible component start.',
      'For each unvisited land cell, traverse its component.',
      'Track the maximum component size.',
    ],
    'Each land cell is visited once and contributes one to exactly one component size. Orthogonal traversal takes O(rows·columns) time and O(rows·columns) worst-case state.',
  ),
  'redundant-connection': _guide(
    'Find the edge that first closes a cycle in a nearly-tree undirected graph.',
    'The graph began as a tree with one additional edge. Return an input edge whose removal restores a tree; when multiple choices exist, return the last valid edge in input order.',
    'edges = [[1,2],[1,3],[2,3]]\nOutput: [2,3]',
    'The graph is connected and has exactly one extra edge; edge order determines which cycle-closing edge to report.',
    'What does it mean for an edge’s endpoints to already be connected before that edge is added?',
    'How can disjoint-set union detect the first edge that joins one component to itself?',
    [
      'Initialize each label in its own set.',
      'For each edge, compare the roots of its endpoints.',
      'If the roots match, that edge is redundant; otherwise union the sets.',
    ],
    'A DSU maintains connected components as edges are processed. An edge whose endpoints already share a root closes a cycle. With path compression and union by rank, operations are near-constant amortized time.',
  ),
};

String _patternCue(String pattern) => switch (pattern) {
  'Arrays & hashing' => 'counting, prefix state, or indexed lookup',
  'Two pointers' => 'coordinated scans with a pointer invariant',
  'Sliding window' => 'a window whose validity changes as it moves',
  'Binary search' => 'a monotone boundary or search space',
  'Linked lists' => 'pointer invariants and careful rewiring',
  'Stacks' => 'deferred decisions or a monotonic boundary stack',
  'Trees' => 'recursive state or level-by-level traversal',
  'Tries' => 'prefix-indexed branching',
  'Backtracking' => 'a reversible choice tree with pruning',
  'Heaps' => 'maintaining the next smallest or largest candidate',
  'Graphs' => 'visited-state traversal or dependency modeling',
  'Advanced graphs' => 'connectivity, shortest paths, or graph ordering',
  '1-D dynamic programming' => 'a state and transition over a prefix',
  '2-D dynamic programming' => 'a state and transition over two dimensions',
  'Greedy' => 'a locally optimal choice with a correctness argument',
  'Intervals' => 'ordered boundaries and overlap rules',
  'Bit manipulation' => 'compact bit state and bitwise invariants',
  _ => 'numeric or geometric structure and boundary reasoning',
};

List<String> _patternHints(String pattern) => switch (pattern) {
  'Arrays & hashing' => const [
    'Identify what information about earlier values would prevent rescanning.',
    'Try storing counts or a prefix summary keyed by value.',
    'State what each map entry means before updating it.',
  ],
  'Two pointers' => const [
    'Choose what each pointer represents and where the scan begins.',
    'Decide which pointer can move without losing a possible answer.',
    'Write the invariant that remains true after each move.',
  ],
  'Sliding window' => const [
    'Define the window and the condition that makes it valid.',
    'Track only the counts or totals needed to test validity.',
    'Explain when to expand and when to shrink the window.',
  ],
  'Binary search' => const [
    'Find the property that changes monotonically across the search space.',
    'Define a half-open or closed range and keep it consistent.',
    'Check progress and termination on a two-element range.',
  ],
  'Linked lists' => const [
    'Draw nodes and arrows before changing links.',
    'Use a sentinel node if head updates complicate the cases.',
    'Track which pointers must be saved before rewiring.',
  ],
  'Stacks' => const [
    'Ask whether an earlier item must wait for a future item to resolve it.',
    'Keep unresolved indices or values in a stack.',
    'State the order preserved by the stack and when entries are removed.',
  ],
  'Trees' => const [
    'Decide what each recursive call returns to its parent.',
    'Separate information passed downward from results combined upward.',
    'Check null nodes, one-child nodes, and the root boundary.',
  ],
  'Tries' => const [
    'Represent shared prefixes once and mark complete words explicitly.',
    'Define the node state needed for lookup or deletion.',
    'Account for total inserted characters, not only word count.',
  ],
  'Backtracking' => const [
    'Define the choice, stopping condition, and invalid partial states.',
    'Make one choice, recurse, then undo exactly that choice.',
    'Check whether ordering or duplicate choices create repeated answers.',
  ],
  'Heaps' => const [
    'Identify which candidates must remain available at each step.',
    'Choose a min-heap or max-heap and justify its size.',
    'State the cost of each insertion and removal.',
  ],
  'Graphs' => const [
    'Model the input as nodes and edges before selecting traversal.',
    'Mark nodes when enqueued or first discovered to avoid repeats.',
    'For shortest unweighted paths, process the queue by layers.',
  ],
  'Advanced graphs' => const [
    'Identify whether the task is connectivity, ordering, or weighted distance.',
    'Choose union-find, topological order, or a shortest-path algorithm accordingly.',
    'State the invariant that prevents revisiting or finalizing the wrong state.',
  ],
  '1-D dynamic programming' => const [
    'Define dp[i] in one sentence before writing a recurrence.',
    'Write the transition from smaller states and identify base cases.',
    'Check whether the previous states can be compressed to constant space.',
  ],
  '2-D dynamic programming' => const [
    'Name what the two indices represent.',
    'Write transitions from smaller prefixes or subproblems.',
    'Check row/column initialization and iteration direction.',
  ],
  'Greedy' => const [
    'Propose the local choice and test it against a small counterexample.',
    'Sort or track the boundary that makes the choice efficient.',
    'Explain why exchanging a different choice cannot improve the result.',
  ],
  'Intervals' => const [
    'Sort by the boundary that makes a single forward pass possible.',
    'Clarify whether touching endpoints count as overlap.',
    'Track the current merged or selected interval boundary.',
  ],
  'Bit manipulation' => const [
    'Write a small binary example and identify the relevant bit operation.',
    'Use masks to isolate, toggle, or combine only the required bits.',
    'Check sign, zero, and shift-width behavior in your language.',
  ],
  _ => const [
    'Reduce the task to a precise numeric relation or coordinate invariant.',
    'Check overflow, sign, precision, and degenerate geometry cases.',
    'Compare the direct formula with a small hand-worked example.',
  ],
};

/// 225 interview-relevant extensions chosen to balance the 18 target families.
/// Titles and links identify external challenges; all coaching copy is original.
const mastery300Seeds = <MasteryProblemSeed>[
  // Arrays and hashing (20)
  MasteryProblemSeed('Ransom Note', 'ransom-note', 'Arrays & hashing', 'Easy'),
  MasteryProblemSeed(
    'Majority Element',
    'majority-element',
    'Arrays & hashing',
    'Easy',
  ),
  MasteryProblemSeed(
    'Subarray Sum Equals K',
    'subarray-sum-equals-k',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Continuous Subarray Sum',
    'continuous-subarray-sum',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Longest Well-Performing Interval',
    'longest-well-performing-interval',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'First Missing Positive',
    'first-missing-positive',
    'Arrays & hashing',
    'Hard',
  ),
  MasteryProblemSeed(
    'Find the Duplicate Number',
    'find-the-duplicate-number',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Set Mismatch',
    'set-mismatch',
    'Arrays & hashing',
    'Easy',
  ),
  MasteryProblemSeed(
    'Find All Duplicates in an Array',
    'find-all-duplicates-in-an-array',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Top K Frequent Words',
    'top-k-frequent-words',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Design HashMap',
    'design-hashmap',
    'Arrays & hashing',
    'Easy',
  ),
  MasteryProblemSeed(
    'Range Sum Query - Immutable',
    'range-sum-query-immutable',
    'Arrays & hashing',
    'Easy',
  ),
  MasteryProblemSeed(
    'Maximum Size Subarray Sum Equals k',
    'maximum-size-subarray-sum-equals-k',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Subarray Sums Divisible by K',
    'subarray-sums-divisible-by-k',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Product of the Last K Numbers',
    'product-of-the-last-k-numbers',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Insert Delete GetRandom O(1)',
    'insert-delete-getrandom-o1',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Random Pick with Weight',
    'random-pick-with-weight',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed(
    'Majority Element II',
    'majority-element-ii',
    'Arrays & hashing',
    'Medium',
  ),
  MasteryProblemSeed('Brick Wall', 'brick-wall', 'Arrays & hashing', 'Medium'),
  MasteryProblemSeed(
    'Minimum Index of a Valid Split',
    'minimum-index-of-a-valid-split',
    'Arrays & hashing',
    'Medium',
  ),
  // Two pointers (10)
  MasteryProblemSeed(
    'Two Sum II - Input Array Is Sorted',
    'two-sum-ii-input-array-is-sorted',
    'Two pointers',
    'Medium',
  ),
  MasteryProblemSeed(
    'Remove Duplicates from Sorted Array',
    'remove-duplicates-from-sorted-array',
    'Two pointers',
    'Easy',
  ),
  MasteryProblemSeed(
    'Remove Element',
    'remove-element',
    'Two pointers',
    'Easy',
  ),
  MasteryProblemSeed('Sort Colors', 'sort-colors', 'Two pointers', 'Medium'),
  MasteryProblemSeed('4Sum', '4sum', 'Two pointers', 'Medium'),
  MasteryProblemSeed(
    'Next Permutation',
    'next-permutation',
    'Two pointers',
    'Medium',
  ),
  MasteryProblemSeed(
    'Partition Labels',
    'partition-labels',
    'Two pointers',
    'Medium',
  ),
  MasteryProblemSeed(
    'Boats to Save People',
    'boats-to-save-people',
    'Two pointers',
    'Medium',
  ),
  MasteryProblemSeed('Move Zeroes', 'move-zeroes', 'Two pointers', 'Easy'),
  MasteryProblemSeed(
    'Valid Triangle Number',
    'valid-triangle-number',
    'Two pointers',
    'Medium',
  ),
  // Sliding window (8)
  MasteryProblemSeed(
    'Find All Anagrams in a String',
    'find-all-anagrams-in-a-string',
    'Sliding window',
    'Medium',
  ),
  MasteryProblemSeed(
    'Permutation in String',
    'permutation-in-string',
    'Sliding window',
    'Medium',
  ),
  MasteryProblemSeed(
    'Max Consecutive Ones III',
    'max-consecutive-ones-iii',
    'Sliding window',
    'Medium',
  ),
  MasteryProblemSeed(
    'Fruit Into Baskets',
    'fruit-into-baskets',
    'Sliding window',
    'Medium',
  ),
  MasteryProblemSeed(
    'Longest Subarray of 1s After Deleting One Element',
    'longest-subarray-of-1s-after-deleting-one-element',
    'Sliding window',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximum Average Subarray I',
    'maximum-average-subarray-i',
    'Sliding window',
    'Easy',
  ),
  MasteryProblemSeed(
    'Minimum Size Subarray Sum',
    'minimum-size-subarray-sum',
    'Sliding window',
    'Medium',
  ),
  MasteryProblemSeed(
    'Subarrays with K Different Integers',
    'subarrays-with-k-different-integers',
    'Sliding window',
    'Hard',
  ),
  // Binary search (12)
  MasteryProblemSeed('Binary Search', 'binary-search', 'Binary search', 'Easy'),
  MasteryProblemSeed(
    'First Bad Version',
    'first-bad-version',
    'Binary search',
    'Easy',
  ),
  MasteryProblemSeed(
    'Search a 2D Matrix',
    'search-a-2d-matrix',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Search in Rotated Sorted Array II',
    'search-in-rotated-sorted-array-ii',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Time Based Key-Value Store',
    'time-based-key-value-store',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Find First and Last Position of Element in Sorted Array',
    'find-first-and-last-position-of-element-in-sorted-array',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Find Peak Element',
    'find-peak-element',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Koko Eating Bananas',
    'koko-eating-bananas',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Capacity To Ship Packages Within D Days',
    'capacity-to-ship-packages-within-d-days',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Median of Two Sorted Arrays',
    'median-of-two-sorted-arrays',
    'Binary search',
    'Hard',
  ),
  MasteryProblemSeed(
    'Find K Closest Elements',
    'find-k-closest-elements',
    'Binary search',
    'Medium',
  ),
  MasteryProblemSeed(
    'Split Array Largest Sum',
    'split-array-largest-sum',
    'Binary search',
    'Hard',
  ),
  // Linked lists (10)
  MasteryProblemSeed(
    'Add Two Numbers',
    'add-two-numbers',
    'Linked lists',
    'Medium',
  ),
  MasteryProblemSeed(
    'Copy List with Random Pointer',
    'copy-list-with-random-pointer',
    'Linked lists',
    'Medium',
  ),
  MasteryProblemSeed(
    'Intersection of Two Linked Lists',
    'intersection-of-two-linked-lists',
    'Linked lists',
    'Easy',
  ),
  MasteryProblemSeed(
    'Palindrome Linked List',
    'palindrome-linked-list',
    'Linked lists',
    'Easy',
  ),
  MasteryProblemSeed(
    'Swap Nodes in Pairs',
    'swap-nodes-in-pairs',
    'Linked lists',
    'Medium',
  ),
  MasteryProblemSeed(
    'Reverse Nodes in k-Group',
    'reverse-nodes-in-k-group',
    'Linked lists',
    'Hard',
  ),
  MasteryProblemSeed('Rotate List', 'rotate-list', 'Linked lists', 'Medium'),
  MasteryProblemSeed('Sort List', 'sort-list', 'Linked lists', 'Medium'),
  MasteryProblemSeed(
    'Remove Duplicates from Sorted List II',
    'remove-duplicates-from-sorted-list-ii',
    'Linked lists',
    'Medium',
  ),
  MasteryProblemSeed(
    'Flatten a Multilevel Doubly Linked List',
    'flatten-a-multilevel-doubly-linked-list',
    'Linked lists',
    'Medium',
  ),
  // Stacks (12)
  MasteryProblemSeed('Min Stack', 'min-stack', 'Stacks', 'Medium'),
  MasteryProblemSeed(
    'Evaluate Reverse Polish Notation',
    'evaluate-reverse-polish-notation',
    'Stacks',
    'Medium',
  ),
  MasteryProblemSeed(
    'Daily Temperatures',
    'daily-temperatures',
    'Stacks',
    'Medium',
  ),
  MasteryProblemSeed(
    'Next Greater Element II',
    'next-greater-element-ii',
    'Stacks',
    'Medium',
  ),
  MasteryProblemSeed(
    'Largest Rectangle in Histogram',
    'largest-rectangle-in-histogram',
    'Stacks',
    'Hard',
  ),
  MasteryProblemSeed(
    'Asteroid Collision',
    'asteroid-collision',
    'Stacks',
    'Medium',
  ),
  MasteryProblemSeed('Decode String', 'decode-string', 'Stacks', 'Medium'),
  MasteryProblemSeed('Basic Calculator', 'basic-calculator', 'Stacks', 'Hard'),
  MasteryProblemSeed('Remove K Digits', 'remove-k-digits', 'Stacks', 'Medium'),
  MasteryProblemSeed(
    'Online Stock Span',
    'online-stock-span',
    'Stacks',
    'Medium',
  ),
  MasteryProblemSeed('132 Pattern', '132-pattern', 'Stacks', 'Medium'),
  MasteryProblemSeed(
    'Sum of Subarray Minimums',
    'sum-of-subarray-minimums',
    'Stacks',
    'Medium',
  ),
  // Trees (20)
  MasteryProblemSeed(
    'Balanced Binary Tree',
    'balanced-binary-tree',
    'Trees',
    'Easy',
  ),
  MasteryProblemSeed(
    'Diameter of Binary Tree',
    'diameter-of-binary-tree',
    'Trees',
    'Easy',
  ),
  MasteryProblemSeed(
    'Binary Tree Right Side View',
    'binary-tree-right-side-view',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Binary Tree Zigzag Level Order Traversal',
    'binary-tree-zigzag-level-order-traversal',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed('Path Sum', 'path-sum', 'Trees', 'Easy'),
  MasteryProblemSeed('Path Sum II', 'path-sum-ii', 'Trees', 'Medium'),
  MasteryProblemSeed('Path Sum III', 'path-sum-iii', 'Trees', 'Medium'),
  MasteryProblemSeed(
    'Lowest Common Ancestor of a Binary Tree',
    'lowest-common-ancestor-of-a-binary-tree',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Convert Sorted Array to Binary Search Tree',
    'convert-sorted-array-to-binary-search-tree',
    'Trees',
    'Easy',
  ),
  MasteryProblemSeed(
    'Delete Node in a BST',
    'delete-node-in-a-bst',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Construct Binary Tree from Inorder and Postorder Traversal',
    'construct-binary-tree-from-inorder-and-postorder-traversal',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Populating Next Right Pointers in Each Node',
    'populating-next-right-pointers-in-each-node',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Flatten Binary Tree to Linked List',
    'flatten-binary-tree-to-linked-list',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Count Good Nodes in Binary Tree',
    'count-good-nodes-in-binary-tree',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Find Duplicate Subtrees',
    'find-duplicate-subtrees',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximum Width of Binary Tree',
    'maximum-width-of-binary-tree',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Recover Binary Search Tree',
    'recover-binary-search-tree',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'All Nodes Distance K in Binary Tree',
    'all-nodes-distance-k-in-binary-tree',
    'Trees',
    'Medium',
  ),
  MasteryProblemSeed(
    'Binary Tree Cameras',
    'binary-tree-cameras',
    'Trees',
    'Hard',
  ),
  MasteryProblemSeed(
    'Maximum Difference Between Node and Ancestor',
    'maximum-difference-between-node-and-ancestor',
    'Trees',
    'Medium',
  ),
  // Tries (4)
  MasteryProblemSeed('Replace Words', 'replace-words', 'Tries', 'Medium'),
  MasteryProblemSeed('Map Sum Pairs', 'map-sum-pairs', 'Tries', 'Medium'),
  MasteryProblemSeed(
    'Prefix and Suffix Search',
    'prefix-and-suffix-search',
    'Tries',
    'Hard',
  ),
  MasteryProblemSeed(
    'Longest Word in Dictionary',
    'longest-word-in-dictionary',
    'Tries',
    'Medium',
  ),
  // Backtracking (12)
  MasteryProblemSeed('Subsets', 'subsets', 'Backtracking', 'Medium'),
  MasteryProblemSeed('Subsets II', 'subsets-ii', 'Backtracking', 'Medium'),
  MasteryProblemSeed('Permutations', 'permutations', 'Backtracking', 'Medium'),
  MasteryProblemSeed(
    'Permutations II',
    'permutations-ii',
    'Backtracking',
    'Medium',
  ),
  MasteryProblemSeed(
    'Combination Sum II',
    'combination-sum-ii',
    'Backtracking',
    'Medium',
  ),
  MasteryProblemSeed(
    'Palindrome Partitioning',
    'palindrome-partitioning',
    'Backtracking',
    'Medium',
  ),
  MasteryProblemSeed('N-Queens', 'n-queens', 'Backtracking', 'Hard'),
  MasteryProblemSeed(
    'Restore IP Addresses',
    'restore-ip-addresses',
    'Backtracking',
    'Medium',
  ),
  MasteryProblemSeed(
    'Generate Parentheses',
    'generate-parentheses',
    'Backtracking',
    'Medium',
  ),
  MasteryProblemSeed(
    'Letter Combinations of a Phone Number',
    'letter-combinations-of-a-phone-number',
    'Backtracking',
    'Medium',
  ),
  MasteryProblemSeed(
    'Expression Add Operators',
    'expression-add-operators',
    'Backtracking',
    'Hard',
  ),
  MasteryProblemSeed(
    'Matchsticks to Square',
    'matchsticks-to-square',
    'Backtracking',
    'Medium',
  ),
  // Heaps (10)
  MasteryProblemSeed(
    'Kth Largest Element in an Array',
    'kth-largest-element-in-an-array',
    'Heaps',
    'Medium',
  ),
  MasteryProblemSeed(
    'K Closest Points to Origin',
    'k-closest-points-to-origin',
    'Heaps',
    'Medium',
  ),
  MasteryProblemSeed('Task Scheduler', 'task-scheduler', 'Heaps', 'Medium'),
  MasteryProblemSeed(
    'Find K Pairs with Smallest Sums',
    'find-k-pairs-with-smallest-sums',
    'Heaps',
    'Medium',
  ),
  MasteryProblemSeed(
    'Reorganize String',
    'reorganize-string',
    'Heaps',
    'Medium',
  ),
  MasteryProblemSeed('IPO', 'ipo', 'Heaps', 'Hard'),
  MasteryProblemSeed(
    'Smallest Range Covering Elements from K Lists',
    'smallest-range-covering-elements-from-k-lists',
    'Heaps',
    'Hard',
  ),
  MasteryProblemSeed(
    'Frequency Stack',
    'maximum-frequency-stack',
    'Heaps',
    'Hard',
  ),
  MasteryProblemSeed('Design Twitter', 'design-twitter', 'Heaps', 'Medium'),
  MasteryProblemSeed(
    'Find K-th Smallest Pair Distance',
    'find-k-th-smallest-pair-distance',
    'Binary search',
    'Hard',
  ),
  // Graph traversal (22)
  MasteryProblemSeed(
    'Max Area of Island',
    'max-area-of-island',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Surrounded Regions',
    'surrounded-regions',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed('Walls and Gates', 'walls-and-gates', 'Graphs', 'Medium'),
  MasteryProblemSeed('Rotting Oranges', 'rotting-oranges', 'Graphs', 'Medium'),
  MasteryProblemSeed(
    'Is Graph Bipartite?',
    'is-graph-bipartite',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Minimum Genetic Mutation',
    'minimum-genetic-mutation',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Shortest Path in Binary Matrix',
    'shortest-path-in-binary-matrix',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed('01 Matrix', '01-matrix', 'Graphs', 'Medium'),
  MasteryProblemSeed('Keys and Rooms', 'keys-and-rooms', 'Graphs', 'Medium'),
  MasteryProblemSeed(
    'All Paths From Source to Target',
    'all-paths-from-source-to-target',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Reconstruct Itinerary',
    'reconstruct-itinerary',
    'Graphs',
    'Hard',
  ),
  MasteryProblemSeed(
    'Minimum Height Trees',
    'minimum-height-trees',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Find if Path Exists in Graph',
    'find-if-path-exists-in-graph',
    'Graphs',
    'Easy',
  ),
  MasteryProblemSeed(
    'Evaluate Division',
    'evaluate-division',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed('Shortest Bridge', 'shortest-bridge', 'Graphs', 'Medium'),
  MasteryProblemSeed(
    'Number of Provinces',
    'number-of-provinces',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Snakes and Ladders',
    'snakes-and-ladders',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed('Word Ladder II', 'word-ladder-ii', 'Graphs', 'Hard'),
  MasteryProblemSeed(
    'As Far from Land as Possible',
    'as-far-from-land-as-possible',
    'Graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Shortest Path to Get All Keys',
    'shortest-path-to-get-all-keys',
    'Graphs',
    'Hard',
  ),
  MasteryProblemSeed(
    'Shortest Path Visiting All Nodes',
    'shortest-path-visiting-all-nodes',
    'Graphs',
    'Hard',
  ),
  MasteryProblemSeed('Open the Lock', 'open-the-lock', 'Graphs', 'Medium'),
  // Advanced graphs (12)
  MasteryProblemSeed(
    'Redundant Connection',
    'redundant-connection',
    'Advanced graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Redundant Connection II',
    'redundant-connection-ii',
    'Advanced graphs',
    'Hard',
  ),
  MasteryProblemSeed(
    'Min Cost to Connect All Points',
    'min-cost-to-connect-all-points',
    'Advanced graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Network Delay Time',
    'network-delay-time',
    'Advanced graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Cheapest Flights Within K Stops',
    'cheapest-flights-within-k-stops',
    'Advanced graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Path With Minimum Effort',
    'path-with-minimum-effort',
    'Advanced graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Swim in Rising Water',
    'swim-in-rising-water',
    'Advanced graphs',
    'Hard',
  ),
  MasteryProblemSeed(
    'Critical Connections in a Network',
    'critical-connections-in-a-network',
    'Advanced graphs',
    'Hard',
  ),
  MasteryProblemSeed(
    'Parallel Courses',
    'parallel-courses',
    'Advanced graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Course Schedule II',
    'course-schedule-ii',
    'Advanced graphs',
    'Medium',
  ),
  MasteryProblemSeed(
    'Minimum Cost to Make at Least One Valid Path in a Grid',
    'minimum-cost-to-make-at-least-one-valid-path-in-a-grid',
    'Advanced graphs',
    'Hard',
  ),
  MasteryProblemSeed(
    'Number of Operations to Make Network Connected',
    'number-of-operations-to-make-network-connected',
    'Advanced graphs',
    'Medium',
  ),
  // 1-D DP (18)
  MasteryProblemSeed(
    'Min Cost Climbing Stairs',
    'min-cost-climbing-stairs',
    '1-D dynamic programming',
    'Easy',
  ),
  MasteryProblemSeed(
    'Delete and Earn',
    'delete-and-earn',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximum Length of Repeated Subarray',
    'maximum-length-of-repeated-subarray',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Integer Break',
    'integer-break',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Perfect Squares',
    'perfect-squares',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Word Break II',
    'word-break-ii',
    '1-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Maximum Sum Circular Subarray',
    'maximum-sum-circular-subarray',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Best Time to Buy and Sell Stock with Cooldown',
    'best-time-to-buy-and-sell-stock-with-cooldown',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Best Time to Buy and Sell Stock with Transaction Fee',
    'best-time-to-buy-and-sell-stock-with-transaction-fee',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Decode Ways II',
    'decode-ways-ii',
    '1-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Maximum Alternating Subsequence Sum',
    'maximum-alternating-subsequence-sum',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Number of Longest Increasing Subsequence',
    'number-of-longest-increasing-subsequence',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Russian Doll Envelopes',
    'russian-doll-envelopes',
    '1-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Arithmetic Slices',
    'arithmetic-slices',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximum Length of Pair Chain',
    'maximum-length-of-pair-chain',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Fibonacci Number',
    'fibonacci-number',
    '1-D dynamic programming',
    'Easy',
  ),
  MasteryProblemSeed(
    'Longest Arithmetic Subsequence',
    'longest-arithmetic-subsequence',
    '1-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Partition Array for Maximum Sum',
    'partition-array-for-maximum-sum',
    '1-D dynamic programming',
    'Medium',
  ),
  // 2-D DP (14)
  MasteryProblemSeed(
    'Minimum Path Sum',
    'minimum-path-sum',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Edit Distance',
    'edit-distance',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Distinct Subsequences',
    'distinct-subsequences',
    '2-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Interleaving String',
    'interleaving-string',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Target Sum',
    'target-sum',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Ones and Zeroes',
    'ones-and-zeroes',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Last Stone Weight II',
    'last-stone-weight-ii',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Triangle',
    'triangle',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Minimum Falling Path Sum',
    'minimum-falling-path-sum',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Dungeon Game',
    'dungeon-game',
    '2-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Maximal Square',
    'maximal-square',
    '2-D dynamic programming',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximal Rectangle',
    'maximal-rectangle',
    '2-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Regular Expression Matching',
    'regular-expression-matching',
    '2-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Wildcard Matching',
    'wildcard-matching',
    '2-D dynamic programming',
    'Hard',
  ),
  // Greedy (14)
  MasteryProblemSeed('Jump Game II', 'jump-game-ii', 'Greedy', 'Medium'),
  MasteryProblemSeed('Gas Station', 'gas-station', 'Greedy', 'Medium'),
  MasteryProblemSeed('Candy', 'candy', 'Greedy', 'Hard'),
  MasteryProblemSeed(
    'Queue Reconstruction by Height',
    'queue-reconstruction-by-height',
    'Greedy',
    'Medium',
  ),
  MasteryProblemSeed(
    'Hand of Straights',
    'hand-of-straights',
    'Greedy',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximum Number of Events That Can Be Attended II',
    'maximum-number-of-events-that-can-be-attended-ii',
    '1-D dynamic programming',
    'Hard',
  ),
  MasteryProblemSeed(
    'Wiggle Subsequence',
    'wiggle-subsequence',
    'Greedy',
    'Medium',
  ),
  MasteryProblemSeed(
    'Minimum Number of Arrows to Burst Balloons',
    'minimum-number-of-arrows-to-burst-balloons',
    'Greedy',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximum Units on a Truck',
    'maximum-units-on-a-truck',
    'Greedy',
    'Easy',
  ),
  MasteryProblemSeed(
    'Can Place Flowers',
    'can-place-flowers',
    'Greedy',
    'Easy',
  ),
  MasteryProblemSeed('Lemonade Change', 'lemonade-change', 'Greedy', 'Easy'),
  MasteryProblemSeed(
    'Best Time to Buy and Sell Stock II',
    'best-time-to-buy-and-sell-stock-ii',
    'Greedy',
    'Medium',
  ),
  MasteryProblemSeed(
    'Minimum Deletions to Make Character Frequencies Unique',
    'minimum-deletions-to-make-character-frequencies-unique',
    'Greedy',
    'Medium',
  ),
  MasteryProblemSeed(
    'Maximum Length of Subarray With Positive Product',
    'maximum-length-of-subarray-with-positive-product',
    '1-D dynamic programming',
    'Medium',
  ),
  // Intervals (8)
  MasteryProblemSeed(
    'Meeting Rooms III',
    'meeting-rooms-iii',
    'Intervals',
    'Hard',
  ),
  MasteryProblemSeed(
    'Remove Covered Intervals',
    'remove-covered-intervals',
    'Intervals',
    'Medium',
  ),
  MasteryProblemSeed(
    'Data Stream as Disjoint Intervals',
    'data-stream-as-disjoint-intervals',
    'Intervals',
    'Medium',
  ),
  MasteryProblemSeed(
    'Employee Free Time',
    'employee-free-time',
    'Intervals',
    'Hard',
  ),
  MasteryProblemSeed('My Calendar I', 'my-calendar-i', 'Intervals', 'Medium'),
  MasteryProblemSeed('My Calendar II', 'my-calendar-ii', 'Intervals', 'Medium'),
  MasteryProblemSeed('Car Pooling', 'car-pooling', 'Intervals', 'Medium'),
  MasteryProblemSeed(
    'Interval List Intersections',
    'interval-list-intersections',
    'Intervals',
    'Medium',
  ),
  // Bit manipulation (8)
  MasteryProblemSeed(
    'Single Number',
    'single-number',
    'Bit manipulation',
    'Easy',
  ),
  MasteryProblemSeed(
    'Single Number II',
    'single-number-ii',
    'Bit manipulation',
    'Medium',
  ),
  MasteryProblemSeed(
    'Single Number III',
    'single-number-iii',
    'Bit manipulation',
    'Medium',
  ),
  MasteryProblemSeed(
    'Bitwise AND of Numbers Range',
    'bitwise-and-of-numbers-range',
    'Bit manipulation',
    'Medium',
  ),
  MasteryProblemSeed(
    'Power of Two',
    'power-of-two',
    'Bit manipulation',
    'Easy',
  ),
  MasteryProblemSeed(
    'Power of Four',
    'power-of-four',
    'Bit manipulation',
    'Easy',
  ),
  MasteryProblemSeed(
    'Bitwise ORs of Subarrays',
    'bitwise-ors-of-subarrays',
    'Bit manipulation',
    'Easy',
  ),
  MasteryProblemSeed(
    'Maximum XOR of Two Numbers in an Array',
    'maximum-xor-of-two-numbers-in-an-array',
    'Bit manipulation',
    'Medium',
  ),
  // Math and geometry (11)
  MasteryProblemSeed('Pow(x, n)', 'powx-n', 'Math & geometry', 'Medium'),
  MasteryProblemSeed('Sqrt(x)', 'sqrtx', 'Math & geometry', 'Easy'),
  MasteryProblemSeed(
    'Multiply Strings',
    'multiply-strings',
    'Math & geometry',
    'Medium',
  ),
  MasteryProblemSeed('Happy Number', 'happy-number', 'Math & geometry', 'Easy'),
  MasteryProblemSeed(
    'Roman to Integer',
    'roman-to-integer',
    'Math & geometry',
    'Easy',
  ),
  MasteryProblemSeed(
    'Integer to Roman',
    'integer-to-roman',
    'Math & geometry',
    'Medium',
  ),
  MasteryProblemSeed(
    'Fraction to Recurring Decimal',
    'fraction-to-recurring-decimal',
    'Math & geometry',
    'Medium',
  ),
  MasteryProblemSeed(
    'Detect Squares',
    'detect-squares',
    'Math & geometry',
    'Medium',
  ),
  MasteryProblemSeed(
    'Max Points on a Line',
    'max-points-on-a-line',
    'Math & geometry',
    'Hard',
  ),
  MasteryProblemSeed(
    'Rectangle Area',
    'rectangle-area',
    'Math & geometry',
    'Medium',
  ),
  MasteryProblemSeed(
    'Basic Calculator II',
    'basic-calculator-ii',
    'Math & geometry',
    'Medium',
  ),
];

const _coreExtensionCounts = <String, int>{
  'Arrays & hashing': 10,
  'Two pointers': 5,
  'Sliding window': 5,
  'Binary search': 6,
  'Linked lists': 5,
  'Stacks': 5,
  'Trees': 7,
  'Tries': 1,
  'Backtracking': 4,
  'Heaps': 4,
  'Graphs': 6,
  'Advanced graphs': 2,
  '1-D dynamic programming': 5,
  '2-D dynamic programming': 3,
  'Greedy': 3,
  'Intervals': 2,
  'Bit manipulation': 2,
};

const _breadthExtensionCounts = <String, int>{
  'Arrays & hashing': 6,
  'Two pointers': 3,
  'Sliding window': 2,
  'Binary search': 4,
  'Linked lists': 3,
  'Stacks': 4,
  'Trees': 10,
  'Tries': 2,
  'Backtracking': 5,
  'Heaps': 4,
  'Graphs': 12,
  'Advanced graphs': 7,
  '1-D dynamic programming': 8,
  '2-D dynamic programming': 7,
  'Greedy': 6,
  'Intervals': 4,
  'Bit manipulation': 3,
  'Math & geometry': 10,
};

List<MasteryProblemSeed> _selectExtensionSeeds(
  Map<String, int> counts, {
  Map<String, int> skipByPattern = const {},
}) => [
  for (final quota in counts.entries)
    ...mastery300Seeds
        .where((seed) => seed.pattern == quota.key)
        .skip(skipByPattern[quota.key] ?? 0)
        .take(quota.value),
];

final _core150Extensions = _selectExtensionSeeds(_coreExtensionCounts);
final _breadth250Extensions = _selectExtensionSeeds(
  _breadthExtensionCounts,
  skipByPattern: _coreExtensionCounts,
);
final _milestoneSeeds = <MasteryProblemSeed>[
  ..._core150Extensions,
  ..._breadth250Extensions,
  for (final seed in mastery300Seeds)
    if (!_core150Extensions.contains(seed) &&
        !_breadth250Extensions.contains(seed))
      seed,
];

final mastery300Entries = List<Blind75Entry>.unmodifiable([
  ...blind75Entries,
  for (var i = 0; i < _milestoneSeeds.length; i++)
    _milestoneSeeds[i].build(blind75Entries.length + i + 1),
]);

final mastery300ByLessonId = {
  for (final entry in mastery300Entries) entry.lesson.id: entry,
};
