"""Original reference material for the 25-problem interview sprint.

`build_sprint_content.py` publishes this data to the runner and Flutter app.
Tree inputs in this small reference suite are heap-indexed level order arrays
with -1 for a missing node; the linked-list exercises use value arrays.
"""

CASES = {
    'blind75-contains-duplicate-v1': [
        {'label':'Repeated value','args':[[4,1,8,4]],'expected':True},
        {'label':'Empty input','args':[[]],'expected':False},
        {'label':'Negative duplicate','args':[[-2,3,-2]],'expected':True}],
    'mastery300-ransom-note-v1': [
        {'label':'Enough letters','args':['aab','baa'],'expected':True},
        {'label':'Insufficient copies','args':['aa','ab'],'expected':False},
        {'label':'Empty note','args':['','abc'],'expected':True}],
    'blind75-valid-palindrome-v1': [
        {'label':'Mixed case and punctuation','args':['A man, a plan, a canal: Panama'],'expected':True},
        {'label':'Near miss','args':['race a car'],'expected':False},
        {'label':'Only punctuation','args':['.,'],'expected':True}],
    'blind75-valid-parentheses-v1': [
        {'label':'Nested pairs','args':['{[()]}'],'expected':True},
        {'label':'Wrong order','args':['([)]'],'expected':False},
        {'label':'Unclosed opener','args':['('],'expected':False}],
    'blind75-merge-two-sorted-lists-v1': [
        {'label':'Equal values','args':[[1,2,4],[1,3,4]],'expected':[1,1,2,3,4,4]},
        {'label':'One empty list','args':[[],[0]],'expected':[0]},
        {'label':'Both empty','args':[[],[]],'expected':[]}],
    'blind75-reverse-linked-list-v1': [
        {'label':'Four nodes','args':[[1,2,3,4]],'expected':[4,3,2,1]},
        {'label':'Single node','args':[[7]],'expected':[7]},
        {'label':'Empty chain','args':[[]],'expected':[]}],
    'mastery300-binary-search-v1': [
        {'label':'Found middle','args':[[-1,0,3,5,9,12],9],'expected':4},
        {'label':'Absent target','args':[[-1,0,3,5,9,12],2],'expected':-1},
        {'label':'Empty array','args':[[],5],'expected':-1}],
    'mastery300-first-bad-version-v1': [
        {'label':'First bad in middle','args':[5,4],'expected':4},
        {'label':'All bad','args':[3,1],'expected':1},
        {'label':'Only last is bad','args':[7,7],'expected':7}],
    'blind75-invert-binary-tree-v1': [
        {'label':'Full tree','args':[[4,2,7,1,3,6,9]],'expected':[4,7,2,9,6,3,1]},
        {'label':'Single node','args':[[1]],'expected':[1]},
        {'label':'Empty tree','args':[[]],'expected':[]}],
    'mastery300-balanced-binary-tree-v1': [
        {'label':'Balanced','args':[[3,9,20,-1,-1,15,7]],'expected':True},
        {'label':'Skewed left','args':[[1,2,-1,3]],'expected':False},
        {'label':'Empty tree','args':[[]],'expected':True}],
    'blind75-lowest-common-ancestor-of-a-binary-search-tree-v1': [
        {'label':'Split at root','args':[[6,2,8,0,4,7,9,-1,-1,3,5],2,8],'expected':6},
        {'label':'Ancestor is a target','args':[[6,2,8,0,4,7,9,-1,-1,3,5],2,4],'expected':2},
        {'label':'Same subtree','args':[[6,2,8,0,4,7,9,-1,-1,3,5],3,5],'expected':4}],
    'mastery300-diameter-of-binary-tree-v1': [
        {'label':'Longest path through root','args':[[1,2,3,4,5]],'expected':3},
        {'label':'Single node','args':[[1]],'expected':0},
        {'label':'Empty tree','args':[[]],'expected':0}],
    'mastery300-majority-element-v1': [
        {'label':'Odd length','args':[[3,2,3]],'expected':3},
        {'label':'Even length','args':[[2,2,1,1,1,2,2]],'expected':2},
        {'label':'Single value','args':[[9]],'expected':9}],
    'blind75-climbing-stairs-v1': [
        {'label':'Four steps','args':[4],'expected':5},
        {'label':'One step','args':[1],'expected':1},
        {'label':'Two steps','args':[2],'expected':2}],
    'mastery300-single-number-v1': [
        {'label':'Paired values','args':[[4,1,2,1,2]],'expected':4},
        {'label':'Negative unique value','args':[[-2,1,1]],'expected':-2},
        {'label':'Single value','args':[[8]],'expected':8}],
    'blind75-merge-intervals-v1': [
        {'label':'Overlaps','args':[[[1,3],[2,6],[8,10],[15,18]]],'expected':[[1,6],[8,10],[15,18]]},
        {'label':'Touching endpoints','args':[[[1,4],[4,5]]],'expected':[[1,5]]},
        {'label':'Nested and unsorted','args':[[[6,8],[1,10],[2,3]]],'expected':[[1,10]]}],
}

