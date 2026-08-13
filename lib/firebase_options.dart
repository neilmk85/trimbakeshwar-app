import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not supported');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android; // fallback for macOS/desktop dev builds
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsh9hd7fofB0CZOTzaKRHscpLxRnzS6PQ',
    appId: '1:651026407454:android:14bc128537d35da635ce0f',
    messagingSenderId: '651026407454',
    projectId: 'trimbakeshwarapp',
    storageBucket: 'trimbakeshwarapp.firebasestorage.app',
  );

  // Add GoogleService-Info.plist to ios/Runner/ and fill these values for iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_IOS_API_KEY',
    appId: 'REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '651026407454',
    projectId: 'trimbakeshwarapp',
    storageBucket: 'trimbakeshwarapp.firebasestorage.app',
    iosClientId: 'REPLACE_WITH_IOS_CLIENT_ID',
    iosBundleId: 'com.example.trimbakeshwarApp',
  );
}
