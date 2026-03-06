import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/models.dart';

class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream of all tournaments
  Stream<List<Tournament>> get tournaments {
    return _firestore
        .collection('tournaments')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Tournament.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Stream of tournaments assigned to a specific organizer
  Stream<List<Tournament>> getOrganizerTournaments(String organizerId) {
    return _firestore
        .collection('tournaments')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Tournament.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Create a new tournament
  Future<void> createTournament(Tournament tournament) async {
    await _firestore.collection('tournaments').add(tournament.toMap());
  }

  // Update tournament details
  Future<void> updateTournament(Tournament tournament) async {
    await _firestore
        .collection('tournaments')
        .doc(tournament.id)
        .update(tournament.toMap());
  }

  // Assign tournament to organizer
  Future<void> assignOrganizer(String tournamentId, String organizerId) async {
    await _firestore.collection('tournaments').doc(tournamentId).update({
      'organizerId': organizerId,
    });
  }

  // Register a player for a tournament
  Future<void> registerPlayer(Registration registration) async {
    await _firestore.collection('registrations').add(registration.toMap());
  }

  // Stream of registrations for a specific tournament
  Stream<List<Registration>> getRegistrations(String tournamentId) {
    return _firestore
        .collection('registrations')
        .where('tournamentId', isEqualTo: tournamentId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Registration.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Upload tournament banner to Firebase Storage
  Future<String> uploadBanner(dynamic fileBytes, String fileName) async {
    final ref = _storage.ref().child('banners/$fileName');
    final uploadTask = ref.putData(fileBytes);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }
}
