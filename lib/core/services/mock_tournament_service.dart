import 'package:force_player_register_app/core/models/models.dart';
import 'dart:async';

class MockTournamentService {
  final List<Tournament> _mockTournaments = [
    Tournament(
      id: 'tour_1',
      name: 'Summer Football Bash',
      location: 'Mumbai Sports Arena',
      description: 'The biggest summer tournament in Mumbai.',
      sportType: 'Football',
      type: TournamentType.normal,
      entryFormat: EntryFormat.solo,
      entryFee: 500,
      prizePool: 10000,
      rules: ['Rule 1', 'Rule 2'],
      terms: 'Standard Terms',
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
      sportType: 'Cricket',
      type: TournamentType.teamBased,
      entryFormat: EntryFormat.team,
      entryFee: 2000,
      prizePool: 50000,
      rules: ['Rule 1', 'Rule 2'],
      terms: 'Standard Terms',
      date: DateTime.now().add(const Duration(days: 20)),
      bannerUrl: '',
      organizerId: '',
      createdBy: 'owner_123',
      status: 'OPEN',
      playersPerTeam: 11,
      maxTeams: 16,
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
      sportType: tournament.sportType,
      type: tournament.type,
      entryFormat: tournament.entryFormat,
      entryFee: tournament.entryFee,
      prizePool: tournament.prizePool,
      rules: tournament.rules,
      terms: tournament.terms,
      date: tournament.date,
      endDate: tournament.endDate,
      registrationDeadline: tournament.registrationDeadline,
      organizerAccessExpiry: tournament.organizerAccessExpiry,
      bannerUrl: tournament.bannerUrl,
      organizerId: tournament.organizerId,
      createdBy: tournament.createdBy,
      status: tournament.status,
      enableScoring: tournament.enableScoring,
      playersPerTeam: tournament.playersPerTeam,
      maxTeams: tournament.maxTeams,
      maxParticipants: tournament.maxParticipants,
      allowTeamOverflow: tournament.allowTeamOverflow,
    );
    _mockTournaments.add(newTour);
    _tournamentsController.add(List.from(_mockTournaments));
  }

  Future<void> assignOrganizer(String tournamentId, String organizerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockTournaments.indexWhere((t) => t.id == tournamentId);
    if (index != -1) {
      final t = _mockTournaments[index];
      _mockTournaments[index] = Tournament(
        id: t.id,
        name: t.name,
        location: t.location,
        description: t.description,
        sportType: t.sportType,
        type: t.type,
        entryFormat: t.entryFormat,
        entryFee: t.entryFee,
        prizePool: t.prizePool,
        rules: t.rules,
        terms: t.terms,
        date: t.date,
        endDate: t.endDate,
        registrationDeadline: t.registrationDeadline,
        organizerAccessExpiry: t.organizerAccessExpiry,
        bannerUrl: t.bannerUrl,
        organizerId: organizerId,
        createdBy: t.createdBy,
        status: t.status,
        enableScoring: t.enableScoring,
        playersPerTeam: t.playersPerTeam,
        maxTeams: t.maxTeams,
        maxParticipants: t.maxParticipants,
        allowTeamOverflow: t.allowTeamOverflow,
      );
      _tournamentsController.add(List.from(_mockTournaments));
    }
  }

  Future<void> updateTournament(Tournament tournament) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockTournaments.indexWhere((t) => t.id == tournament.id);
    if (index != -1) {
      _mockTournaments[index] = tournament;
      _tournamentsController.add(List.from(_mockTournaments));
    }
  }
}
