# LoopLoom product and delivery roadmap

Planning baseline: 29 October 2026. Scope, timing, prices, and success targets below are proposals, not achieved results or revenue forecasts.

## Product promise

Learn how to solve unfamiliar coding problems by explaining your thinking to a coach. The coach asks useful questions, identifies misconceptions, and helps you improve an approach before writing code.

The confirmed initial audience is **intermediate developers preparing for coding interviews**. The community Blind 75 collection is now the primary guided path; foundation lessons provide warm-ups and intermediate refreshers. Beginner and advanced paths extend the same learning system later. The confirmed development constraint is **strict zero spend**: no paid AI calls, paid infrastructure, purchased hardware, or automatic upgrade from free quotas. Use existing local resources and fall back to curated guided practice.

The first product is a coding coach. Later modules can teach SQL, system design, CS fundamentals, and other technical material through the same lesson/checkpoint model.

## The learning session

1. Understand: restate the task, inputs, outputs, constraints, and edge cases.
2. Approach: explain an algorithm in plain language or pseudocode. A correct brute-force approach is accepted and discussed; optimization is a separate learning step.
3. Reason: identify the invariant, trace an example, and explain time and space complexity. Support multiple valid strategies, rather than one preferred wording.
4. Code: choose C++, Python, JavaScript, or TypeScript. Keep a separate draft per language.
5. Test and debug: execute visible examples and hidden cases in an isolated judge; use counterexamples to guide revision. Tests provide evidence within the stated contract, not a mathematical proof.
6. Reflect: summarize the pattern, the mistake to remember, and when the method applies.
7. Review: schedule a fresh attempt after a proposed 1, 3, 7, and 14 days; a learner's optional recall rating can shorten or extend the next interval. Validate these intervals with learners.

Incorrect or incomplete explanations stay at the current checkpoint with one focused question. Feedback distinguishes incorrect, incomplete, valid-but-slower, and unclear. The learner can ask for another example, a more direct hint, a different explanation, or explicitly reveal a solution. An uncertain model asks a clarifying question; it does not confidently reject a valid answer.

Progress states: not started, in progress, self-reviewed, verified solved with assistance, verified solved independently, and review due. Reading an editorial or a model saying "correct" never marks a problem solved. Mastery requires later independent recall and transfer to another problem.

## Curriculum and roadmaps

Roadmaps reference one shared problem catalog. A solved problem contributes to every roadmap containing it; attempts remain tied to the content version and language.

- Foundation track: optional diagnostic refreshers in syntax, arrays, strings, complexity, maps/sets, two pointers, fixed/variable windows, stacks, binary search, and recursion basics. Experienced learners can skip mastered refreshers.
- Blind 75 (available as a draft path): 75 community-list entries grouped into four phases and sixteen patterns, with a guided five-checkpoint lesson for each entry. Fifteen entries reuse matching Starter 30 lesson IDs and retain progress; sixty use original LoopLoom prompts. The path filters by difficulty and opens the official LeetCode challenge externally. LoopLoom is not affiliated with LeetCode and does not submit code or synchronize results.
- Starter 30: three warm-ups and twenty-seven intermediate foundation lessons remain available as a separate track.
- Mastery 300: the app now contains 300 guided challenge entries across interview patterns, including the existing Blind 75. Each entry links to the official external challenge and has five reasoning checkpoints. Full problem statements remain on linked challenge pages. Ninety extensions have problem-specific original prompts, examples, edge cases, hints, and explanations; 135 still use pattern-level guidance and need editorial customization and review. Pattern-family targets, selection criteria, and progression are specified in [the Mastery 300 curriculum plan](MASTER_300_CURRICULUM.md).
- A local in-app review queue now schedules each self-reviewed lesson after 1, 3, 7, then 14 days, based on completed attempts. The queue appears on Learn and History and starts a fresh guided attempt. It does not send notifications or claim mastery.
- Learners can save problems from curriculum rows or the practice screen, filter the 75/300 paths to saved problems, and open saved problems from History. Saved IDs persist locally and merge when a workbook backup is restored.
- An eight-scenario local interview diagnostic gives short pattern explanations and recommends matching lessons. Its result is a practice aid, not a readiness score; broader placement needs learner validation.
- Beginner, intermediate, and advanced are learner support modes as well as difficulty filters. Beginners get smaller checkpoints and worked traces; advanced learners get fewer prompts and more proof/optimization questions.
- Editorial review, provenance review, and tested code remain required before calling the 75-entry path a reviewed curriculum. Reference-case specifications and four-language code reveal cover a subset of the path, including the 25-problem one-week plan and six additional Blind 75 lessons; other entries still rely on LeetCode's external judge. Do not treat reference-case matches or self-review as a verified solve.

