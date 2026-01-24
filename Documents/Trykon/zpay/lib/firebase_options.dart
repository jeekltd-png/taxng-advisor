// lib/firebase_options.dart
// Placeholder FirebaseOptions for zpay.
// Replace values with your project config or generate a proper file with
// the FlutterFire CLI: `flutterfire configure` (recommended).

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Example placeholder options — DO NOT use in production.
const FirebaseOptions firebaseOptionsWeb = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  authDomain: 'YOUR_PROJECT.firebaseapp.com',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT.appspot.com',
  messagingSenderId: 'SENDER_ID',
  appId: 'APP_ID',
);

const FirebaseOptions firebaseOptionsDefault = FirebaseOptions(
  apiKey: 'YOUR_API_KEY',
  authDomain: 'YOUR_PROJECT.firebaseapp.com',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT.appspot.com',
  messagingSenderId: 'SENDER_ID',
  appId: 'APP_ID',
);

FirebaseOptions get firebaseOptions {
  // This is just a helper for quick local testing. Prefer generating a
  // fully populated `firebase_options.dart` using FlutterFire CLI.
  return kIsWeb ? firebaseOptionsWeb : firebaseOptionsDefault;
}
