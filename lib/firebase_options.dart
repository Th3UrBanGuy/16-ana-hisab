// Firebase configuration for multi-platform support
// Project: sholoanahisab

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
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
    apiKey: 'AIzaSyB1VeaBqlCmQlLnFdT0z-a5t4bhlAtfEJ8',
    appId: '1:244961720850:web:ae3c5356b86261bf9c36cb',
    messagingSenderId: '244961720850',
    projectId: 'sholoanahisab',
    authDomain: 'sholoanahisab.firebaseapp.com',
    storageBucket: 'sholoanahisab.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1VeaBqlCmQlLnFdT0z-a5t4bhlAtfEJ8',
    appId: '1:244961720850:android:ae3c5356b86261bf9c36cb',
    messagingSenderId: '244961720850',
    projectId: 'sholoanahisab',
    storageBucket: 'sholoanahisab.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1VeaBqlCmQlLnFdT0z-a5t4bhlAtfEJ8',
    appId: '1:244961720850:ios:PLACEHOLDER',
    messagingSenderId: '244961720850',
    projectId: 'sholoanahisab',
    storageBucket: 'sholoanahisab.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );
}
