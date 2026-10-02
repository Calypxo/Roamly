import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool getIsLoading() {
    return _isLoading;
  }

  String? getErrorMessage() {
    return _errorMessage;
  }

  User? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  Stream<User?> getAuthStateChanges() {
    return _authService.getAuthStateChanges();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> register(
      String email,
      String password,
      String username,
      ) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _authService.registerUser(
        email,
        password,
        username,
      );

      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = getAuthErrorMessage(e.code);
      setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';
      setLoading(false);
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      _errorMessage = null;

      await _authService.loginUser(email, password);

      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = getAuthErrorMessage(e.code);

      setLoading(false);
      return false;
    } catch (e) {
      _errorMessage = 'Something went wrong. Please try again.';

      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logoutUser();

    notifyListeners();
  }

  String getAuthErrorMessage(String code) {
    if (code == 'invalid-email') {
      return 'Please enter a valid email address.';
    } else if (code == 'user-not-found') {
      return 'No account found with this email.';
    } else if (code == 'wrong-password') {
      return 'Incorrect password. Please try again.';
    } else if (code == 'email-already-in-use') {
      return 'This email is already registered.';
    } else if (code == 'weak-password') {
      return 'Password should be at least 6 characters.';
    } else if (code == 'invalid-credential') {
      return 'Invalid email or password.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }
}
