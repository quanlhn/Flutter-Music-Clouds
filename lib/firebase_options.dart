// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyBHWYjsZlO0VqB8eVcysg-T5HKOEzwCPUI',
    appId: '1:55473367261:web:6a9bdf08fbe078b12a9334',
    messagingSenderId: '55473367261',
    projectId: 'musiccloud-8eaa8',
    authDomain: 'musiccloud-8eaa8.firebaseapp.com',
    databaseURL: 'https://musiccloud-8eaa8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'musiccloud-8eaa8.appspot.com',
    measurementId: 'G-ZHSS9BTHVM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAsXew-MJ1ZJbblbsviCRG3uZGcGGuba_I',
    appId: '1:55473367261:android:8f584c8e78b411232a9334',
    messagingSenderId: '55473367261',
    projectId: 'musiccloud-8eaa8',
    databaseURL: 'https://musiccloud-8eaa8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'musiccloud-8eaa8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMoVgK1iTouPT0u0wXYp6rzwmPasRY3BQ',
    appId: '1:55473367261:ios:4f13293dae7168202a9334',
    messagingSenderId: '55473367261',
    projectId: 'musiccloud-8eaa8',
    databaseURL: 'https://musiccloud-8eaa8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'musiccloud-8eaa8.appspot.com',
    iosClientId: '55473367261-mod3htfpb133el1c2go4uummoq5km311.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterMusicClouds',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCMoVgK1iTouPT0u0wXYp6rzwmPasRY3BQ',
    appId: '1:55473367261:ios:7acf17e9184db7642a9334',
    messagingSenderId: '55473367261',
    projectId: 'musiccloud-8eaa8',
    databaseURL: 'https://musiccloud-8eaa8-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'musiccloud-8eaa8.appspot.com',
    iosClientId: '55473367261-sjduakcqt4cvc135hpsudgio0n2pekph.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterMusicClouds.RunnerTests',
  );
}
