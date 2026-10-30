# SolveIt

A Flutter problem-solving coach: understand the problem, explain an approach, trace it, write code, and reflect before moving on.

Android first, with a responsive Flutter web application from the same codebase. **SolveIt is a working name**, pending brand and store availability checks.

Confirmed direction: intermediate developers preparing for interviews; strict zero-spend development. Interview 75 is the main planned path. The three original pilot lessons are warm-ups. Default builds use guided practice; optional AI requests go only through a local development gateway.

## Start here

- [Product and delivery roadmap](docs/PRODUCT_ROADMAP.md)
- [Architecture and data model](docs/ARCHITECTURE.md)
- [Free/local AI strategy](docs/AI_STRATEGY.md)
- [UX and design direction](docs/UX_SPEC.md)
- [Monetization and Play Store launch](docs/RELEASE_MONETIZATION.md)
- [Implementation backlog](docs/BUILD_BACKLOG.md)
- [Local storage and AI setup](docs/LOCAL_DEVELOPMENT.md)
- [Measured local AI results](docs/LOCAL_AI_VALIDATION.md)

## Project status

The pilot now has six original problems across warm-up and intermediate tracks, progressive hints, separate language drafts, durable local history, restart recovery, and an optional experimental local-coach connection. A portable local runtime and two free models have been installed and evaluated. Neither met the coaching quality bar; the app stays in guided mode. AI feedback does not approve checkpoints or establish verified solves. Production AI quality, secure code execution, accounts, cloud sync, and billing remain subsequent milestones. See the [model results](docs/LOCAL_AI_VALIDATION.md) and [app validation notes](docs/VALIDATION.md).

The teaching rule is simple: **feedback should help the learner take the next step, without revealing the complete solution by default**. Users can still explicitly choose to reveal a solution; that attempt is recorded as assisted.

Workbook backup is available from the header's **Workbook backup** button. Copy the JSON text into a file; paste it on another device to review and restore missing attempts. Existing attempt IDs are preserved rather than overwritten. See [backup instructions](docs/LOCAL_DEVELOPMENT.md#workbook-backup).

## Repository direction

An opt-in local JavaScript/Python reference runner executes visible cases in restricted disposable Docker containers. It reports case results without granting verified solves. C++ and TypeScript remain drafting-only; the default APK keeps execution disabled. [Setup and scope](docs/REFERENCE_RUNNER.md).

The Code checkpoint includes lesson-specific starter signatures in all four languages, an indentation control, and folded reference cases with expected results. Code remains saved for self-review rather than executed. [Workspace details](docs/CODE_WORKSPACE.md).

The available Intermediate foundations track covers prefix sums, monotonic stacks, and interval merging. Warm-ups remain available. Both tracks have independent self-review counts and lesson resume states. [Content and validation details](docs/INTERMEDIATE_LESSONS.md).

`apps/solveit/` contains the Flutter app. Documentation lives in `docs/`. Keep problem content and coaching rules versioned independently from UI code as the catalog grows.

Use Flutter stable and the Android SDK. From `apps/solveit`, run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For Android, connect a device or start an emulator and run `flutter run`. Production package identity, signing, and Play Console registration must be configured before release.
