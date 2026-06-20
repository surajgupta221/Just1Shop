import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase options are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'AIzaSyButTFo3f5vX87Ia03hzDBvBKLoGTMfgHg',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '1:69791413402:web:882ccdbd6fd4d9cca41b23',
    ),
    messagingSenderId: '69791413402',
    projectId: 'just1shop',
    authDomain: 'just1shop.firebaseapp.com',
    storageBucket: 'just1shop.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDj7FOklzK3o1RBRLIb_f1KYYVbGvplIqo',
    appId: '1:69791413402:android:53965c25243812efa41b23',
    messagingSenderId: '69791413402',
    projectId: 'just1shop',
    storageBucket: 'just1shop.appspot.com',
  );
}
