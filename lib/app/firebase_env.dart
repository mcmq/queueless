import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase_options.dart';

/// Firebase options read from `.env` (see `.env.example`), falling back to the
/// generated `firebase_options.dart` when a value is missing.
FirebaseOptions firebaseOptionsFromEnv() {
  final isIos = defaultTargetPlatform == TargetPlatform.iOS;
  final fallback = DefaultFirebaseOptions.currentPlatform;

  String pick(String key, String fallbackValue) {
    final value = dotenv.maybeGet(key);
    return (value == null || value.isEmpty) ? fallbackValue : value;
  }

  return FirebaseOptions(
    apiKey: pick(
      isIos ? 'FIREBASE_IOS_API_KEY' : 'FIREBASE_ANDROID_API_KEY',
      fallback.apiKey,
    ),
    appId: pick(
      isIos ? 'FIREBASE_IOS_APP_ID' : 'FIREBASE_ANDROID_APP_ID',
      fallback.appId,
    ),
    messagingSenderId: pick(
      'FIREBASE_MESSAGING_SENDER_ID',
      fallback.messagingSenderId,
    ),
    projectId: pick('FIREBASE_PROJECT_ID', fallback.projectId),
    storageBucket: pick(
      'FIREBASE_STORAGE_BUCKET',
      fallback.storageBucket ?? '',
    ),
    iosBundleId: isIos
        ? pick('FIREBASE_IOS_BUNDLE_ID', fallback.iosBundleId ?? '')
        : null,
  );
}
