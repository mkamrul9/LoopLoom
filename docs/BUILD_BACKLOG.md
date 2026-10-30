# Build backlog

## Current slice: guided practice pilot

- Responsive Flutter shell with Learn, Roadmaps, and History.
- Eighteen original lessons across warm-up and intermediate tracks, with a gradual hint ladder.
- Self-check learning stages, explicit solution reveal, and assistance tracking.
- C++, Python, JavaScript, and TypeScript drafts.
- Clear distinction between self-reviewed and verified solved.
- Domain/widget tests and small-screen layout checks where tooling permits.

## Next slice: real coaching

Implemented after the interaction prototype: versioned local persistence, unsent draft recovery, resume card, save status/retry, stale-tab write protection, and an optional local-only AI client/gateway. Portable Ollama, repeatable start/stop scripts, and two local models are installed. Three 16-case smoke runs exposed poor coaching quality; no model is enabled by default. See [results](LOCAL_AI_VALIDATION.md) and [local development](LOCAL_DEVELOPMENT.md).

1. The working pilot has eighteen original lessons and a per-track roadmap. Grow this into a reviewed 30-problem interview starter path, add an interview diagnostic, and finalize identity/package name and target devices within strict zero-spend development.
2. Copy/paste JSON backup and restore are implemented with validation, preview, duplicate preservation, and atomic imports. Validate recovery on physical Android devices; add native file pickers/downloads and broader accessibility coverage.
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
