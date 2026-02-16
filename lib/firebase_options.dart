// File generated for Firebase configuration
// Project: cosmetics-catalog-3c357

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBzmUGSa9gkRoGsMkVU-NYsH9TeSKGrbfw',
    appId: '1:1072681341830:web:84bc63b5ff82c0491e9207',
    messagingSenderId: '1072681341830',
    projectId: 'cosmetics-catalog-3c357',
    authDomain: 'cosmetics-catalog-3c357.firebaseapp.com',
    storageBucket: 'cosmetics-catalog-3c357.firebasestorage.app',
    measurementId: 'G-8DFDS5C2K4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJfvFCUCl6MBL7kvpEYsNfybWQeZ_gcnE',
    appId: '1:1072681341830:android:f2e6598fb5632a081e9207',
    messagingSenderId: '1072681341830',
    projectId: 'cosmetics-catalog-3c357',
    authDomain: 'cosmetics-catalog-3c357.firebaseapp.com',
    storageBucket: 'cosmetics-catalog-3c357.firebasestorage.app',
  );
}
