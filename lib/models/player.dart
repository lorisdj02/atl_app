import 'package:atl_app/models/team.dart';

import 'user.dart';

/// Modello Player dal database
class Player extends User {
  final int playerId;
  final String name;
  final String surname;
  final DateTime? birthdate;
  final Team? team;

  Player({
    required super.id,
    required super.username,
    required super.email,
    required super.firebaseUid,
    required super.createdAt,
    required super.balance,
    super.lastWithdraw,
    super.stripeId,
    super.isVip = false,
    required super.phone,
    required this.playerId,
    required this.name,
    required this.surname,
    this.birthdate,
    super.passwordMD5,
    this.team,
  }) : super(role: UserRole.player);

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
      createdAt: DateTime.parse(json['created_at']),
      balance: double.parse(json['balance'].toString()),
      lastWithdraw: json['last_withdraw'] != null
          ? DateTime.parse(json['last_withdraw'])
          : null,
      stripeId: json['stripe_id'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      playerId: json['player_id'],
      name: json['name'],
      surname: json['surname'],
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : null,
      team: json['team'] != null ? Team.fromJson(json['team']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'player_id': playerId,
      'name': name,
      'surname': surname,
      'birthdate': birthdate?.toIso8601String(),
    };
  }

  String get fullName => '$name $surname';

  /// Calcola l'età del giocatore
  int? get age {
    if (birthdate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthdate!.year;
    if (now.month < birthdate!.month ||
        (now.month == birthdate!.month && now.day < birthdate!.day)) {
      age--;
    }
    return age;
  }
}
