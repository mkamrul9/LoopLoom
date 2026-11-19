part of 'pattern_library.dart';

/// Reusable starting structures. TODO comments are intentional decision points.
const patternTemplates = <String, Map<CodeLanguage, String>>{
  'Hash map lookup': {
    CodeLanguage.python:
        'def solve(values):\n    seen = {}\n    for i, value in enumerate(values):\n        key = value  # TODO: derive the needed lookup key\n        if key in seen:\n            return (seen[key], i)  # TODO: shape the answer\n        seen[value] = i\n    return None',
    CodeLanguage.cpp:
        'vector<int> solve(const vector<int>& values) {\n    unordered_map<int, int> seen;\n    for (int i = 0; i < (int)values.size(); ++i) {\n        int key = values[i]; // TODO: derive lookup key\n        if (seen.count(key)) return {seen[key], i};\n        seen[values[i]] = i;\n    }\n    return {};\n}',
    CodeLanguage.javascript:
        'function solve(values) {\n  const seen = new Map();\n  for (let i = 0; i < values.length; i++) {\n    const key = values[i]; // TODO: derive lookup key\n    if (seen.has(key)) return [seen.get(key), i];\n    seen.set(values[i], i);\n  }\n  return null;\n}',
    CodeLanguage.typescript:
        'function solve(values: number[]): [number, number] | null {\n  const seen = new Map<number, number>();\n  for (let i = 0; i < values.length; i++) {\n    const key = values[i]; // TODO: derive lookup key\n    if (seen.has(key)) return [seen.get(key)!, i];\n    seen.set(values[i], i);\n  }\n  return null;\n}',
  },
  'Two pointers': {
    CodeLanguage.python:
        'def scan_sorted(values, target):\n    left, right = 0, len(values) - 1\n    while left < right:\n        score = values[left] + values[right]  # TODO: comparison\n        if score == target: return left, right\n        if score < target: left += 1\n        else: right -= 1\n    return None',
    CodeLanguage.cpp:
        'pair<int,int> scanSorted(const vector<int>& a, int target) {\n    int left = 0, right = (int)a.size() - 1;\n    while (left < right) {\n        int score = a[left] + a[right]; // TODO: comparison\n        if (score == target) return {left, right};\n        if (score < target) ++left; else --right;\n    }\n    return {-1, -1};\n}',
    CodeLanguage.javascript:
        'function scanSorted(values, target) {\n  let left = 0, right = values.length - 1;\n  while (left < right) {\n    const score = values[left] + values[right]; // TODO\n    if (score === target) return [left, right];\n    if (score < target) left++; else right--;\n  }\n  return null;\n}',
    CodeLanguage.typescript:
        'function scanSorted(values: number[], target: number): [number, number] | null {\n  let left = 0, right = values.length - 1;\n  while (left < right) {\n    const score = values[left] + values[right]; // TODO\n    if (score === target) return [left, right];\n    if (score < target) left++; else right--;\n  }\n  return null;\n}',
  },
  'Sliding window': {
    CodeLanguage.python:
        'def scan_window(values, k):\n    if k <= 0 or k > len(values): return None\n    state = sum(values[:k])  # TODO: window summary\n    best = state\n    for right in range(k, len(values)):\n        state += values[right] - values[right - k]\n        best = max(best, state)  # TODO: answer rule\n    return best',
    CodeLanguage.cpp:
        'int scanWindow(const vector<int>& a, int k) {\n    if (k <= 0 || k > (int)a.size()) return 0;\n    int state = 0;\n    for (int i = 0; i < k; ++i) state += a[i];\n    int best = state;\n    for (int r = k; r < (int)a.size(); ++r) {\n        state += a[r] - a[r-k];\n        best = max(best, state); // TODO: answer rule\n    }\n    return best;\n}',
    CodeLanguage.javascript:
        'function scanWindow(values, k) {\n  if (k <= 0 || k > values.length) return null;\n  let state = values.slice(0, k).reduce((a, b) => a + b, 0);\n  let best = state;\n  for (let r = k; r < values.length; r++) {\n    state += values[r] - values[r-k];\n    best = Math.max(best, state); // TODO: answer rule\n  }\n  return best;\n}',
    CodeLanguage.typescript:
        'function scanWindow(values: number[], k: number): number | null {\n  if (k <= 0 || k > values.length) return null;\n  let state = values.slice(0, k).reduce((a, b) => a + b, 0);\n  let best = state;\n  for (let r = k; r < values.length; r++) {\n    state += values[r] - values[r-k];\n    best = Math.max(best, state); // TODO: answer rule\n  }\n  return best;\n}',
  },
  'Binary search': {
    CodeLanguage.python:
        'def first_true(low, high, feasible):\n    answer = None\n    while low <= high:\n        mid = low + (high - low) // 2\n        if feasible(mid):\n            answer = mid; high = mid - 1\n        else: low = mid + 1\n    return answer',
    CodeLanguage.cpp:
        'int firstTrue(int low, int high, function<bool(int)> feasible) {\n    int answer = -1;\n    while (low <= high) {\n        int mid = low + (high - low) / 2;\n        if (feasible(mid)) { answer = mid; high = mid - 1; }\n        else low = mid + 1;\n    }\n    return answer;\n}',
    CodeLanguage.javascript:
        'function firstTrue(low, high, feasible) {\n  let answer = null;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (feasible(mid)) { answer = mid; high = mid - 1; }\n    else low = mid + 1;\n  }\n  return answer;\n}',
    CodeLanguage.typescript:
        'function firstTrue(low: number, high: number, feasible: (x: number) => boolean): number | null {\n  let answer: number | null = null;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (feasible(mid)) { answer = mid; high = mid - 1; }\n    else low = mid + 1;\n  }\n  return answer;\n}',
  },
  'Graph traversal': {
    CodeLanguage.python:
        'from collections import deque\ndef traverse(graph, start):\n    queue = deque([start]); seen = {start}\n    while queue:\n        node = queue.popleft()\n        # TODO: use node\n        for nxt in graph[node]:\n            if nxt not in seen:\n                seen.add(nxt); queue.append(nxt)',
    CodeLanguage.cpp:
        'void traverse(const vector<vector<int>>& graph, int start) {\n    queue<int> pending; pending.push(start);\n    vector<bool> seen(graph.size()); seen[start] = true;\n    while (!pending.empty()) {\n        int node = pending.front(); pending.pop();\n        // TODO: use node\n        for (int next : graph[node]) if (!seen[next]) {\n            seen[next] = true; pending.push(next);\n        }\n    }\n}',
    CodeLanguage.javascript:
        'function traverse(graph, start) {\n  const queue = [start], seen = new Set([start]);\n  for (let head = 0; head < queue.length; head++) {\n    const node = queue[head]; // TODO: use node\n    for (const next of graph[node]) if (!seen.has(next)) {\n      seen.add(next); queue.push(next);\n    }\n  }\n}',
    CodeLanguage.typescript:
        'function traverse(graph: number[][], start: number): void {\n  const queue = [start], seen = new Set<number>([start]);\n  for (let head = 0; head < queue.length; head++) {\n    const node = queue[head]; // TODO: use node\n    for (const next of graph[node]) if (!seen.has(next)) {\n      seen.add(next); queue.push(next);\n    }\n  }\n}',
  },
  'Dynamic programming': {
    CodeLanguage.python:
        'def solve(n):\n    dp = [0] * (n + 1)\n    dp[0] = 1  # TODO: base case\n    for i in range(1, n + 1):\n        dp[i] = dp[i-1]  # TODO: recurrence\n    return dp[n]',
    CodeLanguage.cpp:
        'int solve(int n) {\n    vector<int> dp(n + 1);\n    dp[0] = 1; // TODO: base case\n    for (int i = 1; i <= n; ++i)\n        dp[i] = dp[i-1]; // TODO: recurrence\n    return dp[n];\n}',
    CodeLanguage.javascript:
        'function solve(n) {\n  const dp = Array(n + 1).fill(0);\n  dp[0] = 1; // TODO: base case\n  for (let i = 1; i <= n; i++)\n    dp[i] = dp[i-1]; // TODO: recurrence\n  return dp[n];\n}',
    CodeLanguage.typescript:
        'function solve(n: number): number {\n  const dp = Array<number>(n + 1).fill(0);\n  dp[0] = 1; // TODO: base case\n  for (let i = 1; i <= n; i++)\n    dp[i] = dp[i-1]; // TODO: recurrence\n  return dp[n];\n}',
  },
  'Reverse a linked list': {
    CodeLanguage.python:
        'def transform(head):\n    prev = None\n    while head:\n        nxt = head.next  # save before rewiring\n        head.next = prev  # TODO: link change\n        prev, head = head, nxt\n    return prev',
    CodeLanguage.cpp:
        'ListNode* transform(ListNode* head) {\n    ListNode* prev = nullptr;\n    while (head) {\n        ListNode* next = head->next;\n        head->next = prev; // TODO: link change\n        prev = head; head = next;\n    }\n    return prev;\n}',
    CodeLanguage.javascript:
        'function transform(head) {\n  let prev = null;\n  while (head) {\n    const next = head.next; // save first\n    head.next = prev; // TODO: link change\n    prev = head; head = next;\n  }\n  return prev;\n}',
    CodeLanguage.typescript:
        'function transform(head: ListNode | null): ListNode | null {\n  let prev: ListNode | null = null;\n  while (head) {\n    const next: ListNode | null = head.next;\n    head.next = prev; // TODO: link change\n    prev = head; head = next;\n  }\n  return prev;\n}',
  },
  'Monotonic stack': {
    CodeLanguage.python:
        'def next_greater(values):\n    answer = [-1] * len(values)\n    stack = []  # unresolved indices\n    for i, value in enumerate(values):\n        while stack and values[stack[-1]] < value:\n            j = stack.pop(); answer[j] = i\n        stack.append(i)\n    return answer',
    CodeLanguage.cpp:
        'vector<int> nextGreater(const vector<int>& a) {\n    vector<int> answer(a.size(), -1), stack;\n    for (int i = 0; i < (int)a.size(); ++i) {\n        while (!stack.empty() && a[stack.back()] < a[i]) {\n            answer[stack.back()] = i; stack.pop_back();\n        }\n        stack.push_back(i);\n    }\n    return answer;\n}',
    CodeLanguage.javascript:
        'function nextGreater(values) {\n  const answer = Array(values.length).fill(-1), stack = [];\n  values.forEach((value, i) => {\n    while (stack.length && values[stack.at(-1)] < value)\n      answer[stack.pop()] = i;\n    stack.push(i);\n  });\n  return answer;\n}',
    CodeLanguage.typescript:
        'function nextGreater(values: number[]): number[] {\n  const answer = Array<number>(values.length).fill(-1);\n  const stack: number[] = [];\n  values.forEach((value, i) => {\n    while (stack.length && values[stack[stack.length-1]] < value)\n      answer[stack.pop()!] = i;\n    stack.push(i);\n  });\n  return answer;\n}',
  },
  'Tree recursion': {
    CodeLanguage.python:
        'def dfs(node):\n    if node is None: return 0  # base case\n    left = dfs(node.left)\n    right = dfs(node.right)\n    return 1 + max(left, right)  # TODO: combine',
    CodeLanguage.cpp:
        'int dfs(TreeNode* node) {\n    if (!node) return 0; // base case\n    int left = dfs(node->left);\n    int right = dfs(node->right);\n    return 1 + max(left, right); // TODO: combine\n}',
    CodeLanguage.javascript:
        'function dfs(node) {\n  if (node == null) return 0; // base case\n  const left = dfs(node.left), right = dfs(node.right);\n  return 1 + Math.max(left, right); // TODO: combine\n}',
    CodeLanguage.typescript:
        'function dfs(node: TreeNode | null): number {\n  if (node === null) return 0; // base case\n  const left = dfs(node.left), right = dfs(node.right);\n  return 1 + Math.max(left, right); // TODO: combine\n}',
  },
  'Prefix trie': {
    CodeLanguage.python:
        'root = {}\ndef insert(word):\n    node = root\n    for ch in word:\n        node = node.setdefault(ch, {})\n    node["#"] = True  # word ends here',
    CodeLanguage.cpp:
        'struct Node { unordered_map<char, Node*> next; bool end = false; };\nvoid insert(Node* root, const string& word) {\n    for (char ch : word) {\n        if (!root->next.count(ch)) root->next[ch] = new Node();\n        root = root->next[ch];\n    }\n    root->end = true;\n}',
    CodeLanguage.javascript:
        'const root = {};\nfunction insert(word) {\n  let node = root;\n  for (const ch of word) node = node[ch] ??= {};\n  node.end = true; // word ends here\n}',
    CodeLanguage.typescript:
        'type Node = { next: Map<string, Node>; end: boolean };\nconst root: Node = { next: new Map(), end: false };\nfunction insert(word: string): void {\n  let node = root;\n  for (const ch of word) {\n    if (!node.next.has(ch)) node.next.set(ch, { next: new Map(), end: false });\n    node = node.next.get(ch)!;\n  }\n  node.end = true;\n}',
  },
  'Choose, explore, undo': {
    CodeLanguage.python:
        'def search(values):\n    path, out = [], []\n    def explore(start):\n        out.append(path.copy())  # TODO: stopping rule\n        for i in range(start, len(values)):\n            path.append(values[i])\n            explore(i + 1)\n            path.pop()  # undo\n    explore(0); return out',
    CodeLanguage.cpp:
        'void explore(const vector<int>& a, int start, vector<int>& path, vector<vector<int>>& out) {\n    out.push_back(path); // TODO: stopping rule\n    for (int i = start; i < (int)a.size(); ++i) {\n        path.push_back(a[i]);\n        explore(a, i + 1, path, out);\n        path.pop_back(); // undo\n    }\n}',
    CodeLanguage.javascript:
        'function search(values) {\n  const path = [], out = [];\n  function explore(start) {\n    out.push([...path]); // TODO: stopping rule\n    for (let i = start; i < values.length; i++) {\n      path.push(values[i]); explore(i+1); path.pop();\n    }\n  }\n  explore(0); return out;\n}',
    CodeLanguage.typescript:
        'function search(values: number[]): number[][] {\n  const path: number[] = [], out: number[][] = [];\n  function explore(start: number): void {\n    out.push([...path]); // TODO: stopping rule\n    for (let i = start; i < values.length; i++) {\n      path.push(values[i]); explore(i+1); path.pop();\n    }\n  }\n  explore(0); return out;\n}',
  },
  'Keep the top k': {
    CodeLanguage.python:
        'import heapq\ndef top_k(values, k):\n    heap = []  # min-heap of k best values\n    for value in values:\n        heapq.heappush(heap, value)\n        if len(heap) > k: heapq.heappop(heap)\n    return heap[0]  # TODO: chosen result',
    CodeLanguage.cpp:
        'int topK(const vector<int>& values, int k) {\n    priority_queue<int, vector<int>, greater<int>> heap;\n    for (int value : values) {\n        heap.push(value);\n        if ((int)heap.size() > k) heap.pop();\n    }\n    return heap.top(); // TODO: chosen result\n}',
    CodeLanguage.javascript:
        'function topK(values, k) {\n  const heap = [];\n  function push(x) {\n    heap.push(x); let i = heap.length - 1;\n    while (i) {\n      const p = Math.floor((i-1)/2);\n      if (heap[p] <= heap[i]) break;\n      [heap[p], heap[i]] = [heap[i], heap[p]]; i = p;\n    }\n  }\n  function pop() {\n    const last = heap.pop();\n    if (!heap.length) return;\n    heap[0] = last; let i = 0;\n    while (2*i+1 < heap.length) {\n      let c = 2*i+1;\n      if (c+1 < heap.length && heap[c+1] < heap[c]) c++;\n      if (heap[i] <= heap[c]) break;\n      [heap[i], heap[c]] = [heap[c], heap[i]]; i = c;\n    }\n  }\n  for (const x of values) { push(x); if (heap.length > k) pop(); }\n  return heap[0];\n}',
    CodeLanguage.typescript:
        'function topK(values: number[], k: number): number {\n  const heap: number[] = [];\n  function push(x: number): void {\n    heap.push(x); let i = heap.length - 1;\n    while (i) {\n      const p = Math.floor((i-1)/2);\n      if (heap[p] <= heap[i]) break;\n      [heap[p], heap[i]] = [heap[i], heap[p]]; i = p;\n    }\n  }\n  function pop(): void {\n    const last = heap.pop()!;\n    if (!heap.length) return;\n    heap[0] = last; let i = 0;\n    while (2*i+1 < heap.length) {\n      let c = 2*i+1;\n      if (c+1 < heap.length && heap[c+1] < heap[c]) c++;\n      if (heap[i] <= heap[c]) break;\n      [heap[i], heap[c]] = [heap[c], heap[i]]; i = c;\n    }\n  }\n  for (const x of values) { push(x); if (heap.length > k) pop(); }\n  return heap[0];\n}',
  },
  'Topological order': {
    CodeLanguage.python:
        'from collections import deque\ndef topo(n, edges):\n    graph = [[] for _ in range(n)]; degree = [0] * n\n    for before, after in edges:\n        graph[before].append(after); degree[after] += 1\n    ready = deque(i for i in range(n) if degree[i] == 0)\n    order = []\n    while ready:\n        node = ready.popleft(); order.append(node)\n        for nxt in graph[node]:\n            degree[nxt] -= 1\n            if degree[nxt] == 0: ready.append(nxt)\n    return order if len(order) == n else None',
    CodeLanguage.cpp:
        'vector<int> topo(int n, const vector<pair<int,int>>& edges) {\n    vector<vector<int>> graph(n); vector<int> degree(n);\n    for (auto [u, v] : edges) { graph[u].push_back(v); ++degree[v]; }\n    queue<int> ready;\n    for (int i = 0; i < n; ++i) if (!degree[i]) ready.push(i);\n    vector<int> order;\n    while (!ready.empty()) {\n        int u = ready.front(); ready.pop(); order.push_back(u);\n        for (int v : graph[u]) if (--degree[v] == 0) ready.push(v);\n    }\n    return order.size() == (size_t)n ? order : vector<int>{};\n}',
    CodeLanguage.javascript:
        'function topo(n, edges) {\n  const graph = Array.from({length:n}, () => []), degree = Array(n).fill(0);\n  for (const [u,v] of edges) { graph[u].push(v); degree[v]++; }\n  const ready = [], order = [];\n  degree.forEach((d,i) => { if (d === 0) ready.push(i); });\n  for (let head = 0; head < ready.length; head++) {\n    const u = ready[head]; order.push(u);\n    for (const v of graph[u]) if (--degree[v] === 0) ready.push(v);\n  }\n  return order.length === n ? order : null;\n}',
    CodeLanguage.typescript:
        'function topo(n: number, edges: number[][]): number[] | null {\n  const graph: number[][] = Array.from({length:n}, () => []);\n  const degree = Array<number>(n).fill(0);\n  for (const [u,v] of edges) { graph[u].push(v); degree[v]++; }\n  const ready: number[] = [], order: number[] = [];\n  degree.forEach((d,i) => { if (d === 0) ready.push(i); });\n  for (let head = 0; head < ready.length; head++) {\n    const u = ready[head]; order.push(u);\n    for (const v of graph[u]) if (--degree[v] === 0) ready.push(v);\n  }\n  return order.length === n ? order : null;\n}',
  },
  'Grid state table': {
    CodeLanguage.python:
        'def grid_dp(rows, cols):\n    dp = [[0] * cols for _ in range(rows)]\n    for r in range(rows):\n        for c in range(cols):\n            above = dp[r-1][c] if r else 0\n            left = dp[r][c-1] if c else 0\n            dp[r][c] = above + left  # TODO: base/transition\n    return dp[-1][-1]',
    CodeLanguage.cpp:
        'int gridDp(int rows, int cols) {\n    vector<vector<int>> dp(rows, vector<int>(cols));\n    for (int r = 0; r < rows; ++r)\n        for (int c = 0; c < cols; ++c) {\n            int above = r ? dp[r-1][c] : 0;\n            int left = c ? dp[r][c-1] : 0;\n            dp[r][c] = above + left; // TODO: base/transition\n        }\n    return dp[rows-1][cols-1];\n}',
    CodeLanguage.javascript:
        'function gridDp(rows, cols) {\n  const dp = Array.from({length:rows}, () => Array(cols).fill(0));\n  for (let r = 0; r < rows; r++) for (let c = 0; c < cols; c++) {\n    const above = r ? dp[r-1][c] : 0;\n    const left = c ? dp[r][c-1] : 0;\n    dp[r][c] = above + left; // TODO: base/transition\n  }\n  return dp[rows-1][cols-1];\n}',
    CodeLanguage.typescript:
        'function gridDp(rows: number, cols: number): number {\n  const dp: number[][] = Array.from({length:rows}, () => Array<number>(cols).fill(0));\n  for (let r = 0; r < rows; r++) for (let c = 0; c < cols; c++) {\n    const above = r ? dp[r-1][c] : 0;\n    const left = c ? dp[r][c-1] : 0;\n    dp[r][c] = above + left; // TODO: base/transition\n  }\n  return dp[rows-1][cols-1];\n}',
  },
  'Farthest reachable point': {
    CodeLanguage.python:
        'def reachable(jumps):\n    farthest = 0\n    for i, jump in enumerate(jumps):\n        if i > farthest: return False\n        farthest = max(farthest, i + jump)\n        # TODO: return early if target reached\n    return True',
    CodeLanguage.cpp:
        'bool reachable(const vector<int>& jumps) {\n    int farthest = 0;\n    for (int i = 0; i < (int)jumps.size(); ++i) {\n        if (i > farthest) return false;\n        farthest = max(farthest, i + jumps[i]);\n    }\n    return true;\n}',
    CodeLanguage.javascript:
        'function reachable(jumps) {\n  let farthest = 0;\n  for (let i = 0; i < jumps.length; i++) {\n    if (i > farthest) return false;\n    farthest = Math.max(farthest, i + jumps[i]);\n  }\n  return true;\n}',
    CodeLanguage.typescript:
        'function reachable(jumps: number[]): boolean {\n  let farthest = 0;\n  for (let i = 0; i < jumps.length; i++) {\n    if (i > farthest) return false;\n    farthest = Math.max(farthest, i + jumps[i]);\n  }\n  return true;\n}',
  },
  'Merge overlapping intervals': {
    CodeLanguage.python:
        'def merge_ranges(ranges):\n    ranges.sort(key=lambda x: x[0])\n    out = []\n    for start, end in ranges:\n        if out and start <= out[-1][1]:\n            out[-1][1] = max(out[-1][1], end)\n        else: out.append([start, end])\n    return out',
    CodeLanguage.cpp:
        'vector<vector<int>> mergeRanges(vector<vector<int>> a) {\n    sort(a.begin(), a.end());\n    vector<vector<int>> out;\n    for (auto x : a) {\n        if (!out.empty() && x[0] <= out.back()[1])\n            out.back()[1] = max(out.back()[1], x[1]);\n        else out.push_back(x);\n    }\n    return out;\n}',
    CodeLanguage.javascript:
        'function mergeRanges(ranges) {\n  ranges.sort((a,b) => a[0]-b[0]);\n  const out = [];\n  for (const [start,end] of ranges) {\n    if (out.length && start <= out.at(-1)[1])\n      out.at(-1)[1] = Math.max(out.at(-1)[1], end);\n    else out.push([start,end]);\n  }\n  return out;\n}',
    CodeLanguage.typescript:
        'function mergeRanges(ranges: number[][]): number[][] {\n  ranges.sort((a,b) => a[0]-b[0]);\n  const out: number[][] = [];\n  for (const [start,end] of ranges) {\n    if (out.length && start <= out[out.length-1][1])\n      out[out.length-1][1] = Math.max(out[out.length-1][1], end);\n    else out.push([start,end]);\n  }\n  return out;\n}',
  },
  'XOR cancellation': {
    CodeLanguage.python:
        'def cancel_pairs(values):\n    state = 0\n    for value in values:\n        state ^= value  # equal bits cancel\n    return state',
    CodeLanguage.cpp:
        'int cancelPairs(const vector<int>& values) {\n    int state = 0;\n    for (int value : values) state ^= value;\n    return state;\n}',
    CodeLanguage.javascript:
        'function cancelPairs(values) {\n  let state = 0;\n  for (const value of values) state ^= value;\n  return state;\n}',
    CodeLanguage.typescript:
        'function cancelPairs(values: number[]): number {\n  let state = 0;\n  for (const value of values) state ^= value;\n  return state;\n}',
  },
  'Integer square root': {
    CodeLanguage.python:
        'def greatest_feasible(low, high, feasible):\n    best = low - 1\n    while low <= high:\n        mid = low + (high - low) // 2\n        if feasible(mid): best, low = mid, mid + 1\n        else: high = mid - 1\n    return best',
    CodeLanguage.cpp:
        'int greatestFeasible(int low, int high, function<bool(int)> feasible) {\n    int best = low - 1;\n    while (low <= high) {\n        int mid = low + (high - low) / 2;\n        if (feasible(mid)) { best = mid; low = mid + 1; }\n        else high = mid - 1;\n    }\n    return best;\n}',
    CodeLanguage.javascript:
        'function greatestFeasible(low, high, feasible) {\n  let best = low - 1;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (feasible(mid)) { best = mid; low = mid + 1; }\n    else high = mid - 1;\n  }\n  return best;\n}',
    CodeLanguage.typescript:
        'function greatestFeasible(low: number, high: number, feasible: (x: number) => boolean): number {\n  let best = low - 1;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (feasible(mid)) { best = mid; low = mid + 1; }\n    else high = mid - 1;\n  }\n  return best;\n}',
  },
};
