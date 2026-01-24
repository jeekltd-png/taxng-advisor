import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authProvider = StateNotifierProvider<AuthNotifier, User?>(
  (ref) => AuthNotifier(ref),
);

// Small in-file admin list - replace with your own admin logic (custom claims or server-side list)
const List<String> _adminEmails = [
  'admin@example.com',
];

final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null || user.email == null) return false;
  try {
    // Check token claims for 'admin' first
    final idTokenResult = await user.getIdTokenResult(true);
    final claims = idTokenResult.claims ?? {};
    if (claims['admin'] == true) return true;
  } catch (_) {}
  // Fallback to email list
  return _adminEmails.contains(user.email);
});

class AuthNotifier extends StateNotifier<User?> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthNotifier(Ref ref) : super(FirebaseAuth.instance.currentUser) {
    FirebaseAuth.instance.authStateChanges().listen((u) async {
      state = u;
      await _persistToken();
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    state = cred.user;
    await _persistToken();
  }

  Future<void> signUpWithEmail(String email, String password) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    state = cred.user;
    await _persistToken();
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // cancelled
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await FirebaseAuth.instance.signInWithCredential(credential);
    state = cred.user;
    await _persistToken();
  }

  Future<void> sendPasswordReset(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = null;
    await _storage.delete(key: 'auth_token');
  }

  Future<void> _persistToken() async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
      }
    } catch (_) {}
  }
}
