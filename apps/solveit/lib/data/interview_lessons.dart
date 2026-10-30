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
  Lesson(
    id: 'rotated-index-v1',
    title: 'Find a value in the shifted shelf',
    pattern: 'Binary search',
    summary: 'Use the sorted half to shrink a rotated search range.',
    statement:
        'A shelf contains distinct numbers in increasing order, then it may have been rotated at one position. Return the index of target, or -1 when it is absent. The array may be empty or unrotated.',
    example:
        'values = [6, 7, 9, 1, 3, 5], target = 3\nAnswer: 4.',
    constraints:
        '0–10,000 distinct integers from −1,000,000 to 1,000,000. Do not modify the input. Return -1 when target is not present.',
    questions: [
      'What does the result mean when the value is absent? Can the array be empty or unrotated?',
      'Start with a correct linear search. In a rotated array with distinct values, what can you infer about one side of the midpoint?',
      'Trace [4, 5, 6, 7, 0, 1, 2] for target 0. Show how you choose the next range and give the time and space costs.',
      codeQuestion,
      'What invariant keeps the target, if present, inside your remaining range? Why do distinct values help?',
    ],
    checks: [
      'I return the matching index or -1 and account for empty, unrotated, and rotated inputs.',
      'My search is correct for a baseline and then uses the ordered half to discard only values that cannot contain the target.',
      'I return index 4 for the trace, keep the target in the remaining range, and explain logarithmic time.',
      codeCheck,
      'I described the range invariant, termination, and why equality at a boundary is handled correctly.',
    ],
    hints: [
      'Compare the left, middle, and right values. What does that tell you about a half of the range?',
      'At least one half is increasing. Check whether the target lies between that half’s endpoints.',
      'If the left half is ordered and left ≤ target < middle, keep it; otherwise discard it. If the right half is ordered, keep it only when middle < target ≤ right. Check middle before narrowing.',
    ],
    explanation:
        'A linear scan is a correct O(n) baseline. To use binary search, keep inclusive bounds left and right. Check the midpoint first. With distinct values, at least one side is increasing: if values[left] ≤ values[mid], the left side is ordered. Keep it only when values[left] ≤ target < values[mid]; otherwise search right. If the right side is ordered, keep it only when values[mid] < target ≤ values[right]; otherwise search left. The bounds shrink each iteration, so the search takes O(log n) time and O(1) extra space. Return -1 after the range becomes empty. Distinct values avoid an ambiguous equal-endpoint case.',
  ),
  Lesson(
    id: 'products-except-self-v1',
    title: 'Multiply everything except this one',
    pattern: 'Prefix and suffix products',
    summary: 'Build each answer from the values on both sides.',
    statement:
        'For every position, return the product of all input values except the value at that position. Do not use division. Zeros are allowed. Return an empty list for empty input.',
    example:
        'values = [1, 2, 0, 4]\nAnswer: [0, 0, 8, 0].',
    constraints:
        '0–12 integers, each from −2 to 2. Products fit a signed 32-bit integer. Do not modify the input.',
    questions: [
      'What should the output contain for each position? How does a zero affect the other answers?',
      'For one position, separate the values before it from the values after it. What summaries would let you combine them?',
      'Trace [1, 2, 0, 4]. Show the prefix contribution and suffix contribution at every index. Give time and extra space costs.',
      codeQuestion,
      'How does your method work with two zeros or a one-element input, and why does it not need division?',
    ],
    checks: [
      'I produce one product per position, exclude that position, avoid division, and handle zeros and empty input.',
      'I combine information from the left and right of each index without recomputing every product.',
      'I get [0, 0, 8, 0], account for both sides at each index, and state O(n) time.',
      codeCheck,
      'I checked zero counts and a one-element input, and separated output space from auxiliary space.',
    ],
    hints: [
      'For index i, what product comes from indices before i, and what comes from indices after i?',
      'Write left products into the output first. Then scan from the right while carrying one running product.',
      'Initialize a running product to 1 and write the product-before-i for each index. Scan backward, multiply output[i] by the product-after-i, then include values[i] in the running product.',
    ],
    explanation:
        'For each index i, the desired value is the product before i times the product after i. A left-to-right pass writes the product before each position into the output, updating a running product afterward. A right-to-left pass multiplies each output entry by the product after that position, then updates the suffix product. Starting both running products at 1 handles the boundaries and a one-element array. Zeros need no special case: they naturally make products on the side that contains them zero. This is O(n) time and O(1) auxiliary space beyond the O(n) output. No division or input mutation is needed.',
  ),
  Lesson(
    id: 'longest-run-v1',
    title: 'Measure the longest consecutive run',
    pattern: 'Hash sets & sequence starts',
    summary: 'Begin counting only where a run can start.',
    statement:
        'Given an unordered list of integers, return the length of its longest sequence of consecutive values. Duplicates count once, and consecutive values differ by exactly one. Return 0 for empty input.',
    example:
        'values = [100, 4, 200, 1, 3, 2]\nAnswer: 4, from [1, 2, 3, 4].',
    constraints:
        '0–10,000 integers from −1,000,000 to 1,000,000. The input is unordered and may contain duplicates. Do not modify it.',
    questions: [
      'Do duplicates extend a run? Does the sequence have to appear in adjacent input positions?',
      'A set makes membership checks possible. Which values can begin a run rather than continue one?',
      'Trace [9, 1, 4, 7, 3, -1, 0, 5, 8, -1, 6]. Identify the longest run and give time and extra space costs.',
      codeQuestion,
      'Why does starting only at a value with no predecessor avoid repeatedly counting the same run?',
    ],
    checks: [
      'I count distinct consecutive values regardless of input order and return 0 for empty input.',
      'My method recognizes a run start and counts upward while values remain present.',
      'I find the run from 3 through 9 with length 7 and explain expected linear time.',
      codeCheck,
      'I justified why a value is counted only as part of one forward scan and accounted for the set.',
    ],
    hints: [
      'Would sorting solve the task? What would it cost, and can you use membership instead?',
      'A value x is the start of a run when x − 1 is absent. Only extend a run from those starts.',
      'Put values in a set. For each start x with no predecessor, count x, x+1, and so on while present; retain the largest count.',
    ],
    explanation:
        'A sorted copy gives a correct O(n log n) baseline, skipping duplicates while measuring adjacent values. For expected O(n), put the values in a set. For each value x, begin a scan only if x − 1 is absent. Count x, x + 1, and subsequent values while they are in the set, then update the maximum. Every value belongs to at most one such forward scan: a value inside a run has a predecessor, so it cannot start another scan. Return 0 for an empty set. This takes expected O(n) time and O(n) extra space; hash operations have implementation-dependent worst cases.',
  ),
  Lesson(
    id: 'budget-window-v1',
    title: 'Fit the longest block under budget',
    pattern: 'Variable-size sliding window',
    summary: 'Shrink only when a nonnegative window exceeds its limit.',
    statement:
        'Given nonnegative daily costs and a budget, return the maximum length of a nonempty consecutive block whose total cost is at most the budget. Return 0 for empty input. Zero-cost days are allowed.',
    example:
        'costs = [2, 1, 1, 1, 4], budget = 5\nAnswer: 4, from [2, 1, 1, 1].',
    constraints:
        '0–10,000 costs, each from 0 to 1,000. Budget: 0–10,000,000. The input is not modified.',
    questions: [
      'What makes a block valid? Can a zero-cost day extend it, and what should an empty input return?',
      'Start with a correct method that tries each start. Under what condition can you safely move the left edge forward?',
      'Trace [2, 1, 1, 1, 4] with budget 5. Show each shrink and state the time and extra space costs.',
      codeQuestion,
      'Why does this shrinking rule depend on nonnegative costs? Would it still be safe with negative values?',
    ],
    checks: [
      'I maximize the length of a consecutive nonempty block with total at most the budget; empty input returns 0.',
      'My baseline checks all starts. My window method restores validity by removing leftmost costs only when the total is too large.',
      'I find length 4, handle zero costs, and explain why each index moves at most once.',
      codeCheck,
      'I used nonnegativity to justify shrinking, and I identified why negative values break that argument.',
    ],
    hints: [
      'Could you extend a valid block one day at a time and keep its running total?',
      'When the total exceeds the budget, what happens to it as you remove a nonnegative value from the left?',
      'Add each new cost to the right. While the sum is too large, subtract costs[left] and advance left. Update the best length after the window is valid.',
    ],
    explanation:
        'Trying every start and extending while tracking the sum is a correct O(n²) baseline. With nonnegative costs, maintain a window and its sum. For each right endpoint, add the new cost. While the sum exceeds the budget, remove costs[left] and advance left; removing a nonnegative value cannot increase the sum. Once valid, update the best length. Each index enters once and leaves at most once, so the scan is O(n) time and O(1) extra space. Zero-cost values can extend a valid block. With negative costs, extending or shrinking no longer changes the sum monotonically, so this window rule is not generally correct.',
  ),
  Lesson(
    id: 'lower-bound-v1',
    title: 'Find the first place a value belongs',
    pattern: 'Binary search boundaries',
    summary: 'Search for a boundary, not just an equal value.',
    statement:
        'Given values sorted in nondecreasing order and a target, return the first index whose value is at least the target. If every value is smaller, return the array length. Duplicates are allowed.',
    example: 'values = [1, 3, 3, 8], target = 3\nAnswer: 1.',
    constraints:
        '0–10,000 sorted integers from −1,000,000 to 1,000,000. The input is not modified.',
    questions: [
      'What does the returned index mean if the target is absent? What if the input is empty?',
      'A linear scan is a baseline. How can sorted order let you locate the first qualifying position without scanning every value?',
      'Trace [1, 3, 3, 8] with target 3. Why must the search continue left after it finds an equal value?',
      codeQuestion,
      'State what is known about positions before and after your remaining search range. How does that prove the final boundary?',
    ],
    checks: [
      'I return the first index with value ≥ target, including the array length when no such value exists.',
      'My search keeps the earliest possible qualifying position rather than stopping at any equal value.',
      'I return index 1 for the trace, handle duplicates and empty input, and explain logarithmic time.',
      codeCheck,
      'I described a boundary invariant and showed why the final lower edge is the first valid position.',
    ],
    hints: [
      'Imagine dividing positions into values below target and values at least target. Where does that boundary lie?',
      'Use a half-open range [left, right). If values[mid] is below target, the boundary must be after mid; otherwise it can be at mid or before.',
      'Start with left = 0 and right = n. While left < right, set mid between them. Move left to mid + 1 if values[mid] < target; otherwise move right to mid. Return left.',
    ],
    explanation:
        'A linear scan returns the first index with value at least target in O(n) time. Binary search keeps a half-open candidate range [left, right), starting at [0, n). Every position before left is known to be smaller than target; every position at or after right is known to be at least target. If values[mid] < target, the boundary is strictly after mid, so set left = mid + 1. Otherwise the boundary is at mid or earlier, so set right = mid. When the bounds meet, left is the first qualifying index, or n if none qualifies. This takes O(log n) time and O(1) extra space and naturally returns the first duplicate.',
  ),
  Lesson(
    id: 'island-count-v1',
    title: 'Count the connected garden plots',
    pattern: 'Grid traversal · BFS/DFS',
    summary: 'Visit each four-direction land component once.',
    statement:
        'A rectangular map uses 1 for land and 0 for water. Count connected land groups. Cells connect only up, down, left, or right; diagonal contact does not connect them. Do not modify the map. An empty map contains zero groups.',
    example:
        'map = [[1, 1, 0], [0, 1, 0], [1, 0, 1]]\nAnswer: 3.',
    constraints:
        '0–50 rows and 0–50 columns, all rows have the same length, and each cell is 0 or 1. Return 0 for an empty or all-water map.',
    questions: [
      'Which neighboring cells connect land? Do diagonals count? What should an all-water map return?',
      'How could a flood fill find one group? What must you remember so the same land cell is not counted again?',
      'Trace [[1, 1, 0], [0, 1, 0], [1, 0, 1]]. Which cells belong to each group?',
      codeQuestion,
      'Why is the total work linear in the number of cells, and what extra storage does your traversal need?',
    ],
    checks: [
      'I count four-direction connected components; diagonal-only contact makes separate groups.',
      'I start a traversal at unseen land and mark every reached land cell so no group is counted twice.',
      'I find three groups in the example, ignore water, and handle empty or all-water maps.',
      codeCheck,
      'I account for every cell at most once and explain the visited storage or safe in-place marking choice.',
    ],
    hints: [
      'Scan every cell. What should happen when you encounter land that has not belonged to a traversal yet?',
      'Start a queue or stack there, count one group, and visit only in-bounds four-direction land neighbors.',
      'Keep a visited grid. Each unseen land cell starts one BFS/DFS; mark cells when they are added, not when removed, to avoid duplicate queue entries.',
    ],
    explanation:
        'Scan the map. Whenever an unvisited land cell appears, increment the group count and flood-fill its four-direction neighbors with BFS or DFS. Mark a land cell visited when it is added to the worklist, then add only in-bounds, unvisited land neighbors. This prevents duplicate work and keeps diagonal cells separate. Water is skipped. Empty dimensions return zero. Each cell is visited at most once, giving O(rows × columns) time and O(rows × columns) extra space for visited state and the worklist. The input remains unchanged.',
  ),
];

const allLessons = <Lesson>[...pilotLessons, ...interviewLessons];
