# Intermediate foundations

Nine original lessons extend the pilot to twelve problems across two available tracks. Intermediate foundations is selected by default for the confirmed interview-preparation audience. Warm-ups remain accessible from the track chips on Learn and Roadmaps. The 30/75/300 paths remain planned; the app does not claim their catalogs are complete.

**Count the signal ranges** introduces prefix totals and frequency maps. Learners count nonempty, potentially overlapping consecutive ranges with a target sum, including zeros and negative values. The trace checks six ranges in three zeros. A nested-loop baseline is accepted; the explanation discusses query-before-insert ordering and why a positive-only window rule fails.

**Wait for a warmer reading** introduces a monotonic stack of unresolved indices. Answers are distances to the first strictly warmer future reading, with zero for no match. Equal temperatures remain unresolved. The trace and explanation distinguish an aggregate linear bound from a separate nested search for each day.

**Combine the busy periods** introduces sorted interval processing. The contract uses half-open intervals and explicitly keeps touching intervals separate. It includes nesting, duplicates, empty input, and input preservation. Copying, output memory, and sorting workspace are discussed separately.

**Find a value in the shifted shelf** introduces binary search over a rotated, strictly increasing array with distinct values. Learners identify the ordered half and discard only a range that cannot contain the target. Empty and unrotated inputs are valid.

**Multiply everything except this one** introduces prefix and suffix products without division. Zeros, negative values, the one-element case, and empty input are covered with bounds that keep results consistent across the four supported languages.

**Measure the longest consecutive run** introduces sequence starts in a hash set. Duplicate values count once, input order is irrelevant, and the expected linear-time explanation contrasts with sorting.

**Fit the longest block under budget** introduces a variable-size window over nonnegative costs. It explains why shrinking restores validity here and why the same rule fails with negative values.

**Find the first place a value belongs** uses a half-open binary-search range to find the first value at least the target, including duplicates and the end position when all values are smaller.

**Count the connected garden plots** introduces four-direction grid flood fill. The example separates diagonal contact, and the contract requires an unchanged input map.

Each lesson includes five checkpoints, self-checks, three progressive hints, and an explicit explanation reveal. The same C++/Python/JavaScript/TypeScript draft workflow is available. Arbitrary explanations are not semantically graded. The opt-in local development runner checks only the visible examples and never awards a verified solve; default Android builds leave it disabled.

Roadmap counts use distinct self-reviewed lesson IDs within the selected track. Multiple attempts cannot inflate the count. Tiles show Start, Resume, or Self-reviewed, and every lesson is available without a prerequisite lock. Existing unfinished work stays on the resume card. Track choice is currently view state and resets to Intermediate after restarting the app.

The production bootstrap and backup screen use the combined versioned catalog. Existing lesson IDs and snapshot schemas are unchanged. New drafts can reopen and import through the same storage and backup system. Local coach rubrics and visible runner cases now include all twelve lessons; the models remain unapproved and disabled by default. The prior live-model benchmark covered only the original three lessons.

## Content validation

The original three foundation lessons have trusted Dart authoring references: prefix counting and next-warmer results are compared against brute-force baselines on every array of length 0–5 over −1, 0, and 1; interval fixtures cover overlap chains, nesting, duplicates, adjacency, sorted output, empty input, and input preservation. The nine lessons added later include visible fixtures and runner references in all four languages, but those fixtures have not yet been independently reviewed or run through the validation scripts. Existing tests check versioned IDs, checkpoint structure, four-language draft backup recovery, no early solution message, and progress scoped to each track.

This is internal content verification, not independent editorial approval, a four-language solution suite, or a learner-code judge. Those remain release requirements.
