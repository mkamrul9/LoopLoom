# LoopLoom Flutter application

The Android and web client lives in this directory. For the product overview,
roadmaps, current limitations, and project documentation, start with the
[repository README](../../README.md).

## Run the app

Install Flutter with Dart 3.12 or newer, then:

```sh
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or connect a device and run `flutter run`.

## Main features

- Guided Understand, Approach, Trace, Code, and Reflect checkpoints
- Starter 30, Blind 75, and Interview Mastery 300 study paths
- C++, Python, JavaScript, and TypeScript code drafts
- Local history, saved problems, profile goals, and workbook backup
- System, Light, and Dark appearance preferences
- Optional local-only AI feedback and a development-only reference runner

Practice progress is self-reviewed; it is not a verified online judge result.
The app has no account, cloud sync, paid AI service, or hosted code execution.
See the root [local development guide](../../docs/LOCAL_DEVELOPMENT.md) and
[reference runner notes](../../docs/REFERENCE_RUNNER.md).

The Android application ID remains `dev.solveit.solveit` to retain existing
local installs and their workbook data. Configure a new release identity only
as part of the planned migration and store-release work.
