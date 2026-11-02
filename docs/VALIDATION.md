# Pilot validation

## Interview catalog expansion — batch 8 — 30 October 2026

Added three backtracking lessons: one-use subset feasibility, order-independent combinations with reuse, and counting signed target assignments. The draft catalog now has thirty original lessons: three warm-ups and twenty-seven intermediate. The new contracts specify reuse, ordering, duplicate positions, zero behavior, and input preservation; all have four-language fixtures and local-coach rubrics.

Tests and live-container checks were not run for this batch. The complete 30-problem draft catalog still needs independent editorial review and tested solutions; the 75/300 roadmaps remain incomplete and AI feedback remains disabled by default.

## Interview catalog expansion — batch 7 — 30 October 2026

Added three linked-list lessons: finding the middle, cycle detection, and locating the nth node from the end. The catalog now has twenty-seven lessons: three warm-ups and twenty-four intermediate foundations. The node-table format uses rows `[value, nextIndex]` with row 0 as head; the existing matrix/scalar starters and runner cover C++, Python, JavaScript, and TypeScript. Coach rubrics and immutable-input reporting were updated.

Tests and live-container checks were not run for this batch. The new references and fixtures need independent editorial review; the 30/75/300 roadmaps remain incomplete and AI feedback remains disabled by default.

## Interview catalog expansion — batch 6 — 30 October 2026

Added three original tree lessons: maximum depth, widest level by real-node count, and root-to-leaf path sum. The catalog now has twenty-four lessons: three warm-ups and twenty-one intermediate foundations. The indexed node-row representation uses the shared matrix starter and C++ harness; all three problems have four-language runner fixtures, immutable-input reporting, and local-coach rubrics.

Tests and live-container checks were not run for this batch. Tree references and fixtures need independent editorial review; the 30/75/300 roadmaps remain incomplete and AI feedback remains disabled by default.

## Interview catalog expansion — batch 5 — 30 October 2026

Added three original intermediate heap lessons: kth-largest ranking, top-frequency selection with a defined tie rule, and merging sorted streams. The catalog now has twenty-one lessons: three warm-ups and eighteen intermediate foundations. Typed array/matrix starters, visible cases, local-runner fixtures in four languages, input-preservation reporting, and local-coach rubrics cover the new lessons.

Tests and live-container checks were not run for this batch. The new references and fixtures need independent editorial review; the 30/75/300 roadmaps remain incomplete and AI feedback remains disabled by default.

## Interview catalog expansion — batch 4 — 30 October 2026

Added three original intermediate string lessons: first unique character, anagram matching, and longest substring without repeats. The catalog now has eighteen lessons: three warm-ups and fifteen intermediate foundations. Typed string starters support C++, Python, JavaScript, and TypeScript; the anagram lesson also returns a boolean. Visible cases, local-runner fixtures, and local-coach rubrics cover all three.

Tests and live-container checks were not run for this batch. New string references and fixtures still need independent editorial review; the 30/75/300 roadmaps remain incomplete and AI feedback remains disabled by default.

## Interview catalog expansion — batch 3 — 30 October 2026

Added three original intermediate lessons for maximum-subarray dynamic programming, one-trade greedy scanning, and graph components. The catalog now has fifteen lessons: three warm-ups and twelve intermediate foundations. Graph adjacency lists use the shared nested-input starter and local C++ harness; local-coach rubrics and reference fixtures were extended for all three.

Tests and live-container checks were not run for this batch. The new content still needs independent editorial review; the 30/75/300 roadmaps remain incomplete and AI feedback remains disabled by default.

## Interview catalog expansion — batch 2 — 30 October 2026

Added three original intermediate lessons for variable-size windows, lower-bound search, and four-direction grid traversal. The catalog now has twelve lessons: three warm-ups and nine intermediate foundations. The grid problem adds typed matrix input to the C++/Python/TypeScript starter generation and C++ reference harness. The local runner is configured to flag input mutation for the new problem contracts.

This content batch includes four-language reference fixtures and local-coach rubrics, but tests and live-container checks were not run. These additions still need independent editorial review. The 30/75/300 roadmaps remain incomplete and AI feedback remains disabled by default.

## Interview catalog expansion — batch 1 — 30 October 2026

