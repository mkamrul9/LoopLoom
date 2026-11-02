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
    final lesson = Lesson(
      id: 'mastery300-$slug-v1',
      title: title,
      pattern: pattern,
      summary: 'Practice $cue through $title.',
      statement:
          'Open the linked challenge and restate its input, required output, and constraints in your own words. Then solve $title by identifying when $cue is useful. SolveIt’s guided prompts help you reason through the external challenge; the challenge page supplies its full statement and examples.',
      example:
          'Use one official example from the linked challenge. Before coding, write the expected result and the intermediate state that best tests $cue.',
      constraints:
          'Read the challenge constraints before choosing a data structure or complexity target. Clarify empty, minimal, duplicate, and boundary inputs where the contract allows them.',
      questions: [
        'Restate $title: what are the inputs, exact output, and important constraints?',
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
      hints: _patternHints(pattern),
      explanation:
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
    'Heaps',
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
    'Greedy',
    'Medium',
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
    'Greedy',
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

final mastery300Entries = List<Blind75Entry>.unmodifiable([
  ...blind75Entries,
  for (var i = 0; i < mastery300Seeds.length; i++)
    mastery300Seeds[i].build(blind75Entries.length + i + 1),
]);

final mastery300ByLessonId = {
  for (final entry in mastery300Entries) entry.lesson.id: entry,
};
