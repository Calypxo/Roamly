import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Stream<User?> getAuthStateChanges() {
    return _auth.authStateChanges();
  }

  Future<UserCredential> registerUser(
      String email,
      String password,
      String username,
      ) async {
    UserCredential userCredential;

    userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await userCredential.user!.updateDisplayName(username.trim());
    await userCredential.user!.reload();

    return userCredential;
  }

  Future<UserCredential> loginUser(String email, String password) async {
    UserCredential userCredential;

    userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    return userCredential;
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}
