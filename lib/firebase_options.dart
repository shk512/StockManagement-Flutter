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
    apiKey: 'AIzaSyDOp81DxuLB-7evL-7MVY64uASM-mk2wVc',
    appId: '1:1089228164764:web:bbbaa9debc7e4d1b0ae759',
    messagingSenderId: '1089228164764',
    projectId: 'point-of-sales-f74aa',
    authDomain: 'point-of-sales-f74aa.firebaseapp.com',
    databaseURL: 'https://point-of-sales-f74aa-default-rtdb.firebaseio.com',
    storageBucket: 'point-of-sales-f74aa.appspot.com',
    measurementId: 'G-F9Z656B1XC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-VhpX0261Iez90Ar_5hsqJg3nJ4CbJjk',
    appId: '1:1089228164764:android:272c73b8f942aa470ae759',
    messagingSenderId: '1089228164764',
    projectId: 'point-of-sales-f74aa',
    databaseURL: 'https://point-of-sales-f74aa-default-rtdb.firebaseio.com',
    storageBucket: 'point-of-sales-f74aa.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCG_7TKewm15q6050AUIJwDcwYtcfIxBXU',
    appId: '1:1089228164764:ios:f44dab62398834940ae759',
    messagingSenderId: '1089228164764',
    projectId: 'point-of-sales-f74aa',
    databaseURL: 'https://point-of-sales-f74aa-default-rtdb.firebaseio.com',
    storageBucket: 'point-of-sales-f74aa.appspot.com',
    iosClientId: '1089228164764-mstfmgdeglp9gphuh8t8s3jv8s3j03dj.apps.googleusercontent.com',
    iosBundleId: 'com.example.stockManagement',
  );
}
