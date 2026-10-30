# Code workspace

The Code checkpoint now supplies a lesson-specific `solve` signature in C++, Python, JavaScript, and TypeScript. Each of the nine lessons has input names and a return type where the language supports it. The templates throw a TODO exception; they do not contain an algorithm or a working solution. Return the result directly rather than reading console input or printing output.

The editor keeps separate drafts for each language, disables smart punctuation, and displays line/character counts. **Insert 4 spaces** replaces the current selection or inserts at the cursor and saves through the same draft path as typing. It leaves Tab available for keyboard focus navigation. Existing saved drafts, including older comment-only starters, are preserved.

An untouched new starter or legacy default comment cannot acknowledge the Code checkpoint. Edited code can be saved for an explicit self-review; this is not evidence that the code compiles or is correct. Changing the language or editing invalidates the current code acknowledgement. No automatic solution insertion or draft reset was added.

**Reference cases · expected results** contains three authored examples per lesson. The disclosure starts closed. Cases show inputs and expected results, including negative scores, duplicate values, empty input, equal temperatures, nested intervals, and touching endpoints. Pair tasks explicitly allow either index order and any valid pair where applicable. These are examples for reasoning, not an exhaustive test suite or execution results. Actual opt-in execution results appear in a separate panel.

## Validation

The Flutter suite checks all nine lessons across four languages to ensure untouched templates cannot acknowledge the code checkpoint, verifies preservation of legacy drafts, and tests selection-based indentation and folded reference cases at phone width. Existing recovery, per-language drafts, backup, and progress tests remain applicable.

From `apps/solveit`, `dart run tool/write_starters.dart` exports only trusted authored templates into ignored `.local/starter-validation` for developer syntax checks. It does not read learner drafts. Python AST parsing, Node `--check`, TypeScript `--noEmit --strict --target es2020`, and Android NDK clang++ `--target=aarch64-linux-android24 -std=c++17 -fsyntax-only` are used for their respective templates. The [syntax report](STARTER_SYNTAX_VALIDATION.json) records results. Syntax checks do not execute the TODO bodies or establish algorithm correctness.

An opt-in local C++/JavaScript/Python/TypeScript runner adds **Run reference cases** in development builds. C++ compiles as C++17; TypeScript removes erasable type syntax without checking types. Default builds keep execution disabled. Results show only observed behavior against the three visible cases and never create a verified solve. Semantic TypeScript checks, a hardened production judge, and authoritative verdicts remain future work. [Setup and limits](REFERENCE_RUNNER.md).