EDGE_CASES = {
    'two-sum':['Repeated values can form a pair at different indices.','Never reuse the same index twice.','A missing pair returns an empty list in this workbook.'],
    'valid-anagram':['Check different lengths first.','Repeated letters need counts, not just a set.','Two empty strings are anagrams.'],
    'contains-duplicate':['An empty or one-value array has no duplicate.','Negative values behave like other keys.','Do not change the input while checking.'],
    'ransom-note':['A letter may be needed more than once.','An empty note is always possible.','Case and character constraints come from the official problem.'],
    'best-time-to-buy-and-sell-stock':['Sell only after buying.','A declining series has profit zero.','The earliest minimum is not always the first value.'],
    'valid-palindrome':['Ignore punctuation and spaces.','Compare letters without case sensitivity.','A string with no letters or digits is valid.'],
    'valid-parentheses':['A closer must match the latest unmatched opener.','An unfinished opener invalidates the string.','Order matters even when counts match.'],
    'product-of-array-except-self':['One zero changes every position except its own.','Two zeros make every product zero.','Do not divide; preserve input order.'],
    'merge-two-sorted-lists':['Either list can be empty.','Equal values must both remain.','The workbook returns values; the official site uses list nodes.'],
    'reverse-linked-list':['Empty and one-node chains stay valid.','Save the next pointer before reversing a link.','The workbook returns values; the official site uses list nodes.'],
    'linked-list-cycle':['A null next pointer means no cycle.','A one-node self-loop is a cycle.','Do not mistake repeated values for repeated nodes.'],
    'longest-substring-without-repeating-characters':['Repeated characters can sit inside a sliding window.','The empty string has length zero.','Move the left edge forward only.'],
    'binary-search':['The target may lie beyond either end.','An empty array returns -1.','Update boundaries so the interval shrinks.'],
    'first-bad-version':['Version 1 may already be bad.','Only the last version may be bad.','Avoid overflow in midpoint calculations.'],
    'invert-binary-tree':['A missing child remains missing after swapping.','An empty tree stays empty.','The workbook uses -1 for absent nodes in heap-indexed level order.'],
    'maximum-depth-of-binary-tree':['An empty tree has depth zero.','A single node has depth one.','A skewed tree is deeper than a full tree of similar size.'],
    'balanced-binary-tree':['Check balance at every node, not just the root.','A height difference of one is allowed.','The workbook uses -1 for absent nodes in heap-indexed level order.'],
    'lowest-common-ancestor-of-a-binary-search-tree':['One target may itself be the ancestor.','Use BST ordering to choose a side.','The workbook uses -1 for absent nodes in heap-indexed level order.'],
    'diameter-of-binary-tree':['Diameter counts edges, not nodes.','The longest path need not pass through the root.','An empty or one-node tree has diameter zero.'],
    'maximum-subarray':['All values may be negative.','A one-value array returns that value.','Do not reset the running sum before considering the current value.'],
    'majority-element':['The majority count is strictly greater than half.','The official problem guarantees one exists.','A candidate needs validation if that guarantee is removed.'],
    'climbing-stairs':['One and two steps are base cases.','The next count adds the previous two.','Clarify whether zero steps is allowed in the official constraints.'],
    'single-number':['Other numbers appear exactly twice.','Negative values work with XOR.','The unique number can be the only element.'],
    'number-of-islands':['Empty and all-water grids have zero islands.','Only horizontal and vertical neighbors connect.','Mark a cell when enqueuing to avoid duplicate visits.'],
    'merge-intervals':['Intervals may arrive unsorted.','Touching endpoints overlap under closed intervals.','Nested intervals must not shrink the current end.'],
}

