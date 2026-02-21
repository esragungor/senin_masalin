// File generated based on Firebase Console web app config
// Project: senin-masalin-128f2

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ── Web ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCIheB6eqmDrImLKo1DNTyWhaa8fEFX608',
    authDomain: 'senin-masalin-128f2.firebaseapp.com',
    projectId: 'senin-masalin-128f2',
    storageBucket: 'senin-masalin-128f2.firebasestorage.app',
    messagingSenderId: '536032076114',
    appId: '1:536032076114:web:ad80e4e27b41e85da21a8b',
  );

  // ── Android ───────────────────────────────────────────────────────────────
  // Bu değerler google-services.json'dan gelecek.
  // Firebase Console → Project Settings → Android app ekle
  // Package name: com.seninmasalin.senin_masalin
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJE-WirHfSklnkP1Ez3DYFvhLa6Tb_YY4',
    authDomain: 'senin-masalin-128f2.firebaseapp.com',
    projectId: 'senin-masalin-128f2',
    storageBucket: 'senin-masalin-128f2.firebasestorage.app',
    messagingSenderId: '536032076114',
    appId: '1:536032076114:android:12bf025cbe70e63ea21a8b',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIheB6eqmDrImLKo1DNTyWhaa8fEFX608',
    authDomain: 'senin-masalin-128f2.firebaseapp.com',
    projectId: 'senin-masalin-128f2',
    storageBucket: 'senin-masalin-128f2.firebasestorage.app',
    messagingSenderId: '536032076114',
    appId: '1:536032076114:ios:BURAYA_IOS_APP_ID',
    iosClientId: 'BURAYA_IOS_CLIENT_ID',
    iosBundleId: 'com.seninmasalin.seninMasalin',
  );
}
