// Import necessari per il factory
import 'player.dart';
import 'coordinator.dart';
import 'referee.dart';
import 'organization.dart';

/// Enum per i ruoli utente
enum UserRole {
  player,
  coordinator,
  referee,
  organization,
  guest;

  String get displayName {
    switch (this) {
      case UserRole.player:
        return 'Player';
      case UserRole.coordinator:
        return 'Coordinator';
      case UserRole.referee:
        return 'Referee';
      case UserRole.organization:
        return 'Organization';
      case UserRole.guest:
        return 'Guest';
    }
  }
}

enum VipType { none, monthly, yearly }

enum UserStatus { active, inactive, deleted }

/// Modello astratto User dal database
class User {
  final int id;
  String username;
  int? preferredCityId;
  final String email;
  final String firebaseUid;
  final DateTime createdAt;
  final String? stripeId;
  final UserRole role;
  String phone;
  String? passwordMD5;
  String? imageUrl;
  final String name;
  final String surname;
  final DateTime birthdate;
  bool isVip;
  DateTime? startVip;
  DateTime? endVip;
  VipType vipType;
  UserStatus status;

  User({
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
    this.status = UserStatus.active,
    this.preferredCityId,
  });

  /// Factory per creare l'istanza corretta in base al ruolo
  factory User.fromJson(Map<String, dynamic> json) {
    final role = _roleFromString(json['role']);

    switch (role) {
      case UserRole.player:
        return Player.fromJson(json);
      case UserRole.coordinator:
        return Coordinator.fromJson(json);
      case UserRole.referee:
        return Referee.fromJson(json);
      case UserRole.organization:
        return Organization.fromJson(json);
      case UserRole.guest:
        return throw Exception('Guest role cannot be instantiated from JSON');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firebase_uid': firebaseUid,
      'created_at': createdAt.toIso8601String(),
      'stripe_id': stripeId,
      'role': role.name.toUpperCase(),
      'vip': isVip,
      'phone': phone,
      'password_md5': passwordMD5,
      'image_url': imageUrl,
      'name': name,
      'surname': surname,
      'birthdate': birthdate.toIso8601String(),
      'start_vip': startVip?.toIso8601String(),
      'end_vip': endVip?.toIso8601String(),
      'vip_type': vipType.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'preferred_city_id': preferredCityId,
    };
  }

  /// Nome visualizzato del ruolo
  String get roleDisplayName => role.displayName;

  static UserRole _roleFromString(String role) {
    switch (role.toUpperCase()) {
      case 'PLAYER':
        return UserRole.player;
      case 'COORDINATOR':
        return UserRole.coordinator;
      case 'REFEREE':
        return UserRole.referee;
      case 'ORGANIZATION':
        return UserRole.organization;
      default:
        throw Exception('Unknown role: $role');
    }
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firebaseUid,
    DateTime? createdAt,
    double? balance,
    DateTime? lastWithdraw,
    String? stripeId,
    UserRole? role,
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
    UserStatus? status,
    int? preferredCityId,
  }) {
    return User(
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

  bool get isGuest => role == UserRole.guest;
  bool get isPlayer => role == UserRole.player;
  bool get isCoordinator => role == UserRole.coordinator;
  bool get isReferee => role == UserRole.referee;
  bool get isOrganization => role == UserRole.organization;
}
