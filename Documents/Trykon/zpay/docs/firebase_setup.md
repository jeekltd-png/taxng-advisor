# Firebase Setup (Web & Mobile) — zpay 🚀

This document explains quick steps to configure Firebase for web and mobile, including creating `firebase_options.dart`, adding platform configs, and enabling Authentication/Firestore.

---

## 1) Recommended: Generate `firebase_options.dart` with FlutterFire CLI

1. Install CLI: `dart pub global activate flutterfire_cli`
2. Authenticate: `flutterfire login` (opens browser)
3. Run in project root: `flutterfire configure` and follow prompts. This generates `lib/firebase_options.dart` tailored for your platforms.

If you can't run the CLI, paste your Web config into `lib/firebase_options.dart` (see placeholders already added).

---

## 2) Web (Chrome) setup

- Ensure `lib/main.dart` initializes Firebase with options when `kIsWeb` is true (already set up in the project).
- Replace placeholders in `lib/firebase_options.dart` or generate via `flutterfire configure`.
- Enable Authentication providers in the Firebase Console: Email/Password and Google.
- Add any required OAuth origins for Google Sign-In (in console > Auth > Sign-in method > Web SDK configuration).

To run on web:
- `flutter create .` (only if project wasn't created with web enabled)
- `flutter run -d chrome` (after `flutter pub get`)

---

## 3) Android / iOS setup (emulator or device)

- Android: download `google-services.json` from Firebase Console and place in `android/app/`.
- iOS: download `GoogleService-Info.plist` and add to `ios/Runner` using Xcode (Runner target).
- Configure `android/build.gradle` and `android/app/build.gradle` as Firebase docs demand (if you used FlutterFire CLI it does this automatically).
- Add configuration for Google Sign-In on Android/iOS per FlutterFire docs.

Testing on emulators:
- Android emulator: `flutter emulators --launch <id>` then `flutter run -d <deviceId>`
- iOS simulator (macOS required): `flutter run -d <deviceId>`

---

## 4) Firestore rules & Auth provider

We added sample Firestore rules file `firestore.rules` (see repo). After you deploy rules, only users with `request.auth.token.admin == true` can write (create/update/delete) admin documents.

Example rule deployment:
- Use Firebase CLI: `firebase deploy --only firestore:rules` or `gcloud`/CI pipeline.

---

## 5) Notes

- Client-side admin checks are for UX only; enforce server-side rules using Firestore security rules and the Admin SDK.
- If you want, I can run `flutterfire configure` for you (needs Firebase project selection and API access) or generate a complete `firebase_options.dart` if you supply the config.
