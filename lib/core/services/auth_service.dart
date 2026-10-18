import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> get changes => _auth.authStateChanges();
  User? get current => _auth.currentUser;

  /// Staff = signed in with email/password; customers are anonymous.
  static bool isStaff(User? u) => u != null && !u.isAnonymous;

  /// Customers never see this: they get a silent anonymous session.
  Future<User> ensureSignedIn() async {
    return _auth.currentUser ?? (await _auth.signInAnonymously()).user!;
  }

  Future<void> staffSignUp(String email, String password) async {
    // Upgrade the anonymous session is avoided: create a clean staff account.
    await _auth.signOut();
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> staffLogIn(String email, String password) async {
    await _auth.signOut();
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Back to a fresh anonymous customer session.
  Future<void> signOut() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  }
}
