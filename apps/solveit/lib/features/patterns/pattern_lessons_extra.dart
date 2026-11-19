part of 'pattern_library.dart';

const extraPatternLessons = <PatternLesson>[
  PatternLesson(
    category: 'Linked lists',
    visual: PatternVisual.links,
    title: 'Reverse a linked list',
    cue: 'Save the next link before changing the current one.',
    concept:
        'A linked list is held together by references. Reversal changes one arrow at a time while prev keeps the already reversed chain.',
    recognize:
        'The input is a chain of nodes, and the task changes, skips, or reorders next links.',
    whenToUse:
        'A problem asks you to reorder nodes in place or move through a chain with constant extra space.',
    softwareUse:
        'A memory-managed queue or LRU cache rewires linked nodes when entries move or are removed.',
    watchFor:
        'Save next before overwriting current.next. An empty list and one node need no special loop.',
    example: 'Reverse 1 → 2 → 3 → null.',
    problemSlug: 'reverse-linked-list',
    tokens: ['1', '2', '3'],
    frames: [
      PatternFrame(
        'Start',
        'Prev is null; current is 1.',
        [0],
        state: 'prev: null · current: 1 · next: 2',
        display: ['1', '2', '3'],
      ),
      PatternFrame(
        'Flip 1',
        'Save 2, then point 1 to null.',
        [0],
        state: 'reversed: 1 → null · remaining: 2 → 3',
        display: ['1→∅', '2', '3'],
      ),
      PatternFrame(
        'Flip 2',
        'Save 3, then point 2 back to 1.',
        [0, 1],
        state: 'reversed: 2 → 1 → null · remaining: 3',
        display: ['2→1', '3'],
      ),
      PatternFrame(
        'Flip 3',
        'Point 3 back to 2. Prev is the new head.',
        [0],
        state: 'new head: 3 → 2 → 1 → null',
        display: ['3→2→1'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def reverse(head):\n    prev = None\n    while head:\n        nxt = head.next\n        head.next = prev\n        prev, head = head, nxt\n    return prev',
      CodeLanguage.cpp:
          'ListNode* reverse(ListNode* head) {\n    ListNode* prev = nullptr;\n    while (head) {\n        auto* next = head->next;\n        head->next = prev;\n        prev = head; head = next;\n    }\n    return prev;\n}',
      CodeLanguage.javascript:
          'function reverse(head) {\n  let prev = null;\n  while (head) {\n    const next = head.next;\n    head.next = prev;\n    prev = head; head = next;\n  }\n  return prev;\n}',
      CodeLanguage.typescript:
          'function reverse(head: ListNode | null): ListNode | null {\n  let prev: ListNode | null = null;\n  while (head) {\n    const next: ListNode | null = head.next;\n    head.next = prev;\n    prev = head; head = next;\n  }\n  return prev;\n}',
    },
  ),
  PatternLesson(
    category: 'Stacks',
    visual: PatternVisual.stack,
    title: 'Monotonic stack',
    cue: 'Keep only unresolved candidates.',
    concept:
        'A monotonic stack holds indices whose answer has not appeared yet. A warmer temperature resolves every cooler index on top.',
    recognize:
        'The prompt asks for the next greater or smaller item, or how long an item waits to be resolved.',
    whenToUse:
        'You need the next greater or smaller value, or an earlier item must wait for a future one.',
    softwareUse:
        'A charting service can find the next higher measurement for each earlier measurement in one pass.',
    watchFor:
        'Store indices when the answer is a distance. Pop while the new value resolves the top, then push the new index.',
    example: 'Find days until warmer for [73, 74, 71, 76].',
    problemSlug: 'daily-temperatures',
    tokens: ['73', '74', '71', '76'],
    frames: [
      PatternFrame(
        'Push day 0',
        'No earlier day to resolve.',
        [0],
        state: 'stack: [0] · answer: [0, 0, 0, 0]',
        display: ['73'],
      ),
      PatternFrame(
        'Day 1 is warmer',
        'Pop day 0; its wait was one day.',
        [0, 1],
        state: 'stack: [1] · answer: [1, 0, 0, 0]',
        display: ['74'],
      ),
      PatternFrame(
        'Day 2 is cooler',
        'Keep day 1, then push day 2.',
        [1, 2],
        state: 'stack: [1, 2] · answer: [1, 0, 0, 0]',
        display: ['74', '71'],
      ),
      PatternFrame(
        'Day 3 resolves both',
        'Pop days 2 and 1; their waits are 1 and 2.',
        [1, 2, 3],
        state: 'stack: [3] · answer: [1, 2, 1, 0]',
        display: ['76'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def warmer_days(temps):\n    answer = [0] * len(temps)\n    stack = []\n    for i, temp in enumerate(temps):\n        while stack and temps[stack[-1]] < temp:\n            j = stack.pop()\n            answer[j] = i - j\n        stack.append(i)\n    return answer',
      CodeLanguage.cpp:
          'vector<int> warmerDays(const vector<int>& t) {\n    vector<int> answer(t.size()), stack;\n    for (int i = 0; i < (int)t.size(); ++i) {\n        while (!stack.empty() && t[stack.back()] < t[i]) {\n            int j = stack.back(); stack.pop_back();\n            answer[j] = i - j;\n        }\n        stack.push_back(i);\n    }\n    return answer;\n}',
      CodeLanguage.javascript:
          'function warmerDays(temps) {\n  const answer = Array(temps.length).fill(0), stack = [];\n  temps.forEach((temp, i) => {\n    while (stack.length && temps[stack.at(-1)] < temp) {\n      const j = stack.pop(); answer[j] = i - j;\n    }\n    stack.push(i);\n  });\n  return answer;\n}',
      CodeLanguage.typescript:
          'function warmerDays(temps: number[]): number[] {\n  const answer = Array<number>(temps.length).fill(0);\n  const stack: number[] = [];\n  temps.forEach((temp, i) => {\n    while (stack.length && temps[stack[stack.length - 1]] < temp) {\n      const j = stack.pop()!; answer[j] = i - j;\n    }\n    stack.push(i);\n  });\n  return answer;\n}',
    },
  ),
  PatternLesson(
    category: 'Trees',
    visual: PatternVisual.tree,
    title: 'Tree recursion',
    cue: 'Let each child return a useful answer.',
    concept:
        'A recursive call solves the same question for a smaller subtree. For depth, the parent combines left and right depths with one extra level.',
    recognize:
        'The input is a tree and each node asks the same question of its children.',
    whenToUse:
        'The input branches into subtrees and a parent answer can be built from child answers.',
    softwareUse:
        'A UI renderer traverses a component tree and combines child layout information at each parent.',
    watchFor:
        'Define the null-tree base case before recursing. Keep clear whether depth counts nodes or edges.',
    example:
        'Depth of a tree with root 3, children 9 and 20, and 20’s children 15 and 7.',
    problemSlug: 'maximum-depth-of-binary-tree',
    tokens: ['3', '9', '20', '15', '7'],
    frames: [
      PatternFrame(
        'Reach the leaves',
        'Both 9 and 15 have no children, so each returns depth 1.',
        [1, 3],
        state: 'depth(9) = 1 · depth(15) = 1',
      ),
      PatternFrame(
        'Resolve the right branch',
        '7 returns 1, so 20 returns 1 + max(1, 1) = 2.',
        [2, 3, 4],
        state: 'depth(20) = 2',
      ),
      PatternFrame(
        'Resolve the root',
        '3 combines left depth 1 and right depth 2.',
        [0, 1, 2],
        state: 'depth(3) = 1 + max(1, 2) = 3',
      ),
    ],
    code: {
      CodeLanguage.python:
          'def max_depth(node):\n    if node is None: return 0\n    return 1 + max(max_depth(node.left), max_depth(node.right))',
      CodeLanguage.cpp:
          'int maxDepth(TreeNode* node) {\n    if (!node) return 0;\n    return 1 + max(maxDepth(node->left), maxDepth(node->right));\n}',
      CodeLanguage.javascript:
          'function maxDepth(node) {\n  if (node == null) return 0;\n  return 1 + Math.max(maxDepth(node.left), maxDepth(node.right));\n}',
      CodeLanguage.typescript:
          'function maxDepth(node: TreeNode | null): number {\n  if (node === null) return 0;\n  return 1 + Math.max(maxDepth(node.left), maxDepth(node.right));\n}',
    },
  ),
  PatternLesson(
    category: 'Tries',
    visual: PatternVisual.trie,
    title: 'Prefix trie',
    cue: 'Share common letter paths.',
    concept:
        'A trie stores one edge per character. Words with the same prefix share nodes, and an end marker distinguishes a full word from a prefix.',
    recognize:
        'Many words share beginnings, and the task repeatedly inserts, searches, or checks prefixes.',
    whenToUse:
        'You need many prefix checks, word insertions, or dictionary searches over the same vocabulary.',
    softwareUse:
        'Autocomplete can share prefixes across thousands of words and narrow suggestions as each character arrives.',
    watchFor:
        'A prefix path can exist without being a complete word. Mark word endings explicitly.',
    example: 'Insert cat, then car. Both share c → a.',
    problemSlug: 'implement-trie-prefix-tree',
    tokens: ['root', 'c', 'a', 't', 'r'],
    frames: [
      PatternFrame(
        'Create a branch',
        'Insert c and a once.',
        [0, 1, 2],
        state: 'root → c → a',
        display: ['root', 'c', 'a'],
      ),
      PatternFrame(
        'Finish cat',
        'Add t and mark it as a complete word.',
        [2, 3],
        state: 'cat: end = true',
        display: ['root', 'c', 'a', 't✓'],
      ),
      PatternFrame(
        'Reuse the prefix',
        'Follow c and a again. Do not duplicate these nodes.',
        [1, 2],
        state: 'shared prefix: ca',
        display: ['root', 'c', 'a', 't✓'],
      ),
      PatternFrame(
        'Finish car',
        'Branch from a to r and mark car complete.',
        [2, 4],
        state: 'words: cat, car · ca is only a prefix',
        display: ['root', 'c', 'a', 't✓', 'r✓'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'root = {}\ndef insert(word):\n    node = root\n    for ch in word:\n        node = node.setdefault(ch, {})\n    node["#"] = True\ndef search(word):\n    node = root\n    for ch in word:\n        if ch not in node: return False\n        node = node[ch]\n    return "#" in node',
      CodeLanguage.cpp:
          'struct TrieNode {\n    unordered_map<char, TrieNode*> next;\n    bool end = false;\n};\nvoid insert(TrieNode* root, const string& word) {\n    for (char ch : word) {\n        if (!root->next.count(ch)) root->next[ch] = new TrieNode();\n        root = root->next[ch];\n    }\n    root->end = true;\n}',
      CodeLanguage.javascript:
          'const root = {};\nfunction insert(word) {\n  let node = root;\n  for (const ch of word) node = node[ch] ??= {};\n  node.end = true;\n}\nfunction search(word) {\n  let node = root;\n  for (const ch of word) {\n    node = node[ch]; if (!node) return false;\n  }\n  return node.end === true;\n}',
      CodeLanguage.typescript:
          'type TrieNode = { next: Map<string, TrieNode>; end: boolean };\nconst root: TrieNode = { next: new Map(), end: false };\nfunction insert(word: string): void {\n  let node = root;\n  for (const ch of word) {\n    if (!node.next.has(ch)) node.next.set(ch, { next: new Map(), end: false });\n    node = node.next.get(ch)!;\n  }\n  node.end = true;\n}',
    },
  ),
  PatternLesson(
    category: 'Backtracking',
    visual: PatternVisual.branches,
    title: 'Choose, explore, undo',
    cue: 'Build one partial answer at a time.',
    concept:
        'Backtracking explores a decision tree. Make a choice, recurse, then undo it before trying the next choice.',
    recognize:
        'The prompt asks for all valid arrangements, subsets, paths, or combinations rather than one optimal answer.',
    whenToUse:
        'You must enumerate combinations, subsets, permutations, or valid placements.',
    softwareUse:
        'A configuration validator can explore compatible option combinations and undo a choice before trying another.',
    watchFor:
        'Every recursive call needs a stopping condition. Undo the same change you made before exploring a sibling branch.',
    example: 'Enumerate subsets of [1, 2].',
    problemSlug: 'subsets',
    tokens: ['1', '2'],
    frames: [
      PatternFrame(
        'Start empty',
        'The empty subset is one answer.',
        [0],
        state: 'path: [] · answers: [[]]',
        display: ['∅'],
      ),
      PatternFrame(
        'Choose 1',
        'Record [1], then explore the next choice.',
        [0],
        state: 'path: [1] · answers: [[], [1]]',
        display: ['∅', '1'],
      ),
      PatternFrame(
        'Choose 2',
        'Record [1, 2]. This branch is complete.',
        [0, 1],
        state: 'path: [1, 2] · answers: [[], [1], [1,2]]',
        display: ['∅', '1', '1,2'],
      ),
      PatternFrame(
        'Undo 1; choose 2',
        'Return to the root and explore [2].',
        [1],
        state: 'path: [2] · four subsets total',
        display: ['∅', '1', '1,2', '2'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def subsets(nums):\n    out, path = [], []\n    def explore(start):\n        out.append(path.copy())\n        for i in range(start, len(nums)):\n            path.append(nums[i])\n            explore(i + 1)\n            path.pop()\n    explore(0)\n    return out',
      CodeLanguage.cpp:
          'void explore(const vector<int>& a, int start, vector<int>& path, vector<vector<int>>& out) {\n    out.push_back(path);\n    for (int i = start; i < (int)a.size(); ++i) {\n        path.push_back(a[i]);\n        explore(a, i + 1, path, out);\n        path.pop_back();\n    }\n}',
      CodeLanguage.javascript:
          'function subsets(nums) {\n  const out = [], path = [];\n  function explore(start) {\n    out.push([...path]);\n    for (let i = start; i < nums.length; i++) {\n      path.push(nums[i]); explore(i + 1); path.pop();\n    }\n  }\n  explore(0); return out;\n}',
      CodeLanguage.typescript:
          'function subsets(nums: number[]): number[][] {\n  const out: number[][] = [], path: number[] = [];\n  function explore(start: number): void {\n    out.push([...path]);\n    for (let i = start; i < nums.length; i++) {\n      path.push(nums[i]); explore(i + 1); path.pop();\n    }\n  }\n  explore(0); return out;\n}',
    },
  ),
  PatternLesson(
    category: 'Heaps',
    visual: PatternVisual.heap,
    title: 'Keep the top k',
    cue: 'Discard values that cannot win.',
    concept:
        'A min-heap of size k stores the k largest values seen so far. Its root is the kth largest.',
    recognize:
        'You repeatedly need the current smallest or largest candidate, or only the best k items matter.',
    whenToUse:
        'You need a repeated minimum or maximum, or only the best k candidates matter.',
    softwareUse:
        'A service can keep the top 20 slowest requests seen so far without storing every request in memory.',
    watchFor:
        'Keep the heap at size k. When fewer than k values exist, the kth largest is not defined.',
    example: 'Find the 2nd largest of [3, 1, 5, 2].',
    problemSlug: 'kth-largest-element-in-an-array',
    tokens: ['3', '1', '5', '2'],
    frames: [
      PatternFrame(
        'Read 3',
        'Heap has room; push 3.',
        [0],
        state: 'min-heap: [3]',
        display: ['3'],
      ),
      PatternFrame(
        'Read 1',
        'Push 1. Smallest is now at the root.',
        [0, 1],
        state: 'min-heap: [1, 3]',
        display: ['1', '3'],
      ),
      PatternFrame(
        'Read 5',
        'Push 5, then remove 1 to keep two values.',
        [0, 2],
        state: 'min-heap: [3, 5]',
        display: ['3', '5'],
      ),
      PatternFrame(
        'Read 2',
        '2 cannot beat root 3. Root 3 is the answer.',
        [0, 2, 3],
        state: 'min-heap: [3, 5] · 2nd largest = 3',
        display: ['3', '5'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'import heapq\ndef kth_largest(nums, k):\n    heap = []\n    for value in nums:\n        heapq.heappush(heap, value)\n        if len(heap) > k: heapq.heappop(heap)\n    return heap[0]',
      CodeLanguage.cpp:
          'int kthLargest(const vector<int>& a, int k) {\n    priority_queue<int, vector<int>, greater<int>> heap;\n    for (int x : a) {\n        heap.push(x);\n        if ((int)heap.size() > k) heap.pop();\n    }\n    return heap.top();\n}',
      CodeLanguage.javascript:
          'function kthLargest(nums, k) {\n  const heap = [];\n  function push(x) {\n    heap.push(x); let i = heap.length - 1;\n    while (i > 0) {\n      const p = Math.floor((i - 1) / 2);\n      if (heap[p] <= heap[i]) break;\n      [heap[p], heap[i]] = [heap[i], heap[p]]; i = p;\n    }\n  }\n  function popMin() {\n    const last = heap.pop();\n    if (!heap.length) return;\n    heap[0] = last; let i = 0;\n    while (2 * i + 1 < heap.length) {\n      let c = 2 * i + 1;\n      if (c + 1 < heap.length && heap[c + 1] < heap[c]) c++;\n      if (heap[i] <= heap[c]) break;\n      [heap[i], heap[c]] = [heap[c], heap[i]]; i = c;\n    }\n  }\n  for (const x of nums) { push(x); if (heap.length > k) popMin(); }\n  return heap[0];\n}',
      CodeLanguage.typescript:
          'function kthLargest(nums: number[], k: number): number {\n  const heap: number[] = [];\n  function push(x: number): void {\n    heap.push(x); let i = heap.length - 1;\n    while (i > 0) {\n      const p = Math.floor((i - 1) / 2);\n      if (heap[p] <= heap[i]) break;\n      [heap[p], heap[i]] = [heap[i], heap[p]]; i = p;\n    }\n  }\n  function popMin(): void {\n    const last = heap.pop()!;\n    if (!heap.length) return;\n    heap[0] = last; let i = 0;\n    while (2 * i + 1 < heap.length) {\n      let c = 2 * i + 1;\n      if (c + 1 < heap.length && heap[c + 1] < heap[c]) c++;\n      if (heap[i] <= heap[c]) break;\n      [heap[i], heap[c]] = [heap[c], heap[i]]; i = c;\n    }\n  }\n  for (const x of nums) { push(x); if (heap.length > k) popMin(); }\n  return heap[0];\n}',
    },
  ),
  PatternLesson(
    category: 'Advanced graphs',
    visual: PatternVisual.graph,
    title: 'Topological order',
    cue: 'Resolve prerequisites before dependents.',
    concept:
        'In a directed acyclic graph, nodes with zero incoming edges can be completed now. Removing one may unlock others.',
    recognize:
        'Words such as prerequisite, dependency, ordering, or cycle describe directed relationships.',
    whenToUse:
        'The task has prerequisites, dependency order, or asks whether all tasks can be completed.',
    softwareUse:
        'A build system orders tasks so each generated artifact is ready before a dependent task starts.',
    watchFor:
        'If fewer than all nodes leave the queue, a cycle remains. Count incoming edges in the correct direction.',
    example: 'A → B, A → C, B → D, C → D. Can all four tasks finish?',
    problemSlug: 'course-schedule',
    tokens: ['A', 'B', 'C', 'D'],
    frames: [
      PatternFrame(
        'Count prerequisites',
        'Only A has indegree zero.',
        [0],
        state: 'indegree: A0 B1 C1 D2 · ready: [A]',
        display: ['A'],
      ),
      PatternFrame(
        'Finish A',
        'Removing A unlocks B and C.',
        [1, 2],
        state: 'indegree: B0 C0 D2 · ready: [B,C]',
        display: ['B', 'C'],
      ),
      PatternFrame(
        'Finish B',
        'D still waits for C.',
        [1, 3],
        state: 'indegree: D1 · ready: [C]',
        display: ['C'],
      ),
      PatternFrame(
        'Finish C and D',
        'D reaches zero. All four can finish.',
        [2, 3],
        state: 'processed: 4 / 4 · no cycle',
        display: ['D', '✓'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'from collections import deque\ndef can_finish(n, edges):\n    graph = [[] for _ in range(n)]\n    degree = [0] * n\n    for before, after in edges:\n        graph[before].append(after); degree[after] += 1\n    queue = deque(i for i in range(n) if degree[i] == 0)\n    done = 0\n    while queue:\n        node = queue.popleft(); done += 1\n        for nxt in graph[node]:\n            degree[nxt] -= 1\n            if degree[nxt] == 0: queue.append(nxt)\n    return done == n',
      CodeLanguage.cpp:
          'bool canFinish(int n, const vector<pair<int,int>>& edges) {\n    vector<vector<int>> graph(n); vector<int> degree(n);\n    for (auto [before, after] : edges) { graph[before].push_back(after); ++degree[after]; }\n    queue<int> ready;\n    for (int i = 0; i < n; ++i) if (!degree[i]) ready.push(i);\n    int done = 0;\n    while (!ready.empty()) {\n        int node = ready.front(); ready.pop(); ++done;\n        for (int next : graph[node]) if (--degree[next] == 0) ready.push(next);\n    }\n    return done == n;\n}',
      CodeLanguage.javascript:
          'function canFinish(n, edges) {\n  const graph = Array.from({ length: n }, () => []), degree = Array(n).fill(0);\n  for (const [before, after] of edges) { graph[before].push(after); degree[after]++; }\n  const ready = [];\n  degree.forEach((d, i) => { if (d === 0) ready.push(i); });\n  let done = 0;\n  for (let head = 0; head < ready.length; head++) {\n    done++; for (const next of graph[ready[head]]) if (--degree[next] === 0) ready.push(next);\n  }\n  return done === n;\n}',
      CodeLanguage.typescript:
          'function canFinish(n: number, edges: number[][]): boolean {\n  const graph: number[][] = Array.from({ length: n }, () => []);\n  const degree = Array<number>(n).fill(0);\n  for (const [before, after] of edges) { graph[before].push(after); degree[after]++; }\n  const ready: number[] = [];\n  degree.forEach((d, i) => { if (d === 0) ready.push(i); });\n  let done = 0;\n  for (let head = 0; head < ready.length; head++) {\n    done++; for (const next of graph[ready[head]]) if (--degree[next] === 0) ready.push(next);\n  }\n  return done === n;\n}',
    },
  ),
  PatternLesson(
    category: '2-D dynamic programming',
    visual: PatternVisual.grid,
    title: 'Grid state table',
    cue: 'Combine answers from two directions.',
    concept:
        'A two-dimensional DP table records one answer per cell. For grid paths, every route to a cell comes from above or the left.',
    recognize:
        'Two changing positions define each subproblem, such as a grid cell or two string prefixes.',
    whenToUse:
        'Two independent indices describe a state, such as row and column or two string prefixes.',
    softwareUse:
        'A text-diff tool can compare prefixes of two documents with a table of reusable edit costs.',
    watchFor:
        'Initialize the first row and column before applying the recurrence to interior cells.',
    example: 'Count paths through a 3 × 3 grid, moving only right or down.',
    problemSlug: 'unique-paths',
    tokens: ['1', '1', '1', '1', '2', '3', '1', '3', '6'],
    frames: [
      PatternFrame(
        'Base edges',
        'The top row and left column each have one way.',
        [0, 1, 2, 3, 6],
        state: 'dp[0][c] = 1 · dp[r][0] = 1',
        display: ['1', '1', '1', '1', '·', '·', '1', '·', '·'],
      ),
      PatternFrame(
        'Fill the center',
        'Above 1 + left 1 gives 2.',
        [1, 3, 4],
        state: 'dp[1][1] = 2',
        display: ['1', '1', '1', '1', '2', '·', '1', '·', '·'],
      ),
      PatternFrame(
        'Fill borders',
        'The right-middle and bottom-middle cells each have 3 ways.',
        [2, 4, 5, 6, 7],
        state: 'dp[1][2] = 3 · dp[2][1] = 3',
        display: ['1', '1', '1', '1', '2', '3', '1', '3', '·'],
      ),
      PatternFrame(
        'Finish',
        'Above 3 + left 3 gives 6 paths.',
        [5, 7, 8],
        state: 'dp[2][2] = 6',
        display: ['1', '1', '1', '1', '2', '3', '1', '3', '6'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def unique_paths(rows, cols):\n    dp = [[1] * cols for _ in range(rows)]\n    for r in range(1, rows):\n        for c in range(1, cols):\n            dp[r][c] = dp[r-1][c] + dp[r][c-1]\n    return dp[-1][-1]',
      CodeLanguage.cpp:
          'int uniquePaths(int rows, int cols) {\n    vector<vector<int>> dp(rows, vector<int>(cols, 1));\n    for (int r = 1; r < rows; ++r)\n        for (int c = 1; c < cols; ++c)\n            dp[r][c] = dp[r-1][c] + dp[r][c-1];\n    return dp[rows-1][cols-1];\n}',
      CodeLanguage.javascript:
          'function uniquePaths(rows, cols) {\n  const dp = Array.from({ length: rows }, () => Array(cols).fill(1));\n  for (let r = 1; r < rows; r++)\n    for (let c = 1; c < cols; c++) dp[r][c] = dp[r-1][c] + dp[r][c-1];\n  return dp[rows-1][cols-1];\n}',
      CodeLanguage.typescript:
          'function uniquePaths(rows: number, cols: number): number {\n  const dp: number[][] = Array.from({ length: rows }, () => Array<number>(cols).fill(1));\n  for (let r = 1; r < rows; r++)\n    for (let c = 1; c < cols; c++) dp[r][c] = dp[r-1][c] + dp[r][c-1];\n  return dp[rows-1][cols-1];\n}',
    },
  ),
  PatternLesson(
    category: 'Greedy',
    visual: PatternVisual.sequence,
    title: 'Farthest reachable point',
    cue: 'Keep the best boundary seen so far.',
    concept:
        'At each index, record the farthest position you can reach. If the current index lies past that boundary, no earlier choice can reach it.',
    recognize:
        'The task asks for reachability or minimum choices, and one boundary summarizes earlier options.',
    whenToUse:
        'A locally best boundary summarizes all choices made so far, and you can justify why no discarded choice helps.',
    softwareUse:
        'A scheduler can maintain the farthest reachable checkpoint while scanning available transitions.',
    watchFor:
        'A greedy move needs a correctness argument. For this problem, every reachable index can extend the same farthest boundary.',
    example: 'Can [2, 3, 1, 1, 4] reach the last index?',
    problemSlug: 'jump-game',
    tokens: ['2', '3', '1', '1', '4'],
    frames: [
      PatternFrame(
        'Start at 0',
        '0 + 2 gives a reachable boundary at index 2.',
        [0, 1, 2],
        state: 'farthest = 2',
      ),
      PatternFrame(
        'Visit 1',
        'Index 1 is reachable. 1 + 3 extends the boundary to 4.',
        [1, 2, 3, 4],
        state: 'farthest = 4',
      ),
      PatternFrame(
        'Reach the end',
        'The final index is within the boundary.',
        [4],
        state: '4 ≥ last index 4 · answer: true',
      ),
    ],
    code: {
      CodeLanguage.python:
          'def can_jump(nums):\n    farthest = 0\n    for i, jump in enumerate(nums):\n        if i > farthest: return False\n        farthest = max(farthest, i + jump)\n    return True',
      CodeLanguage.cpp:
          'bool canJump(const vector<int>& nums) {\n    int farthest = 0;\n    for (int i = 0; i < (int)nums.size(); ++i) {\n        if (i > farthest) return false;\n        farthest = max(farthest, i + nums[i]);\n    }\n    return true;\n}',
      CodeLanguage.javascript:
          'function canJump(nums) {\n  let farthest = 0;\n  for (let i = 0; i < nums.length; i++) {\n    if (i > farthest) return false;\n    farthest = Math.max(farthest, i + nums[i]);\n  }\n  return true;\n}',
      CodeLanguage.typescript:
          'function canJump(nums: number[]): boolean {\n  let farthest = 0;\n  for (let i = 0; i < nums.length; i++) {\n    if (i > farthest) return false;\n    farthest = Math.max(farthest, i + nums[i]);\n  }\n  return true;\n}',
    },
  ),
  PatternLesson(
    category: 'Intervals',
    visual: PatternVisual.intervals,
    title: 'Merge overlapping intervals',
    cue: 'Sort by start, then maintain one open range.',
    concept:
        'Once intervals are sorted by start, only the current merged interval can overlap the next one.',
    recognize:
        'Input items are start/end ranges and the output depends on overlap, gaps, or coverage.',
    whenToUse:
        'The input describes ranges of time, positions, or values and asks about overlap or coverage.',
    softwareUse:
        'A calendar merges overlapping busy slots before showing a person’s actual unavailable time.',
    watchFor:
        'Touching endpoints overlap when ranges are closed. Sort first, and update the end with max.',
    example: 'Merge [1,3], [2,6], [8,10].',
    problemSlug: 'merge-intervals',
    tokens: ['1–3', '2–6', '8–10'],
    frames: [
      PatternFrame(
        'Sort starts',
        'Intervals are already ordered by start.',
        [0],
        state: 'merged: [1,3]',
        display: ['1–3'],
      ),
      PatternFrame(
        'Overlap',
        '[2,6] begins before 3 ends, so extend the end to 6.',
        [0, 1],
        state: 'merged: [1,6]',
        display: ['1–6'],
      ),
      PatternFrame(
        'Gap',
        '[8,10] starts after 6. Begin a new merged range.',
        [2],
        state: 'result: [1,6], [8,10]',
        display: ['1–6', '8–10'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def merge(intervals):\n    intervals.sort()\n    out = []\n    for start, end in intervals:\n        if out and start <= out[-1][1]:\n            out[-1][1] = max(out[-1][1], end)\n        else: out.append([start, end])\n    return out',
      CodeLanguage.cpp:
          'vector<vector<int>> merge(vector<vector<int>> a) {\n    sort(a.begin(), a.end());\n    vector<vector<int>> out;\n    for (auto x : a) {\n        if (!out.empty() && x[0] <= out.back()[1])\n            out.back()[1] = max(out.back()[1], x[1]);\n        else out.push_back(x);\n    }\n    return out;\n}',
      CodeLanguage.javascript:
          'function merge(intervals) {\n  intervals.sort((a, b) => a[0] - b[0]);\n  const out = [];\n  for (const [start, end] of intervals) {\n    if (out.length && start <= out.at(-1)[1]) out.at(-1)[1] = Math.max(out.at(-1)[1], end);\n    else out.push([start, end]);\n  }\n  return out;\n}',
      CodeLanguage.typescript:
          'function merge(intervals: number[][]): number[][] {\n  intervals.sort((a, b) => a[0] - b[0]);\n  const out: number[][] = [];\n  for (const [start, end] of intervals) {\n    if (out.length && start <= out[out.length - 1][1])\n      out[out.length - 1][1] = Math.max(out[out.length - 1][1], end);\n    else out.push([start, end]);\n  }\n  return out;\n}',
    },
  ),
  PatternLesson(
    category: 'Bit manipulation',
    visual: PatternVisual.bits,
    title: 'XOR cancellation',
    cue: 'Equal values cancel bit by bit.',
    concept:
        'XOR is associative and x XOR x equals zero. Pairwise duplicates disappear, leaving the single value.',
    recognize:
        'The constraints describe paired duplicates, toggles, parity, or values represented as bits.',
    whenToUse:
        'Values repeat in pairs and one value is unpaired, or a compact mask can represent a set of binary choices.',
    softwareUse:
        'Feature flags and permissions can use bit masks for compact on/off state; XOR toggles or compares bit changes.',
    watchFor:
        'This exact shortcut requires every other value to appear twice. Check signed and fixed-width behavior for other bit tricks.',
    example: 'Find the single value in [4, 1, 4, 2, 1].',
    problemSlug: 'single-number',
    tokens: ['100', '001', '100', '010', '001'],
    frames: [
      PatternFrame(
        'Start with zero',
        '0 XOR 4 = 4.',
        [0],
        state: 'accumulator: 100₂ = 4',
        display: ['000', '100'],
      ),
      PatternFrame(
        'Add 1',
        '4 XOR 1 = 5.',
        [0, 1],
        state: 'accumulator: 101₂ = 5',
        display: ['100', '001', '101'],
      ),
      PatternFrame(
        'Cancel 4',
        '5 XOR 4 = 1; the two 4s cancel.',
        [0, 2],
        state: 'accumulator: 001₂ = 1',
        display: ['101', '100', '001'],
      ),
      PatternFrame(
        'Cancel 1',
        'XOR 2 then 1; the remaining value is 2.',
        [1, 3, 4],
        state: 'accumulator: 010₂ = 2',
        display: ['001', '010', '001', '010'],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def single_number(nums):\n    answer = 0\n    for value in nums: answer ^= value\n    return answer',
      CodeLanguage.cpp:
          'int singleNumber(const vector<int>& nums) {\n    int answer = 0;\n    for (int value : nums) answer ^= value;\n    return answer;\n}',
      CodeLanguage.javascript:
          'function singleNumber(nums) {\n  let answer = 0;\n  for (const value of nums) answer ^= value;\n  return answer;\n}',
      CodeLanguage.typescript:
          'function singleNumber(nums: number[]): number {\n  let answer = 0;\n  for (const value of nums) answer ^= value;\n  return answer;\n}',
    },
  ),
  PatternLesson(
    category: 'Math & geometry',
    visual: PatternVisual.numberLine,
    title: 'Integer square root',
    cue: 'Turn a numeric answer into a boundary search.',
    concept:
        'For nonnegative x, candidate roots whose square is at most x form a monotonic prefix. Find the greatest feasible root.',
    recognize:
        'A formula defines a numeric boundary, and the prompt asks for an integer or rounded result.',
    whenToUse:
        'A numeric or geometric condition has a clear formula and a monotonic true/false boundary.',
    softwareUse:
        'A capacity planner can binary-search the largest safe batch size under a measurable resource limit.',
    watchFor:
        'Use mid <= x / mid to avoid multiplying into overflow in fixed-width integer languages; handle x = 0.',
    example: 'Find floor(sqrt(10)).',
    problemSlug: 'sqrtx',
    tokens: ['0', '1', '2', '3', '4', '5'],
    frames: [
      PatternFrame(
        'Search candidates',
        'Root lies from 0 through 5 because 6² exceeds 10.',
        [0, 5],
        state: 'low = 0 · high = 5 · best = 0',
      ),
      PatternFrame(
        'Try 2',
        '2² = 4 ≤ 10, so 2 is feasible. Search higher.',
        [2],
        state: 'low = 3 · high = 5 · best = 2',
      ),
      PatternFrame(
        'Try 4',
        '4² = 16 > 10, so search lower.',
        [4],
        state: 'low = 3 · high = 3 · best = 2',
      ),
      PatternFrame(
        'Try 3',
        '3² = 9 ≤ 10. The greatest feasible root is 3.',
        [3],
        state: 'low = 4 · high = 3 · answer = 3',
      ),
    ],
    code: {
      CodeLanguage.python:
          'def integer_sqrt(x):\n    low, high, best = 0, x, 0\n    while low <= high:\n        mid = (low + high) // 2\n        if mid * mid <= x:\n            best = mid; low = mid + 1\n        else: high = mid - 1\n    return best',
      CodeLanguage.cpp:
          'int integerSqrt(int x) {\n    int low = 0, high = x, best = 0;\n    while (low <= high) {\n        int mid = low + (high - low) / 2;\n        if (mid == 0 || mid <= x / mid) { best = mid; low = mid + 1; }\n        else high = mid - 1;\n    }\n    return best;\n}',
      CodeLanguage.javascript:
          'function integerSqrt(x) {\n  let low = 0, high = x, best = 0;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (mid * mid <= x) { best = mid; low = mid + 1; }\n    else high = mid - 1;\n  }\n  return best;\n}',
      CodeLanguage.typescript:
          'function integerSqrt(x: number): number {\n  let low = 0, high = x, best = 0;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (mid * mid <= x) { best = mid; low = mid + 1; }\n    else high = mid - 1;\n  }\n  return best;\n}',
    },
  ),
];
