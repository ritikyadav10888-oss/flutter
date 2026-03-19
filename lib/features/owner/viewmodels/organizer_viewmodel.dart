import 'dart:async';
import 'package:flutter/material.dart';
import 'package:force_player_register_app/core/services/auth_service.dart';
import 'package:force_player_register_app/core/models/models.dart';
import 'dart:typed_data';

class OrganizerViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  OrganizerViewModel();

  List<AppUser> _organizers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _pollingTimer;

  List<AppUser> get organizers => _organizers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch organizers and start simple polling (instead of Firestore snapshots)
  void startListening(String ownerId) {
    _pollingTimer?.cancel();
    _fetchOrganizers();
    
    // Poll every 30 seconds for updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _fetchOrganizers());
  }

  Future<void> _fetchOrganizers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _organizers = await _authService.getOrganizers();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Create a new organizer account
  Future<bool> createOrganizer({
    required String email,
    required String password,
    required String name,
    required String ownerId,
    String? phoneNumber,
    String? address,
    String? aadharNumber,
    Uint8List? aadharBytes,
    String? aadharFileName,
    String? panNumber,
    Uint8List? panBytes,
    String? panFileName,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? accessDuration,
    Uint8List? profilePicBytes,
    String? profilePicFileName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.createOrganizer(
        email: email,
        password: password,
        name: name,
        ownerId: ownerId,
        phoneNumber: phoneNumber,
        address: address,
        aadharNumber: aadharNumber,
        aadharBytes: aadharBytes,
        aadharFileName: aadharFileName,
        panNumber: panNumber,
        panBytes: panBytes,
        panFileName: panFileName,
        bankName: bankName,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        accessDuration: accessDuration,
        profilePicBytes: profilePicBytes,
        profilePicFileName: profilePicFileName,
      );

      await _fetchOrganizers();
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update organizer details
  Future<bool> updateOrganizer(String uid, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateUser(uid, data);
      await _fetchOrganizers();
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _handleError(dynamic e) {
    return e.toString().contains('Exception:')
        ? e.toString().replaceAll('Exception: ', '')
        : 'An error occurred. Please try again.';
  }
}