# For new sprint lessons: first argument types, then any additional argument types.
CPP_TYPES = {
    'blind75-contains-duplicate-v1':['vector<int>'],
    'mastery300-ransom-note-v1':['string','string'],
    'blind75-valid-palindrome-v1':['string'],
    'blind75-valid-parentheses-v1':['string'],
    'blind75-merge-two-sorted-lists-v1':['vector<int>','vector<int>'],
    'blind75-reverse-linked-list-v1':['vector<int>'],
    'mastery300-binary-search-v1':['vector<int>','int'],
    'mastery300-first-bad-version-v1':['int','int'],
    'blind75-invert-binary-tree-v1':['vector<int>'],
    'mastery300-balanced-binary-tree-v1':['vector<int>'],
    'blind75-lowest-common-ancestor-of-a-binary-search-tree-v1':['vector<int>','int','int'],
    'mastery300-diameter-of-binary-tree-v1':['vector<int>'],
    'mastery300-majority-element-v1':['vector<int>'],
    'blind75-climbing-stairs-v1':['int'],
    'mastery300-single-number-v1':['vector<int>'],
    'blind75-merge-intervals-v1':['vector<vector<int>>'],
}

PYTHON = {
 'blind75-contains-duplicate-v1': '''def solve(values):
    seen = set()
    for value in values:
        if value in seen:
            return True
        seen.add(value)
    return False''',
 'mastery300-ransom-note-v1': '''def solve(note, magazine):
    from collections import Counter
    available = Counter(magazine)
    for letter in note:
        if available[letter] == 0:
            return False
        available[letter] -= 1
    return True''',
 'blind75-valid-palindrome-v1': '''def solve(text):
    left, right = 0, len(text) - 1
    while left < right:
        if not text[left].isalnum():
            left += 1
        elif not text[right].isalnum():
            right -= 1
        elif text[left].lower() != text[right].lower():
            return False
        else:
            left += 1
            right -= 1
    return True''',
 'blind75-valid-parentheses-v1': '''def solve(text):
    matching = {')': '(', ']': '[', '}': '{'}
    stack = []
    for char in text:
        if char in matching:
            if not stack or stack.pop() != matching[char]:
                return False
        else:
            stack.append(char)
    return not stack''',
 'blind75-merge-two-sorted-lists-v1': '''def solve(first, second):
    left = right = 0
    merged = []
    while left < len(first) and right < len(second):
        if first[left] <= second[right]:
            merged.append(first[left]); left += 1
        else:
            merged.append(second[right]); right += 1
    return merged + first[left:] + second[right:]''',
 'blind75-reverse-linked-list-v1': '''def solve(values):
    result = []
    for index in range(len(values) - 1, -1, -1):
        result.append(values[index])
    return result''',
 'mastery300-binary-search-v1': '''def solve(values, target):
    left, right = 0, len(values) - 1
    while left <= right:
        mid = left + (right - left) // 2
        if values[mid] == target:
            return mid
        if values[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    return -1''',
 'mastery300-first-bad-version-v1': '''def solve(n, first_bad):
    # first_bad stands in for the official isBadVersion API.
    left, right = 1, n
    while left < right:
        mid = left + (right - left) // 2
        if mid >= first_bad:
            right = mid
        else:
            left = mid + 1
    return left''',
 'blind75-invert-binary-tree-v1': '''def solve(level_order):
    # This workbook uses heap-indexed level order with -1 for null.
    if not level_order:
        return []
    result = []
    queue = [0]
    head = 0
    while head < len(queue):
        index = queue[head]; head += 1
        if index < 0 or index >= len(level_order) or level_order[index] == -1:
            result.append(-1)
            continue
        result.append(level_order[index])
        queue.extend((2 * index + 2, 2 * index + 1))
    while result and result[-1] == -1:
        result.pop()
    return result''',
 'mastery300-balanced-binary-tree-v1': '''def solve(level_order):
    def height(index):
        if index >= len(level_order) or level_order[index] == -1:
            return 0
        left = height(2 * index + 1)
        right = height(2 * index + 2)
        if left < 0 or right < 0 or abs(left - right) > 1:
            return -1
        return 1 + max(left, right)
    return height(0) >= 0''',
 'blind75-lowest-common-ancestor-of-a-binary-search-tree-v1': '''def solve(level_order, p, q):
    index = 0
    while index < len(level_order) and level_order[index] != -1:
        value = level_order[index]
        if p < value and q < value:
            index = 2 * index + 1
        elif p > value and q > value:
            index = 2 * index + 2
        else:
            return value
    return -1''',
 'mastery300-diameter-of-binary-tree-v1': '''def solve(level_order):
    diameter = 0
    def height(index):
        nonlocal diameter
        if index >= len(level_order) or level_order[index] == -1:
            return 0
        left = height(2 * index + 1)
        right = height(2 * index + 2)
        diameter = max(diameter, left + right)
        return 1 + max(left, right)
    height(0)
    return diameter''',
 'mastery300-majority-element-v1': '''def solve(values):
    candidate = None
    balance = 0
    for value in values:
        if balance == 0:
            candidate = value
        balance += 1 if value == candidate else -1
    return candidate''',
 'blind75-climbing-stairs-v1': '''def solve(n):
    previous, current = 1, 1
    for _ in range(n):
        previous, current = current, previous + current
    return previous''',
 'mastery300-single-number-v1': '''def solve(values):
    unique = 0
    for value in values:
        unique ^= value
    return unique''',
 'blind75-merge-intervals-v1': '''def solve(intervals):
    merged = []
    for start, end in sorted(intervals):
        if merged and start <= merged[-1][1]:
            merged[-1][1] = max(merged[-1][1], end)
        else:
            merged.append([start, end])
    return merged''',
}

