# Gemini AI coach setup

The app now has a Firebase AI Logic provider for Gemini 3.8 Flash. It is disabled until a Firebase project is configured. The offline coach keeps working without Firebase or an internet connection.

## What runs on the phone

- The Gemini model stays on Google's servers; no model weights are included in the APK or downloaded to the phone.
- The ARM64 release APK measured 19.13 MB with the Firebase SDK, up 1.09 MB (6.1%) from the previous 18.03 MB build. The model itself adds no bundled asset.
- No request runs in the background. The app sends a request only after the learner taps **Ask AI coach** and accepts the data notice.
- A request includes the current answer, the current lesson's short problem context, and at most two earlier answers. It excludes authored hints, the solution explanation, profile details, and saved history.
- Requests are bounded to about 11 KB of prompt data, 220 response tokens, an 8-second secure setup timeout, and a 15-second model timeout. Slow or failed requests leave the learner's work saved and the offline coach available.
- AI output is a coaching suggestion and one follow-up question. It cannot mark an answer correct, advance a step, or run code.
- Gemini's Developer API free tier currently has limited capacity and may use submitted content to improve Google's products. The app asks for consent before the first request. Do not send personal or confidential information.

The free tier is not a promise of unlimited service. LoopLoom does not attach a paid provider or automatically fall back to one; if the free quota is unavailable, use the offline coach and try AI later.

## Firebase project

Firebase project `looploom-coach-2026` is already set up on the no-cost Spark plan. Gemini Developer API is the Firebase AI Logic provider, and App Check is enforced for AI Logic. The Android app (`dev.solveit.solveit`) is registered with Play Integrity; the Web app is registered with Fraud Defense (reCAPTCHA Enterprise). Google Analytics and billing are not enabled.

The Android fingerprint currently registered is the local debug signing certificate. Before a Play Store release, add the Play App Signing SHA-256 fingerprint in Firebase Console → Project settings → Android app. Do not use a debug-token build as a public release.

For local Android or Web debug builds, the App Check debug provider is selected automatically. Run once, copy the emitted debug token from the local console, and register it under Firebase Console → App Check → Apps → Debug tokens. Debug tokens bypass device attestation, so keep them private and never include them in a public build. Release builds use Play Integrity on Android and the registered Enterprise site key on Web.

## Configure this checkout

Copy `apps/solveit/firebase.ai.example.json` to `apps/solveit/firebase.ai.json` and fill the values from Firebase project settings:

- `LOOPLOOM_FIREBASE_API_KEY`
- `LOOPLOOM_FIREBASE_PROJECT_ID`
- `LOOPLOOM_FIREBASE_MESSAGING_SENDER_ID`
- `LOOPLOOM_FIREBASE_ANDROID_APP_ID`
- `LOOPLOOM_FIREBASE_WEB_APP_ID`
- `LOOPLOOM_FIREBASE_WEB_AUTH_DOMAIN` (if present in the Web app settings)
- `LOOPLOOM_FIREBASE_WEB_RECAPTCHA_SITE_KEY`
- `LOOPLOOM_APPCHECK_DEBUG` (`true` only for a registered local debug token)

The local config file is ignored by Git. Firebase client IDs are app configuration, not server secrets; restrict the API key and keep App Check enforced.

From `apps/solveit`, run:

```powershell
flutter pub get
flutter run --dart-define-from-file=firebase.ai.json
```

For the Web app, use the Enterprise key configured in this project for `looploom-coach-2026.web.app`. Local debug uses the App Check debug provider, so `localhost` does not need to be added to the production key. Then use:

```powershell
flutter run -d chrome --dart-define-from-file=firebase.ai.json
```

The final Play Store build must use Play Integrity, a production signing key, and the same Android app registration. A debug App Check token must never ship in a public APK.

## Deploy the Flutter Web app

The repository-root `firebase.json` serves `apps/solveit/build/web` and rewrites client routes to Flutter's `index.html`. Once signed in and after setting the Firebase project as the CLI's default, build and deploy from the repository root:

```powershell
cd apps/solveit
flutter build web --release --dart-define-from-file=firebase.ai.json
cd ../..
firebase deploy --only hosting
```

Firebase Hosting stays on the no-cost Spark plan unless a billing account is explicitly linked. The site is public. A deployment without `firebase.ai.json` still works offline, but the cloud coach remains disabled.
