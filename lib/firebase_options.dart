// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyA45-Tma2K3zxaP-kdgJA0_B3amHMFYeEc',
    appId: '1:1051924189567:web:6309cae15d9d3bd544ca4a',
    messagingSenderId: '1051924189567',
    projectId: 'greengrass-6aeef',
    authDomain: 'greengrass-6aeef.firebaseapp.com',
    storageBucket: 'greengrass-6aeef.firebasestorage.app',
    measurementId: 'G-0Q7Y3J273J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyASWFZCOxQgQo6pwJT5Ik7B_HxM_MDISJM',
    appId: '1:1051924189567:android:2fe5d5a9f23af7ce44ca4a',
    messagingSenderId: '1051924189567',
    projectId: 'greengrass-6aeef',
    storageBucket: 'greengrass-6aeef.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCf4pxiyE0KpqYNsqEIhyGugCRM8YY_PP4',
    appId: '1:1051924189567:ios:82c420b6ad669eef44ca4a',
    messagingSenderId: '1051924189567',
    projectId: 'greengrass-6aeef',
    storageBucket: 'greengrass-6aeef.firebasestorage.app',
    iosBundleId: 'com.example.greengrass',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCf4pxiyE0KpqYNsqEIhyGugCRM8YY_PP4',
    appId: '1:1051924189567:ios:82c420b6ad669eef44ca4a',
    messagingSenderId: '1051924189567',
    projectId: 'greengrass-6aeef',
    storageBucket: 'greengrass-6aeef.firebasestorage.app',
    iosBundleId: 'com.example.greengrass',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA45-Tma2K3zxaP-kdgJA0_B3amHMFYeEc',
    appId: '1:1051924189567:web:6083115658db9e3344ca4a',
    messagingSenderId: '1051924189567',
    projectId: 'greengrass-6aeef',
    authDomain: 'greengrass-6aeef.firebaseapp.com',
    storageBucket: 'greengrass-6aeef.firebasestorage.app',
    measurementId: 'G-EXFLX9V9KP',
  );
}
