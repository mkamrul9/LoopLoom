# UX and visual direction

## Calm, focused, encouraging

The user's confirmed direction is a distinctive, focus-oriented, essentially monochrome workbook. Do not introduce green or purple accents. Use warm paper (#F6F4F0), graphite text and primary buttons (#272630), a near-white writing surface (#FFFEFC), and soft stone-gray active surfaces (#E7E3DD). Hints use the same quiet gray as secondary text. Keep body text high contrast, surfaces flat, and dividers subtle. Distinction comes from typography, numbered sections, whitespace, and thoughtful interaction rather than saturated color. No gradients, decorative motion, confetti, invented streaks, or competing colored cards.

The visual identity combines a small `s/` mark, numbered notebook sections, quiet monospace metadata, and generous reading/writing space. Use a modestly rounded writing sheet rather than oversized promotional hero blocks. Pattern lessons use open ruled rows. The workspace leads with the current problem and one next coaching question; save earlier conversation in an expandable Session notes section.

Focus view is an explicit toggle. It centers the current step in a narrower reading column and folds the problem into an accessible Problem & examples disclosure. Toggling it must preserve reasoning and code drafts. Overview restores the full context, including the side-by-side layout on wide screens. The current question, active checkpoint, hint state, and draft correctness limitations remain visible. Support a dark theme after validating this flow.

## Navigation

Learn: resume the current session, see the next suggested lesson, and browse patterns.

Roadmaps: choose a path, inspect prerequisites, switch support level, and see completed/review-due items. Counts reflect published content only.

History: inspect attempts, feedback, code, hints, solution reveals, verified outcomes, and reflections. Filter by problem, pattern, language, and state when history grows.

Profile/settings: preferred language, daily goal, theme, accessibility, AI mode and data controls, subscription, export, deletion, and support.

Compact screens use a bottom bar; wide screens use a rail. The coach and problem statement become a split workspace with an editor on large screens. Adapt by available width rather than device brand. Keep routes shareable on web before web beta.

## First session

The first release targets intermediate interview candidates. Lead with Interview 75, tradeoffs, invariants, edge cases, and interview follow-ups. Use a short diagnostic to offer refreshers rather than assuming the learner needs syntax lessons. The current six-lesson pilot spans warm-up and intermediate foundations; the paid MVP needs the reviewed medium-difficulty interview starter set described in the roadmap.

Allow guest start. Ask preferred language, experience level, and daily time budget without a long form. Recommend one small lesson. Introduce the teaching contract: "Explain your idea. I will help you improve it before you code."

Keep the problem/constraints readily available during conversation. Display the current checkpoint and a compact session step indicator. Use one main action per stage. Keep the composer visible above the keyboard and preserve drafts when navigating.

Feedback should name what the learner got right, identify one gap, and ask a concrete next question. Avoid aggressive failure colors for partial understanding. Show checking, timeout, retry, quota, offline, and code-execution states explicitly. Never simulate an AI response as if it were semantic evaluation.

Keep hint requests and solution reveal visually distinct. Explain the effect on assisted progress at the reveal action. Include an opt-in "skip coaching and practice" path later for experienced learners; track its evidence separately.

## Editor

C++, Python, JavaScript, and TypeScript, with a draft per language. Mobile starts with a full-screen editor, indentation helpers, accessible selection, and an optional external-keyboard workflow. Desktop can show statement, coach, and editor in resizable panes. Prototype multiline input is acceptable only while clearly labeled as a prototype.

Examples and visible test results are readable without requiring color interpretation. Separate compiler errors, wrong answers, and infrastructure failures. A loading indicator is never a fake test verdict.

## Accessibility and polish gates

Touch targets at least 48 logical pixels, readable contrast, scalable text without clipped cards, screen-reader labels for icon actions, keyboard navigation and focus visibility on web, reduced motion, and no essential content behind hover. Validate small phones, rotation, large text, keyboard open, and wide windows. Use short purposeful transitions rather than decorative animation.

## Prototype boundaries

Guided self-check mode must be named visibly. Drafts/history persist locally with Saving, Saved locally, and Not saved states. The home card resumes an unfinished session. Explain local-data removal and failed/conflicting writes without claiming cloud backup. Optional local AI feedback is labeled experimental; unavailable inference keeps guided practice usable. The code step saves work but does not execute it. A finished self-check session must not appear as test-verified solved. Upcoming roadmaps show planned coverage honestly.
