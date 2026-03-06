import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { owner, organizer, player }

abstract class AppUser {
  final String uid;
  final String email;
  final UserRole role;
  final String name;
  final DateTime createdAt;
  final bool isProfileComplete;
  final String? phoneNumber;
  final String? profilePic;
  final String? aadharNumber;
  final String? aadharPic;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.createdAt,
    this.isProfileComplete = false,
    this.phoneNumber,
    this.profilePic,
    this.aadharNumber,
    this.aadharPic,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    final roleStr = (map['role'] as String?)?.toUpperCase() ?? 'PLAYER';
    final role = UserRole.values.firstWhere(
      (e) => e.toString().split('.').last.toUpperCase() == roleStr,
      orElse: () => UserRole.player,
    );

    switch (role) {
      case UserRole.player:
        return Player.fromMap(map, id);
      case UserRole.organizer:
        return Organizer.fromMap(map, id);
      case UserRole.owner:
        return Owner.fromMap(map, id);
    }
  }

  Map<String, dynamic> toMap();
}

class Player extends AppUser {
  final DateTime? dateOfBirth;
  final String? gender;
  final String? emergencyContactNumber;
  final bool? hasHealthIssues;
  final String? healthIssueDetails;
  final String? playingPosition;
  final String? bloodGroup;

  Player({
    required super.uid,
    required super.email,
    required super.role,
    required super.name,
    required super.createdAt,
    super.isProfileComplete,
    super.phoneNumber,
    super.profilePic,
    super.aadharNumber,
    super.aadharPic,
    this.dateOfBirth,
    this.gender,
    this.emergencyContactNumber,
    this.hasHealthIssues,
    this.healthIssueDetails,
    this.playingPosition,
    this.bloodGroup,
  });

  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int calculatedAge = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      calculatedAge--;
    }
    return calculatedAge;
  }

  factory Player.fromMap(Map<String, dynamic> map, String id) {
    DateTime? dob;
    if (map['dateOfBirth'] != null) {
      if (map['dateOfBirth'] is Timestamp) {
        dob = (map['dateOfBirth'] as Timestamp).toDate();
      } else if (map['dateOfBirth'] is String) {
        dob = DateTime.tryParse(map['dateOfBirth']);
      }
    }

    return Player(
      uid: id,
      email: map['email'] ?? '',
      role: UserRole.player,
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
                ? (map['createdAt'] as Timestamp).toDate()
                : DateTime.parse(map['createdAt'].toString()))
          : DateTime.now(),
      isProfileComplete: map['isProfileComplete'] ?? false,
      phoneNumber: map['phoneNumber'],
      profilePic: map['profilePic'],
      aadharNumber: map['aadharNumber'],
      aadharPic: map['aadharPic'],
      dateOfBirth: dob,
      gender: map['gender'],
      emergencyContactNumber: map['emergencyContactNumber'],
      hasHealthIssues: map['hasHealthIssues'],
      healthIssueDetails: map['healthIssueDetails'],
      playingPosition: map['playingPosition'],
      bloodGroup: map['bloodGroup'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': 'PLAYER',
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isProfileComplete': isProfileComplete,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'aadharNumber': aadharNumber,
      'aadharPic': aadharPic,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      'gender': gender,
      'emergencyContactNumber': emergencyContactNumber,
      'hasHealthIssues': hasHealthIssues,
      'healthIssueDetails': healthIssueDetails,
      'playingPosition': playingPosition,
      'bloodGroup': bloodGroup,
    };
  }
}

class Organizer extends AppUser {
  final String? ownerId;
  final String? address;
  final String? panNumber;
  final String? panPic;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accessDuration;

  Organizer({
    required super.uid,
    required super.email,
    required super.role,
    required super.name,
    required super.createdAt,
    super.isProfileComplete,
    super.phoneNumber,
    super.profilePic,
    super.aadharNumber,
    super.aadharPic,
    this.ownerId,
    this.address,
    this.panNumber,
    this.panPic,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accessDuration,
  });

