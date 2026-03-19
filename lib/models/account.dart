// Import necessari per il factory
import 'player.dart';
import 'coordinator.dart';
import 'referee.dart';
import 'organization.dart';

/// Enum per i ruoli utente
enum AccountRole {
  player,
  coordinator,
  referee,
  organization,
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
      case AccountRole.guest:
        return 'Guest';
    }
  }
}

enum VipType { none, monthly, yearly }

enum AccountStatus { active, inactive, deleted }

/// Modello astratto Account dal database
class Account {
  final int id;
  String username;
  int? preferredCityId;
  String email;
  String firebaseUid;
  final DateTime createdAt;
  String? stripeId;
  final AccountRole role;
  String phone;
  String? passwordMD5;
  String? imageUrl;
  final String name;
  String surname;
  final DateTime birthdate;
  bool isVip;
  DateTime? startVip;
  DateTime? endVip;
  VipType vipType;
  AccountStatus status;

  Account({
    required this.id,
    required this.username,
    required this.email,
    required this.firebaseUid,
    required this.createdAt,
    this.stripeId,
    required this.role,
    this.isVip = false,
    required this.phone,
    this.passwordMD5,
    this.imageUrl,
    required this.name,
    required this.surname,
    required this.birthdate,
    this.startVip,
    this.endVip,
    this.vipType = VipType.none,
    this.status = AccountStatus.active,
    this.preferredCityId = 1,
  });

  /// Factory per creare l'istanza corretta in base al ruolo
  factory Account.fromJson(Map<String, dynamic> json) {
    final role = _roleFromString(json['role']);

    switch (role) {
      case AccountRole.player:
        return Player.fromJson(json);
      case AccountRole.coordinator:
        return Coordinator.fromJson(json);
      case AccountRole.referee:
        return Referee.fromJson(json);
      case AccountRole.organization:
        return Organization.fromJson(json);
      case AccountRole.guest:
        return throw Exception('Guest role cannot be instantiated from JSON');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firebaseUid': firebaseUid,
      'createdAt': createdAt.toIso8601String(),
      'stripeId': stripeId,
      'role': role.name.toUpperCase(),
      'vip': isVip,
      'phone': phone,
      'passwordMd5': passwordMD5,
      'imageUrl': imageUrl,
      'name': name,
      'surname': surname,
      'birthdate': birthdate.toIso8601String(),
      'startVip': startVip?.toIso8601String(),
      'endVip': endVip?.toIso8601String(),
      'vipType': vipType.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'preferredCityId': preferredCityId,
    };
  }

  /// Nome visualizzato del ruolo
  String get roleDisplayName => role.displayName;

  static AccountRole _roleFromString(String role) {
    switch (role.toUpperCase()) {
      case 'PLAYER':
        return AccountRole.player;
      case 'COORDINATOR':
        return AccountRole.coordinator;
      case 'REFEREE':
        return AccountRole.referee;
      case 'ORGANIZATION':
        return AccountRole.organization;
      default:
        throw Exception('Unknown role: $role');
    }
  }

  Account copyWith({
    int? id,
    String? username,
    String? email,
    String? firebaseUid,
    DateTime? createdAt,
    double? balance,
    DateTime? lastWithdraw,
    String? stripeId,
    AccountRole? role,
    bool? isVip,
    String? phone,
    String? passwordMD5,
    String? imageUrl,
    int? teamId,
    DateTime? birthdate,
    String? name,
    String? surname,
    DateTime? startVip,
    DateTime? endVip,
    VipType? vipType,
    AccountStatus? status,
    int? preferredCityId,
  }) {
    return Account(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      createdAt: createdAt ?? this.createdAt,
      stripeId: stripeId ?? this.stripeId,
      role: role ?? this.role,
      isVip: isVip ?? this.isVip,
      phone: phone ?? this.phone,
      passwordMD5: passwordMD5 ?? this.passwordMD5,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      birthdate: birthdate ?? this.birthdate,
      startVip: startVip ?? this.startVip,
      endVip: endVip ?? this.endVip,
      vipType: vipType ?? this.vipType,
      status: status ?? this.status,
      preferredCityId: preferredCityId ?? this.preferredCityId,
    );
  }

  bool get isGuest => role == AccountRole.guest;
  bool get isPlayer => role == AccountRole.player;
  bool get isCoordinator => role == AccountRole.coordinator;
  bool get isReferee => role == AccountRole.referee;
  bool get isOrganization => role == AccountRole.organization;
}
