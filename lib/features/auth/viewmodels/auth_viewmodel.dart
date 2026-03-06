import 'package:flutter/material.dart';
import 'package:force_player_register_app/core/services/auth_service.dart';
import 'package:force_player_register_app/core/models/models.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  String? get errorMessage => _errorMessage;

  AuthViewModel() {
    _authService.user.listen((user) {
      // While a sign-in is actively in progress (_isLoading == true), ignore
      // null emissions from the stream. These nulls happen because Firebase
      // Auth fires authStateChanges() BEFORE the Firestore document is written
      // for new Google/Phone users (race condition). The explicit assignment
      // inside signInWithGoogle() / signIn() handles the real user value.
      if (user == null && _isLoading) return;
      _user = user;
      _isInitializing = false;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signIn(email, password);
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerPlayer({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.registerPlayer(
        email: email,
        password: password,
        name: name,
      );
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithGoogle();
      _isInitializing = false; // ensure the loading splash never gets stuck
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception:')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Google sign-in failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String? _verificationId;
  String? get verificationId => _verificationId;

  Future<void> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationFailed: (e) {
          _errorMessage = e.message;
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (verificationId, forceResendingToken) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String smsCode) async {
    if (_verificationId == null) {
      _errorMessage = 'Verification ID not found. Request OTP again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.verifyOTP(_verificationId!, smsCode);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception:')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Invalid OTP or sign-in failed.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    if (_user == null) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updatePlayerProfile(_user!.uid, profileData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception:')
          ? e.toString().replaceAll('Exception: ', '')
          : 'Failed to send reset email. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
