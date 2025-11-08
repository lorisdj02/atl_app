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
  organization;

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
    }
  }
}

/// Modello astratto User dal database
abstract class User {
  final int id;
  final String username;
  final String email;
  final String firebaseUid;
  final DateTime createdAt;
  final double balance;
  final DateTime? lastWithdraw;
  final String? stripeId;
  final UserRole role;
  final bool vip;
  final DateTime? vipStart;
  final DateTime? vipEnd;
  final DateTime? lastLogin;
  final String phone;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firebaseUid,
    required this.createdAt,
    required this.balance,
    this.lastWithdraw,
    this.stripeId,
    required this.role,
    this.vip = false,
    this.vipStart,
    this.vipEnd,
    this.lastLogin,
    required this.phone,
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
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firebase_uid': firebaseUid,
      'created_at': createdAt.toIso8601String(),
      'balance': balance,
      'last_withdraw': lastWithdraw?.toIso8601String(),
      'stripe_id': stripeId,
      'role': role.name.toUpperCase(),
      'vip': vip,
      'vip_start': vipStart?.toIso8601String(),
      'vip_end': vipEnd?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'phone': phone,
    };
  }

  /// Verifica se l'utente ha VIP attivo
  bool get isVipActive {
    if (!vip || vipEnd == null) return false;
    return DateTime.now().isBefore(vipEnd!);
  }

  /// Giorni rimanenti VIP
  int? get vipDaysRemaining {
    if (!isVipActive || vipEnd == null) return null;
    return vipEnd!.difference(DateTime.now()).inDays;
  }

  /// Formatta il balance come stringa con valuta
  String get formattedBalance => '€${balance.toStringAsFixed(2)}';

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
}
