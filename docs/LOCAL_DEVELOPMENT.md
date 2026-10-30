# Saved workbook and local coach

The app saves progress locally and has an optional experimental Ollama connection. No paid provider, cloud fallback, API key, or automatic model download on an app request is included. Explicit setup commands download a portable runtime and selected weights into `.local/`.

## Saved progress

Android uses an app support file database. Web uses IndexedDB, scoped to browser origin: keep `http://127.0.0.1:8123/` to reopen the same workbook. Another host or port has separate data. [Sembast](https://pub.dev/packages/sembast) and its [web adapter](https://pub.dev/packages/sembast_web) sit behind a replaceable repository.

Saved data includes attempts, checkpoints, unsent reasoning, four-language code drafts, hints, reveals, notes, AI assistance counts, and Focus view. Edits save after a 250 ms pause; submissions and lifecycle changes request an immediate flush. Wait for **Saved locally** before closing. Abrupt termination while **Saving** can lose a pending edit. Clearing browser storage or uninstalling the app removes local work; cloud backup is not implemented. The local database is not application-encrypted.

Failed writes retain the latest snapshot for Retry. Transactional versions reject stale updates from another tab, keeping the unsaved draft visible so it can be copied before reloading. Unknown lesson/schema records are retained and reported as unavailable. The home card resumes the latest unfinished attempt. Earlier in-memory prototype work cannot be recovered once its process closes.

## Workbook backup

Open **Workbook backup** in the home header. **Copy workbook backup** captures the current workbook, including unsent edits. Paste the JSON into a text file and save it yourself. The generated text also appears in a selectable field for manual copying when clipboard access is unavailable. This first version uses copy/paste; native file pickers, direct downloads, encryption, and automatic cloud backup are not implemented.

On the destination device, paste the full text into **Backup JSON**, tap **Review backup**, then **Restore missing attempts**. Review validates the whole input without changing progress. Restore adds missing attempt IDs in a database transaction. Existing IDs keep their local version, even if the backup contains a newer draft; this is recovery rather than sync or conflict merging. Repeated imports do not create duplicate attempts.

Import accepts version 1 envelopes up to 2 MB, 500 attempts, and 64 levels of JSON nesting. Larger exports need a future file/streaming workflow and cannot be imported through this pilot UI. Known lesson sessions must pass validation; unknown lesson/schema versions are retained without being opened. Invalid input or a failed transaction does not partially restore attempts. No imported field establishes a test-verified solve. Export does not reset stale-window write protection.

Backup text includes learner explanations, code, notes, and assistance history in plain text. Store it somewhere you trust. Restoring saves locally on the destination; it does not upload content or execute imported code.

## Run guided practice

From `apps/solveit`:

```powershell
flutter pub get
flutter run -d chrome --web-port 8123
```

The default build makes no AI requests. Its monochrome workbook design is unchanged.

For a compiled preview, run `flutter build web` from `apps/solveit`, then `python scripts/serve-preview.py` from the repository root. Open `http://127.0.0.1:8123/`. The helper serves only the compiled web directory, disables HTTP caching, and adds a content version to the JavaScript URLs so a rebuild replaces a stale preview bundle. It preserves the origin and saved IndexedDB workbook. This is a loopback development server, not production hosting.

The Android path plugin is pinned to `path_provider_android` 2.2.23 for compatibility with the installed development toolchain. Version 2.3 moved to JNI ([official changelog](https://pub.dev/packages/path_provider_android/changelog)), which needs the currently incomplete NDK 28.2 installation. Review this pin when validating the standard release toolchain; it is a declared dependency constraint rather than an override of package source.

## Experimental local feedback

Portable Ollama 0.40.13 and the `qwen3:0.6b` / `qwen3:1.7b` models are installed on this computer. **Neither model passed coaching evaluation.** The normal web preview and APK use guided practice. Read the [results and limitations](LOCAL_AI_VALIDATION.md) before experimenting.

From the repository root, these commands reproduce setup without a system installation:

```powershell
./scripts/setup-local-ai.ps1
./scripts/start-local-ai.ps1 -RuntimeOnly

# Explicit download, once per model. The runtime stores it in .local/models.
& './.local/ollama/0.40.13/ollama.exe' pull 'qwen3:1.7b'

# Run the real-model smoke set. Failed cases produce a nonzero exit code.
python services/local_coach/evaluate.py --model 'qwen3:1.7b' --output '.local/evaluation.json'
```

Setup verifies the official archive's SHA-256 before extraction. Startup sets `OLLAMA_NO_CLOUD=1`, binds loopback, allows one loaded model and one request, and uses a 60-second idle unload. It refuses to manage an unrelated runtime already on the port. Weights, binaries, logs, and process records stay in ignored `.local/`; they are not bundled into Android/web builds. There are no PATH, startup, or tray changes. [Ollama local-only configuration](https://docs.ollama.com/faq).

To deliberately test a model through the UI, start an experimental gateway and use a separate development build:

```powershell
./scripts/start-local-ai.ps1 -Model 'qwen3:1.7b' -Experimental
# From apps/solveit:
flutter run -d chrome --web-port 8123 --dart-define=SOLVEIT_COACH_URL=http://127.0.0.1:8765
```

For the Android emulator:

```powershell
flutter run --dart-define=SOLVEIT_COACH_URL=http://10.0.2.2:8765
```

Stop only processes owned by these scripts:

```powershell
./scripts/stop-local-ai.ps1          # stop gateway and unload weights
./scripts/stop-local-ai.ps1 -Runtime # also stop the portable daemon
```

Ownership uses the recorded PID, executable path, and process creation time to avoid stopping a reused PID. Start/stop helpers do not delete downloaded files or app progress. The startup experiment flag is a developer guard; it is not model approval or a production authorization system. The Python gateway can also be run directly by a developer.

The emulator alias does not connect a physical phone to the computer. Guided practice works on a phone; LAN AI access is not configured. Debug Android allows HTTP only to local/emulator hosts. Release networking is not loosened. The client rejects remote coach URLs.

The gateway binds only `127.0.0.1:8765` and calls only `127.0.0.1:11434`. It checks installed-model metadata, rejects cloud/remote tags, never pulls a model, and has no provider fallback. It restricts browser origins, allows one review at a time, bounds input/output, and does not log student text. This is a development service; public authentication, quotas, and production hosting remain future work.

Only **Ask local coach** sends learner text. Replies use [Ollama's structured-output API](https://docs.ollama.com/capabilities/structured-outputs) and are validated on both sides. Feedback remains experimental: it does not advance checkpoints, execute code, or mark a solve. Successful feedback records assistance. Unavailable or malformed replies preserve the draft and guided flow. JSON validation does not establish that feedback is correct; the tested models produced structurally valid but misleading replies.

`GET /health` checks the local runtime and installed-model metadata. It reports configuration, model digest, prompt version, and missing/unavailable status. `ready` means locally installed, not that inference or coaching quality has passed. Running the gateway without a model gives an unavailable response for testing fallback.

## Verification

Run `flutter analyze` and `flutter test` from `apps/solveit`. From the repository root:

```powershell
python -m unittest discover -s services/local_coach -p 'test_*.py' -v
python -m unittest discover -s scripts -p 'test_*.py' -v
```

Gateway tests use a fake model transport and actual loopback HTTP. They verify protocol behavior, not LLM reasoning quality. Flutter tests cover file-database close/reopen recovery, save failure/retry, edits during pending writes, stale-write rejection, unknown-record retention, reply validation, and the separation of self-review from verified solves.
