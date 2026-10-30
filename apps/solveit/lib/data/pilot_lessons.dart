import '../domain/lesson.dart';

// Original pilot content; independent review and tested language solutions
// are required before production publishing.
const codeQuestion =
    'Write your implementation. This preview saves a draft; it does not execute or grade code.';
const codeCheck =
    'I have a code draft and understand that it has not been compiled or tested here.';

const pilotLessons = <Lesson>[
  Lesson(
    id: 'supply-pair-v1',
    title: 'The supply pair',
    pattern: 'Maps & lookup',
    summary: 'Find the missing piece without searching twice.',
    statement:
        'A workshop has supply prices and a budget. Return two distinct '
        'zero-based indices whose prices add up to the budget. Return an empty '
        'list if no pair exists. If several pairs work, return any one.',
    example: 'prices = [4, 11, 6, 2], budget = 8\nA valid answer is [2, 3].',
    constraints:
        '0–10,000 prices. Prices and budget are integers from 0 to '
        '1,000,000. Duplicate prices are allowed. Do not reuse an index.',
    questions: [
      'What must the answer contain? What happens if two supplies have the same price?',
      'Start with a correct approach, even a slow one. Then describe how you could avoid repeatedly searching earlier prices.',
      'Trace [4, 11, 6, 2] with budget 8. Explain when you check and store each price, and give time and space costs.',
      codeQuestion,
      'What information did you reuse? Describe an edge case and when this pattern would help again.',
    ],
    checks: [
      'I use distinct indices, handle duplicates, and define the no-pair result.',
      'My method finds any valid pair and never reuses one item. A correct nested-loop method is a valid starting point.',
      'My trace matches my algorithm. I distinguish repeated scanning from lookup and account for extra memory.',
      codeCheck,
      'I recorded the reusable idea and an edge case in my own words.',
    ],
    hints: [
      'For one price, what other price would finish the budget?',
      'Could you remember earlier prices and their indices?',
      'Look for budget − currentPrice before storing the current item. Why does checking first avoid reusing an index?',
    ],
    explanation:
        'Scanning all distinct pairs is correct: O(n²) time, O(1) '
        'extra space. Another method keeps a map of earlier price → index. '
        'For each price x, first look for budget − x. If found, return the '
        'earlier and current indices. Otherwise store x. Checking before '
        'inserting prevents index reuse and handles duplicate values. Return '
        '[] if no pair is found. Expected O(n) time and O(n) extra space with '
        'a suitable hash map; worst-case lookup depends on the runtime.',
  ),
  Lesson(
    id: 'sorted-crates-v1',
    title: 'Two crates, one limit',
    pattern: 'Two pointers',
    summary: 'Use sorted order to rule out wasted work.',
    statement:
        'Crate weights are sorted in nondecreasing order. Return two '
        'distinct zero-based indices whose weights sum to a target. Return '
        'an empty list if no pair exists. Any valid pair is acceptable.',
    example:
        'weights = [1, 3, 5, 8, 12], target = 13\nA valid answer is [0, 4].',
    constraints:
        '0–10,000 integer weights, each 0–1,000,000. Target: '
        '0–2,000,000. Duplicates allowed. Input is already sorted.',
    questions: [
      'What does sorted order tell you? What happens for fewer than two crates?',
      'Describe a correct algorithm. Can two positions narrow the search without missing a pair?',
      'Trace [1, 3, 5, 8, 12] with target 11. Explain why each move is safe and state time and space costs.',
      codeQuestion,
      'What made moving a pointer safe? Would the same reasoning work on unsorted input?',
    ],
    checks: [
      'I use distinct indices and account for sorted input, duplicates, and short lists.',
      'My algorithm terminates and finds a pair or correctly returns an empty list.',
      'I justified each move with sorted order, stopped before pointers meet, and explained complexity.',
      codeCheck,
      'I explained the invariant and the assumption that makes it work.',
    ],
    hints: [
      'Compare the smallest remaining value with the largest.',
      'If the sum is too small, can the smallest value pair with anything still inside the range?',
      'Start left = 0, right = n − 1. Move left for a sum below target and right for a sum above target. Continue while left < right.',
    ],
    explanation:
        'Start at both ends. If the sum matches, return the indices. '
        'If too small, the left value cannot pair with anything remaining, '
        'since right is the largest: increment left. If too large, the right '
        'value cannot pair with anything remaining, since left is the smallest: '
        'decrement right. Stop when left >= right and return []. O(n) time, '
        'O(1) extra space. For target 11, try 1 + 12, then 1 + 8, then 3 + 8.',
  ),
  Lesson(
    id: 'focus-block-v1',
    title: 'Your best focus block',
    pattern: 'Sliding window',
    summary: 'Update a window instead of starting over.',
    statement:
        'Given daily focus scores and a block length k, return the '
        'largest sum of exactly k consecutive scores. Scores can be negative. '
        'The input always has at least k entries.',
    example: 'scores = [3, -2, 5, 4, -1], k = 3\nAnswer: 8, from [5, 4, -1].',
    constraints:
        '1 ≤ k ≤ number of scores ≤ 10,000. Scores are integers '
        'from −1,000 to 1,000.',
    questions: [
      'Must the block be consecutive and exactly k entries long? What if all scores are negative?',
      'Describe a correct approach. What calculation can you reuse between neighboring blocks?',
      'Trace window sums for [3, -2, 5, 4, -1], k = 3. Explain initialization and time/space costs.',
      codeQuestion,
      'What leaves and enters a window? Why is initializing the best sum to zero risky?',
    ],
    checks: [
      'I require exactly k consecutive entries and preserve negative answers.',
      'I check every valid block. When reusing sums, I subtract the outgoing value and add the incoming one.',
      'I get sums 6, 7, and 8, initialize best from a real window, and explain complexity.',
      codeCheck,
      'I explained reuse and considered all-negative scores, k = 1, and k = n.',
    ],
    hints: [
      'Which values do neighboring blocks share?',
      'Moving by one removes one score and adds one score.',
      'Sum the first k entries and initialize best from it. Then update sum += scores[i] − scores[i − k] and update best.',
    ],
    explanation:
        'Sum the first k scores and use this as current and best. '
        'For each next score, subtract the outgoing score, add the new score, '
        'and update best. Return best. Initializing from a real window '
        'preserves negative maxima. The example sums are 6, 7, and 8. O(n) '
        'time, O(1) extra space. Recomputing each window is also correct but '
        'takes O(nk) time.',
  ),
];
