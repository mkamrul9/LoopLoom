# Pilot validation

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
