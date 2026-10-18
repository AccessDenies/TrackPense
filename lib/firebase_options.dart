
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'TrackPense is currently configured for Android only.',
      );
    }

    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1iE7c2eyF2R2AA--lIRl16BCzFtNwf-Y',
    appId: '1:196043232101:android:b78609388a24ab16b1078c',
    messagingSenderId: '196043232101',
    projectId: 'trackpense-c4ca0',
    storageBucket: 'trackpense-c4ca0.firebasestorage.app',
  );
}
