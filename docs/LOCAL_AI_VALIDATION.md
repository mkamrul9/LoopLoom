# Local AI experiment

The runtime works on this computer, but **no tested model is approved for learner feedback**. The preview and default APK stay in guided mode. No paid provider, hosting, billing account, or hardware purchase was used.

## Measured results

Three real-model runs used the same 16 original development cases:

- Qwen3 0.6B, prompt v2: **6/16 passed**, median **6.114 seconds**. [Full replies](model-evaluations/qwen3-0.6b-v2.json).
- Qwen3 1.7B, prompt v2: **6/16 passed**, median **10.762 seconds**. [Full replies](model-evaluations/qwen3-1.7b-v2.json).
- Qwen3 1.7B, shorter checkpoint-specific prompt v3: **2/16 passed**, median **7.909 seconds**. [Full replies](model-evaluations/qwen3-1.7b-v3.json).

These are development smoke results, not held-out accuracy estimates. Expected-outcome and forbidden-phrase checks are coarse; inspect the actual replies. Passing them would still require independent human review. Cases cover the problem contract, valid alternatives/brute force, duplicate indices, incorrect complexity, reversed pointers, all-negative windows, ambiguity, reflection, injection, and code in four languages. Each language appears in the set; this does not establish language coverage or code correctness.

The v2 models wrongly approved clear mistakes, including index reuse, reversed pointer movement, and out-of-bounds C++ access. They also introduced algorithms before the learner was ready. The v3 prompt reduced editorial context and bounded replies more tightly, but mostly produced generic clarification requests and rejected sufficient reasoning. It did not solve the quality problem. A separate 1.7B reasoning-enabled C++ probe timed out at the 120-second network wait; it produced no review to score. [Probe record](model-evaluations/qwen3-1.7b-thinking-probe.json).

## Reproduction and resources

Runtime: portable official **Ollama 0.40.13**, Windows AMD64. The setup script pins the release and archive SHA-256 `7afa38624fa62ee5d8293422d0ab084c1bb4603134c7f4dafce11a033b57cc19`. [Official release](https://github.com/ollama/ollama/releases/tag/v0.40.13), [Windows setup](https://docs.ollama.com/windows).

Models are Q4_K_M artifacts in `.local/models`, separate from the app:

- `qwen3:0.6b`: 522,653,767 bytes on disk. Digest `7df6b6e09427a769808717c0a93cadc4ae99ed4eb8bf5ca557c90846becea435`. Approximately 1.02 GB loaded CPU memory reported by the runtime. [Official model entry](https://ollama.com/library/qwen3:0.6b).
- `qwen3:1.7b`: 1,359,293,444 bytes on disk. Digest `8f68893c685c3ddff2aa3fffce2aa60a30bb2da65ca488b61fff134a4d1730e7`. Approximately 1.89 GB loaded CPU memory reported by the runtime. [Official model entry](https://ollama.com/library/qwen3:1.7b).

The machine has a Ryzen 5 7430U, approximately 13.8 GB usable RAM, and integrated Radeon graphics. Inference used CPU, four threads, one request at a time, a 4,096-token context, temperature zero, and thinking disabled. V2 allowed 320 generated tokens; v3 allows 240. Available RAM was only about 1.5–2.1 GB during the experiment. Larger models were not tried under this pressure; these timings do not predict phone performance. Model weights unload after 60 seconds idle. User applications were left open.

New evaluation reports record inference settings, fixture hash, model digest, runtime/prompt versions, per-case replies/errors, and latency. The earlier v2 reports predate the extra settings/hash fields; their settings are documented above. The evaluator exits nonzero if a case fails and saves each completed result. It does not call cloud services, retry through another provider, or execute learner code. See [setup commands](LOCAL_DEVELOPMENT.md).

## Product decision

Keep the curated coaching loop, saved drafts, and explicit self-checks as the usable pilot. Local inference is an opt-in developer experiment. Starting a gateway through the helper requires both an explicit model and `-Experimental`; there is no default model choice. A model response never advances a checkpoint or establishes a verified solve.

Before learner-facing AI, create at least 100 independently reviewed examples and a held-out split; measure false approvals, false rejections, solution leakage, injection, and teaching usefulness. Revalidate latency and resource use on target devices. Automatic checkpoint approval and test-verified solve state remain separate work. The next useful product slices are backup/export, intermediate lesson content, and isolated code execution with reviewed test cases.
