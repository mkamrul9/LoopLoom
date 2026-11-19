import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/mastery300_curriculum.dart';
import '../../domain/lesson.dart';
import '../../ui/looploom_theme.dart';

class PatternFrame {
  const PatternFrame(this.title, this.note, this.active);
  final String title;
  final String note;
  final List<int> active;
}

class PatternLesson {
  const PatternLesson({
    required this.title,
    required this.cue,
    required this.concept,
    required this.whenToUse,
    required this.watchFor,
    required this.example,
    required this.problemSlug,
    required this.tokens,
    required this.frames,
    required this.code,
  });

  final String title, cue, concept, whenToUse, watchFor, example, problemSlug;
  final List<String> tokens;
  final List<PatternFrame> frames;
  final Map<CodeLanguage, String> code;
}

const patternLessons = <PatternLesson>[
  PatternLesson(
    title: 'Hash map lookup',
    cue: 'Remember what you have already seen.',
    concept:
        'A map turns a search through earlier values into a direct lookup. Store only the information the next item needs.',
    whenToUse:
        'You need to find a complement, count frequencies, or remember the first position of a value.',
    watchFor:
        'Check the map before inserting the current value when an element must not pair with itself.',
    example: 'Find two values that add to 9 in [2, 7, 11, 15].',
    problemSlug: 'two-sum',
    tokens: ['2', '7', '11', '15'],
    frames: [
      PatternFrame(
        'Start at 2',
        'Need 7. The map is empty, so save 2 at index 0.',
        [0],
      ),
      PatternFrame('Move to 7', 'Need 2. The map already has 2 at index 0.', [
        0,
        1,
      ]),
      PatternFrame('Return the pair', 'Indices 0 and 1 give 2 + 7 = 9.', [
        0,
        1,
      ]),
    ],
    code: {
      CodeLanguage.python:
          'def two_sum(nums, target):\n    seen = {}\n    for i, value in enumerate(nums):\n        need = target - value\n        if need in seen:\n            return [seen[need], i]\n        seen[value] = i\n    return []',
      CodeLanguage.cpp:
          'vector<int> twoSum(const vector<int>& nums, int target) {\n    unordered_map<int, int> seen;\n    for (int i = 0; i < (int)nums.size(); ++i) {\n        int need = target - nums[i];\n        if (seen.count(need)) return {seen[need], i};\n        seen[nums[i]] = i;\n    }\n    return {};\n}',
      CodeLanguage.javascript:
          'function twoSum(nums, target) {\n  const seen = new Map();\n  for (let i = 0; i < nums.length; i++) {\n    const need = target - nums[i];\n    if (seen.has(need)) return [seen.get(need), i];\n    seen.set(nums[i], i);\n  }\n  return [];\n}',
      CodeLanguage.typescript:
          'function twoSum(nums: number[], target: number): number[] {\n  const seen = new Map<number, number>();\n  for (let i = 0; i < nums.length; i++) {\n    const need = target - nums[i];\n    if (seen.has(need)) return [seen.get(need)!, i];\n    seen.set(nums[i], i);\n  }\n  return [];\n}',
    },
  ),
  PatternLesson(
    title: 'Two pointers',
    cue: 'Move the boundary that can improve the answer.',
    concept:
        'Keep two positions and use an ordering rule to discard impossible choices. Each move must be justified by an invariant.',
    whenToUse:
        'The data is sorted, or a comparison at both ends tells you which side can be discarded.',
    watchFor:
        'Use left < right when the same element cannot be used twice. Explain why a pointer move cannot skip the answer.',
    example: 'Find a pair summing to 11 in sorted [1, 3, 4, 7, 9].',
    problemSlug: 'two-sum-ii-input-array-is-sorted',
    tokens: ['1', '3', '4', '7', '9'],
    frames: [
      PatternFrame(
        'Start at both ends',
        '1 + 9 = 10. Too small: move the left pointer right.',
        [0, 4],
      ),
      PatternFrame(
        'Compare again',
        '3 + 9 = 12. Too large: move the right pointer left.',
        [1, 4],
      ),
      PatternFrame('Narrow the range', '3 + 7 = 10. Move left again.', [1, 3]),
      PatternFrame('Match', '4 + 7 = 11. Return this pair.', [2, 3]),
    ],
    code: {
      CodeLanguage.python:
          'def sorted_pair(nums, target):\n    left, right = 0, len(nums) - 1\n    while left < right:\n        total = nums[left] + nums[right]\n        if total == target: return [left, right]\n        if total < target: left += 1\n        else: right -= 1\n    return []',
      CodeLanguage.cpp:
          'vector<int> sortedPair(const vector<int>& nums, int target) {\n    int left = 0, right = (int)nums.size() - 1;\n    while (left < right) {\n        int sum = nums[left] + nums[right];\n        if (sum == target) return {left, right};\n        if (sum < target) ++left; else --right;\n    }\n    return {};\n}',
      CodeLanguage.javascript:
          'function sortedPair(nums, target) {\n  let left = 0, right = nums.length - 1;\n  while (left < right) {\n    const sum = nums[left] + nums[right];\n    if (sum === target) return [left, right];\n    if (sum < target) left++; else right--;\n  }\n  return [];\n}',
      CodeLanguage.typescript:
          'function sortedPair(nums: number[], target: number): number[] {\n  let left = 0, right = nums.length - 1;\n  while (left < right) {\n    const sum = nums[left] + nums[right];\n    if (sum === target) return [left, right];\n    if (sum < target) left++; else right--;\n  }\n  return [];\n}',
    },
  ),
  PatternLesson(
    title: 'Sliding window',
    cue: 'Update a range instead of rebuilding it.',
    concept:
        'Keep a contiguous window and maintain a small summary as one item leaves and another enters. The example uses a fixed window; variable windows also need a clear validity rule.',
    whenToUse:
        'The question asks about a contiguous subarray or substring, especially with a fixed length or a condition that changes as the range grows.',
    watchFor:
        'Handle input shorter than the window and include the very first window in the answer.',
    example:
        'Find the maximum average of any 3 adjacent values in [2, 1, 5, 1, 3, 2].',
    problemSlug: 'maximum-average-subarray-i',
    tokens: ['2', '1', '5', '1', '3', '2'],
    frames: [
      PatternFrame('First window', '2 + 1 + 5 = 8. Best is 8.', [0, 1, 2]),
      PatternFrame('Slide right', 'Remove 2, add 1: sum is 7. Best stays 8.', [
        1,
        2,
        3,
      ]),
      PatternFrame(
        'Slide again',
        'Remove 1, add 3: sum is 9. Best becomes 9.',
        [2, 3, 4],
      ),
      PatternFrame(
        'Last window',
        'Remove 5, add 2: sum is 6. Best sum 9 gives average 9 / 3 = 3.',
        [3, 4, 5],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def max_average(nums, k):\n    if k <= 0 or k > len(nums): return None\n    window = sum(nums[:k])\n    best = window\n    for right in range(k, len(nums)):\n        window += nums[right] - nums[right - k]\n        best = max(best, window)\n    return best / k',
      CodeLanguage.cpp:
          'double maxAverage(const vector<int>& nums, int k) {\n    if (k <= 0 || k > (int)nums.size()) throw invalid_argument("k");\n    int window = 0;\n    for (int i = 0; i < k; ++i) window += nums[i];\n    int best = window;\n    for (int r = k; r < (int)nums.size(); ++r) {\n        window += nums[r] - nums[r - k];\n        best = max(best, window);\n    }\n    return (double)best / k;\n}',
      CodeLanguage.javascript:
          'function maxAverage(nums, k) {\n  if (k <= 0 || k > nums.length) return null;\n  let window = nums.slice(0, k).reduce((a, b) => a + b, 0);\n  let best = window;\n  for (let r = k; r < nums.length; r++) {\n    window += nums[r] - nums[r - k];\n    best = Math.max(best, window);\n  }\n  return best / k;\n}',
      CodeLanguage.typescript:
          'function maxAverage(nums: number[], k: number): number | null {\n  if (k <= 0 || k > nums.length) return null;\n  let window = nums.slice(0, k).reduce((a, b) => a + b, 0);\n  let best = window;\n  for (let r = k; r < nums.length; r++) {\n    window += nums[r] - nums[r - k];\n    best = Math.max(best, window);\n  }\n  return best / k;\n}',
    },
  ),
  PatternLesson(
    title: 'Binary search',
    cue: 'Discard half using a monotonic rule.',
    concept:
        'Maintain an inclusive search interval. Compare the middle with a target, then discard the half that cannot contain the answer.',
    whenToUse:
        'The input is sorted or the possible answers follow a monotonic yes/no condition.',
    watchFor:
        'State whether high is inclusive. Update low to mid + 1 or high to mid - 1 so the interval shrinks.',
    example: 'Find 9 in sorted [1, 3, 5, 7, 9, 11].',
    problemSlug: 'binary-search',
    tokens: ['1', '3', '5', '7', '9', '11'],
    frames: [
      PatternFrame(
        'Check the middle',
        'Low 0, high 5, middle 2: value 5 is too small.',
        [0, 2, 5],
      ),
      PatternFrame(
        'Discard the left half',
        'Low becomes 3. Middle 4 has value 9.',
        [3, 4, 5],
      ),
      PatternFrame(
        'Found',
        'Return index 4. No other positions need checking.',
        [4],
      ),
    ],
    code: {
      CodeLanguage.python:
          'def binary_search(nums, target):\n    low, high = 0, len(nums) - 1\n    while low <= high:\n        mid = (low + high) // 2\n        if nums[mid] == target: return mid\n        if nums[mid] < target: low = mid + 1\n        else: high = mid - 1\n    return -1',
      CodeLanguage.cpp:
          'int binarySearch(const vector<int>& nums, int target) {\n    int low = 0, high = (int)nums.size() - 1;\n    while (low <= high) {\n        int mid = low + (high - low) / 2;\n        if (nums[mid] == target) return mid;\n        if (nums[mid] < target) low = mid + 1;\n        else high = mid - 1;\n    }\n    return -1;\n}',
      CodeLanguage.javascript:
          'function binarySearch(nums, target) {\n  let low = 0, high = nums.length - 1;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (nums[mid] === target) return mid;\n    if (nums[mid] < target) low = mid + 1;\n    else high = mid - 1;\n  }\n  return -1;\n}',
      CodeLanguage.typescript:
          'function binarySearch(nums: number[], target: number): number {\n  let low = 0, high = nums.length - 1;\n  while (low <= high) {\n    const mid = low + Math.floor((high - low) / 2);\n    if (nums[mid] === target) return mid;\n    if (nums[mid] < target) low = mid + 1;\n    else high = mid - 1;\n  }\n  return -1;\n}',
    },
  ),
  PatternLesson(
    title: 'Graph traversal',
    cue: 'Visit each reachable state once.',
    concept:
        'Model states as nodes and connections as edges. Breadth-first search keeps a queue so nearby states are visited before distant ones.',
    whenToUse:
        'The problem describes connections, reachability, shortest unweighted paths, or a grid you can move through.',
    watchFor:
        'Mark a node visited when adding it to the queue, so two neighbors cannot enqueue it twice.',
    example: 'Start at A with edges A–B, A–C, B–D, C–E. Visit in BFS order.',
    problemSlug: 'number-of-islands',
    tokens: ['A', 'B', 'C', 'D', 'E'],
    frames: [
      PatternFrame('Start', 'Queue [A]; mark A visited.', [0]),
      PatternFrame('Expand A', 'Add B and C to the queue. Visit order: A.', [
        1,
        2,
      ]),
      PatternFrame('Expand B', 'Add D. Visit order: A, B.', [1, 3]),
      PatternFrame('Expand C', 'Add E. Visit order: A, B, C.', [2, 4]),
      PatternFrame('Finish', 'After D and E, BFS order is A, B, C, D, E.', [
        3,
        4,
      ]),
    ],
    code: {
      CodeLanguage.python:
          'from collections import deque\ndef bfs(graph, start):\n    queue = deque([start])\n    seen = {start}\n    order = []\n    while queue:\n        node = queue.popleft()\n        order.append(node)\n        for neighbor in graph[node]:\n            if neighbor not in seen:\n                seen.add(neighbor)\n                queue.append(neighbor)\n    return order',
      CodeLanguage.cpp:
          'vector<int> bfs(const vector<vector<int>>& graph, int start) {\n    queue<int> pending; pending.push(start);\n    vector<bool> seen(graph.size(), false); seen[start] = true;\n    vector<int> order;\n    while (!pending.empty()) {\n        int node = pending.front(); pending.pop();\n        order.push_back(node);\n        for (int next : graph[node]) if (!seen[next]) {\n            seen[next] = true; pending.push(next);\n        }\n    }\n    return order;\n}',
      CodeLanguage.javascript:
          'function bfs(graph, start) {\n  const queue = [start], seen = new Set([start]), order = [];\n  for (let head = 0; head < queue.length; head++) {\n    const node = queue[head];\n    order.push(node);\n    for (const next of graph[node]) {\n      if (!seen.has(next)) { seen.add(next); queue.push(next); }\n    }\n  }\n  return order;\n}',
      CodeLanguage.typescript:
          'function bfs(graph: number[][], start: number): number[] {\n  const queue = [start], seen = new Set<number>([start]);\n  const order: number[] = [];\n  for (let head = 0; head < queue.length; head++) {\n    const node = queue[head];\n    order.push(node);\n    for (const next of graph[node]) {\n      if (!seen.has(next)) { seen.add(next); queue.push(next); }\n    }\n  }\n  return order;\n}',
    },
  ),
  PatternLesson(
    title: 'Dynamic programming',
    cue: 'Reuse answers to smaller states.',
    concept:
        'Define what one state means, its base cases, and how earlier states produce the next one. Store each answer once.',
    whenToUse:
        'The same subproblem appears repeatedly and the answer can be built from smaller answers.',
    watchFor:
        'Write the base cases before the recurrence. Check the smallest allowed input.',
    example: 'Count ways to reach stair 5 using moves of 1 or 2 steps.',
    problemSlug: 'climbing-stairs',
    tokens: ['0', '1', '2', '3', '4', '5'],
    frames: [
      PatternFrame('Base cases', 'Ways(0) = 1 and ways(1) = 1.', [0, 1]),
      PatternFrame('Stair 2', 'Ways(2) = ways(1) + ways(0) = 2.', [0, 1, 2]),
      PatternFrame('Stair 3', 'Ways(3) = 2 + 1 = 3.', [1, 2, 3]),
      PatternFrame('Stair 4', 'Ways(4) = 3 + 2 = 5.', [2, 3, 4]),
      PatternFrame('Stair 5', 'Ways(5) = 5 + 3 = 8.', [3, 4, 5]),
    ],
    code: {
      CodeLanguage.python:
          'def climb_stairs(n):\n    previous, current = 1, 1\n    for _ in range(2, n + 1):\n        previous, current = current, previous + current\n    return current',
      CodeLanguage.cpp:
          'int climbStairs(int n) {\n    int previous = 1, current = 1;\n    for (int step = 2; step <= n; ++step) {\n        int next = previous + current;\n        previous = current; current = next;\n    }\n    return current;\n}',
      CodeLanguage.javascript:
          'function climbStairs(n) {\n  let previous = 1, current = 1;\n  for (let step = 2; step <= n; step++) {\n    [previous, current] = [current, previous + current];\n  }\n  return current;\n}',
      CodeLanguage.typescript:
          'function climbStairs(n: number): number {\n  let previous = 1, current = 1;\n  for (let step = 2; step <= n; step++) {\n    [previous, current] = [current, previous + current];\n  }\n  return current;\n}',
    },
  ),
];

class PatternLibrary extends StatelessWidget {
  const PatternLibrary({super.key, required this.onStartProblem});
  final void Function(Lesson) onStartProblem;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('PATTERN LIBRARY', style: noteLabel),
      const SizedBox(height: 12),
      const Text(
        'Learn the move.',
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text(
        'One idea at a time. Read it, watch the dry run, then try a problem.',
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: context.palette.muted,
        ),
      ),
      const SizedBox(height: 22),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 680 ? 2 : 1;
          final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final pattern in patternLessons)
                SizedBox(
                  width: width,
                  child: Card(
                    margin: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PatternLessonScreen(
                            lesson: pattern,
                            onStartProblem: onStartProblem,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.account_tree_outlined,
                              color: context.palette.accent,
                              size: 24,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              pattern.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              pattern.cue,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.palette.muted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Concept · Code · Dry run',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.palette.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ],
  );
}

enum _LessonView { concept, code, dryRun }

class PatternLessonScreen extends StatefulWidget {
  const PatternLessonScreen({
    super.key,
    required this.lesson,
    required this.onStartProblem,
  });
  final PatternLesson lesson;
  final void Function(Lesson) onStartProblem;

  @override
  State<PatternLessonScreen> createState() => _PatternLessonScreenState();
}

class _PatternLessonScreenState extends State<PatternLessonScreen> {
  _LessonView _view = _LessonView.concept;
  CodeLanguage _language = CodeLanguage.python;
  int _frame = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setView(_LessonView view) {
    _timer?.cancel();
    setState(() => _view = view);
  }

  void _move(int index) {
    _timer?.cancel();
    setState(() => _frame = index.clamp(0, widget.lesson.frames.length - 1));
  }

  void _play() {
    if (_timer?.isActive == true) {
      _timer?.cancel();
      setState(() {});
      return;
    }
    if (_frame == widget.lesson.frames.length - 1) _frame = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) return;
      if (_frame == widget.lesson.frames.length - 1) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() => _frame++);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final entry = mastery300Entries.singleWhere(
      (entry) => entry.slug == widget.lesson.problemSlug,
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
            children: [
              Text(
                widget.lesson.cue,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Concept'),
                    selected: _view == _LessonView.concept,
                    onSelected: (_) => _setView(_LessonView.concept),
                  ),
                  ChoiceChip(
                    label: const Text('Code'),
                    selected: _view == _LessonView.code,
                    onSelected: (_) => _setView(_LessonView.code),
                  ),
                  ChoiceChip(
                    label: const Text('Dry run'),
                    selected: _view == _LessonView.dryRun,
                    onSelected: (_) => _setView(_LessonView.dryRun),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                child: KeyedSubtree(
                  key: ValueKey(_view),
                  child: switch (_view) {
                    _LessonView.concept => _concept(context),
                    _LessonView.code => _code(context),
                    _LessonView.dryRun => _dryRun(context),
                  },
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onStartProblem(entry.lesson);
                },
                icon: const Icon(Icons.arrow_forward),
                label: Text('Practice: ${entry.lesson.title}'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _concept(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('The idea'),
      Text(
        widget.lesson.concept,
        style: const TextStyle(fontSize: 16, height: 1.65),
      ),
      const SizedBox(height: 20),
      _heading('When to use it'),
      Text(
        widget.lesson.whenToUse,
        style: const TextStyle(fontSize: 16, height: 1.65),
      ),
      const SizedBox(height: 20),
      _heading('Watch for'),
      Text(
        widget.lesson.watchFor,
        style: const TextStyle(fontSize: 16, height: 1.65),
      ),
      const SizedBox(height: 14),
      OutlinedButton.icon(
        onPressed: () => _setView(_LessonView.dryRun),
        icon: const Icon(Icons.play_arrow_outlined),
        label: const Text('See the example'),
      ),
    ],
  );

  Widget _code(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _heading('Pattern example'),
      Text(
        'This is a small teaching example, not a solution for every problem in this pattern.',
        style: TextStyle(fontSize: 14, color: context.palette.muted),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          for (final language in CodeLanguage.values)
            ChoiceChip(
              label: Text(language.label),
              selected: _language == language,
              onSelected: (_) => setState(() => _language = language),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.palette.recess,
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            widget.lesson.code[_language]!,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _dryRun(BuildContext context) {
    final frame = widget.lesson.frames[_frame];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading('Worked example'),
        Text(
          widget.lesson.example,
          style: const TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (index, token) in widget.lesson.tokens.indexed)
              AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: frame.active.contains(index)
                      ? context.palette.accentWash
                      : context.palette.sheet,
                  border: Border.all(
                    color: frame.active.contains(index)
                        ? context.palette.accent
                        : context.palette.line,
                    width: frame.active.contains(index) ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  token,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        LinearProgressIndicator(
          value: (_frame + 1) / widget.lesson.frames.length,
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          child: Column(
            key: ValueKey(_frame),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_frame + 1} / ${widget.lesson.frames.length} · ${frame.title}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                frame.note,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: _frame == 0 ? null : () => _move(_frame - 1),
              icon: const Icon(Icons.arrow_back, size: 17),
              label: const Text('Back'),
            ),
            FilledButton.tonalIcon(
              onPressed: _play,
              icon: Icon(
                _timer?.isActive == true ? Icons.pause : Icons.play_arrow,
                size: 18,
              ),
              label: Text(
                _timer?.isActive == true
                    ? 'Pause'
                    : _frame == widget.lesson.frames.length - 1
                    ? 'Replay'
                    : 'Play',
              ),
            ),
            OutlinedButton.icon(
              onPressed: _frame == widget.lesson.frames.length - 1
                  ? null
                  : () => _move(_frame + 1),
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: const Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}
