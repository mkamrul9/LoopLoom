# SolveIt Flutter pilot

Android and web interaction prototype with three original pattern lessons.

The confirmed audience is intermediate interview candidates. The current lessons
are warm-ups; Interview 75 is the main planned path. Development is strictly zero
spend, with no paid AI calls or automatic paid fallback.

Uses Flutter 3.44.0 / Dart 3.12.0 in this workspace. The SDK was found at
`D:\SWE\flutter\flutter_windows_3.44.0-stable\flutter`; add its `bin` directory
to your local PATH if `flutter` is not recognized.

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For an Android device or running emulator, use `flutter run`. Build web with
`flutter build web` and a development APK with `flutter build apk --debug`.

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
The generated Android identity `dev.solveit.solveit`, prototype vector icon, and debug
signing are development placeholders. Configure owned identity and secure release
signing before publishing. See the root `docs/` for the delivery plan.
