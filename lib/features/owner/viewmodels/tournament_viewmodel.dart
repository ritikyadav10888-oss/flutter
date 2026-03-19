import 'package:flutter/material.dart';
import 'package:force_player_register_app/core/services/tournament_service.dart';
import 'package:force_player_register_app/core/models/models.dart';

class TournamentViewModel extends ChangeNotifier {
  final TournamentService _tournamentService = TournamentService();

  List<Tournament> _tournaments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Tournament> get tournaments => _tournaments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TournamentViewModel() {
    _fetchTournaments();
  }

  void _fetchTournaments() {
    _isLoading = true;
    notifyListeners();

    _tournamentService.tournaments.listen(
      (list) {
        _tournaments = list;
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

  Future<bool> createTournament(Tournament tournament) async {
    try {
      await _tournamentService.createTournament(tournament);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTournament(String tournamentId, Map<String, dynamic> updates) async {
    try {
      await _tournamentService.updateTournament(tournamentId, updates);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignOrganizer(String tournamentId, String organizerId) async {
    try {
      await _tournamentService.assignOrganizer(tournamentId, organizerId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
