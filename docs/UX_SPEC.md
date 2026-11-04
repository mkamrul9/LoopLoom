# UX and visual direction

## Calm, focused, encouraging

The user's confirmed direction is a distinctive, focus-oriented workbook. Do not introduce green or purple accents. Use warm paper (#F7F4EF), charcoal text (#262B2D), a near-white writing surface (#FFFDF9), soft stone active surfaces (#ECE7DF), and muted clay (#914B36) only for focus and the four linked `o` loops in the LoopLoom name. Hints use the same quiet gray as secondary text. Keep body text high contrast, surfaces flat, and dividers subtle. Distinction comes from the woven wordmark, typography, numbered sections, whitespace, and thoughtful interaction. No gradients, decorative motion, confetti, invented streaks, or competing colored cards. The logo uses the name itself with “Think · Trace · Code” beneath it; there is no separate abstract icon.

The visual identity combines the one-line LoopLoom wordmark, numbered notebook sections, quiet monospace metadata, and generous reading/writing space. Each pair of `o` letters forms a continuous infinity stroke aligned with the lowercase letters. Use a modestly rounded writing sheet rather than oversized promotional hero blocks. Pattern lessons use open ruled rows. The workspace leads with the current problem and one next coaching question; save earlier conversation in an expandable Session notes section.

Focus view is an explicit toggle. It centers the current step in a narrower reading column and folds the problem into an accessible Problem & examples disclosure. Toggling it must preserve reasoning and code drafts. Overview restores the full context, including the side-by-side layout on wide screens. The current question, active checkpoint, hint state, and draft correctness limitations remain visible. System, Light, and Dark appearances are available and saved in the local workbook; validate focus view and editor contrast in both palettes before release.

## Navigation

Learn: resume unfinished work; otherwise use a diagnostic-flagged pattern or
continue to the next unreviewed lesson in the selected path. After a path is
self-reviewed, offer a fresh recall attempt. Learners can browse patterns and
open the eight-scenario interview diagnostic, which explains choices and routes
to matching guided problems. It is a practice guide, not a readiness score.

Roadmaps: choose a path, inspect prerequisites, switch support level, and see completed/review-due items. Counts reflect published content only.

History: inspect attempts, feedback, code, hints, solution reveals, verified outcomes, and reflections. Filter by problem, pattern, language, and state when history grows.

Profile/settings (available): local display name, target role and interview date, weekly and daily practice targets, default language, coaching pace, four readable-text sizes through 1.5×, save status, and workbook backup. Learners can save or choose a plain JSON backup file on Android and web, or use copy/paste; restore always previews and validates before merging. Profile details are device-local; there is no account or sync. AI mode, subscription, deletion tooling, and support workflows remain future work.

Compact screens use a bottom bar; wide screens use a rail. The coach and problem statement become a split workspace with an editor on large screens. Adapt by available width rather than device brand. Keep routes shareable on web before web beta.

## First session

The first release targets intermediate interview candidates. Lead with the Blind 75 guided path, tradeoffs, invariants, edge cases, and interview follow-ups. Use warm-up and intermediate lessons as refreshers. The current 75-entry path is a draft curriculum: fifteen entries reuse Starter 30 lessons and sixty have original LoopLoom prompts. It still needs independent editorial review and broader tested reference cases before it can be presented as a reviewed interview curriculum.

Allow guest start. Ask preferred language, experience level, and daily time budget without a long form. Offer the optional pattern diagnostic and recommend one small lesson. Introduce the teaching contract: "Explain your idea. I will help you improve it before you code."

Keep the problem/constraints readily available during conversation. Display the current checkpoint and a compact session step indicator. Use one main action per stage. Keep the composer visible above the keyboard and preserve drafts when navigating.

Feedback should name what the learner got right, identify one gap, and ask a concrete next question. Avoid aggressive failure colors for partial understanding. Show checking, timeout, retry, quota, offline, and code-execution states explicitly. Never simulate an AI response as if it were semantic evaluation.

Keep hint requests and solution reveal visually distinct. Explain the effect on assisted progress at the reveal action. Include an opt-in "skip coaching and practice" path later for experienced learners; track its evidence separately.

## Editor

C++, Python, JavaScript, and TypeScript, with a draft per language. Mobile starts with a full-screen editor, indentation helpers, accessible selection, and an optional external-keyboard workflow. Desktop can show statement, coach, and editor in resizable panes. Prototype multiline input is acceptable only while clearly labeled as a prototype.

Examples and visible test results are readable without requiring color interpretation. Separate compiler errors, wrong answers, and infrastructure failures. A loading indicator is never a fake test verdict.

## Accessibility and polish gates

Touch targets at least 48 logical pixels, readable contrast, scalable text without clipped cards, screen-reader labels for icon actions, keyboard navigation and focus visibility on web, reduced motion, and no essential content behind hover. Validate small phones, rotation, large text, keyboard open, and wide windows. Use short purposeful transitions rather than decorative animation.

## Prototype boundaries

Guided self-check mode must be named visibly. Drafts/history and profile settings persist locally with Saving, Saved locally, and Not saved states. The home card resumes an unfinished session and displays the learner's study plan. Explain local-data removal and failed/conflicting writes without claiming cloud backup. Optional local AI feedback is labeled experimental; unavailable inference keeps guided practice usable. Code drafts save locally. Only problems with authored reference cases can run through the optional development runner; Blind 75 links open LeetCode externally and do not submit or sync code. A finished self-check session must not appear as test-verified solved. Upcoming roadmaps show planned coverage honestly.
