<p align="center">
  <img src="docs/looploom-logo-preview.png" alt="LoopLoom — Think · Trace · Code" width="760" />
</p>

<p align="center">
  <a href="https://github.com/mkamrul9/LoopLoom"><img src="https://img.shields.io/github/stars/mkamrul9/LoopLoom?style=flat-square&color=914B36" alt="GitHub stars" /></a>
  <a href="https://github.com/mkamrul9/LoopLoom/network/members"><img src="https://img.shields.io/github/forks/mkamrul9/LoopLoom?style=flat-square&color=914B36" alt="GitHub forks" /></a>
  <a href="https://github.com/mkamrul9/LoopLoom/issues"><img src="https://img.shields.io/github/issues/mkamrul9/LoopLoom?style=flat-square&color=914B36" alt="Open issues" /></a>
  <img src="https://img.shields.io/badge/Flutter-Android%20%2B%20Web-914B36?style=flat-square" alt="Flutter for Android and web" />
  <img src="https://img.shields.io/badge/Practice-local--first-262B2D?style=flat-square" alt="Local first practice" />
</p>

<h1 align="center">Think it through. Then write the code.</h1>

<p align="center">
  LoopLoom is a focused coding interview coach that helps you build an approach one decision at a time.
</p>

<table>
  <tr>
    <th align="center">Light</th>
    <th align="center">Dark</th>
  </tr>
  <tr>
    <td><img src="docs/looploom-app-preview.png" alt="LoopLoom learning screen in light theme" width="480" /></td>
    <td><img src="docs/looploom-app-preview-dark.png" alt="LoopLoom learning screen in dark theme" width="480" /></td>
  </tr>
</table>

## Learn the reasoning, not just the answer

Most practice tools show a problem and wait for a submission. LoopLoom guides you through the thinking that comes first: understand the constraints, explain an algorithm, trace it through an example, write code, and reflect on the tradeoffs.

The coach asks for the next step instead of revealing a complete solution by default. You can request a hint or reveal an explanation when you need one; assisted work is recorded as assisted.

## What is in the app

- **Guided interview practice** across five checkpoints: Understand, Approach, Trace, Code, and Reflect.
- **Three study paths:** Starter 30, Blind 75, and Interview Mastery 300, organized around interview patterns and phases.
- **An interview diagnostic** with eight short scenarios, plain-language explanations, and saved pattern recommendations linked to guided lessons.
- **Four coding languages:** C++, Python, JavaScript, and TypeScript, with a saved draft for each language.
- **A local workbook** for attempts, notes, saved problems, study goals, and review history. Save or restore JSON backup files on Android and web, with a validated preview before importing; copy/paste remains available.
- **Readable study settings** with an Extra large 1.5× option, device text scaling, and persistent System, Light, and Dark themes.
- **Responsive Flutter screens** for Android and web.
- **Optional local AI experiments** through a development gateway. Guided practice works without an AI service or paid API.

### How a session works

1. Read the constraints and explain what the problem asks.
2. Describe an approach and why it should work.
3. Trace the approach through an example and an edge case.
4. Write a code draft in your preferred language.
5. State the complexity and reflect on a follow-up.

Progress is labeled **self-reviewed**. It does not claim a verified solve when code has not been judged.

## The curriculum, honestly described

LoopLoom writes its own learning prompts, hints, and explanations. The Blind 75 path links to the official challenge pages and is not affiliated with LeetCode. The 300-problem roadmap combines the Blind 75 with additional interview challenges; canonical statements and online judging remain on their linked sites.

The curriculum is still being reviewed. Fifteen Blind 75 lessons currently have local reference-case specifications. The remaining challenges use external judges. The optional development runner executes only authored reference cases in disposable Docker containers; it is not enabled as a production code-execution service.

## A quiet place to practice

The paper, charcoal, and muted-clay palette keeps problem text and code in focus. Choose System to follow the device, or select Light or Dark in **Profile & settings → Appearance**. Your choice is saved in the local workbook. The two infinity-shaped `oo` pairs are drawn directly into the one-line wordmark.

## Run locally

### Requirements

- Flutter SDK with Dart 3.12 or newer
- Android SDK for Android builds
- A browser for Flutter web

### Start the app

```bash
cd apps/solveit
flutter pub get
flutter run -d chrome
```

For Android, start an emulator or connect a device, then run:

```bash
flutter run
```

The app stores its workbook locally. There is no sign-in or cloud sync in this release. The Android application ID still uses the original `dev.solveit.solveit` identity to preserve existing local installs.

## Repository map

```text
apps/solveit/       Flutter app, Android project, and web assets
docs/               Product, architecture, curriculum, and release documentation
scripts/            Local development helpers and brand asset generator
```

Useful guides:

- [Product roadmap](docs/PRODUCT_ROADMAP.md)
- [Architecture and data model](docs/ARCHITECTURE.md)
- [UX and visual direction](docs/UX_SPEC.md)
- [LoopLoom brand and color palettes](docs/LOOPLOOM_BRAND.md)
- [Curriculum: Interview Mastery 300](docs/MASTER_300_CURRICULUM.md)
- [Local development and backup](docs/LOCAL_DEVELOPMENT.md)
- [Local AI evaluation](docs/LOCAL_AI_VALIDATION.md)
- [Code runner scope](docs/REFERENCE_RUNNER.md)
- [Release and monetization plan](docs/RELEASE_MONETIZATION.md)

## Project status

LoopLoom is under active development. Accounts, cross-device sync, production AI, secure hosted code execution, and billing are not implemented. Public release still needs curriculum review, device and accessibility checks, release signing, and Play Store preparation. See the [delivery roadmap](docs/PRODUCT_ROADMAP.md) for the current plan.

## License

No open-source license has been added yet. Until the project publishes one, public visibility does not grant permission to reuse or distribute the code.