  factory Organizer.fromMap(Map<String, dynamic> map, String id) {
    return Organizer(
      uid: id,
      email: map['email'] ?? '',
      role: UserRole.organizer,
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isProfileComplete: map['isProfileComplete'] ?? false,
      phoneNumber: map['phoneNumber'],
      profilePic: map['profilePic'],
      aadharNumber: map['aadharNumber'],
      aadharPic: map['aadharPic'],
      ownerId: map['ownerId'],
      address: map['address'],
      panNumber: map['panNumber'],
      panPic: map['panPic'],
      bankName: map['bankName'],
      accountNumber: map['accountNumber'],
      ifscCode: map['ifscCode'],
      accessDuration: map['accessDuration'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': 'ORGANIZER',
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isProfileComplete': isProfileComplete,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'aadharNumber': aadharNumber,
      'aadharPic': aadharPic,
      'ownerId': ownerId,
      'address': address,
      'panNumber': panNumber,
      'panPic': panPic,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'accessDuration': accessDuration,
    };
  }
}

class Owner extends AppUser {
  final String? panNumber;
  final String? panPic;

  Owner({
    required super.uid,
    required super.email,
    required super.role,
    required super.name,
    required super.createdAt,
    super.isProfileComplete,
    super.phoneNumber,
    super.profilePic,
    super.aadharNumber,
    super.aadharPic,
    this.panNumber,
    this.panPic,
  });

  factory Owner.fromMap(Map<String, dynamic> map, String id) {
    return Owner(
      uid: id,
      email: map['email'] ?? '',
      role: UserRole.owner,
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isProfileComplete: map['isProfileComplete'] ?? false,
      phoneNumber: map['phoneNumber'],
      profilePic: map['profilePic'],
      aadharNumber: map['aadharNumber'],
      aadharPic: map['aadharPic'],
      panNumber: map['panNumber'],
      panPic: map['panPic'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': 'OWNER',
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isProfileComplete': isProfileComplete,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'aadharNumber': aadharNumber,
      'aadharPic': aadharPic,
      'panNumber': panNumber,
      'panPic': panPic,
    };
  }
}

class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime date;
  final String location;
  final String bannerUrl;
  final String organizerId;
  final String createdBy; // Owner UID
  final String status; // OPEN, CLOSED, CANCELLED

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.bannerUrl,
    required this.organizerId,
    required this.createdBy,
    required this.status,
  });

  factory Tournament.fromMap(Map<String, dynamic> map, String id) {
    return Tournament(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      location: map['location'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      organizerId: map['organizerId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'OPEN',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'bannerUrl': bannerUrl,
      'organizerId': organizerId,
      'createdBy': createdBy,
      'status': status,
    };
  }
}

class Registration {
  final String id;
  final String tournamentId;
  final String playerUid;
  final String playerName;
  final String playerEmail;
  final DateTime registrationDate;
  final String status; // PENDING, CONFIRMED, CANCELLED
  final String ownerId;

  Registration({
    required this.id,
    required this.tournamentId,
    required this.playerUid,
    required this.playerName,
    required this.playerEmail,
    required this.registrationDate,
    required this.status,
    required this.ownerId,
  });

  factory Registration.fromMap(Map<String, dynamic> map, String id) {
    return Registration(
      id: id,
      tournamentId: map['tournamentId'] ?? '',
      playerUid: map['playerUid'] ?? '',
      playerName: map['playerName'] ?? '',
      playerEmail: map['playerEmail'] ?? '',
      registrationDate: map['registrationDate'] != null
          ? (map['registrationDate'] as Timestamp).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'PENDING',
      ownerId: map['ownerId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'playerUid': playerUid,
      'playerName': playerName,
      'playerEmail': playerEmail,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'status': status,
      'ownerId': ownerId,
    };
  }
}
