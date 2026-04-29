/// Enum per i ruoli utente
enum AccountRole {
  player,
  coordinator,
  referee,
  organization,
  admin,
  guest;

  String get displayName {
    switch (this) {
      case AccountRole.player:
        return 'Player';
      case AccountRole.coordinator:
        return 'Coordinator';
      case AccountRole.referee:
        return 'Referee';
      case AccountRole.organization:
        return 'Organization';
      case AccountRole.admin:
        return 'Admin';
      case AccountRole.guest:
        return 'Guest';
    }
  }

  String get apiValue {
    switch (this) {
      case AccountRole.player:
        return 'PLAYER';
      case AccountRole.coordinator:
        return 'COORDINATOR';
      case AccountRole.referee:
        return 'REFEREE';
      case AccountRole.organization:
        return 'ORGANIZATION';
      case AccountRole.guest:
        return 'GUEST';
      case AccountRole.admin:
        return 'ADMIN';
    }
  }
}

enum VipType {
  none,
  monthly,
  yearly;

  String get apiName {
    switch (this) {
      case VipType.none:
        return 'NONE';
      case VipType.monthly:
        return 'MONTHLY';
      case VipType.yearly:
        return 'YEARLY';
    }
  }
}

enum AccountStatus { active, inactive, deleted }

// OK
/// Modello astratto Account dal database
class Account {
  final double id;
  final String username;
  final String name;
  final String surname;
  final String email;
  final String phone;
  final String? imageUrl;
  final AccountRole role;
  final DateTime birthdate;
  final bool vip;
  final VipType vipType;
  final DateTime? startVip;
  final DateTime? endVip;
  final double? preferredCityId;

  Account({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone,
    required this.name,
    required this.surname,
    required this.birthdate,
    required this.vip,
    required this.vipType,
    required this.startVip,
    required this.endVip,
    required this.preferredCityId,
    required this.imageUrl,
  });

  /// Factory per creare l'istanza corretta in base al ruolo
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: AccountRole.values.firstWhere((e) => e.apiValue == json['role']),
      phone: json['phone'],
      name: json['name'],
      surname: json['surname'],
      birthdate: DateTime.parse(json['birthdate']),
      vip: json['vip'],
      vipType: VipType.values.firstWhere((e) => e.apiName == json['vipType']),
      startVip: json['startVip'] != null
          ? DateTime.parse(json['startVip'])
          : null,
      endVip: json['endVip'] != null ? DateTime.parse(json['endVip']) : null,
      preferredCityId: json['preferredCityId'] != null
          ? (json['preferredCityId'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role.apiValue,
      'vip': vip,
      'phone': phone,
      'imageUrl': imageUrl,
      'name': name,
      'surname': surname,
      'birthdate': birthdate.toIso8601String(),
      'startVip': startVip?.toIso8601String(),
      'endVip': endVip?.toIso8601String(),
      'vipType': vipType.apiName,
      'preferredCityId': preferredCityId,
    };
  }

  /// Nome visualizzato del ruolo
  String get roleDisplayName => role.displayName;

  bool get isGuest => role == AccountRole.guest;
  bool get isPlayer => role == AccountRole.player;
  bool get isCoordinator => role == AccountRole.coordinator;
  bool get isReferee => role == AccountRole.referee;
  bool get isOrganization => role == AccountRole.organization;
}
