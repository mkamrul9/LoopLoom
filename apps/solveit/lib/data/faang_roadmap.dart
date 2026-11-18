import 'interview_sprints.dart';

/// An independent, pattern-based preparation route through the existing
/// Mastery 300 catalog. This is not a list of questions reported by, or
/// guaranteed to be asked at, any particular company.
const faangStyleRoadmap = InterviewSprint(
  'FAANG-style coding prep',
  '48 focused problems across eight topic blocks. Begin with core patterns, then move to trees, graphs, dynamic programming, and mixed interview rounds. Progress is shared with Blind 75 and Mastery 300.',
  [
    InterviewSprintDay(
      'Block 1 · Arrays & hashing',
      'Build lookup, counting, and prefix-sum instincts.',
      [
        'two-sum',
        'group-anagrams',
        'product-of-array-except-self',
        'longest-consecutive-sequence',
        'subarray-sum-equals-k',
        'top-k-frequent-elements',
      ],
    ),
    InterviewSprintDay(
      'Block 2 · Pointers & windows',
      'Explain the invariant and every boundary move.',
      [
        'valid-palindrome',
        '3sum',
        'container-with-most-water',
        'longest-substring-without-repeating-characters',
        'longest-repeating-character-replacement',
        'minimum-window-substring',
      ],
    ),
    InterviewSprintDay(
      'Block 3 · Search & stacks',
      'Practice binary-search boundaries and monotonic state.',
      [
        'binary-search',
        'search-in-rotated-sorted-array',
        'find-minimum-in-rotated-sorted-array',
        'koko-eating-bananas',
        'valid-parentheses',
        'daily-temperatures',
      ],
    ),
    InterviewSprintDay(
      'Block 4 · Lists & intervals',
      'Trace pointer changes and interval overlap.',
      [
        'reverse-linked-list',
        'merge-two-sorted-lists',
        'reorder-list',
        'copy-list-with-random-pointer',
        'merge-intervals',
        'insert-interval',
      ],
    ),
    InterviewSprintDay(
      'Block 5 · Trees & heaps',
      'Choose traversal order and state the heap invariant.',
      [
        'binary-tree-level-order-traversal',
        'validate-binary-search-tree',
        'binary-tree-right-side-view',
        'kth-smallest-element-in-a-bst',
        'kth-largest-element-in-an-array',
        'find-median-from-data-stream',
      ],
    ),
    InterviewSprintDay(
      'Block 6 · Graphs',
      'Model edges before choosing BFS, DFS, or shortest path.',
      [
        'number-of-islands',
        'clone-graph',
        'course-schedule',
        'rotting-oranges',
        'pacific-atlantic-water-flow',
        'network-delay-time',
      ],
    ),
    InterviewSprintDay(
      'Block 7 · Search & DP',
      'Separate decisions, state, and repeated subproblems.',
      [
        'subsets',
        'combination-sum-ii',
        'word-search',
        'coin-change',
        'word-break',
        'longest-increasing-subsequence',
      ],
    ),
    InterviewSprintDay(
      'Block 8 · Mixed rounds',
      'Solve under a timer, then explain tradeoffs and edge cases.',
      [
        'serialize-and-deserialize-binary-tree',
        'merge-k-sorted-lists',
        'task-scheduler',
        'shortest-path-in-binary-matrix',
        'edit-distance',
        'largest-rectangle-in-histogram',
      ],
    ),
  ],
);