JAVASCRIPT = {
 'blind75-contains-duplicate-v1': '''function solve(values) {
  const seen = new Set();
  for (const value of values) {
    if (seen.has(value)) return true;
    seen.add(value);
  }
  return false;
}''',
 'mastery300-ransom-note-v1': '''function solve(note, magazine) {
  const counts = new Map();
  for (const char of magazine) counts.set(char, (counts.get(char) || 0) + 1);
  for (const char of note) {
    if (!counts.get(char)) return false;
    counts.set(char, counts.get(char) - 1);
  }
  return true;
}''',
 'blind75-valid-palindrome-v1': '''function solve(text) {
  let left = 0, right = text.length - 1;
  const isLetterOrDigit = char => /^[a-z0-9]$/i.test(char);
  while (left < right) {
    if (!isLetterOrDigit(text[left])) left++;
    else if (!isLetterOrDigit(text[right])) right--;
    else if (text[left++].toLowerCase() !== text[right--].toLowerCase()) return false;
  }
  return true;
}''',
 'blind75-valid-parentheses-v1': '''function solve(text) {
  const matching = {')':'(', ']':'[', '}':'{'};
  const stack = [];
  for (const char of text) {
    if (char in matching) {
      if (stack.pop() !== matching[char]) return false;
    } else stack.push(char);
  }
  return stack.length === 0;
}''',
 'blind75-merge-two-sorted-lists-v1': '''function solve(first, second) {
  let left = 0, right = 0;
  const merged = [];
  while (left < first.length && right < second.length) {
    if (first[left] <= second[right]) merged.push(first[left++]);
    else merged.push(second[right++]);
  }
  return merged.concat(first.slice(left), second.slice(right));
}''',
 'blind75-reverse-linked-list-v1': '''function solve(values) {
  const reversed = [];
  for (let i = values.length - 1; i >= 0; i--) reversed.push(values[i]);
  return reversed;
}''',
 'mastery300-binary-search-v1': '''function solve(values, target) {
  let left = 0, right = values.length - 1;
  while (left <= right) {
    const mid = left + Math.floor((right - left) / 2);
    if (values[mid] === target) return mid;
    if (values[mid] < target) left = mid + 1;
    else right = mid - 1;
  }
  return -1;
}''',
 'mastery300-first-bad-version-v1': '''function solve(n, firstBad) {
  // firstBad stands in for the official isBadVersion API.
  let left = 1, right = n;
  while (left < right) {
    const mid = left + Math.floor((right - left) / 2);
    if (mid >= firstBad) right = mid;
    else left = mid + 1;
  }
  return left;
}''',
 'blind75-invert-binary-tree-v1': '''function solve(levelOrder) {
  // Heap-indexed level order; -1 denotes null in this workbook.
  if (!levelOrder.length) return [];
  const result = [], queue = [0];
  for (let head = 0; head < queue.length; head++) {
    const i = queue[head];
    if (i < 0 || i >= levelOrder.length || levelOrder[i] === -1) {
      result.push(-1); continue;
    }
    result.push(levelOrder[i]);
    queue.push(2 * i + 2, 2 * i + 1);
  }
  while (result.at(-1) === -1) result.pop();
  return result;
}''',
 'mastery300-balanced-binary-tree-v1': '''function solve(levelOrder) {
  function height(i) {
    if (i >= levelOrder.length || levelOrder[i] === -1) return 0;
    const left = height(2 * i + 1), right = height(2 * i + 2);
    if (left < 0 || right < 0 || Math.abs(left - right) > 1) return -1;
    return 1 + Math.max(left, right);
  }
  return height(0) >= 0;
}''',
 'blind75-lowest-common-ancestor-of-a-binary-search-tree-v1': '''function solve(levelOrder, p, q) {
  let i = 0;
  while (i < levelOrder.length && levelOrder[i] !== -1) {
    const value = levelOrder[i];
    if (p < value && q < value) i = 2 * i + 1;
    else if (p > value && q > value) i = 2 * i + 2;
    else return value;
  }
  return -1;
}''',
 'mastery300-diameter-of-binary-tree-v1': '''function solve(levelOrder) {
  let diameter = 0;
  function height(i) {
    if (i >= levelOrder.length || levelOrder[i] === -1) return 0;
    const left = height(2 * i + 1), right = height(2 * i + 2);
    diameter = Math.max(diameter, left + right);
    return 1 + Math.max(left, right);
  }
  height(0);
  return diameter;
}''',
 'mastery300-majority-element-v1': '''function solve(values) {
  let candidate = 0, balance = 0;
  for (const value of values) {
    if (balance === 0) candidate = value;
    balance += value === candidate ? 1 : -1;
  }
  return candidate;
}''',
 'blind75-climbing-stairs-v1': '''function solve(n) {
  let previous = 1, current = 1;
  for (let step = 0; step < n; step++) [previous, current] = [current, previous + current];
  return previous;
}''',
 'mastery300-single-number-v1': '''function solve(values) {
  let unique = 0;
  for (const value of values) unique ^= value;
  return unique;
}''',
 'blind75-merge-intervals-v1': '''function solve(intervals) {
  const ordered = intervals.map(pair => [...pair]).sort((a,b) => a[0] - b[0]);
  const merged = [];
  for (const [start,end] of ordered) {
    if (merged.length && start <= merged.at(-1)[1])
      merged.at(-1)[1] = Math.max(merged.at(-1)[1], end);
    else merged.push([start,end]);
  }
  return merged;
}''',
}

