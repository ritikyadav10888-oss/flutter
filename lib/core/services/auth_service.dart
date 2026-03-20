import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../constants/api_constants.dart';
import '../models/models.dart';

class AuthService {
  static const String baseUrl = ApiConstants.baseUrl;
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '538870113377-3sd94fguge6f9n2nam5smsq4tmcfj5no.apps.googleusercontent.com',
  );

  // Stream of current user (using periodic polling or just current state for now)
  Stream<AppUser?> get user async* {
    final token = await _storage.read(key: 'jwt');
    if (token == null) {
      yield null;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        yield AppUser.fromMap(data, data['id']);
      } else {
        yield null;
      }
    } catch (e) {
      yield null;
    }
  }

  // Google Sign-In
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('Google ID Token not found');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'jwt', value: data['token']);
        return AppUser.fromMap({...data['user'], 'profile': data['profile']}, data['user']['id']);
      } else {
        final error = json.decode(response.body);
        final msg = error['error'] ?? 'Google Sign-In failed';
        final details = error['details'] != null ? '\nDetails: ${error['details']}' : '';
        throw Exception('$msg$details');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'jwt', value: data['token']);
        return AppUser.fromMap({...data['user'], 'profile': data['profile']}, data['user']['id']);
      } else {
        final error = json.decode(response.body);
        final msg = error['error'] ?? 'Login failed';
        final details = error['details'] != null ? '\nDetails: ${error['details']}' : '';
        throw Exception('$msg$details');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Register or Add Player Role
  Future<AppUser?> registerPlayer({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'role': role
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'jwt', value: data['token']);
        return AppUser.fromMap({...data['user'], 'profile': data['profile']}, data['user']['id']);
      } else {
        final error = json.decode(response.body);
        final msg = error['error'] ?? 'Registration failed';
        final details = error['details'] != null ? '\nDetails: ${error['details']}' : '';
        throw Exception('$msg$details');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all organizers for an owner
  Future<List<AppUser>> getOrganizers() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/organizers'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((u) => AppUser.fromMap(u, u['id'])).toList();
      } else {
        throw Exception('Failed to fetch organizers');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get all players (for owner)
  Future<List<AppUser>> getPlayers() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/auth/players'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((u) => AppUser.fromMap(u, u['id'])).toList();
      } else {
        throw Exception('Failed to fetch players');
      }
    } catch (e) {
      return [];
    }
  }

  // Update player profile
  Future<void> updatePlayerProfile(String uid, Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/users/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Update failed');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createOrganizer({
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
    try {
      final token = await getToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/create-organizer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'ownerId': ownerId,
          'phoneNumber': phoneNumber,
          'address': address,
          'aadharNumber': aadharNumber,
          'panNumber': panNumber,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'ifscCode': ifscCode,
          'accessDuration': accessDuration,
          'profilePic': profilePicFileName,
          'aadharPic': aadharFileName,
          'panPic': panFileName,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to create organizer');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Update user data
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      final token = await getToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/auth/users/$uid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update user');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _storage.delete(key: 'jwt');
  }

  // Get token helper
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }
}
