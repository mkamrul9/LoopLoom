/// A short, local placement check for choosing what to practice next.
///
/// It measures recognition of a few common interview patterns, not interview
/// readiness or coding ability.
class DiagnosticChoice {
  const DiagnosticChoice(this.label);

  final String label;
}

class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.pattern,
    required this.patternNeedle,
    required this.prompt,
    required this.choices,
    required this.bestChoice,
    required this.explanation,
  });

  final String id;
  final String pattern;
  final String patternNeedle;
  final String prompt;
  final List<DiagnosticChoice> choices;
  final int bestChoice;
  final String explanation;
}

const interviewDiagnostic = <DiagnosticQuestion>[
  DiagnosticQuestion(
    id: 'pair-sum',
    pattern: 'Arrays & hashing',
    patternNeedle: 'arrays & hashing',
    prompt:
        'An unsorted list can contain negative values and duplicates. You need two distinct indices whose values add to a target. Which method gives expected linear time while retaining the original indices?',
    choices: [
      DiagnosticChoice('Try every pair and keep the first one that matches.'),
      DiagnosticChoice(
        'Scan once, storing values already seen and checking the needed complement.',
      ),
      DiagnosticChoice(
        'Sort value-index pairs, then use two pointers to find the target.',
      ),
      DiagnosticChoice(
        'Store seen values without their positions, then return the matching values as indices.',
      ),
    ],
    bestChoice: 1,
    explanation:
        'A hash set or map can check each needed complement in average O(1), giving O(n) expected time. Sorting can lose original indices unless they are carried along.',
  ),
  DiagnosticQuestion(
    id: 'sorted-pair',
    pattern: 'Two pointers',
    patternNeedle: 'two pointers',
    prompt:
        'A sorted list must be checked for a pair with a target sum. Which movement uses the ordering to avoid checking every pair?',
    choices: [
      DiagnosticChoice(
        'For every value, restart a binary search over the entire list.',
      ),
      DiagnosticChoice(
        'Use a hash set of earlier values and ignore the sorted order.',
      ),
      DiagnosticChoice(
        'Keep two indices at the ends; move the left one up for a small sum and the right one down for a large sum.',
      ),
      DiagnosticChoice(
        'Store every pair in a second list before comparing sums.',
      ),
    ],
    bestChoice: 2,
    explanation:
        'Because the values are sorted, moving the left pointer increases the sum and moving the right pointer decreases it. Each index moves only inward, so the scan is O(n).',
  ),
  DiagnosticQuestion(
    id: 'bounded-window',
    pattern: 'Sliding window',
    patternNeedle: 'sliding window',
    prompt:
        'Find the longest substring containing at most k distinct characters. What state should a linear scan maintain?',
    choices: [
      DiagnosticChoice('A fresh set for every possible substring.'),
      DiagnosticChoice(
        'Use a fixed window of exactly k characters because the limit is k distinct characters.',
      ),
      DiagnosticChoice('Track the longest run of one repeated character.'),
      DiagnosticChoice(
        'A moving window with character counts; shrink its left edge while the distinct count exceeds k.',
      ),
    ],
    bestChoice: 3,
    explanation:
        'A frequency map describes the current window. Expand right, then move left until the window is valid; this keeps the work linear because each edge advances at most n times.',
  ),
  DiagnosticQuestion(
    id: 'merge-intervals',
    pattern: 'Sorting & intervals',
    patternNeedle: 'sorting & intervals',
    prompt:
        'You are given intervals in arbitrary order and must merge all overlapping ranges. What makes a one-pass merge possible?',
    choices: [
      DiagnosticChoice(
        'Sort by start, then compare each interval with the end of the current merged range.',
      ),
      DiagnosticChoice(
        'Compare only neighboring intervals in the original input order.',
      ),
      DiagnosticChoice(
        'After sorting by start, compare each range with the previous input end without extending the merged end.',
      ),
      DiagnosticChoice(
        'Merge only intervals that have identical start values.',
      ),
    ],
    bestChoice: 0,
    explanation:
        'Sorting by start puts possible overlaps next to each other. A single forward pass extends the current end or starts a new output interval; clarify whether touching endpoints count as overlap.',
  ),
  DiagnosticQuestion(
    id: 'unweighted-shortest-path',
    pattern: 'Graphs',
    patternNeedle: 'graphs',
    prompt:
        'Every move in a grid costs one step. You need the fewest moves from a start cell to a destination in O(V + E). Which traversal fits?',
    choices: [
      DiagnosticChoice(
        'Depth-first search; the first route found must be shortest.',
      ),
      DiagnosticChoice(
        'A greedy move toward the destination without revisiting cells.',
      ),
      DiagnosticChoice('Breadth-first search with a visited set and a queue.'),
      DiagnosticChoice(
        'Explore every possible route with depth-first search, then keep the shortest.',
      ),
    ],
    bestChoice: 2,
    explanation:
        'BFS explores cells in increasing distance layers when every edge has equal cost. Mark cells when enqueued so each is processed once.',
  ),
  DiagnosticQuestion(
    id: 'reusable-minimum-items',
    pattern: 'Dynamic programming',
    patternNeedle: 'dynamic programming',
    prompt:
        'Given reusable item sizes, find the minimum number needed to reach an exact total. Which idea handles the repeated smaller totals?',
    choices: [
      DiagnosticChoice(
        'Always take the largest item that fits; this is optimal for every set of sizes.',
      ),
      DiagnosticChoice(
        'Store the best answer for each total and build it from smaller totals.',
      ),
      DiagnosticChoice(
        'Try every item sequence recursively without remembering solved totals.',
      ),
      DiagnosticChoice(
        'Store only whether each total is reachable, not the minimum item count.',
      ),
    ],
    bestChoice: 1,
    explanation:
        'Define a state for each total and transition from totals reachable by one more item. The base case is total zero; unreachable totals need an explicit sentinel.',
  ),
  DiagnosticQuestion(
    id: 'top-k-stream',
    pattern: 'Heaps',
    patternNeedle: 'heaps',
    prompt:
        'A stream is too large to sort fully, but you need its k largest values. Which structure keeps the useful candidates?',
    choices: [
      DiagnosticChoice(
        'Store the whole stream, then use quickselect to find its kth-largest value.',
      ),
      DiagnosticChoice(
        'Keep a sorted list of the best k candidates and insert each new value in place.',
      ),
      DiagnosticChoice(
        'Use a max-heap for every stream value, then remove the smallest n-k values.',
      ),
      DiagnosticChoice(
        'A min-heap capped at k values; discard the smallest when a larger candidate arrives.',
      ),
    ],
    bestChoice: 3,
    explanation:
        'A min-heap of size k exposes the weakest retained candidate at its root. The stream can be processed in O(n log k) time with O(k) extra space.',
  ),
  DiagnosticQuestion(
    id: 'bracket-nesting',
    pattern: 'Stacks',
    patternNeedle: 'stacks',
    prompt:
        'A string contains opening and closing brackets of several kinds. What helps verify that every closer matches the most recent unmatched opener?',
    choices: [
      DiagnosticChoice(
        'Push openers; on a closer, compare it with and remove the top opener.',
      ),
      DiagnosticChoice(
        'Count all opening and closing brackets, ignoring their order.',
      ),
      DiagnosticChoice(
        'Use a queue so each closer matches the earliest unmatched opener.',
      ),
      DiagnosticChoice(
        'Track a separate net count for each bracket kind and accept if none go negative.',
      ),
    ],
    bestChoice: 0,
    explanation:
        'Nested brackets follow last-in, first-out order. A stack preserves that order; reject a mismatched closer and require the stack to be empty at the end.',
  ),
];