CPP = {
 'blind75-contains-duplicate-v1': '''bool solve(const vector<int>& values) {
  unordered_set<int> seen;
  for (int value : values) if (!seen.insert(value).second) return true;
  return false;
}''',
 'mastery300-ransom-note-v1': '''bool solve(const string& note, const string& magazine) {
  int count[26] = {};
  for (char c : magazine) ++count[c - 'a'];
  for (char c : note) if (--count[c - 'a'] < 0) return false;
  return true;
}''',
 'blind75-valid-palindrome-v1': '''bool solve(const string& text) {
  int left = 0, right = (int)text.size() - 1;
  while (left < right) {
    if (!isalnum((unsigned char)text[left])) ++left;
    else if (!isalnum((unsigned char)text[right])) --right;
    else if (tolower((unsigned char)text[left++]) != tolower((unsigned char)text[right--])) return false;
  }
  return true;
}''',
 'blind75-valid-parentheses-v1': '''bool solve(const string& text) {
  stack<char> open;
  for (char c : text) {
    if (c == '(' || c == '[' || c == '{') open.push(c);
    else {
      if (open.empty()) return false;
      char previous = open.top(); open.pop();
      if ((c == ')' && previous != '(') || (c == ']' && previous != '[') || (c == '}' && previous != '{')) return false;
    }
  }
  return open.empty();
}''',
 'blind75-merge-two-sorted-lists-v1': '''vector<int> solve(const vector<int>& first, const vector<int>& second) {
  vector<int> merged;
  int left = 0, right = 0;
  while (left < (int)first.size() && right < (int)second.size()) {
    if (first[left] <= second[right]) merged.push_back(first[left++]);
    else merged.push_back(second[right++]);
  }
  while (left < (int)first.size()) merged.push_back(first[left++]);
  while (right < (int)second.size()) merged.push_back(second[right++]);
  return merged;
}''',
 'blind75-reverse-linked-list-v1': '''vector<int> solve(const vector<int>& values) {
  return vector<int>(values.rbegin(), values.rend());
}''',
 'mastery300-binary-search-v1': '''int solve(const vector<int>& values, int target) {
  int left = 0, right = (int)values.size() - 1;
  while (left <= right) {
    int mid = left + (right - left) / 2;
    if (values[mid] == target) return mid;
    if (values[mid] < target) left = mid + 1;
    else right = mid - 1;
  }
  return -1;
}''',
 'mastery300-first-bad-version-v1': '''int solve(int n, int firstBad) {
  // firstBad stands in for the official isBadVersion API.
  int left = 1, right = n;
  while (left < right) {
    int mid = left + (right - left) / 2;
    if (mid >= firstBad) right = mid;
    else left = mid + 1;
  }
  return left;
}''',
 'blind75-invert-binary-tree-v1': '''vector<int> solve(const vector<int>& levelOrder) {
  if (levelOrder.empty()) return {};
  vector<int> result;
  queue<int> pending; pending.push(0);
  while (!pending.empty()) {
    int i = pending.front(); pending.pop();
    if (i < 0 || i >= (int)levelOrder.size() || levelOrder[i] == -1) {
      result.push_back(-1); continue;
    }
    result.push_back(levelOrder[i]);
    pending.push(2 * i + 2); pending.push(2 * i + 1);
  }
  while (!result.empty() && result.back() == -1) result.pop_back();
  return result;
}''',
 'mastery300-balanced-binary-tree-v1': '''bool solve(const vector<int>& levelOrder) {
  function<int(int)> height = [&](int i) {
    if (i >= (int)levelOrder.size() || levelOrder[i] == -1) return 0;
    int left = height(2 * i + 1), right = height(2 * i + 2);
    if (left < 0 || right < 0 || abs(left - right) > 1) return -1;
    return 1 + max(left, right);
  };
  return height(0) >= 0;
}''',
 'blind75-lowest-common-ancestor-of-a-binary-search-tree-v1': '''int solve(const vector<int>& levelOrder, int p, int q) {
  int i = 0;
  while (i < (int)levelOrder.size() && levelOrder[i] != -1) {
    int value = levelOrder[i];
    if (p < value && q < value) i = 2 * i + 1;
    else if (p > value && q > value) i = 2 * i + 2;
    else return value;
  }
  return -1;
}''',
 'mastery300-diameter-of-binary-tree-v1': '''int solve(const vector<int>& levelOrder) {
  int diameter = 0;
  function<int(int)> height = [&](int i) {
    if (i >= (int)levelOrder.size() || levelOrder[i] == -1) return 0;
    int left = height(2 * i + 1), right = height(2 * i + 2);
    diameter = max(diameter, left + right);
    return 1 + max(left, right);
  };
  height(0);
  return diameter;
}''',
 'mastery300-majority-element-v1': '''int solve(const vector<int>& values) {
  int candidate = 0, balance = 0;
  for (int value : values) {
    if (balance == 0) candidate = value;
    balance += value == candidate ? 1 : -1;
  }
  return candidate;
}''',
 'blind75-climbing-stairs-v1': '''int solve(int n) {
  int previous = 1, current = 1;
  for (int step = 0; step < n; ++step) {
    int next = previous + current;
    previous = current; current = next;
  }
  return previous;
}''',
 'mastery300-single-number-v1': '''int solve(const vector<int>& values) {
  int unique = 0;
  for (int value : values) unique ^= value;
  return unique;
}''',
 'blind75-merge-intervals-v1': '''vector<vector<int>> solve(const vector<vector<int>>& intervals) {
  auto ordered = intervals;
  sort(ordered.begin(), ordered.end());
  vector<vector<int>> merged;
  for (const auto& interval : ordered) {
    if (!merged.empty() && interval[0] <= merged.back()[1])
      merged.back()[1] = max(merged.back()[1], interval[1]);
    else merged.push_back(interval);
  }
  return merged;
}''',
}