Added three original intermediate lessons for rotated binary search, products except self, and longest consecutive runs. The catalog now has nine lessons: three warm-ups and six intermediate foundations. Each new lesson has five guided checkpoints, three hints, an explicit explanation, four language starters, visible reference cases, local runner fixtures, and an optional local-coach rubric. Existing lesson IDs and stored session schemas were left intact.

The three new lessons' reference implementations and fixtures have not yet been run through the test or live-container validation scripts. Their content remains pending independent editorial review. The 30/75/300 roadmaps are still incomplete, and the AI models remain disabled by default.

## C++17 reference execution follow-up — 30 October 2026

C++ now uses the Docker Official GCC 13.5 image pinned by digest. The compiler builds one harness for the selected problem, then evaluates all three authored examples together; each learner request remains in its own local disposable container. A compiler error is distinct from an execution error. C++ extends the same local reference-run flow and never marks a lesson solved.

Flutter analysis passed with no issues; all 45 Flutter tests passed; 19 runner unit/HTTP tests passed; and all 16 live C++ checks passed. The live checks cover all six authored reference solutions, compile/runtime/time/output/memory failures, UID/filesystem/network controls, debug output, boolean rejection, mutation reporting, and cleanup. These examples are regression checks, not a security certification or hidden correctness suite. See `CPP_RUNNER_VALIDATION.json`.

The web preview and default Android debug APK built successfully; the APK's v2 signature verified. Builds used the existing development NDK override, and the APK remains debug-signed. No physical-device installation or store release was performed. The C++ execution surface was exercised in the separate localhost web workbook. The compiler image uses roughly 2 GB of local Docker storage. It was pulled explicitly during development; request handling never pulls images. The compiler requires a 64 MB executable temporary filesystem, 512 MB memory and a 12-second total limit while compiling and running. The temporary executable remains inside the container.

The development-only web preview is the supported execution surface. The default Android APK keeps its runner URL empty, so it still provides guided practice, drafts, roadmap and history without executing code. A public judge, hidden cases, hardened hostile-code isolation and authoritative verdicts remain launch work.

## TypeScript reference execution follow-up — 30 October 2026

TypeScript now runs the visible examples in the existing pinned Node 24.22.2 container. Node's strip-mode parser removes erasable syntax without semantic type checking. The editor explicitly explains this limit; enums and parameter properties produce a separate unsupported-syntax result. No npm package, image download, paid service or host execution fallback was added. The parser requires WebAssembly, so this runtime uses normal Node execution with a 64 MB old-space limit, retaining the same Docker restrictions as the other languages. Full TypeScript type checks remain open.

Clean Flutter analysis and all 43 Flutter tests passed. Fifteen runner unit/HTTP tests passed. Live checks passed 19/19 for TypeScript, 14/14 for JavaScript and 16/16 for Python (49 total). The TypeScript report covers all six authored implementations, syntax/unsupported/runtime/time/output/memory cases, actual UID/filesystem/network controls, debug output, deliberately absent semantic checking, boolean rejection, mutation reporting and cleanup. These fixtures are regression evidence, not a production security certification or hidden correctness suite. See `TYPESCRIPT_RUNNER_VALIDATION.json`.

The web preview built with its explicit local runner URL. The default Android debug APK built with the documented NDK development override and its v2 signature verified; no physical-device run or release signing was performed. Restarting only the owned idle service exposed JavaScript, TypeScript and Python in health. The existing warm-paper/charcoal palette is unchanged.

Browser verification used only the separate localhost development workbook for submissions. An authored typed range-count function with console logging returned 3/3 matches, with the attempt still at Code and no reflection completion or verified solve. The temporary test tab was closed. Reloading the main 127.0.0.1 workbook retained the supply-pair Approach checkpoint and 0 self-reviewed problems.

## Python reference execution follow-up — 30 October 2026

Python now uses the same restricted-container reference runner as JavaScript. The official Python 3.14 slim Bookworm image was explicitly downloaded and pinned by digest. Requests never download images or fall back to a host interpreter. Health reports installed usable runtimes independently; a missing Python image leaves JavaScript available. The client sends the selected language, rejects mismatched replies, and discards a result when the language changes mid-run. Duplicate in-flight button actions are guarded.

