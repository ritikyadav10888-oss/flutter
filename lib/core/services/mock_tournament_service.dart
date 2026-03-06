import 'package:force_player_register_app/core/models/models.dart';
import 'dart:async';

class MockTournamentService {
  final List<Tournament> _mockTournaments = [
    Tournament(
      id: 'tour_1',
      name: 'Summer Football Bash',
      location: 'Mumbai Sports Arena',
      description: 'The biggest summer tournament in Mumbai.',
      date: DateTime.now().add(const Duration(days: 10)),
      bannerUrl: '',
      organizerId: 'org_123',
      createdBy: 'owner_123',
      status: 'OPEN',
    ),
    Tournament(
      id: 'tour_2',
      name: 'Corporate Cricket League',
      location: 'Delhi Stadium',
      description: 'Compete for the corporate trophy!',
      date: DateTime.now().add(const Duration(days: 20)),
      bannerUrl: '',
      organizerId: '',
      createdBy: 'owner_123',
      status: 'OPEN',
    ),
  ];

  late final StreamController<List<Tournament>> _tournamentsController =
      StreamController<List<Tournament>>.broadcast();

  Stream<List<Tournament>> get tournaments {
    _tournamentsController.add(_mockTournaments);
    return _tournamentsController.stream;
  }

  Future<void> createTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newTour = Tournament(
      id: 'tour_${DateTime.now().millisecondsSinceEpoch}',
      name: tournament.name,
      location: tournament.location,
      description: tournament.description,
      date: tournament.date,
      bannerUrl: tournament.bannerUrl,
      organizerId: tournament.organizerId,
      createdBy: tournament.createdBy,
      status: tournament.status,
    );
    _mockTournaments.add(newTour);
    _tournamentsController.add(List.from(_mockTournaments));
  }

  Future<void> assignOrganizer(String tournamentId, String organizerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockTournaments.indexWhere((t) => t.id == tournamentId);
    if (index != -1) {
      _mockTournaments[index] = Tournament(
        id: _mockTournaments[index].id,
        name: _mockTournaments[index].name,
        location: _mockTournaments[index].location,
        description: _mockTournaments[index].description,
        date: _mockTournaments[index].date,
        bannerUrl: _mockTournaments[index].bannerUrl,
        organizerId: organizerId,
        createdBy: _mockTournaments[index].createdBy,
        status: _mockTournaments[index].status,
      );
      _tournamentsController.add(List.from(_mockTournaments));
    }
  }

  // Implementation of update, delete etc. would be similar
  Future<void> updateTournament(Tournament tournament) async {}
}