TS_SIGNATURES = {
 'blind75-contains-duplicate-v1':'values: readonly number[]): boolean',
 'mastery300-ransom-note-v1':'note: string, magazine: string): boolean',
 'blind75-valid-palindrome-v1':'text: string): boolean',
 'blind75-valid-parentheses-v1':'text: string): boolean',
 'blind75-merge-two-sorted-lists-v1':'first: readonly number[], second: readonly number[]): number[]',
 'blind75-reverse-linked-list-v1':'values: readonly number[]): number[]',
 'mastery300-binary-search-v1':'values: readonly number[], target: number): number',
 'mastery300-first-bad-version-v1':'n: number, firstBad: number): number',
 'blind75-invert-binary-tree-v1':'levelOrder: readonly number[]): number[]',
 'mastery300-balanced-binary-tree-v1':'levelOrder: readonly number[]): boolean',
 'blind75-lowest-common-ancestor-of-a-binary-search-tree-v1':'levelOrder: readonly number[], p: number, q: number): number',
 'mastery300-diameter-of-binary-tree-v1':'levelOrder: readonly number[]): number',
 'mastery300-majority-element-v1':'values: readonly number[]): number',
 'blind75-climbing-stairs-v1':'n: number): number',
 'mastery300-single-number-v1':'values: readonly number[]): number',
 'blind75-merge-intervals-v1':'intervals: ReadonlyArray<readonly number[]>): number[][]',
}