Validation: clean Flutter analysis, 41 Flutter tests, 13 runner unit/HTTP tests, 16 live Python checks, and 14 live JavaScript checks passed. The Python checks cover all six lessons, syntax/runtime/time/output/memory failures, actual non-root/read-only/no-network behavior, debug-print separation, boolean-versus-integer answers, input mutation reporting, and cleanup. Both workers redirect ordinary debug prints to bounded stderr and keep the result protocol separate. Reports: `PYTHON_RUNNER_VALIDATION.json` and `REFERENCE_RUNNER_VALIDATION.json`.

The web preview and debug APK built successfully using the existing development toolchain/NDK override. Execution is enabled only in the explicit local preview, with JavaScript and Python ready at the service's health endpoint. The default APK remains guided unless configured for the emulator; no physical-device execution test or production release was performed.

Browser verification resumed the separate localhost development workbook's Code checkpoint, selected Python, and ran an authored range-count implementation with a debug print. The UI reported 3/3 matches and remained at Code without completing reflection or granting a verified solve. The test tab was closed. Reloading the main 127.0.0.1 preview recovered the existing supply-pair Approach checkpoint unchanged. No changes to the focus palette, subscriptions, paid AI, public hosting, or Git remotes were made.

## Local reference execution follow-up — 30 October 2026

Added opt-in JavaScript execution for the visible reference cases in all six lessons. Each case runs in a fresh restricted local Docker container with no host bind mount or network, non-root UID, read-only runtime, limits, bounded output, and per-case cleanup. Source is never executed on the host. The default APK leaves execution disabled; the loopback web preview explicitly enables it. This is a development experiment, not hardened production judging. [Setup, boundary, and limitations](REFERENCE_RUNNER.md).

Validation: 39 Flutter tests passed, including strict runner response validation, rejection of fake verified-solve responses, source/language staleness handling, cursor-versus-edit invalidation, visible/server case consistency, and restored-question display. Nine runner unit/HTTP tests passed. Thirteen live Docker checks passed: all six trusted implementations, separate syntax/runtime/time/output/memory failures, actual non-root/read-only/no-network probes, and cleanup. The live report is saved in `REFERENCE_RUNNER_VALIDATION.json`. These are authored regression probes, not a sandbox security review or hidden correctness suite.

Browser testing used the separate localhost development workbook's existing Code checkpoint. Switching to JavaScript and submitting a trusted prefix-count implementation through the UI returned 3/3 matched reference cases while remaining at Code, without self-review completion or a verified solve. The main 127.0.0.1 workbook was not used for test submissions. Historical question messages are retained in notes while current guidance is displayed at the active checkpoint. Static analysis and web/debug APK builds passed during the phase; final builds include that display correction.

Results are transient and cleared by source edits or reload. No authoritative result persistence, additional runtime support, account access control, public deployment, or production isolation claim was added. Docker/Desktop configuration and unrelated containers were left unchanged; the already installed pinned Node image was reused without purchases or image pulls.

## Code workspace follow-up — 30 October 2026

Added 24 lesson/language starter templates, cursor-based four-space insertion, line/character counts, and 18 authored reference cases behind a collapsed disclosure. Both new untouched templates and legacy default comments are rejected as code checkpoint submissions. Previously saved drafts remain unchanged. Cases explicitly say “not run”; no execution verdict or verified solve was added. [Workspace details](CODE_WORKSPACE.md).

Flutter analysis passed with no issues; 34 Flutter tests passed. All 24 trusted authored scaffolds passed syntax checks using Python AST, Node, TypeScript, and the installed Android NDK C++ compiler. Web and Android debug APK builds succeeded with the documented development NDK override. These checks do not establish correctness of learner code or replace a language judge.

Browser check used an empty separate workbook at `http://localhost:8123/`, leaving the main `127.0.0.1` workbook untouched. A development attempt supplied valid reasoning through Understand/Approach/Trace, reached Code, and displayed the Python signature, indentation control, counters, and expanded reference cases. No code was executed, solution revealed, or attempt completed. The temporary browser tab was closed; test progress remains confined to that separate localhost origin. Reloading the main preview confirmed its existing supply-pair Approach checkpoint still resumes normally.

