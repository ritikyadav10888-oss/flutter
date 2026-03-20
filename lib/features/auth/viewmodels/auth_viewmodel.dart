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
      // The explicit assignment inside signIn methods handles the real user value.
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
      _errorMessage = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerPlayer({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.registerPlayer(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
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
      _isInitializing = false;
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUser(_user!.uid, data);
      
      // Re-fetch user to update local state and trigger navigation
      final updatedUser = await _authService.user.first;
      if (updatedUser != null) {
        _user = updatedUser;
      }
      
      _isLoading = false;
      _isInitializing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> switchRole(UserRole role) async {
    if (_user == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.updateUser(_user!.uid, {'active_role': role.name});
      _user = _user!.copyWith(activeRole: role);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _errorMessage = 'Password reset is not yet implemented in the new backend.';
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  String _handleAuthError(dynamic e) {
    return e.toString().contains('Exception:')
        ? e.toString().replaceAll('Exception: ', '')
        : 'An error occurred. Please try again.';
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
