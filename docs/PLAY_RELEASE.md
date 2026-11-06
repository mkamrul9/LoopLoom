# Google Play release preparation

The Android application ID is `dev.solveit.solveit`; keep it stable to preserve installed workbooks. The current build targets Android API 36. The GitHub APK is for local installation and uses the existing local debug signing identity. It is not the Play upload artifact.

## Create a Play upload bundle

1. Create and back up a private upload keystore. Keep the keystore and passwords outside this repository. Google Play App Signing manages the final app signing key, but you must retain your upload key or complete Google's key-reset process if it is lost.
2. Set these environment variables in your own terminal: `LOOPLOOM_UPLOAD_KEYSTORE` (absolute `.jks` path), `LOOPLOOM_UPLOAD_STORE_PASSWORD`, `LOOPLOOM_UPLOAD_KEY_ALIAS`, and `LOOPLOOM_UPLOAD_KEY_PASSWORD`. Do not commit them, put them in a command transcript, or send them in chat.
3. From `apps/solveit`, build with `flutter build appbundle --release --dart-define-from-file=firebase.ai.json`. The bundle task fails when the upload key is missing. The resulting `build/app/outputs/bundle/release/app-release.aab` is the candidate for Play internal testing.
4. Register the Play App Signing SHA-256 certificate fingerprint in Firebase project settings for the same Android app. Keep Play Integrity App Check enabled. Test Gemini through a Play internal test install before a wider release.
5. In Play Console, finish the store listing, privacy policy, Data safety declarations, content rating, testing requirements, and any account or payment policies that apply at submission time. Upload to internal testing first, then verify installation, app links, offline practice, backup, code runner configuration, and AI consent on real devices.

The current sideloaded APK may fail App Check's default Play-recognized verdict. Changing the production policy to allow outside-Play builds is a separate security decision; the web PWA and authored offline review remain usable while it is undecided.