## Intermediate catalog follow-up — 30 October 2026

The available catalog now contains six original lessons: three warm-ups and three intermediate foundations. Learn and Roadmaps share track selection, independent progress counts, and Start/Resume/Self-reviewed states. Existing IDs and session schemas are unchanged; bootstrap and backup restore use the full catalog. [Content contracts and limits](INTERMEDIATE_LESSONS.md).

Final checks: Flutter analysis passed with no issues; 31 Flutter tests passed; 10 local-gateway protocol tests passed; web and debug APK builds succeeded. The APK continues to use the documented NDK 26.1 development override and is debug-signed, not store-ready. Trusted authoring references validate new examples, including exhaustive small signed-array checks for prefix counting and next-warmer results. This does not establish correctness of learner submissions or constitute a four-language solution suite.

The browser reloaded the expanded catalog while retaining the existing supply-pair Approach checkpoint and its assistance history. Intermediate is selected by default; Roadmaps shows the three new lessons and 0 of 3 self-reviewed, with larger catalogs clearly marked planned. The paper/charcoal palette remains unchanged. No new attempt, hint, reveal, or solve was created during this browser check.

The experimental local gateway recognizes all six lesson IDs. No additional model-quality evaluation was run; prior failed model results remain a reason to keep AI disabled by default. Independent content review, real-device testing, isolated code execution, and production release work remain open.

Checked on 29 October 2026 with the existing Flutter 3.44.0 and Dart 3.12.0 SDK. These results apply to the interaction prototype, not production readiness.

- `flutter analyze --no-pub`: passed with no issues.
- `flutter test --no-pub`: 18 tests passed. Covers checkpoint/solve separation, hints/reveals, language drafts, responsive navigation, Focus view, actual file-database reopen recovery, failed-save retry, edits during a pending write, stale-write rejection, unsupported-record retention, structured local feedback, stale AI replies, and unavailable-coach fallback.
- `python -m unittest discover -s services/local_coach -p 'test_*.py' -v`: 10 tests passed after the local AI experiment. Uses fake model transport and actual loopback HTTP to verify request/schema validation, origin/host restrictions, input/output limits, rejection of cloud/remote model tags, installed-model health, and withholding editorial algorithm context at the first checkpoint. One preceding run encountered Windows connection-aborted error 10053 on the malformed-content test; the complete rerun passed. These tests do not establish LLM reasoning quality.
- `flutter build web --no-pub`: succeeded, including the toolchain's Wasm compatibility dry run. No separate Wasm deployment was tested.
- Browser checks: verified layout at desktop and phone widths. For this milestone, typed an unsent explanation, waited for Saved locally, requested feedback from the unconfigured gateway, reloaded the browser, and resumed the same attempt. The draft, Focus view, notes, and checkpoint recovered. The unavailable-model response preserved guided practice. Full screen-reader, large-text, keyboard, and real-device testing remain release work.
- `flutter build apk --debug --no-pub`: succeeded with local persistence and the installed NDK 26.1.10909125 development override. The official Android path plugin is pinned to pre-JNI version 2.2.23. Build output warns that the plugin's default NDK configuration expects 28.2; the debug APK built, while the standard release toolchain still needs verification. Output: `apps/solveit/build/app/outputs/flutter-apk/app-debug.apk`. This is debug-signed, not a production App Bundle. No real-device installation or runtime test was performed.

The final visual direction is monochrome warm paper, graphite, and stone gray, following the user's request to avoid green and purple. Calculated body contrast on paper is 13.59:1 and secondary-text contrast is 5.35:1. These palette calculations are not a complete accessibility audit. The practice interface shows the current question and keeps earlier conversation inside Session notes; Focus view folds the problem panel into a disclosure.

Local preview: `http://127.0.0.1:8123/` while the development server is running. The server exposes only the compiled web directory on loopback. It is not a public deployment.

## Local AI and preview follow-up

Portable runtime archive checksum verification, explicit model downloads, three complete real-model smoke runs, and helper startup/shutdown were exercised. The helper refuses an implicit/unapproved model selection. All PowerShell setup/start/stop files parsed successfully; repeat setup skips the existing portable installation. Shutdown checks process ownership and repeated shutdown is harmless. The runtime was stopped after evaluation to free memory; downloaded artifacts remain in ignored `.local/` for later experiments.

