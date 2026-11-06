# Can we use free or local AI?

Yes for development and limited operation. There is no reliable promise of unlimited, high-quality public AI at zero cost. Open-weight models still require hardware, electricity, hosting, operations, and license review.

## Confirmed zero-spend development policy

Use existing hardware, the installed Flutter/Android tools, curated content, and optional local model experiments. Do not enable paid providers, attach billing for AI, purchase hardware, or provision paid hosting. Default builds make no inference calls. The app now has an optional Firebase AI Logic integration for the Gemini Developer API free tier; it only activates when project configuration is present and the learner has consented. Keep the project on a no-billing plan and App Check enforced. There is no paid-provider fallback. The portable local runtime and two models are installed in the ignored project cache. Both failed the initial coaching smoke set; neither is approved for learner feedback. See [measured results](LOCAL_AI_VALIDATION.md), [AI setup](AI_SETUP.md), and [local setup](LOCAL_DEVELOPMENT.md). Production funding is a later explicit decision.

## Recommended progression

1. Ship the interaction prototype with curated hints and explicit self-checks. This costs no AI tokens and proves the lesson design, but does not evaluate arbitrary explanations.
2. Add a backend coaching adapter and use a locally hosted model through Ollama during development. Do not expose a developer laptop or raw model endpoint to public users.
3. Benchmark local models and eligible hosted free tiers on the same reviewed problem/rubric set. Choose on measured coaching quality and latency, not a model name or parameter count.
4. Before a public beta, make a separate explicit production funding decision. Within the current zero-spend constraint, keep access limited to capacity that existing resources can support and use curated fallback. A future capped hosted budget or additional self-hosted capacity requires changing that constraint.
5. Explore optional on-device inference after the core product works. Keep it optional until representative affordable Android devices meet memory, latency, battery, and quality targets.

## Options and tradeoffs

Curated offline coach: the practice screen offers task clarification, example tracing, constraint-based edge-case prompts, the current self-check, and the next authored hint. Selected guidance is saved in session notes and counts as assisted practice. It uses the lesson content already on the device, makes no inference call, and cannot assess an open-ended answer or run code; label it "offline coach" or "guided practice," never AI grading.

Local computer/server: Ollama can run models locally, with local-only configuration available. This is suitable for a development experiment; serving many simultaneous users needs capacity planning and an authenticated API boundary. Model licenses are separate from runtime licensing. [Ollama documentation](https://docs.ollama.com/faq).

Hosted free tier: useful for experiments within provider/model/region quotas, with no guarantee that free capacity remains available. Check actual account limits rather than hardcoding advertised limits. Google's pricing page distinguishes free and paid tiers. Its unpaid-service terms describe data use and regional differences; review these before sending learner content. [Pricing](https://ai.google.dev/gemini-api/docs/pricing), [terms](https://ai.google.dev/gemini-api/terms).

On-device Android: technically feasible, but device coverage, model download size, memory pressure, battery, and reasoning quality need real tests. Current Google guidance points Android integrations toward LiteRT-LM. Flutter needs a platform adapter; Android support does not automatically provide a web implementation. [LiteRT-LM Android](https://developers.google.com/edge/litert-lm/android), [MediaPipe migration guidance](https://developers.google.com/edge/mediapipe/solutions/genai/llm_inference/android).

## Coaching contract

Input: problem version, stage, student explanation, concise relevant conversation, accepted-strategy rubric, current hint level, allowed teaching actions. Exclude hidden tests and full editorial unless an explicitly authorized reveal requires them.

Output schema:

```json
{
  "outcome": "needs_clarification",
  "rubric_evidence": [],
  "misconception_ids": [],
  "feedback": "What information would you need to avoid checking every earlier item?",
  "next_question": "Describe what you would store and when you would update it.",
  "suggested_action": "stay",
  "hint_level": 1
}
```

Allowed outcomes: correct, valid_but_slower, incomplete, incorrect, needs_clarification. Evidence cites specific student statements; do not use a model's self-reported confidence as the quality gate. Validate JSON/schema, allowed actions, length, and stage policy before rendering. Invalid output becomes a curated clarification without advancing.

Accept brute force when correct, then ask about constraints and optimization. Accept alternative algorithms supported by the contract. Never gate progress on English phrasing or keywords. The server applies transition rules, and actual code execution supplies correctness evidence. A statement like "hash map, O(n)" or a keyword checklist cannot reliably establish understanding.

## Hint ladder

Level 0: restate constraints or ask a diagnostic question.

Level 1: name the missing observation without naming the full method.

Level 2: guide a trace or ask about a suitable data structure.

Level 3: give a partial pseudocode structure.

Explicit reveal: show the full explanation/code and mark the attempt assisted. Never silently reveal after a fixed number of incorrect messages.

## Evaluation before launch

Build at least 100 reviewed explanation examples across the first patterns, then expand. Include alternative correct algorithms, inefficient but correct approaches, false complexity claims, malformed explanations, negation, ambiguous reasoning, prompt injection, solution requests, and long/mixed conversations. Split training/prompt-tuning examples from a held-out evaluation set.

Measure false rejection of valid reasoning, false approval, solution leakage, clarity, expert usefulness, latency by device/provider, and estimated cost per finished session. Record model/runtime/prompt/content versions. Evaluate 4-language debugging against actual judge results. A second LLM is not a replacement for expert review or execution.

## Cost controls

Per-user daily coach turn limits, per-session context/token limits, request-size caps, timeout and bounded retry, spend alerts, a hard circuit breaker, and graceful guided fallback are required before public traffic. Summarize older session context while preserving algorithm claims and assistance history. Cache reviewed hints rather than private answers.

Budget model: monthly cost = coaching turns × measured average tokens × current provider rates + judge runtime + database/storage/hosting + observability + support. When self-hosting, include reserved hardware cost even during idle time. Free users still consume resources; subscription quotas must follow measured usage. Never embed provider API secrets in Flutter or web builds.
