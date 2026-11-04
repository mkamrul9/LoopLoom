# LoopLoom Flutter app

Android-first and responsive web problem-solving workbook.

The confirmed audience is intermediate interview candidates. The available
Interview Starter has thirty original lesson drafts: three warm-ups and
twenty-seven intermediate pattern lessons. Interview 75 is the main planned path
beyond that starter. Development is strictly zero spend, with no paid AI calls
or automatic paid fallback.

## Available in this build

- Thirty problems with five ordered checkpoints each: Understand, Approach,
  Trace, Code, and Reflect. Lessons include three optional hints and an explicit
  solution reveal that records assistance.
- Beginner, Intermediate, and Advanced coaching paces. Beginner prompts add a
  smaller first step; Advanced prompts add invariant, proof, or tradeoff
  challenges. These are support modes, not separate claims about problem
  difficulty. The preference is saved locally and applies to new attempts.
- Separate C++, Python, JavaScript, and TypeScript drafts. Choose a default
  language and change it inside a lesson without losing per-language drafts.
- Learn, Warm-ups, Intermediate, Interview Starter 30, Roadmaps, and History
  views with local resume, self-review counts, Focus view, and copy/paste
  workbook backup/restore.
- A quiet warm-paper and charcoal interface with a muted-clay loop accent and no green or purple accents.

The 75-problem and 300-problem roadmaps are not complete. The thirty available
lessons are original drafts awaiting independent editorial review. Completing
the guided reflection records a **self-reviewed** attempt; it does not establish
a verified solve. The default Android build does not run submitted code. The
optional loopback web runner is for local development and is not a public judge.
No account, sync, subscription, or paid AI service is enabled.

Uses Flutter 3.44.0 / Dart 3.12.0 in this workspace. The SDK was found at
`D:\SWE\flutter\flutter_windows_3.44.0-stable\flutter`; add its `bin` directory
to your local PATH if `flutter` is not recognized.

```powershell
$flutter = 'D:\SWE\flutter\flutter_windows_3.44.0-stable\flutter\bin\flutter.bat'
& $flutter pub get
& $flutter analyze
& $flutter test
& $flutter run -d chrome
```

For an Android device or running emulator, use `& $flutter run`. Build web with
`& $flutter build web`. For smaller device-specific local installers, build with
`& $flutter build apk --debug --split-per-abi`; choose
`build\app\outputs\flutter-apk\app-arm64-v8a-debug.apk` for most current
Android phones or `app-x86_64-debug.apk` for the emulator used here. These APKs
are debug-signed for local installation only; they are not Play Store releases.

If the default Android NDK is not installed, a development build can use an
already installed NDK through `SOLVEIT_NDK_VERSION`. For example, this machine
has `26.1.10909125`. Clear that override and verify the current default toolchain
before production release; this setting does not change the release requirement.

The default coach uses curated prompts and self-checks. An optional local-only
Ollama gateway provides experimental feedback when configured; it does not approve
checkpoints, run code, or mark verified solves. The editor keeps separate C++,
Python, JavaScript, and TypeScript drafts. History, unsent reasoning, saved code,
checkpoints, hints, and Focus view persist locally across restarts. Solutions
reveal only on explicit request and record assistance. See
[local setup](../../docs/LOCAL_DEVELOPMENT.md) for storage behavior and AI commands.

Production work includes auth/sync, evaluated AI coaching, isolated
execution, reviewed four-language solutions, purchases, and operational controls.
The Android identity `dev.solveit.solveit` remains stable so existing local installs keep their workbook. The launcher now uses the LoopLoom wordmark. Configure an owned release identity and secure signing before publishing. See the root `docs/` for the delivery plan.