Explicit experimental startup with `qwen3:1.7b` returned local-only installed-model health, the expected digest, and prompt v3. The owned gateway and runtime then stopped successfully. This checked the service lifecycle without approving the model or adding feedback to a learner attempt.

The web build was repeated without a coach URL and succeeded. Browser testing initially exposed a stale JavaScript bundle after reload. `scripts/serve-preview.py` now serves content-versioned asset URLs with `Cache-Control: no-store`. Reloading at the original origin showed **Guided self-check**, removed the local-coach button, and restored the exact unsent explanation, Focus view, notes, and Understand checkpoint. No new feedback or solve was recorded. This did not require changing the Flutter app source or its saved-data format.

`python -m unittest discover -s scripts -p 'test_*.py' -v`: 3 tests passed for rebuild-driven asset versions, query/HEAD cache behavior, and rejection of paths outside the compiled directory. The earlier Flutter analysis and 18-test results above remain the last app-source checks; Flutter source was unchanged during this follow-up.

## Known pilot limits

An optional local-coach client and loopback-only Ollama gateway are implemented. Portable Ollama and two models were subsequently installed and evaluated on 16 original development cases. Both v2 runs passed 6/16; the shorter v3 prompt passed 2/16. Neither model is approved for learner feedback. See [model results](LOCAL_AI_VALIDATION.md) for full replies, settings, latency, resource use, and limitations. The web preview has been rebuilt in default guided mode; the APK remains guided-only unless built with a coach URL. Self-checks require learner acknowledgement; no model response establishes a verified solve. Code is not executed. Original pilot content awaits independent editorial review; runtime-tested solutions for all four languages are planned.

Progress, unsent reasoning, code drafts, notes, and assistance persist locally and can now be copied/restored as JSON backups. Writes show Saving/Saved locally/Not saved; an abrupt termination before a write commits can still lose pending edits. Clearing browser data or uninstalling removes local data unless a separate backup was kept. Account auth, cloud backup/sync, native backup file pickers/downloads, test-verified progress, payments, production store assets/adaptive launcher variants, secure release signing, and Play Store submission remain unimplemented. See [local development](LOCAL_DEVELOPMENT.md) for setup, storage behavior, and the zero-spend policy.

## Workbook backup follow-up — 30 October 2026

Added a header entry for copy/paste JSON backup and restore. The export includes current unsent edits and retained records with valid IDs. A selectable text fallback is provided for clipboard restrictions. Import validates the envelope and sessions, previews additions, preserves local versions of duplicate IDs, retains unknown lesson versions, and commits new records in one transaction. Export never reloads repository version state, preserving stale-window write protection.

Flutter tests: 26 passed, including fresh-workbook recovery, pending drafts and language preservation, duplicate import behavior, malformed/oversized/deep input rejection, failed-save safety, unknown-record round trips, stale-window protection, transaction rollback on an import collision, and phone UI review/restore. Analyze and web/debug Android builds were rerun for this milestone. Android continues to use the documented development NDK override; physical-device testing and production signing remain open.

Backups use plain text, not encrypted files or account sync. Import is limited to 2 MB and 500 attempts. Existing IDs always preserve the local version; no automatic merge or overwrite is offered.

Browser verification: the current Approach checkpoint recovered after the new build. The visible export contained the saved attempt, answers, three hints, notes, and assistance flags. Re-importing that visible backup completed with “0 attempts restored. 1 existing attempts kept. Saved locally.” Browser automation's virtual clipboard could not independently read Flutter's clipboard write; the selectable export text was used to verify the round trip instead. Clean analysis, 26 tests, web build, and debug APK build all passed for the final source.

## Learning preferences and starter roadmap follow-up — 30 October 2026

Corrected the stale intermediate catalog count and added a selectable Interview Starter 30 path that combines three warm-ups and twenty-seven intermediate lessons. Roadmaps now show the 30 available lessons with self-review progress and keep the incomplete 75/300 paths explicitly planned. The five stages are named on the home screen. Added locally persisted Beginner, Intermediate, and Advanced coaching paces with stage-specific scaffolds/challenges, plus a preferred default language; new attempts inherit those settings while existing attempts retain their saved pace and language. The small-phone workbook options menu holds settings and backup without crowding the header.

