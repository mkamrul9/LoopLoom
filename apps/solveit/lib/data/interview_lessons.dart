import '../domain/lesson.dart';
import 'pilot_lessons.dart';

// Original intermediate pilot content, pending independent editorial review.
const interviewLessons = <Lesson>[
  Lesson(
    id: 'signal-ranges-v1',
    title: 'Count the signal ranges',
    pattern: 'Prefix sums & frequency maps',
    summary: 'Count overlapping ranges when negative values change the rules.',
    statement:
        'A sensor records signed integer changes. Return the number of nonempty consecutive ranges whose sum equals a target. Count ranges separately by their start and end positions, even if their values are equal. Ranges may overlap.',
    example:
        'changes = [2, -2, 2], target = 2\nAnswer: 3. The ranges are indices [0..0], [0..2], and [2..2].',
    constraints:
        '0–10,000 changes, each −1,000 to 1,000. Target: −10,000,000 to 10,000,000. Return 0 for an empty input. Use an integer type that holds the count.',
    questions: [
      'What distinguishes two ranges? Can they overlap, and does an empty range count?',
      'Describe a correct counting method. With negative changes allowed, what can you safely infer when a running sum exceeds the target?',
      'Trace [0, 0, 0] with target 0 using your method. Explain why the answer is 6, how you avoid counting empty ranges, and the time and space costs.',
      codeQuestion,
      'Why can the same cumulative total matter more than once? Contrast this task with finding just one matching range.',
    ],
    checks: [
      'I count nonempty consecutive index ranges, including overlapping ones, and return 0 for empty input.',
      'My method works with zeros and negative values. Enumerating all starts and extending each end is a correct starting point.',
      'I account for all 6 ranges. If I use prefix frequencies, I count earlier prefixes before recording the current one and include the prefix before index 0.',
      codeCheck,
      'I explained why frequencies, ordering, and the initial empty prefix matter.',
    ],
    hints: [
      'Write the sum of a range as the difference of two cumulative totals.',
      'For a current prefix total p, how many earlier prefixes equal p − target?',
      'Start with frequency[0] = 1. For each value, update p, add frequency[p − target] to the answer, then increment frequency[p]. Checking first excludes an empty range.',
    ],
    explanation:
        'A correct baseline extends every start position while maintaining a sum: O(n²) time and O(1) extra space. For an expected O(n) method, keep frequencies of earlier prefix totals. Seed total 0 with frequency 1 to represent the position before the input. Add each value to prefix p, add the frequency of p − target to the count, then increment the frequency of p. Each earlier occurrence identifies a different nonempty range ending here. For [0, 0, 0], contributions are 1, 2, 3: answer 6. Negative values do not invalidate the prefix identity. A window that shrinks solely because its sum is too large is not generally correct here. Expected O(n) time, O(n) space with hashing; worst-case lookup depends on the runtime. At n = 10,000 the count is at most 50,005,000.',
  ),
  Lesson(
    id: 'warmer-readings-v1',
    title: 'Wait for a warmer reading',
    pattern: 'Monotonic stack',
    summary: 'Keep unresolved positions until a future reading answers them.',
    statement:
        'For each daily temperature, return the number of days until the first later day with a strictly higher temperature. Return 0 at positions with no warmer future day. Equal temperatures are not warmer.',
    example: 'temperatures = [20, 20, 19, 23, 21]\nAnswer: [3, 2, 1, 0, 0].',
    constraints:
        '0–10,000 integer temperatures, each −100 to 100. Output length equals input length. Return [] for empty input.',
    questions: [
      'Does an equal temperature qualify? Why must you find the first warmer day rather than any warmer day?',
      'Start with a correct search for each position. What information must an unresolved position retain while later readings arrive?',
      'Trace [20, 20, 19, 23, 21]. Describe what is resolved at 23, why it is the first valid answer, and your total time and extra space costs.',
      codeQuestion,
      'How often can one position enter and leave your data structure? Explain the bound across the whole input.',
    ],
    checks: [
      'I produce a distance for every day, require strictly greater temperatures, and handle empty input and no future match.',
      'My method finds the first valid future day and remembers indices so it can calculate distances. A nested search is a valid baseline.',
      'My output is [3, 2, 1, 0, 0]. Equal readings remain unresolved. If using a stack, I explain why each index is pushed and popped at most once.',
      codeCheck,
      'I connected the maintained order to unresolved work and justified an aggregate complexity bound.',
    ],
    hints: [
      'Could a new reading answer several earlier days at once?',
      'Keep indices of days still waiting. Which waiting day is easiest to compare with the newest temperature?',
      'Maintain a stack of unresolved indices with nonincreasing temperatures. While the new temperature is strictly greater than the top temperature, pop j and set answer[j] = i − j. Then push i.',
    ],
    explanation:
        'A nested search scans later days until the first strictly warmer value: correct in O(n²) time. A stack stores unresolved indices in nonincreasing temperature order. Initialize output to zeros. For each day i, while its temperature exceeds the stack top temperature, pop index j and set its distance to i − j. Push i after resolving those days. A popped day has seen no earlier warmer day, since that day would already have resolved it. Equal temperatures stay on the stack. Each index enters and leaves at most once, giving O(n) total time and O(n) auxiliary space, plus O(n) output. Indices left on the stack correctly retain zero.',
  ),
  Lesson(
    id: 'busy-periods-v1',
    title: 'Combine the busy periods',
    pattern: 'Sorting & intervals',
    summary: 'Turn unordered bookings into disjoint periods of activity.',
    statement:
        'Bookings are half-open time intervals [start, end): start is included and end is excluded. Merge bookings that overlap, returning disjoint intervals in increasing start order. Merely touching intervals stay separate: [1, 3) and [3, 5) do not overlap. Do not modify the input. Duplicate and nested bookings are allowed.',
    example:
        'bookings = [[5, 8], [1, 4], [2, 3], [7, 9], [9, 10]]\nAnswer: [[1, 4], [5, 9], [9, 10]].',
    constraints:
        '0–10,000 intervals. Integer times: 0 ≤ start < end ≤ 1,000,000. Return [] for empty input. Each output interval uses the same half-open convention.',
    questions: [
      'When exactly do two bookings overlap? What should happen for touching endpoints, duplicates, and an empty list?',
      'Describe a correct merging process. How could choosing a useful processing order simplify which intervals you need to compare?',
      'Trace [[1, 6], [2, 4], [6, 8], [7, 9]]. Explain why the answer is [[1, 6], [6, 9]], how nested bookings affect the end, and your time and space costs.',
      codeQuestion,
      'What invariant lets you finalize a period? How would the overlap condition change if touching periods were meant to merge?',
    ],
    checks: [
      'I keep touching intervals separate, preserve all covered times, sort the result, and leave the input unchanged.',
      'My method handles unordered, nested, and duplicate intervals, and can distinguish a gap from a true overlap.',
      'I get [[1, 6], [6, 9]]. A nested interval cannot shorten an existing end. I account for copying, sorting, working storage, and output.',
      codeCheck,
      'I justified when a period is final and distinguished strict overlap from adjacency.',
    ],
    hints: [
      'What would change if you processed bookings by increasing start time?',
      'Compare the next start to the current merged end. Equality represents touching, not overlap, in this problem.',
      'Sort a copy by start. Keep a current period; if next.start < current.end, extend its end with max. Otherwise emit current and begin the next period. Emit the last period after the scan.',
    ],
    explanation:
        'Copy the bookings, then sort the copy by start. For nonempty input, initialize a current period from the first booking. If the next start is strictly smaller than the current end, the bookings overlap: update the end to the maximum of both ends. Otherwise output the current period and begin the next. Output the last period too. Start order ensures that after a nonoverlapping next start, no later interval can overlap the period just finalized. Using max prevents a nested booking from shortening coverage. Equality stays separate for half-open intervals under this task’s policy. Sorting dominates at O(n log n) time. Copying and output require O(n) space; sorting may require additional implementation-dependent working memory. Empty input returns [].',
  ),
];

const allLessons = <Lesson>[...pilotLessons, ...interviewLessons];
