# Intermediate foundations

Three original lessons extend the pilot to six problems across two available tracks. Intermediate foundations is selected by default for the confirmed interview-preparation audience. Warm-ups remain accessible from the track chips on Learn and Roadmaps. The 30/75/300 paths remain planned; the app does not claim their catalogs are complete.

**Count the signal ranges** introduces prefix totals and frequency maps. Learners count nonempty, potentially overlapping consecutive ranges with a target sum, including zeros and negative values. The trace checks six ranges in three zeros. A nested-loop baseline is accepted; the explanation discusses query-before-insert ordering and why a positive-only window rule fails.

**Wait for a warmer reading** introduces a monotonic stack of unresolved indices. Answers are distances to the first strictly warmer future reading, with zero for no match. Equal temperatures remain unresolved. The trace and explanation distinguish an aggregate linear bound from a separate nested search for each day.

**Combine the busy periods** introduces sorted interval processing. The contract uses half-open intervals and explicitly keeps touching intervals separate. It includes nesting, duplicates, empty input, and input preservation. Copying, output memory, and sorting workspace are discussed separately.

Each lesson includes five checkpoints, self-checks, three progressive hints, and an explicit explanation reveal. The same C++/Python/JavaScript/TypeScript draft workflow is available. These are guided lessons: arbitrary explanations are not semantically graded and learner code is not executed.

Roadmap counts use distinct self-reviewed lesson IDs within the selected track. Multiple attempts cannot inflate the count. Tiles show Start, Resume, or Self-reviewed, and every lesson is available without a prerequisite lock. Existing unfinished work stays on the resume card. Track choice is currently view state and resets to Intermediate after restarting the app.

The production bootstrap and backup screen now use the combined versioned catalog. Existing lesson IDs and snapshot schemas are unchanged. Intermediate drafts can reopen and import through the same storage and backup system. The local development gateway recognizes the new IDs, but its models remain unapproved and disabled by default; the prior live-model benchmark covered only the original three lessons.

## Content validation

Trusted Dart authoring references check the stated examples. Prefix counting and next-warmer results are compared against brute-force baselines on every array of length 0–5 over −1, 0, and 1. Interval fixtures cover overlap chains, nesting, duplicates, adjacency, sorted output, empty input, and input preservation. Additional tests check versioned IDs, checkpoint structure, four-language draft backup recovery, no early solution message, and progress scoped to each track.

This is internal content verification, not independent editorial approval, a four-language solution suite, or a learner-code judge. Those remain release requirements.
