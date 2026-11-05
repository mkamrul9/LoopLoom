# Build backlog

## Current slice: guided interview practice

- Responsive Flutter shell with Learn, Roadmaps, and History.
- Thirty original lesson drafts across warm-up and intermediate tracks, with a gradual hint ladder.
- Self-check learning stages, explicit solution reveal, and assistance tracking.
- C++, Python, JavaScript, and TypeScript drafts.
- Clear distinction between self-reviewed and verified solved.
- Beginner, intermediate, and advanced coaching paces with stage-specific
  prompts; preferred language and pace persist locally and seed new attempts.
- Learn and Roadmaps expose Starter 30, Blind 75, and Interview Mastery 300,
  while distinguishing pattern-guided drafts from independently reviewed content.
- An eight-scenario, on-device interview diagnostic explains each choice,
  recommends matching guided problems, and saves its latest result locally.
- Learn resumes unfinished work, then follows diagnostic-flagged patterns or
  advances to the next unreviewed lesson in the selected path.
- Learn now puts the next due spaced-recall problem on the primary action card,
  after any unfinished session and before a new lesson recommendation.
- Learn shows a Monday–Sunday weekly practice view against the learner's chosen
  days-per-week goal, based on saved attempt start/completion dates; it does not
  imply that study minutes are measured.
- History can search attempts by problem, pattern, language, or checkpoint stage
  and filter between in-progress and self-reviewed sessions.
- Blind 75 and Mastery 300 Roadmaps show self-reviewed and in-progress counts
  for each pattern and the selected milestone; learners can filter to problems
  not yet self-reviewed while keeping the labels clear that these are not judge
  verified solves.
- Domain/widget tests and small-screen layout checks where tooling permits.

## Next slice: real coaching

Implemented after the interaction prototype: versioned local persistence, unsent draft recovery, resume card, save status/retry, stale-tab write protection, and an optional local-only AI client/gateway. Portable Ollama, repeatable start/stop scripts, and two local models are installed. Three 16-case smoke runs exposed poor coaching quality; no model is enabled by default. See [results](LOCAL_AI_VALIDATION.md) and [local development](LOCAL_DEVELOPMENT.md).

1. Independently review the thirty original lesson drafts and runtime-tested
   solutions to publish the reviewed 30-problem interview starter. The local
   interview diagnostic is implemented; validate it with interview candidates
   and finalize supported target devices.
2. Copy/paste and file-based JSON backup/restore are implemented for Android and web with validation, preview, duplicate preservation, and atomic imports. Validate recovery on physical devices and browsers. Extra large text and screen-reader checkpoint progress are implemented; continue accessibility and small-screen checks.
3. Stand up the application API with a versioned published-content endpoint and ownership checks.
4. Find a model/configuration that clears independent correctness, teaching, injection, and latency review on available hardware. The initial small-model experiments failed. Keep guided practice until a candidate qualifies; hosted adapters are deferred under the zero-spend constraint.
5. Author accepted-strategy rubrics and a held-out benchmark before enabling automatic semantic approval.
6. Enforce coaching state and hint/reveal policy server-side; test ambiguous/alternative explanations.
7. A local-only development C++/JavaScript/Python/TypeScript runner now executes visible reference cases in restricted containers, with limits and per-case statuses. TypeScript strips types without semantic checking. Add full TypeScript type checks, harden and independently review isolation, add hidden execution tests and authoritative result provenance before production verified execution.
8. Require a matching accepted judge result for verified solve state.
9. Add auth/opt-in sync, review scheduling, and basic operations metrics.

## Paid beta dependency chain

Trustworthy loop → 30 reviewed problems → persistence/sync → cost instrumentation/limits → server-verified purchases → privacy/deletion and store materials → applicable closed testing → staged production launch.

## Deliberately deferred

300 problems, public discussion boards, contests, social leaderboards, voice coaching, universal offline LLM support, additional subject libraries, and institution dashboards. Revisit after retention and content-review throughput are understood.