Flutter analysis passed with no issues; all 50 Flutter tests passed. The tests include full lesson question/check content, 30-path inclusion, per-track progress, phone settings interaction, pace/language persistence after reopen, settings-save retry recovery, and the five-stage session and backup flows. Local service tests passed: 10 coach tests, 19 runner tests, and 3 preview-server tests. These test fixtures require loopback sockets and writable temp directories; they were run in the local test context after the restricted sandbox denied those operations.

`flutter build web --no-pub` succeeded, and the open local preview reloaded with all 30 lessons. Browser verification showed the existing “The supply pair” Approach attempt and its resume action unchanged; it did not create or complete an attempt. The starter roadmap displayed 0 of 30 self-reviewed. Preferences were inspected and left at their existing Intermediate/Python values. The web route remained local to `127.0.0.1:8123`.

`flutter build apk --debug --no-pub` succeeded with the existing development NDK override `26.1.10909125`; Gradle still warns that the Android path plugin requests NDK 28.2.13676358. A split-ABI build also succeeded for `app-arm64-v8a-debug.apk`, `app-armeabi-v7a-debug.apk`, and `app-x86_64-debug.apk`, alongside the universal `app-debug.apk`. The x86_64 APK installed on the connected Android 15 emulator; the SolveIt activity was foregrounded and the app process remained alive with no fatal exception in the checked log. This was a startup smoke check, not full manual interaction testing on a physical device. All APKs are debug-signed local installers. No Play Store signing, account/sync, subscriptions, production AI, or public judge was added. The built-in Android app remains guided/self-reviewed and does not execute submitted code.

## Blind 75, profile, and readability follow-up — 30 October 2026

Added a 75-entry Blind 75 roadmap organized into four study phases and sixteen patterns. Fifteen entries reuse existing Starter 30 lessons so prior attempt IDs and progress remain stable; the other sixty have SolveIt-authored prompts, staged reasoning checks, graduated hints, optional explanations, and language starters. Challenge links open the corresponding LeetCode pages. SolveIt is not affiliated with LeetCode. Reference cases and local execution remain limited to the lessons already covered by the prototype runner; Blind 75 does not imply a verified online judge or automatic LeetCode submission.

Added a locally stored learner profile (name, target role, interview date), weekly practice days, daily time goal, preferred language, coaching pace, and a whole-app reading-size preference. Standard, Comfortable (1.15×), and Large (1.3×) sizes multiply the device's own text scaling. A widget regression check covers home and guided practice at 1.3× on a narrow 360-pixel layout. The warm paper, charcoal, and stone palette remains; no purple or green accent palette was introduced.

Flutter analysis passed without issues; all 56 Flutter tests passed. `flutter build web --release` succeeded. `flutter build apk --debug` succeeded using the installed NDK 26.1.10909125. Gradle still reports that Android plugins request NDK 28.2.13676358; the installed 28.2 copy is malformed, so the local build uses the valid 26.1 development override. The generated APK is debug-signed and is not a Play Store release artifact. This change did not add account/cloud sync, paid services, production AI, subscriptions, or Play Store signing.

## In-app Mastery 300 plan follow-up — 2 November 2026

Added the Interview Mastery 300 path and populated 225 curated extensions alongside the existing Blind 75. The app exposes 300 searchable guided entries across the interview path; all entries link to official LeetCode challenge pages, while the extension prompts and hints are original pattern-guided scaffolds rather than copied problem statements. Full statements/examples remain on linked challenge pages. Local reference cases remain limited to lessons already supported by the prototype runner. Catalog checks cover ordered numbering, unique IDs/slugs, five checkpoints, three hints, and 18+ pattern labels. Flutter analysis passed, all 59 Flutter tests passed, and `flutter build web --release` succeeded.

Added filters for the 300 path’s Core 75, Core 150, Breadth 250, and Mastery 300 cumulative milestones. Each selection scopes the problem count and self-reviewed progress; the 300-entry path remains searchable by title, pattern, and difficulty. Flutter analysis passed, all 59 tests passed, and the release web build succeeded after this UI update.