Start with original problem statements and examples. Familiar algorithmic ideas can be taught with original scenarios. Maintain authorship, license, provenance, reviewers, and version metadata. [LeetCode's terms](https://leetcode.com/terms/) are relevant before incorporating its content; a public URL is not a redistribution license.

## Milestone 0 — define and prove the loop

Estimated 1–2 weeks for one experienced full-time builder with content review help; validate effort after the first slice.

- Write the product, coaching, AI, architecture, UX, and release specifications.
- Build a responsive Flutter pilot with three original problems: map lookup, two pointers, and a fixed sliding window.
- Support all four requested languages in the UI and draft model.
- Use honest guided self-checks while real AI and the judge are unavailable.
- Observe 5–10 intermediate interview candidates completing a session; record where hints are too vague or too revealing. The three simple pilot lessons validate interactions rather than represent the final difficulty mix.

Exit: learners can finish the loop and explain what they learned; source passes analysis/tests, mobile layout works with the keyboard, and no unverified action is presented as a solved problem.

## Milestone 1 — trustworthy coaching MVP

Estimated 4–6 additional weeks, dependent on review capacity and judge infrastructure.

- A 30-problem interview starter set across 6–8 patterns, weighted toward medium difficulty with a few diagnostic warm-ups. Each original reviewed problem has multiple accepted strategies, misconception examples, progressive hints, and four tested reference implementations.
- Auth with optional guest start; durable local drafts; opt-in cloud sync; recovery after network failure.
- Provider-independent coaching API, structured feedback, quotas, cost limits, and curated fallback.
- Isolated execution for C++, Python, JavaScript, and TypeScript. TypeScript is compiled before execution; compiler versions are pinned per runtime image.
- Real attempt history, verified solve state, bookmarks, reflection, and review scheduling.
- Content publishing workflow with draft/review/published states and rollback.

Exit: end-to-end sessions, adversarial AI evaluations, judge isolation checks, data ownership checks, and restore/delete flows meet the quality gates in the architecture and AI documents.

## Milestone 2 — paid Android beta

Estimated 2–4 additional weeks plus testing and store review time.

- Add Google Play subscriptions, server-verified entitlements, purchase restore, grace-period handling, and cancellation state.
- Complete privacy, data deletion, support, store listing, accessibility, crash monitoring, and signed release build.
- Run internal and applicable closed tests. Launch to a limited audience before increasing AI quotas.
- Offer the reviewed interview starter catalog; label incomplete roadmaps as upcoming rather than advertising empty 75/300 catalogs.

Exit: real testers complete sessions reliably; costs per session are measurable; payment lifecycle tests pass; applicable Play production-access requirements are met.

## Milestone 3 — 75-problem product and web beta

Estimated 4–6 additional weeks, strongly dependent on content throughput.

- Expand to 75 reviewed problems; validate and expand diagnostic placement, pattern mastery, and spaced review.
- Ship web layouts with keyboard navigation, URL-based routing, browser history, and a larger editor workspace.
- Add a small public HTML marketing/content site if search discovery matters. Flutter is suitable for the interactive learning application; document-heavy public articles can use a separate web rendering approach. [Flutter web guidance](https://docs.flutter.dev/platform-integration/web).
- Run acquisition and pricing experiments with university clubs and interview-preparation communities.

## Milestone 4 — deepen to 300 and expand

Only commit a date after measuring problem authoring/review throughput and learner retention.

- Independently review and test the current 75-problem path before expanding toward 300 reviewed problems and more advanced patterns.
- Add personalized weekly plans, mock interviews, team/cohort dashboards, and institution licensing when demand is demonstrated.
- Explore optional on-device AI on supported devices and the next subject module.
- Split backend services only when operational evidence requires it.

## Measures and launch decisions

Primary learning measure: independently verified solves on a later fresh attempt, normalized by problem difficulty. Track self-reported learning alongside this measure, not as its replacement.

Instrument: onboarding completed, session started, approach submitted, misconception identified, hint requested by level, solution revealed, code submitted, judge finished, reflection completed, review attempted, subscription activated/renewed/cancelled.

Proposed beta targets to validate: 60% of recruited learners finish a first session; 25% return in week one; at least 80% of reviewed coaching replies are rated useful by an expert; fewer than 2% of benchmark replies incorrectly reject a valid strategy. These are internal decision thresholds, not industry benchmarks. Report sample size and uncertainty; expand the benchmark before public claims.

Revenue is a result to validate. Do not scale paid acquisition until retention, coaching quality, subscription conversion, and contribution margin justify it.
