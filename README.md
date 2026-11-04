# LoopLoom

A Flutter problem-solving coach: understand the problem, explain an approach, trace it, write code, and reflect before moving on.

Android first, with a responsive Flutter web application from the same codebase. **LoopLoom is the selected product name**; store and trademark clearance remains a release task.

Confirmed direction: intermediate developers preparing for interviews; strict zero-spend development. The Blind 75 guided path is the main interview-preparation roadmap, alongside three warm-ups, twenty-seven intermediate lessons, and a combined Starter 30 track. Default builds use guided practice; optional AI requests go only through a local development gateway.

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

The catalog includes thirty original starter lessons plus a 75-entry Blind 75 path, grouped into sixteen patterns and four study phases. Fifteen entries reuse a matching Starter 30 lesson so saved progress carries over; sixty have new LoopLoom-authored prompts, hints, and explanations. Every entry has five guided checkpoints and starter drafts in C++, Python, JavaScript, and TypeScript. Editorial review and tested language solutions remain release work. A portable local runtime and two free models were evaluated; neither met the coaching quality bar, so the app stays in guided mode by default. AI feedback does not approve checkpoints or establish verified solves. Only fifteen reused Blind 75 lessons currently have reference-case specifications, and code execution requires the optional local development runner; the other sixty link to LeetCode's judge. LoopLoom writes its own prompts and is not affiliated with LeetCode. Production AI quality, secure execution, accounts, cloud sync, and billing remain subsequent milestones. See the [model results](docs/LOCAL_AI_VALIDATION.md) and [app validation notes](docs/VALIDATION.md).

The teaching rule is simple: **feedback should help the learner take the next step, without revealing the complete solution by default**. Users can still explicitly choose to reveal a solution; that attempt is recorded as assisted.

Profile & settings are available from the header. Name, target role, interview date, practice targets, text size, coaching pace, and default language are stored locally. Device text scaling remains active. Workbook backup is available from the header menu; copy the JSON text into a file and paste it on another device to review and restore missing attempts. Existing attempt IDs are preserved rather than overwritten. See [backup instructions](docs/LOCAL_DEVELOPMENT.md#workbook-backup).

## Repository direction

An opt-in local C++/JavaScript/Python/TypeScript reference runner executes visible cases in restricted disposable Docker containers. TypeScript uses type stripping without type checking. Results never grant verified solves; the default APK keeps execution disabled. [Setup and scope](docs/REFERENCE_RUNNER.md).

The Code checkpoint includes lesson-specific starter signatures in all four languages, an indentation control, and folded reference cases with expected results. Drafts save locally; opt-in execution is available only in the local development preview and never marks a problem solved. [Workspace details](docs/CODE_WORKSPACE.md).

The Blind 75 roadmap can be searched by problem or pattern, filtered by difficulty, and browsed by phase. Progress is device-local and labeled self-reviewed; it is not a verified solve. Official challenge links open outside LoopLoom and do not submit or synchronize code. The focus-oriented paper, charcoal, and muted-clay theme uses larger default text and Standard, Comfortable, and Large reading choices that combine with device accessibility settings. The one-line wordmark turns each `oo` into a continuous infinity loop, with “Think · Trace · Code” below. See the [UX specification](docs/UX_SPEC.md) and [starter lesson details](docs/INTERMEDIATE_LESSONS.md).

`apps/solveit/` contains the Flutter app. Documentation lives in `docs/`. Keep problem content and coaching rules versioned independently from UI code as the catalog grows.

Use Flutter stable and the Android SDK. From `apps/solveit`, run:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For Android, connect a device or start an emulator and run `flutter run`. Local checks currently build a debug APK and web output; neither is a published release. Production package identity, signing, store listing, and Play Console registration must be configured before release.
