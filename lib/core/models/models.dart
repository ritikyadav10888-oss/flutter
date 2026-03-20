// cloud_firestore import removed

enum UserRole { owner, organizer, player }

class AppUser {
  final String uid;
  final String email;
  final List<UserRole> roles;
  final UserRole activeRole;
  final String name;
  final DateTime createdAt;
  final bool isProfileComplete;
  final String? phoneNumber;
  final String? profilePic;
  final String? aadharNumber;
  final String? aadharPic;

  // Role-specific fields consolidated
  // Player fields
  final DateTime? dateOfBirth;
  final String? gender;
  final String? emergencyContactNumber;
  final bool? hasHealthIssues;
  final String? healthIssueDetails;
  final String? playingPosition;
  final String? bloodGroup;

  // Organizer fields
  final String? ownerId;
  final String? address;
  final String? panNumber;
  final String? panPic;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accessDuration;

  AppUser({
    required this.uid,
    required this.email,
    required this.roles,
    required this.activeRole,
    required this.name,
    required this.createdAt,
    this.isProfileComplete = false,
    this.phoneNumber,
    this.profilePic,
    this.aadharNumber,
    this.aadharPic,
    this.dateOfBirth,
    this.gender,
    this.emergencyContactNumber,
    this.hasHealthIssues,
    this.healthIssueDetails,
    this.playingPosition,
    this.bloodGroup,
    this.ownerId,
    this.address,
    this.panNumber,
    this.panPic,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accessDuration,
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

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    // Parse roles
    final rolesList =
        (map['roles'] as List<dynamic>?)
            ?.map(
              (r) => UserRole.values.firstWhere(
                (e) => e.name.toUpperCase() == r.toString().toUpperCase(),
                orElse: () => UserRole.player,
              ),
            )
            .toList() ??
        [];

    // Fallback for legacy 'role' field
    if (rolesList.isEmpty && map['role'] != null) {
      final legacyRole = UserRole.values.firstWhere(
        (e) => e.name.toUpperCase() == map['role'].toString().toUpperCase(),
        orElse: () => UserRole.player,
      );
      rolesList.add(legacyRole);
    }

    if (rolesList.isEmpty) rolesList.add(UserRole.player);

    // Active Role
    final activeRoleStr = (map['activeRole'] as String? ?? map['active_role'] as String?)?.toLowerCase();
    final activeRole = UserRole.values.firstWhere(
      (e) => e.name == activeRoleStr,
      orElse: () => rolesList.first,
    );

    // Profiles
    final profile = map['profile'] as Map<String, dynamic>?;

    DateTime? dob;
    if (profile?['date_of_birth'] != null || map['dateOfBirth'] != null) {
      final dobValue = profile?['date_of_birth'] ?? map['dateOfBirth'];
      if (dobValue is String) {
        dob = DateTime.tryParse(dobValue);
      }
    }

    return AppUser(
      uid: id,
      email: map['email'] ?? '',
      roles: rolesList,
      activeRole: activeRole,
      name: map['name'] ?? '',
      createdAt: map['createdAt'] != null
          ? (DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : (map['created_at'] != null 
                ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
                : DateTime.now()),
      isProfileComplete: profile?['is_profile_complete'] ?? map['is_profile_complete'] ?? map['isProfileComplete'] ?? false,
      phoneNumber: profile?['phone_number'] ?? map['phone_number'] ?? map['phoneNumber'],
      profilePic: profile?['profile_pic'] ?? map['profile_pic'] ?? map['profilePic'],
      aadharNumber: profile?['aadhar_number'] ?? map['aadhar_number'] ?? map['aadharNumber'],
      aadharPic: profile?['aadhar_pic'] ?? map['aadhar_pic'] ?? map['aadharPic'],
      dateOfBirth: dob,
      gender: profile?['gender'] ?? map['gender'],
      emergencyContactNumber: profile?['emergency_contact_number'] ?? map['emergency_contact_number'] ?? map['emergencyContactNumber'],
      hasHealthIssues: profile?['has_health_issues'] ?? map['has_health_issues'] ?? map['hasHealthIssues'],
      healthIssueDetails: profile?['health_issue_details'] ?? map['health_issue_details'] ?? map['healthIssueDetails'],
      playingPosition: profile?['playing_position'] ?? map['playing_position'] ?? map['playingPosition'],
      bloodGroup: profile?['blood_group'] ?? map['blood_group'] ?? map['bloodGroup'],
      ownerId: profile?['owner_id'] ?? map['owner_id'] ?? map['ownerId'],
      address: profile?['address'] ?? map['address'],
      panNumber: profile?['pan_number'] ?? map['pan_number'] ?? map['panNumber'],
      panPic: profile?['pan_pic'] ?? map['pan_pic'] ?? map['panPic'],
      bankName: profile?['bank_name'] ?? map['bank_name'] ?? map['bankName'],
      accountNumber: profile?['account_number'] ?? map['account_number'] ?? map['accountNumber'],
      ifscCode: profile?['ifsc_code'] ?? map['ifsc_code'] ?? map['ifscCode'],
      accessDuration: profile?['access_duration'] ?? map['access_duration'] ?? map['accessDuration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'roles': roles.map((r) => r.name.toUpperCase()).toList(),
      'activeRole': activeRole.name,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'isProfileComplete': isProfileComplete,
      'phoneNumber': phoneNumber,
      'profilePic': profilePic,
      'aadharNumber': aadharNumber,
      'aadharPic': aadharPic,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      'gender': gender,
      'emergencyContactNumber': emergencyContactNumber,
      'hasHealthIssues': hasHealthIssues,
      'healthIssueDetails': healthIssueDetails,
      'playingPosition': playingPosition,
      'bloodGroup': bloodGroup,
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

  AppUser copyWith({UserRole? activeRole, List<UserRole>? roles}) {
    return AppUser(
      uid: uid,
      email: email,
      roles: roles ?? this.roles,
      activeRole: activeRole ?? this.activeRole,
      name: name,
      createdAt: createdAt,
      isProfileComplete: isProfileComplete,
      phoneNumber: phoneNumber,
      profilePic: profilePic,
      aadharNumber: aadharNumber,
      aadharPic: aadharPic,
      dateOfBirth: dateOfBirth,
      gender: gender,
      emergencyContactNumber: emergencyContactNumber,
      hasHealthIssues: hasHealthIssues,
      healthIssueDetails: healthIssueDetails,
      playingPosition: playingPosition,
      bloodGroup: bloodGroup,
      ownerId: ownerId,
      address: address,
      panNumber: panNumber,
      panPic: panPic,
      bankName: bankName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      accessDuration: accessDuration,
    );
  }
}

enum TournamentType { normal, teamBased, auctionBased }

enum EntryFormat { solo, duo, team, auctionPoolSolo }

class Tournament {
  final String id;
  final String name;
  final String description;
  final String sportType;
  final TournamentType type;
  final EntryFormat entryFormat;
  final double entryFee;
  final double prizePool;
  final List<String> rules;
  final String terms;
  final DateTime date; // Keep for backward compatibility or as Start Date
  final DateTime? endDate;
  final DateTime? registrationDeadline;
  final DateTime? organizerAccessExpiry;
  final String location;
  final String bannerUrl;
  final String organizerId;
  final String createdBy; // Owner UID
  final String status; // OPEN, CLOSED, CANCELLED
  final bool enableScoring;
  final int? playersPerTeam;
  final int? maxTeams;
  final int? maxParticipants;
  final bool allowTeamOverflow;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.sportType,
    required this.type,
    required this.entryFormat,
    required this.entryFee,
    required this.prizePool,
    required this.rules,
    required this.terms,
    required this.date,
    this.endDate,
    this.registrationDeadline,
    this.organizerAccessExpiry,
    required this.location,
    required this.bannerUrl,
    required this.organizerId,
    required this.createdBy,
    required this.status,
    this.enableScoring = false,
    this.playersPerTeam,
    this.maxTeams,
    this.maxParticipants,
    this.allowTeamOverflow = false,
  });

  factory Tournament.fromMap(Map<String, dynamic> map, String id) {
    return Tournament(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sportType: map['sportType'] ?? 'Other',
      type: TournamentType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'normal'),
        orElse: () => TournamentType.normal,
      ),
      entryFormat: EntryFormat.values.firstWhere(
        (e) => e.name == (map['entryFormat'] ?? 'solo'),
        orElse: () => EntryFormat.solo,
      ),
      entryFee: (map['entryFee'] ?? 0.0).toDouble(),
      prizePool: (map['prizePool'] ?? 0.0).toDouble(),
      rules: List<String>.from(map['rules'] ?? []),
      terms: map['terms'] ?? '',
      date: map['date'] != null
          ? (DateTime.tryParse(map['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      endDate: map['endDate'] != null
          ? (DateTime.tryParse(map['endDate'].toString()))
          : null,
      registrationDeadline: map['registrationDeadline'] != null
          ? (DateTime.tryParse(map['registrationDeadline'].toString()))
          : null,
      organizerAccessExpiry: map['organizerAccessExpiry'] != null
          ? (DateTime.tryParse(map['organizerAccessExpiry'].toString()))
          : null,
      location: map['location'] ?? '',
      bannerUrl: map['bannerUrl'] ?? '',
      organizerId: map['organizerId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      status: map['status'] ?? 'OPEN',
      enableScoring: map['enableScoring'] ?? false,
      playersPerTeam: map['playersPerTeam'],
      maxTeams: map['maxTeams'],
      maxParticipants: map['maxParticipants'],
      allowTeamOverflow: map['allowTeamOverflow'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'sportType': sportType,
      'type': type.name,
      'entryFormat': entryFormat.name,
      'entryFee': entryFee,
      'prizePool': prizePool,
      'rules': rules,
      'terms': terms,
      'date': date.toIso8601String(),
      if (endDate != null) 'endDate': endDate!.toIso8601String(),
      if (registrationDeadline != null)
        'registrationDeadline': registrationDeadline!.toIso8601String(),
      if (organizerAccessExpiry != null)
        'organizerAccessExpiry': organizerAccessExpiry!.toIso8601String(),
      'location': location,
      'bannerUrl': bannerUrl,
      'organizerId': organizerId,
      'createdBy': createdBy,
      'status': status,
      'enableScoring': enableScoring,
      if (playersPerTeam != null) 'playersPerTeam': playersPerTeam,
      if (maxTeams != null) 'maxTeams': maxTeams,
      if (maxParticipants != null) 'maxParticipants': maxParticipants,
      'allowTeamOverflow': allowTeamOverflow,
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
          ? (DateTime.tryParse(map['registrationDate'].toString()) ?? DateTime.now())
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
      'registrationDate': registrationDate.toIso8601String(),
      'status': status,
      'ownerId': ownerId,
    };
  }
}
