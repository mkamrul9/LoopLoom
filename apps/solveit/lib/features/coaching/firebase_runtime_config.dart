import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase client identifiers are public app configuration, not API secrets.
/// Restrict the project's API key and enforce App Check in Firebase Console.
class FirebaseRuntimeConfig {
  FirebaseRuntimeConfig._();

  static const _apiKey = String.fromEnvironment('LOOPLOOM_FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment(
    'LOOPLOOM_FIREBASE_PROJECT_ID',
  );
  static const _senderId = String.fromEnvironment(
    'LOOPLOOM_FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _androidAppId = String.fromEnvironment(
    'LOOPLOOM_FIREBASE_ANDROID_APP_ID',
  );
  static const _webAppId = String.fromEnvironment(
    'LOOPLOOM_FIREBASE_WEB_APP_ID',
  );
  static const _webAuthDomain = String.fromEnvironment(
    'LOOPLOOM_FIREBASE_WEB_AUTH_DOMAIN',
  );
  static const _webRecaptchaSiteKey = String.fromEnvironment(
    'LOOPLOOM_FIREBASE_WEB_RECAPTCHA_SITE_KEY',
  );
  static const _debugAppCheck = bool.fromEnvironment('LOOPLOOM_APPCHECK_DEBUG');

  static FirebaseOptions? get currentPlatformOptions {
    if (_apiKey.isEmpty || _projectId.isEmpty || _senderId.isEmpty) {
      return null;
    }
    final appId = switch ((kIsWeb, defaultTargetPlatform)) {
      (true, _) => _webAppId,
      (false, TargetPlatform.android) => _androidAppId,
      _ => '',
    };
    final needsWebSiteKey =
        kIsWeb &&
        !kDebugMode &&
        !_debugAppCheck &&
        _webRecaptchaSiteKey.isEmpty;
    if (appId.isEmpty || needsWebSiteKey) {
      return null;
    }
    return FirebaseOptions(
      apiKey: _apiKey,
      appId: appId,
      messagingSenderId: _senderId,
      projectId: _projectId,
      authDomain: kIsWeb && _webAuthDomain.isNotEmpty ? _webAuthDomain : null,
    );
  }

  static bool get isConfigured => currentPlatformOptions != null;

  static Future<void> initializeForAi() async {
    final options = currentPlatformOptions;
    if (options == null) {
      throw StateError('Firebase AI configuration is missing for this app.');
    }
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }
    await FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode || _debugAppCheck
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerWeb: kIsWeb
          ? kDebugMode || _debugAppCheck
                ? WebDebugProvider()
                : ReCaptchaEnterpriseProvider(_webRecaptchaSiteKey)
          : null,
    );
  }
}
