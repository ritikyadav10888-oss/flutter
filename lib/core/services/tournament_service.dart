import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'auth_service.dart';

class TournamentService {
  static const String baseUrl = 'https://force-sports-backend.onrender.com/api';
  final AuthService _authService = AuthService();

  // Stream of all tournaments (polling implementation)
  Stream<List<Tournament>> get tournaments async* {
    while (true) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/tournaments'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          yield data.map((t) => Tournament.fromMap(t, t['id'])).toList();
        }
      } catch (e) {
        // Silently fail or log
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  // Get tournaments for a specific organizer
  Stream<List<Tournament>> getOrganizerTournaments(String organizerId) async* {
    while (true) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/tournaments/organizer/$organizerId'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          yield data.map((t) => Tournament.fromMap(t, t['id'])).toList();
        }
      } catch (e) {
        // Silently fail
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }

  // Create a new tournament
  Future<void> createTournament(Tournament tournament) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/tournaments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(tournament.toMap()),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to create tournament');
    }
  }

  // Register a player for a tournament
  Future<void> registerPlayer(Registration registration) async {
    final token = await _authService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/registrations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(registration.toMap()),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  }

  // Update a tournament
  Future<void> updateTournament(String tournamentId, Map<String, dynamic> updates) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/tournaments/$tournamentId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(updates),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to update tournament');
    }
  }

  // Assign an organizer to a tournament
  Future<void> assignOrganizer(String tournamentId, String organizerId) async {
    final token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/tournaments/$tournamentId/assign-organizer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'organizerId': organizerId}),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to assign organizer');
    }
  }

  // Get registrations for a specific tournament
  Stream<List<Registration>> getRegistrations(String tournamentId) async* {
    while (true) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/registrations/tournament/$tournamentId'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          yield data.map((r) => Registration.fromMap(r, r['id'])).toList();
        }
      } catch (e) {
        // Silently fail
      }
      await Future.delayed(const Duration(seconds: 30));
    }
  }
}
