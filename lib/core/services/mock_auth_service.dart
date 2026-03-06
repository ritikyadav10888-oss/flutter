import 'package:force_player_register_app/core/models/models.dart';
import 'dart:async';

class MockAuthService {
  late final StreamController<AppUser?> _userController =
      StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;

  Stream<AppUser?> get user => _userController.stream;

  MockAuthService() {
    // Initial state: not logged in
    _userController.add(null);
  }

  Future<AppUser?> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    // Demo Owner
    if (email == 'admin@force.com') {
      _currentUser = AppUser(
        uid: 'owner_123',
        name: 'Super Owner',
        email: 'admin@force.com',
        role: UserRole.owner,
        createdAt: DateTime.now(),
      );
    }
    // Demo Organizer
    else if (email == 'organizer@force.com') {
      _currentUser = AppUser(
        uid: 'org_123',
        name: 'Tournament Pro',
        email: 'organizer@force.com',
        role: UserRole.organizer,
        createdAt: DateTime.now(),
      );
    }
    // Demo Player
    else {
      _currentUser = AppUser(
        uid: 'player_123',
        name: 'Guest Player',
        email: email,
        role: UserRole.player,
        createdAt: DateTime.now(),
      );
    }

    _userController.add(_currentUser);
    return _currentUser;
  }

  Future<AppUser?> registerPlayer({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = AppUser(
      uid: 'new_player_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      role: UserRole.player,
      createdAt: DateTime.now(),
    );
    _userController.add(_currentUser);
    return _currentUser;
  }

  Future<void> createOrganizer({
    required String email,
    required String password,
    required String name,
    required String ownerId,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // In mock mode, we just simulate success
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
  }
}
