import 'package:atl_app/models/enums/account_role.dart';
import 'package:atl_app/models/enums/vip_type.dart';

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
  final DateTime createdAt;

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
    required this.createdAt,
  });

  /// Factory per creare l'istanza corretta in base al ruolo
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      username: json['username'],
      email: json['email'],
      role: json['role'] != null
          ? AccountRoleExtension.fromJson(json['role'])
          : AccountRole.guest,
      phone: json['phone'],
      name: json['name'],
      surname: json['surname'],
      birthdate: DateTime.parse(json['birthdate']),
      vip: json['vip'],
      vipType: json['vipType'] != null
          ? VipTypeExtension.fromJson(json['vipType'])
          : VipType.none,
      startVip: json['startVip'] != null
          ? DateTime.parse(json['startVip'])
          : null,
      endVip: json['endVip'] != null ? DateTime.parse(json['endVip']) : null,
      preferredCityId: json['preferredCityId'] != null
          ? (json['preferredCityId'] as num).toDouble()
          : null,
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
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
      'createdAt': createdAt.toIso8601String(),
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
