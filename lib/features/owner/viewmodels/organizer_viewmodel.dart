import 'dart:async';
import 'package:flutter/material.dart';
import 'package:force_player_register_app/core/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:force_player_register_app/core/models/models.dart';
import 'dart:typed_data';

class OrganizerViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OrganizerViewModel();

  List<AppUser> _organizers = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _organizerSubscription;

  List<AppUser> get organizers => _organizers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Listen to organizers created by the current owner in real-time
  void startListening(String ownerId) {
    _organizerSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _organizerSubscription = _firestore
        .collection('users')
        .where(
          'role',
          isEqualTo: 'ORGANIZER',
        ) // Filter by role from AppUser.toMap
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .listen(
          (snapshot) {
            _organizers = snapshot.docs
                .map((doc) => AppUser.fromMap(doc.data(), doc.id))
                .toList();
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _organizerSubscription?.cancel();
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

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update organizer details (Owner Only)
  Future<bool> updateOrganizer(String uid, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(uid).update(data);

      // Update local list
      final index = _organizers.indexWhere((o) => o.uid == uid);
      if (index != -1) {
        _organizers[index] = AppUser.fromMap({
          ..._organizers[index].toMap(),
          ...data,
        }, uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
