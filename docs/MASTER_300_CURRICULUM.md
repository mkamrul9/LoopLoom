# LoopLoom Interview Mastery 300

## Purpose

Build a 300-problem interview curriculum with deliberate coverage and progression. The 300 is the total path, not 300 extra questions on top of Blind 75. Blind 75 remains the recognizable first milestone and keeps its existing lesson IDs and learner progress. Problems are selected for reusable interview techniques and breadth, not to maximize quantity or claim a guaranteed interview frequency.

## Selection evidence

- NeetCode 250 publicly groups 250 interview practice problems across 18 topics, with 60 Easy, 155 Medium, and 35 Hard problems. Its categories provide a useful breadth baseline.
- NeetCode 150 is described as Blind 75 plus 75 additional questions and provides a familiar intermediate milestone.
- The Tech Interview Handbook recommends topic-first preparation followed by mixed practice; its study guide marks arrays, strings, sorting/search, matrices, trees, and graphs as high priority and hash tables, linked lists, stacks/queues, heaps, tries, and intervals as mid priority.
- These collections are editorial signals, not measured evidence that a question is likely at a particular employer. LoopLoom should not label a problem “frequently asked” without employer-specific and dated evidence.

## Planned coverage (300 total)

The baseline is the official NeetCode 250 topic allocation. The additional 50 deepen the most transferable skills and cover advanced variants. These targets are curriculum allocation counts, not claims that the referenced collections have identical taxonomies.

| Pattern family | Target | Add over 250 | Priority rationale |
| --- | ---: | ---: | --- |
| Arrays, strings, and hashing | 26 | 4 | Core data handling, frequency maps, prefix state |
| Two pointers | 15 | 2 | Sorted scans, partitioning, opposing pointers |
| Sliding window | 11 | 2 | Fixed and variable windows with explicit invariants |
| Binary search | 16 | 2 | Boundary search and answer-space search |
| Linked lists | 16 | 2 | Pointer rewiring, cycles, and list invariants |
| Stacks and monotonic structures | 16 | 2 | Parsing, next-greater, and range-boundary problems |
| Trees and BSTs | 27 | 4 | Traversal, path state, construction, and ordering |
| Tries | 5 | 1 | Prefix lookup and word search |
| Backtracking | 19 | 2 | Subsets, permutations, constraints, and pruning |
| Heaps and top-k | 15 | 3 | Streaming selection and merging ordered inputs |
| Graph traversal and modeling | 25 | 4 | Components, grids, traversal state, and dependencies |
| Advanced graphs | 15 | 5 | Union-find, shortest paths, spanning trees, and state graphs |
| One-dimensional DP | 21 | 4 | State design, transitions, and reconstruction |
| Two-dimensional DP | 20 | 4 | Sequence, grid, and knapsack state spaces |
| Greedy | 17 | 3 | Exchange arguments, scheduling, and reachability |
| Intervals | 9 | 2 | Merge, sweep-line, and scheduling boundaries |
| Bit manipulation | 12 | 2 | Masks, XOR, and bit-state reasoning |
| Math and geometry | 15 | 2 | Modular arithmetic, coordinate reasoning, and numeric edges |
| **Total** | **300** | **50** | |

## Learning progression

1. **Core 75:** preserve the existing community Blind 75 order as the first recognizable milestone; keep LoopLoom-authored coaching text and external challenge links distinct from LeetCode content.
2. **Core 150:** add canonical medium problems that extend the same patterns, especially arrays, trees, graphs, binary search, and dynamic programming.
3. **Breadth 250:** add approachable coverage across every family, including implementation and common edge cases, before concentrating on hard variants.
4. **Mastery 300:** add 50 deliberately selected extensions: answer-space search, monotonic stacks, union-find/shortest paths, stateful graph problems, DP reconstruction, and mixed-pattern transfer.

Within each family, order by prerequisite and technique; do not sort only by platform difficulty. Use an Easy/Medium/Hard label as a rough platform label, not as a measure of learner mastery. Interleave cumulative review after each family so learners must recognize patterns without a topic label.

## Editorial and product requirements

- Deduplicate by canonical challenge slug and retain stable IDs when a problem is already in the catalog.
- Store source, external challenge URL, platform difficulty, topic tags, tier, and rationale as explicit metadata.
- Keep original LoopLoom prompts, examples, hints, and explanations. Do not copy third-party statements or editorials.
- Each guided problem must ask for a contract, baseline, pattern choice, trace, complexity, implementation, and reflection, with progressive hints and an optional explanation.
- Mark reference cases and runnable languages per problem. Never imply that an external judge, unreviewed explanation, or self-check verified a solution.
- Review prompt correctness, edge cases, difficulty, overlap, accessibility, and language starter signatures before calling the curriculum reviewed.

## References

- [NeetCode 250](https://neetcode.io/practice/practice/neetcode250)
- [NeetCode 150](https://neetcode.io/practice/practice/neetcode150)
- [Tech Interview Handbook coding interview study plan](https://www.techinterviewhandbook.org/coding-interview-study-plan/)
- [Tech Interview Handbook algorithm study cheatsheet](https://www.techinterviewhandbook.org/algorithms/study-cheatsheet/)