# Additional high-value Blind 75 lessons with deterministic workbook adapters.
CASES.update({
    'blind75-container-with-most-water-v1': [
        {'label':'Classic two-pointer case','args':[[1,8,6,2,5,4,8,3,7]],'expected':49},
        {'label':'Only two lines','args':[[1,1]],'expected':1},
        {'label':'Short outer line','args':[[1,2,4,3]],'expected':4}],
    'blind75-house-robber-v1': [
        {'label':'Skip adjacent high values','args':[[2,7,9,3,1]],'expected':12},
        {'label':'Empty row','args':[[]],'expected':0},
        {'label':'One house','args':[[8]],'expected':8}],
    'blind75-jump-game-v1': [
        {'label':'Reach the end','args':[[2,3,1,1,4]],'expected':True},
        {'label':'Blocked by zero','args':[[3,2,1,0,4]],'expected':False},
        {'label':'Single index','args':[[0]],'expected':True}],
})
EDGE_CASES.update({
    'container-with-most-water':['Two lines form one possible container.','Move the shorter boundary; moving the taller one cannot improve the current width.','A short boundary can hide a better pair inside.'],
    'house-robber':['An empty row returns zero.','Taking a house excludes its immediate neighbors.','Skipping all houses is allowed.'],
    'jump-game':['A zero may block progress before the end.','One position is already at the destination.','Never use a position beyond the farthest reachable index.'],
})
CPP_TYPES.update({
    'blind75-container-with-most-water-v1':['vector<int>'],
    'blind75-house-robber-v1':['vector<int>'],
    'blind75-jump-game-v1':['vector<int>'],
})
PYTHON.update({
    'blind75-container-with-most-water-v1': '''def solve(heights):
    left, right, best = 0, len(heights) - 1, 0
    while left < right:
        best = max(best, (right - left) * min(heights[left], heights[right]))
        if heights[left] <= heights[right]:
            left += 1
        else:
            right -= 1
    return best''',
    'blind75-house-robber-v1': '''def solve(values):
    before_previous = previous = 0
    for value in values:
        before_previous, previous = previous, max(previous, before_previous + value)
    return previous''',
    'blind75-jump-game-v1': '''def solve(jumps):
    farthest = 0
    for index, distance in enumerate(jumps):
        if index > farthest:
            return False
        farthest = max(farthest, index + distance)
    return True''',
})
JAVASCRIPT.update({
    'blind75-container-with-most-water-v1': '''function solve(heights) {
  let left = 0, right = heights.length - 1, best = 0;
  while (left < right) {
    best = Math.max(best, (right - left) * Math.min(heights[left], heights[right]));
    if (heights[left] <= heights[right]) left++; else right--;
  }
  return best;
}''',
    'blind75-house-robber-v1': '''function solve(values) {
  let beforePrevious = 0, previous = 0;
  for (const value of values) {
    const next = Math.max(previous, beforePrevious + value);
    beforePrevious = previous;
    previous = next;
  }
  return previous;
}''',
    'blind75-jump-game-v1': '''function solve(jumps) {
  let farthest = 0;
  for (let index = 0; index < jumps.length; index++) {
    if (index > farthest) return false;
    farthest = Math.max(farthest, index + jumps[index]);
  }
  return true;
}''',
})
CPP.update({
    'blind75-container-with-most-water-v1': '''int solve(const vector<int>& heights) {
  int left = 0, right = (int)heights.size() - 1, best = 0;
  while (left < right) {
    best = max(best, (right - left) * min(heights[left], heights[right]));
    if (heights[left] <= heights[right]) ++left; else --right;
  }
  return best;
}''',
    'blind75-house-robber-v1': '''int solve(const vector<int>& values) {
  int beforePrevious = 0, previous = 0;
  for (int value : values) {
    int next = max(previous, beforePrevious + value);
    beforePrevious = previous;
    previous = next;
  }
  return previous;
}''',
    'blind75-jump-game-v1': '''bool solve(const vector<int>& jumps) {
  int farthest = 0;
  for (int index = 0; index < (int)jumps.size(); ++index) {
    if (index > farthest) return false;
    farthest = max(farthest, index + jumps[index]);
  }
  return true;
}''',
})
TS_SIGNATURES.update({
    'blind75-container-with-most-water-v1':'heights: readonly number[]): number',
    'blind75-house-robber-v1':'values: readonly number[]): number',
    'blind75-jump-game-v1':'jumps: readonly number[]): boolean',
})
