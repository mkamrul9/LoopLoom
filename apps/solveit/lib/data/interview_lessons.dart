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
    example: 'values = [6, 7, 9, 1, 3, 5], target = 3\nAnswer: 4.',
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
    example: 'values = [1, 2, 0, 4]\nAnswer: [0, 0, 8, 0].',
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
    example: 'values = [100, 4, 200, 1, 3, 2]\nAnswer: 4, from [1, 2, 3, 4].',
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
    example: 'map = [[1, 1, 0], [0, 1, 0], [1, 0, 1]]\nAnswer: 3.',
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
  Lesson(
    id: 'max-subarray-v1',
    title: 'Find the strongest consecutive stretch',
    pattern: 'Dynamic programming · Kadane',
    summary: 'Decide whether the next value extends or restarts a run.',
    statement:
        'Given signed daily changes, return the largest sum of any nonempty consecutive segment. The segment must contain at least one value; all-negative inputs still have a negative answer.',
    example:
        'changes = [-2, 1, -3, 4, -1, 2, 1, -5, 4]\nAnswer: 6, from [4, -1, 2, 1].',
    constraints:
        '1–10,000 changes, each from −1,000 to 1,000. The input is not modified.',
    questions: [
      'Must the chosen segment be nonempty? What is the answer when every change is negative?',
      'A quadratic scan is correct. For a segment ending at the current value, should you extend the best earlier segment or restart here?',
      'Trace [-2, 1, -3, 4, -1, 2, 1, -5, 4]. Show the best ending at each index and the overall maximum.',
      codeQuestion,
      'Why must the current-ending value and overall best begin from a real input value rather than zero?',
    ],
    checks: [
      'I select a nonempty consecutive segment and preserve the correct negative result for all-negative input.',
      'For each value, I compare starting a new segment with extending the best segment ending just before it.',
      'I get 6 from [4, -1, 2, 1] and explain how the best ending segment updates.',
      codeCheck,
      'I initialized from actual input, handled the one-element case, and distinguished local from overall best.',
    ],
    hints: [
      'If the best segment ending just before x is negative, can including it help a segment that ends at x?',
      'Let ending be the best segment that must end at the current value. Compare x with ending + x.',
      'Initialize ending and best to the first value. For each later x, set ending = max(x, ending + x), then best = max(best, ending).',
    ],
    explanation:
        'A quadratic baseline tries every start and extends a running sum, taking O(n²) time and O(1) extra space. For a linear method, let ending be the best nonempty segment that must end at the previous position. At each value x, either restart with x or extend with ending + x; choose the larger. Update the overall best afterward. A negative earlier sum is discarded when restarting is better, while positive accumulated work remains useful. Initialize from the first real value so all-negative input stays negative. The method uses O(n) time and O(1) extra space.',
  ),
  Lesson(
    id: 'single-trade-v1',
    title: 'Choose one profitable trade',
    pattern: 'Greedy · running minimum',
    summary: 'For each sell day, keep the cheapest earlier buy.',
    statement:
        'Given a daily price series, choose at most one buy day followed by one later sell day. Return the largest profit; skip trading and return 0 when no positive profit is possible. An empty series also returns 0.',
    example:
        'prices = [7, 1, 5, 3, 6, 4]\nAnswer: 5, by buying at 1 and selling later at 6.',
    constraints:
        '0–10,000 prices, each from 0 to 1,000,000. The input is not modified.',
    questions: [
      'What does “at most one” trade allow when prices only fall? Must the buy happen before the sell?',
      'A quadratic baseline tries all pairs. As you scan a possible sell price, what earlier information is sufficient?',
      'Trace [7, 1, 5, 3, 6, 4]. Show the minimum price before each sell day and the best profit so far.',
      codeQuestion,
      'Why can an earlier buy price larger than the current minimum be discarded for every future sell day?',
    ],
    checks: [
      'I use no more than one buy before one sell and return 0 if no profitable trade exists.',
      'For each sell day, I compare against the cheapest earlier buy rather than a same-day or later price.',
      'I get profit 5, update the minimum after considering each day, and handle falling or empty prices.',
      codeCheck,
      'I justified why retaining only the minimum earlier price is safe and gave O(n) time, O(1) extra space.',
    ],
    hints: [
      'If you already know the best buy price before today, what profit would selling today make?',
      'Keep a running minimum of prices seen before the current sell day and a best profit.',
      'Initialize the minimum from the first day. For each later price, update best with price − minimum, then update the minimum. Start best at 0 to represent skipping a losing trade.',
    ],
    explanation:
        'Trying every earlier buy and later sell is correct but takes O(n²) time. Scan prices from left to right while retaining the minimum price seen before the current day. Selling today can produce current price minus that minimum. Update the best profit, then let today become the minimum for later days. The order guarantees a buy strictly before a sell. A best value of zero represents skipping the trade. This uses O(n) time and O(1) extra space; the input is not changed.',
  ),
  Lesson(
    id: 'graph-components-v1',
    title: 'Count separate friend groups',
    pattern: 'Graphs · BFS/DFS',
    summary: 'Traverse each undirected component from one unseen node.',
    statement:
        'A social graph has nodes numbered from 0 to n−1 and is given as an adjacency list. Each undirected edge appears in both endpoint lists; there are no self-edges or duplicate neighbors. Return the number of connected components. Isolated nodes each count as a group; an empty graph returns 0.',
    example: 'neighbors = [[1], [0, 2], [1], [4], [3], []]\nAnswer: 3.',
    constraints:
        '0–1,000 nodes. Neighbor indices are valid and adjacency is symmetric. Do not modify the input.',
    questions: [
      'What makes two people part of the same group? How should an isolated node and an empty graph count?',
      'How could BFS or DFS find every node reachable from a chosen start? What state prevents counting a node twice?',
      'Trace [[1], [0, 2], [1], [4], [3], []]. Which nodes form each component?',
      codeQuestion,
      'Why does starting a new traversal at each unseen node count exactly one additional component?',
    ],
    checks: [
      'I count connected components in the undirected graph and count each isolated node as one.',
      'Each traversal follows adjacency edges and marks nodes visited so they are processed once.',
      'I find three groups: {0, 1, 2}, {3, 4}, and {5}; empty input yields 0.',
      codeCheck,
      'I account for all nodes and edges in O(n + m) time and O(n) extra space.',
    ],
    hints: [
      'Scan node IDs. What does an unvisited node tell you about groups already explored?',
      'Start a queue or stack at each unseen node. Mark nodes when you add them and follow their neighbors.',
      'Increment the group count when a new traversal starts. Visit each node and each adjacency entry at most once.',
    ],
    explanation:
        'Initialize all nodes as unseen. Scan each node ID; when it is unseen, increment the component count and run BFS or DFS from it. Mark a node when it enters the worklist, then add each unseen neighbor. The traversal reaches exactly the nodes connected to that start. Later nodes in the same component are already marked, so they do not start another traversal. Isolated nodes start and finish a one-node traversal; an empty graph starts none. With n nodes and m undirected edges, adjacency lists give O(n + m) time and O(n) auxiliary space.',
  ),
  Lesson(
    id: 'first-signal-v1',
    title: 'Find the first one-off signal',
    pattern: 'Strings · frequency counts',
    summary: 'Count first, then keep the original order for the answer.',
    statement:
        'Given a lowercase signal string, return the index of its first character that appears exactly once. Return -1 if every character repeats or the string is empty.',
    example: 'signal = "swiss"\nAnswer: 1, the character "w".',
    constraints:
        '0–10,000 lowercase English letters. Return a zero-based index.',
    questions: [
      'What does “first” refer to: the character type or its position? What if no character occurs once?',
      'How can you count occurrences without losing the original left-to-right order?',
      'Trace "swiss". Which characters repeat, and why is the answer index 1 rather than 2?',
      codeQuestion,
      'Why can you return during a second scan, and what bounds the frequency table size?',
    ],
    checks: [
      'I return the first position whose character has frequency one, or -1 when none exists.',
      'I count every character, then scan the original string in order to choose the first qualifying position.',
      'For "swiss", I return 1; I also handle empty and all-repeated strings.',
      codeCheck,
      'I gave O(n) time and O(1) extra space for a fixed lowercase alphabet.',
    ],
    hints: [
      'A character’s count alone does not say whether it is earliest. What extra ordering information do you still have?',
      'Make one pass to build character counts, then read the string from its first position again.',
      'Return the first index i where count[signal[i]] == 1. If the scan ends, return -1.',
    ],
    explanation:
        'A nested comparison can count each character in O(n²) time and O(1) space for the fixed alphabet. A frequency table counts all lowercase letters in one pass. A second left-to-right pass returns the first index whose stored count is one. If none qualifies, return -1. Counting first avoids mistaking a character that appears unique so far for one that never repeats later. The two scans take O(n) time; the 26-entry table is O(1) extra space.',
  ),
  Lesson(
    id: 'anagram-pair-v1',
    title: 'Check whether two labels rearrange',
    pattern: 'Strings · frequency matching',
    summary: 'Compare character counts, not just the shared alphabet.',
    statement:
        'Return true when two lowercase labels contain exactly the same characters with the same multiplicities, in any order. Otherwise return false. Two empty labels match.',
    example: 'first = "listen", second = "silent"\nAnswer: true.',
    constraints:
        'Each label contains 0–10,000 lowercase English letters. Return a boolean.',
    questions: [
      'Does order matter? Do repeated letters need to occur the same number of times?',
      'What quick condition can reject a pair before counting? What information proves the remaining pairs match?',
      'Compare "listen" and "silent" by character counts. Why would checking only that both contain an "s" be insufficient?',
      codeQuestion,
      'How do your counts account for empty strings, different lengths, and extra copies of a letter?',
    ],
    checks: [
      'I compare character multiplicities and ignore order; empty strings match each other.',
      'My method rejects unequal lengths and verifies every lowercase character count.',
      'I return true for "listen" and "silent" and false when one label has a missing or extra character.',
      codeCheck,
      'I explained why matching counts are sufficient and gave O(n + m) time with fixed-alphabet space.',
    ],
    hints: [
      'Can two strings of different lengths contain exactly the same multiset of characters?',
      'Increment counts for one label and decrement for the other. What should every final count be?',
      'After checking equal lengths, update a 26-entry table across both strings. They match exactly when all counts are zero.',
    ],
    explanation:
        'Unequal lengths cannot be anagrams, so they can return false immediately. Otherwise use 26 counts: increment for each character in the first label and decrement for each in the second. The strings have identical multiplicities exactly when every count ends at zero. Empty labels leave all counts zero and match. This takes O(n + m) time and O(1) extra space for the fixed alphabet. Sorting both strings is also correct but takes O(n log n + m log m) time.',
  ),
  Lesson(
    id: 'distinct-letter-window-v1',
    title: 'Find the longest unbroken signal',
    pattern: 'Strings · sliding window',
    summary: 'Move past the last repeated character without rescanning.',
    statement:
        'Return the length of the longest contiguous substring with no repeated character. The input contains lowercase English letters. An empty string returns 0.',
    example: 'signal = "abcabcbb"\nAnswer: 3, from "abc".',
    constraints:
        '0–10,000 lowercase English letters. Return a length, not the substring.',
    questions: [
      'Must the characters be contiguous? What makes a substring invalid?',
      'A quadratic method checks every start. What boundary could help you keep a valid window as you scan right?',
      'Trace "abcabcbb". When the second "a" appears, which earlier positions can no longer belong to the window?',
      codeQuestion,
      'How does remembering the last index improve on removing one character at a time?',
    ],
    checks: [
      'I maximize the length of a contiguous substring with all distinct characters; empty input returns 0.',
      'My window has no repeated characters, and a repeat advances its left edge beyond the prior copy.',
      'I get length 3 for "abcabcbb" and do not move the left edge backward.',
      codeCheck,
      'I explained last-seen positions and gave O(n) time with O(1) space for lowercase letters.',
    ],
    hints: [
      'Keep a window that has no duplicates. What information would tell you where a repeated character last appeared?',
      'Store each character’s most recent index. If it falls inside the current window, move left to one position after it.',
      'Set left = max(left, last[signal[right]] + 1), update that character’s last index, and compare right − left + 1 with the best.',
    ],
    explanation:
        'For each right endpoint, remember the most recent index of its character. Keep a left boundary for a window with no duplicates. If the repeated character’s previous index is at or after left, advance left to one position past that index; taking max with the current left prevents moving backward. Record the current index and update the maximum window length. Each position is processed once, so this is O(n) time. A 26-entry last-seen table gives O(1) extra space. An empty input naturally returns zero.',
  ),
  Lesson(
    id: 'kth-score-v1',
    title: 'Find the kth-highest score',
    pattern: 'Heaps · keep only the best k',
    summary:
        'A small min-heap can track the ranking without sorting everything.',
    statement:
        'Given a list of scores and a valid rank k, return the kth-largest score. Equal scores each occupy a rank; for example, the second-largest score can equal the largest score.',
    example: 'scores = [3, 2, 1, 5, 6, 4], k = 2\nAnswer: 5.',
    constraints:
        '1–10,000 integer scores, each −1,000,000 to 1,000,000. 1 ≤ k ≤ scores.length. Do not modify the input.',
    questions: [
      'Does k count distinct score values or list entries? What happens when scores repeat?',
      'How could sorting answer this directly? If you only need one rank, what information can a size-k min-heap discard?',
      'Trace [3, 2, 1, 5, 6, 4] with k = 2. What does the heap root mean after each insertion?',
      codeQuestion,
      'Compare full sorting with keeping only k candidates. Give the time and extra-space costs of your chosen method.',
    ],
    checks: [
      'I return the kth value in descending order, counting duplicate entries as separate ranks.',
      'My method works for any valid k and does not change the input.',
      'For the example I return 5; I explained what the heap root represents or how sorting establishes the rank.',
      codeCheck,
      'I gave accurate complexity for my method and considered k = 1, k = n, and duplicate scores.',
    ],
    hints: [
      'If the scores were sorted from largest to smallest, which index would contain the answer?',
      'Keep at most k values in a min-heap. When it grows beyond k, remove its smallest value.',
      'After processing all scores, the heap contains the k largest entries and its minimum is the kth-largest score.',
    ],
    explanation:
        'Sorting a copy in descending order and taking index k − 1 is a direct O(n log n) solution with O(n) extra space. To retain only the needed candidates, keep a min-heap of at most k entries. Insert each score and remove the root whenever the heap exceeds k. The root is then the smallest of the k largest values, which is the kth-largest score. This takes O(n log(k + 1)) time and O(k) extra space. Duplicate values remain separate entries and therefore occupy separate ranks.',
  ),
  Lesson(
    id: 'top-frequency-v1',
    title: 'Choose the most frequent values',
    pattern: 'Heaps · frequency ranking',
    summary:
        'Count first, then retain only the strongest frequency candidates.',
    statement:
        'Return the k values with the greatest frequencies. If values tie at the cutoff, choose the smaller numeric values first. Return the chosen values in ascending numeric order. k is between zero and the number of distinct input values.',
    example: 'values = [3, 2, 3, 2, 1], k = 2\nAnswer: [2, 3].',
    constraints:
        '0–10,000 integer values, each −1,000,000 to 1,000,000. Do not modify the input.',
    questions: [
      'Why is frequency counting a separate step from choosing the top k values? What rule breaks ties at the cutoff?',
      'Once you have counts, how can a size-k heap avoid sorting every distinct value?',
      'Trace [3, 2, 3, 2, 1] with k = 2. Which value wins the tie, and what order must the result use?',
      codeQuestion,
      'How do you handle k = 0, all values distinct, and k equal to the number of distinct values?',
    ],
    checks: [
      'I select by descending frequency and use smaller numeric value to break a tie at the cutoff.',
      'I return exactly k distinct values in ascending numeric order.',
      'For the example I return [2, 3], and I separate selection order from required output order.',
      codeCheck,
      'I described frequency-map and selection costs and handle k = 0 without special invalid output.',
    ],
    hints: [
      'First build a map from each value to its count. How should two map entries be ranked?',
      'Rank higher counts first; for equal counts, rank smaller values first. A bounded heap can retain the best k entries.',
      'Select the first k values under that ranking rule, then sort those chosen values numerically before returning them.',
    ],
    explanation:
        'If k is zero, return an empty list. Otherwise count values in a frequency map. Rank entries by greater frequency first, then smaller numeric value. A size-k heap can keep the best k entries while processing the distinct values, using O(u log(k + 1)) selection time after counting, where u is the number of distinct values. Sort the selected k values in ascending numeric order for the required output. Counting takes O(n) expected time and O(u) space. Sorting all distinct entries is a simpler O(u log u) alternative.',
  ),
  Lesson(
    id: 'merge-streams-v1',
    title: 'Merge the sorted reading streams',
    pattern: 'Heaps · k-way merge',
    summary:
        'Only the next unread value from each stream can be the next result.',
    statement:
        'Given several individually sorted integer streams, return every value in one globally sorted list. Streams may be empty. Preserve duplicates and leave the input unchanged.',
    example:
        'streams = [[1, 4, 7], [2, 5], [3, 6, 8]]\nAnswer: [1, 2, 3, 4, 5, 6, 7, 8].',
    constraints:
        'At most 1,000 streams and 10,000 total values. Each stream is nondecreasing. Values are between −1,000,000 and 1,000,000.',
    questions: [
      'If each stream is sorted, which value from a stream is eligible to be emitted next? How many candidates are there?',
      'How can a min-heap combine the candidates without comparing every value against every other value?',
      'Trace the first few outputs for [[1, 4, 7], [2, 5], [3, 6, 8]]. After emitting 1, what replaces it in the heap?',
      codeQuestion,
      'If m streams contain N values and k streams are nonempty, state the heap size, time, and extra space. What does the method do with empty streams?',
    ],
    checks: [
      'I return all values in nondecreasing order and preserve duplicate values.',
      'My heap stores the current unread candidate from each nonempty stream and advances only the stream that supplied the minimum.',
      'I get [1, 2, 3, 4, 5, 6, 7, 8] and skip empty streams safely.',
      codeCheck,
      'I gave O(m + N log(k + 1)) time and described the O(k) heap apart from the output.',
    ],
    hints: [
      'The next value from a sorted stream is its first unread value. Keep one such candidate per nonempty stream.',
      'Put candidates in a min-heap with their stream and position. Remove the smallest candidate next.',
      'Append the minimum value, then insert the next value from that same stream if one remains. Continue until the heap is empty.',
    ],
    explanation:
        'Create a min-heap containing the first value from each nonempty stream, along with that stream’s index and next position. Repeatedly remove the smallest candidate, append its value, and insert the next value from the same stream if available. The heap never needs more than one candidate per nonempty stream. If there are m streams, N total values, and k nonempty streams, the method takes O(m + N log(k + 1)) time and O(k) heap space, excluding the output. Empty streams contribute no heap entries. A flatten-and-sort solution is also correct but takes O(m + N log(N + 1)) time.',
  ),
  Lesson(
    id: 'tree-depth-v1',
    title: 'Measure the tree height',
    pattern: 'Trees · depth-first and breadth-first search',
    summary: 'Track the level as you visit each child.',
    statement:
        'Return the maximum number of nodes on a root-to-leaf path. The tree is given as rows [value, leftIndex, rightIndex]; row 0 is the root and -1 means no child. An empty list represents an empty tree.',
    example:
        'nodes = [[1, 1, 2], [2, 3, 4], [3, -1, -1], [4, -1, -1], [5, -1, -1]]\nAnswer: 3.',
    constraints:
        'A valid binary tree with 0–1,000 nodes. Child indices are valid, each non-root node has one parent, and all nodes are reachable from row 0. Values are integers from −1,000,000 to 1,000,000. Do not modify the input.',
    questions: [
      'Which row is the root? How does -1 differ from a child index?',
      'How would a depth-first or breadth-first traversal carry the depth of the current node?',
      'Trace the example. What depth do the two leaf nodes below node 2 reach?',
      codeQuestion,
      'Why is the maximum over all visited nodes the tree height? Give time and auxiliary-space costs.',
    ],
    checks: [
      'I start from row 0, follow only nonnegative child indices, and return 0 for an empty tree.',
      'I count nodes on a path, so the root has depth 1 rather than depth 0 in the returned height.',
      'I return 3 for the example and do not count missing children as levels.',
      codeCheck,
      'I gave O(n) time and explained the traversal’s stack or queue space.',
    ],
    hints: [
      'Start at root index 0 with depth 1. What depth should each child receive?',
      'Visit each real child at parent depth + 1 and keep the largest depth seen.',
      'Use DFS with a stack or BFS with a queue of (nodeIndex, depth). Return the largest depth, or 0 if there is no root.',
    ],
    explanation:
        'Start at row 0 with depth 1. For each visited row, update the maximum and visit each child whose index is not -1 with depth one greater. DFS uses a stack or recursion; BFS uses a queue. Every node is reached once, so the time is O(n). The auxiliary stack, recursion, or queue uses O(h) for depth-first traversal or O(w) for breadth-first traversal, where h is tree height and w is maximum level size. The empty tree has height zero.',
  ),
  Lesson(
    id: 'tree-width-v1',
    title: 'Find the widest tree level',
    pattern: 'Trees · level-order traversal',
    summary: 'Count a level before moving on to its children.',
    statement:
        'Return the largest number of real nodes found at any one depth. Missing children do not count as positions. The tree uses rows [value, leftIndex, rightIndex], with row 0 as root and -1 for a missing child. An empty tree returns 0.',
    example:
        'nodes = [[1, 1, 2], [2, 3, 4], [3, 5, -1], [4, -1, -1], [5, -1, -1], [6, -1, -1]]\nAnswer: 3.',
    constraints:
        'A valid binary tree with 0–1,000 nodes. Child indices are valid, each non-root node has one parent, and all nodes are reachable from row 0. Do not modify the input.',
    questions: [
      'What makes two nodes belong to the same level? Do missing child slots affect this count?',
      'How can a queue tell you where the current level ends before you start processing the next one?',
      'Trace the example one level at a time. Which level contains three real nodes?',
      codeQuestion,
      'Why must you capture the current queue size before adding children? Give time and auxiliary-space costs.',
    ],
    checks: [
      'I count real nodes at each depth and return 0 for an empty tree.',
      'I process exactly the nodes that were in the queue at the start of a level.',
      'I return 3 for the example and ignore absent children.',
      codeCheck,
      'I gave O(n) time and O(w) queue space, where w is the widest level.',
    ],
    hints: [
      'Use breadth-first search. The number of entries currently in the queue is the size of the next level to process.',
      'Save that queue size before the level loop. Count those nodes while appending their real children for the next level.',
      'After each level, update the best count. The maximum of these counts is the answer.',
    ],
    explanation:
        'Use breadth-first search starting with root index 0. At the start of each level, save the queue length. Process exactly that many entries, counting each real node and appending its non-missing children. Update the maximum level count after the loop. Each node is enqueued once, so time is O(n), and the queue uses O(w) auxiliary space for maximum level width w. This definition counts real nodes only; it does not measure gaps between the leftmost and rightmost positions.',
  ),
  Lesson(
    id: 'tree-path-sum-v1',
    title: 'Check a root-to-leaf total',
    pattern: 'Trees · path search',
    summary:
        'A target is reached only when a complete root-to-leaf path matches.',
    statement:
        'Return true if any path from the root to a leaf has values summing to target. A leaf has no children. The tree uses rows [value, leftIndex, rightIndex], with row 0 as root and -1 for a missing child. An empty tree returns false.',
    example:
        'nodes = [[5, 1, 2], [4, 3, -1], [8, 4, 5], [11, 6, 7], [13, -1, -1], [4, -1, 8], [7, -1, -1], [2, -1, -1], [1, -1, -1]], target = 22\nAnswer: true, from 5 → 4 → 11 → 2.',
    constraints:
        'A valid binary tree with 0–1,000 nodes. Child indices are valid, each non-root node has one parent, and all nodes are reachable from row 0. Values and target are integers from −1,000,000 to 1,000,000. Do not modify the input.',
    questions: [
      'What qualifies as a complete path? Is reaching an internal node with the target sum enough?',
      'What running information can a DFS carry from the root to each child?',
      'Trace the example. Why does reaching node 11 not finish the check until you reach its leaf child?',
      codeQuestion,
      'How do negative values affect pruning? Give time and auxiliary-space costs.',
    ],
    checks: [
      'I check the sum only at a leaf, and an empty tree returns false.',
      'My DFS carries the accumulated root-to-current-node sum and visits both existing children.',
      'I return true for target 22 using the path 5 → 4 → 11 → 2.',
      codeCheck,
      'I avoid pruning based on current sum because node values may be negative, and gave O(n) time.',
    ],
    hints: [
      'Begin with the root value in a running sum. What should happen when you reach a missing child?',
      'At a real node, add its value. If it is a leaf, compare the sum with target; otherwise continue into its real children.',
      'Use a stack of (nodeIndex, sum) pairs or recursive DFS. Return true only for a matching leaf path.',
    ],
    explanation:
        'Run DFS from root index 0 while carrying the sum from the root through the current node. At a leaf, compare that sum with target. For an internal node, continue to each existing child with the updated sum. The check must happen at leaves; an internal prefix that equals target may still extend to a different total. Because values can be negative, do not prune solely because the running sum exceeds target. Each node is visited once for O(n) time; a DFS stack or recursion uses O(h) auxiliary space for tree height h. An empty tree has no root-to-leaf path.',
  ),
  Lesson(
    id: 'list-middle-v1',
    title: 'Find the middle node',
    pattern: 'Linked lists · fast and slow pointers',
    summary:
        'Move one pointer twice as quickly to find the midpoint in one pass.',
    statement:
        'Return the node index at the middle of a finite singly linked list. For an even number of nodes, return the second middle. Each row is [value, nextIndex], row 0 is the head, and -1 ends the list. An empty list returns -1.',
    example:
        'nodes = [[10, 1], [20, 2], [30, 3], [40, 4], [50, -1]]\nAnswer: 2.',
    constraints:
        '0–10,000 nodes. The list is acyclic, every row is reachable from row 0 when nonempty, and each next index is valid or -1. Values may repeat. Do not modify input.',
    questions: [
      'Does the answer ask for a node value or its index? Which middle should you choose when the length is even?',
      'How can a slow pointer advance one link while a fast pointer advances two links?',
      'Trace both pointers through the five-node example. Where is slow when fast reaches the end?',
      codeQuestion,
      'Why does the fast pointer’s stopping condition produce the second middle for even lengths? Give complexity.',
    ],
    checks: [
      'I return the node index, choose the second middle for an even list, and return -1 for an empty list.',
      'Fast advances twice for every one slow step and stops safely at -1.',
      'I return index 2 for the example and do not change any next link.',
      codeCheck,
      'I gave O(n) time and O(1) extra space.',
    ],
    hints: [
      'For a nonempty list, start both pointers at row 0. Let slow move one link for each iteration.',
      'Before moving fast twice, check that fast and fast.next both exist.',
      'Continue while two fast steps are possible. Slow then identifies the second middle when the length is even.',
    ],
    explanation:
        'For a nonempty list, initialize slow and fast to row 0. While fast and its next node exist, move slow one link and fast two links. When the loop ends, slow is at the middle; with an even number of nodes it is the second middle. Return its index, or -1 for an empty list. Each node is traversed at most once, so time is O(n) and extra space is O(1). The fast-pointer guards prevent reading past the end.',
  ),
  Lesson(
    id: 'list-cycle-v1',
    title: 'Check for a loop in the chain',
    pattern: 'Linked lists · cycle detection',
    summary: 'Two pointers moving at different speeds reveal a repeated node.',
    statement:
        'Return true if following next links from row 0 eventually visits a node again. Each row is [value, nextIndex]; -1 ends a chain. An empty list has no cycle. Only nodes reachable from row 0 matter.',
    example:
        'nodes = [[3, 1], [2, 2], [0, 1]]\nAnswer: true, because the last node links back to index 1.',
    constraints:
        '0–10,000 rows. Each next index is -1 or a valid row index; input may contain a cycle. Values may repeat and do not identify nodes. Do not modify input.',
    questions: [
      'Why can equal values not prove a cycle? What must be equal for two pointers to meet?',
      'How do slow and fast move through the next links? What happens if the chain ends?',
      'Trace the example after slow and fast first enter the loop. Why will they eventually meet at the same index?',
      codeQuestion,
      'What are the time and extra-space costs of slow/fast detection compared with a visited-index set?',
    ],
    checks: [
      'I detect revisiting a node index, not merely seeing a repeated value.',
      'I advance slow one link and fast two, checking for -1 before dereferencing.',
      'I return true for the example, false for an acyclic chain, and false for an empty list.',
      codeCheck,
      'I gave O(n) time and O(1) extra space, and do not mutate links.',
    ],
    hints: [
      'A visited set can detect a repeated index. Can you use less extra space?',
      'Move slow by one link and fast by two. If fast reaches -1, there is no cycle.',
      'If the pointers enter a cycle, fast gains one node on slow each turn and must eventually meet it.',
    ],
    explanation:
        'If the list is nonempty, start slow and fast at row 0. Move slow by one next link and fast by two, returning true if their node indices meet. Before moving, handle -1 so an acyclic chain returns false without invalid indexing. If fast reaches the end, no node repeats. If both enter a cycle, fast gains one position per iteration relative to slow and eventually catches it. The traversal is O(n) time and O(1) extra space. A visited-index set is another correct method with O(n) extra space. Compare indices rather than values, since different nodes may hold equal values.',
  ),
  Lesson(
    id: 'list-nth-from-end-v1',
    title: 'Locate the nth node from the end',
    pattern: 'Linked lists · two-pointer gap',
    summary: 'Keep a fixed distance between two pointers in one pass.',
    statement:
        'Return the node index that is nth from the end of a nonempty acyclic singly linked list. Each row is [value, nextIndex], row 0 is the head, and -1 ends the list. n is valid and between 1 and the list length. Do not remove the node.',
    example:
        'nodes = [[10, 1], [20, 2], [30, 3], [40, 4], [50, -1]], n = 2\nAnswer: 3.',
    constraints:
        '1–10,000 nodes. Every row is reachable from row 0, each next index is valid or -1, and the list has no cycle. Values may repeat. Do not modify input.',
    questions: [
      'What does nth from the end mean when n = 1? Why should the result be a node index rather than its possibly repeated value?',
      'How can you create a gap of n links between fast and slow before moving them together?',
      'Trace n = 2 in the example. Where is slow when fast steps past the last node?',
      codeQuestion,
      'Why does the fixed gap make slow stop at the requested index in one pass? Give complexity.',
    ],
    checks: [
      'I return the requested node index and respect the valid n range.',
      'I move fast forward n links, then advance fast and slow together until fast is -1.',
      'I return index 3 for n = 2 in the example, and handle n equal to the full list length.',
      codeCheck,
      'I gave O(n) time and O(1) extra space without changing the chain.',
    ],
    hints: [
      'Advance fast n links before moving slow. Then the pointers are separated by n nodes.',
      'Move both pointers one link at a time until fast reaches -1.',
      'Because fast is n links ahead, slow is at the nth node from the end when fast passes the tail.',
    ],
    explanation:
        'Set fast and slow to row 0, then advance fast n links. Move both pointers one link at a time while fast is not -1. When fast reaches the end, slow is at the node n from the end because the gap stayed n links. Return slow’s index. The contract guarantees n is valid and the list is nonempty, so slow identifies a node. The method takes O(n) time and O(1) extra space and leaves the links unchanged.',
  ),
  Lesson(
    id: 'subset-sum-v1',
    title: 'Choose items to reach a target',
    pattern: 'Backtracking · include or skip',
    summary: 'Explore each choice once, while keeping track of what remains.',
    statement:
        'Return true if some subset of the given positive values sums exactly to target. Each array position may be used at most once, including when values repeat. An empty subset is allowed, so target = 0 returns true.',
    example: 'values = [3, 4, 5, 6], target = 9\nAnswer: true, using 3 and 6.',
    constraints:
        '0–20 values, each 1–100. Target is 0–1,000. Do not modify input.',
    questions: [
      'Does each value represent one reusable number or one particular array position? Can the empty subset solve target 0?',
      'At each position, what are the two choices? What information should a recursive call remember?',
      'Trace target 9 for [3, 4, 5, 6]. Which branch finds 3 + 6, and when may a branch stop?',
      codeQuestion,
      'What is the worst-case number of decision paths? How does the positive-value constraint permit pruning?',
    ],
    checks: [
      'I use each input position at most once and treat target 0 as reachable by the empty subset.',
      'At each position I branch into take or skip, then advance to the next position.',
      'I return true for the example and do not reuse a value or mutate the input.',
      codeCheck,
      'I gave O(2^n) worst-case time and O(n) recursion space, and only prune using the positive-value contract.',
    ],
    hints: [
      'Ask whether the remaining target can be made using positions i and later.',
      'For position i, try excluding it and including it once; both choices continue at i + 1.',
      'Return true when the remainder is zero. If positions are exhausted first, return false. Positive values also let you stop when the remainder becomes negative.',
    ],
    explanation:
        'Define a search state by the next position i and remaining target r. If r is zero, a subset has been found. If no positions remain, the branch fails. Otherwise try skipping values[i] and taking it once, then continue at i + 1. Because values are positive, a negative remainder can be pruned. There can be O(2^n) branches and O(n) recursion depth. A dynamic-programming table can reduce repeated work, but the decision tree makes the include/skip choices explicit.',
  ),
  Lesson(
    id: 'combination-count-v1',
    title: 'Count combinations with reusable values',
    pattern: 'Backtracking · choose or reuse',
    summary: 'Keep a starting position so a combination is counted only once.',
    statement:
        'Return the number of combinations that sum to target using the distinct positive candidate values. A candidate may be reused any number of times, but different orders of the same values count as one combination. target = 0 has one combination: choose nothing.',
    example:
        'candidates = [2, 3, 6, 7], target = 7\nAnswer: 2: [2, 2, 3] and [7].',
    constraints:
        '0–12 distinct candidates, each 1–50. Target is 0–50. The answer fits a signed 32-bit integer. Do not modify input.',
    questions: [
      'May a candidate be reused? Do [2, 3] and [3, 2] count as one combination or two?',
      'How can a recursive call remember the earliest candidate it may choose next?',
      'Trace target 7 with [2, 3, 6, 7]. Why does choosing 2 leave 2 available for the next step?',
      codeQuestion,
      'What are your base cases for remainder 0, a negative remainder, and candidates exhausted?',
    ],
    checks: [
      'I count combinations without treating different orderings as separate answers, and a chosen value can be reused.',
      'My search keeps a start index and recurses with the same index after choosing a candidate.',
      'I return 2 for the example: [2, 2, 3] and [7].',
      codeCheck,
      'I return 1 for target 0 and 0 when a positive remainder cannot be formed.',
    ],
    hints: [
      'Use a start index to keep choices in a consistent order and avoid counting permutations.',
      'When you choose candidate i, recurse from i again to allow reuse. When you skip it, continue from i + 1.',
      'Return 1 when the remainder is zero, 0 when it is negative or no candidates remain, and add the counts from choose and skip branches.',
    ],
    explanation:
        'Search with a candidate start index and remaining target. Choosing candidate i reduces the remainder and keeps i as the next start, allowing reuse. Skipping it moves to i + 1. This fixed nondecreasing choice order counts each combination once, regardless of how its values could be permuted. Return one completed combination when the remainder reaches zero, and zero when it becomes negative or candidates run out. The worst case is exponential in the target/candidate choices, with recursion depth bounded by target divided by the smallest candidate. A one-dimensional dynamic-programming count is another valid optimization.',
  ),
  Lesson(
    id: 'target-sum-ways-v1',
    title: 'Assign signs to reach the target',
    pattern: 'Backtracking · two choices per value',
    summary: 'Try plus and minus for each position, then combine the counts.',
    statement:
        'Return the number of ways to put either a plus or a minus sign before every value so the signed total equals target. Every input position receives a sign; equal values at different positions are still distinct choices. A zero has two sign choices.',
    example: 'values = [1, 1, 1, 1, 1], target = 3\nAnswer: 5.',
    constraints:
        '0–20 values, each 0–20. Target is −1,000 to 1,000. The answer fits a signed 32-bit integer. Do not modify input.',
    questions: [
      'How many choices does each position create? If two values are equal, do their positions remain separate choices?',
      'What state would let you count all completions without constructing every signed expression?',
      'For [1, 1, 1, 1, 1] and target 3, how many values must receive a minus sign?',
      codeQuestion,
      'Why does a zero double the number of sign assignments for the same remaining total?',
    ],
    checks: [
      'I assign one sign to every position and count different position choices separately, including both signs for zero.',
      'For each value I sum the ways from choosing plus and choosing minus.',
      'I return 5 for the example and 1 for an empty input with target 0.',
      codeCheck,
      'I gave O(2^n) worst-case time and O(n) recursion depth, and explained zero handling.',
    ],
    hints: [
      'At each position, the next total can add the value or subtract it.',
      'Define a recursive count by the current index and the remaining target.',
      'At the end of the array return 1 only when the remaining target is zero. Otherwise add the counts from remaining − value and remaining + value.',
    ],
    explanation:
        'Let search(i, remaining) count assignments from position i onward that reach the remaining total. Recurse twice: assign plus and reduce remaining by values[i], or assign minus and increase remaining by values[i]. At the end return one if remaining is zero, otherwise zero. Add the two branch counts because they represent distinct sign choices at this position. A zero creates two separate branches with the same numeric remainder, so it doubles the count. The search takes O(2^n) time and O(n) recursion space; memoization by index and remaining total can reuse repeated states.',
  ),
];
