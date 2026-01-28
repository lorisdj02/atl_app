import 'package:atl_app/models/team.dart';

import 'user.dart';

/// Modello Player dal database
class Player extends User {
  final int playerId;

  Player({
    required super.id,
    required super.username,
    required super.email,
    required super.firebaseUid,
    required super.createdAt,
    super.stripeId,
    super.isVip = false,
    required super.phone,
    required this.playerId,
    required super.name,
    required super.surname,
    required super.birthdate,
    super.passwordMD5,
    super.imageUrl,
    super.startVip,
    super.endVip,
    super.vipType = VipType.none,
  }) : super(role: UserRole.player);

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
      createdAt: DateTime.parse(json['created_at']),
      stripeId: json['stripe_id'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      playerId: json['player_id'],
      name: json['name'],
      surname: json['surname'],
      birthdate: DateTime.parse(json['birthdate']),
      passwordMD5: json['password_md5'],
      imageUrl: json['image_url'],
      startVip: json['start_vip'] != null
          ? DateTime.parse(json['start_vip'])
          : null,
      endVip: json['end_vip'] != null ? DateTime.parse(json['end_vip']) : null,
      vipType: json['vip_type'] != null
          ? VipType.values.firstWhere((e) => e.name == json['vip_type'])
          : VipType.none,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'player_id': playerId};
  }

  String get fullName => '$name $surname';

  /// Calcola l'età del giocatore
  int? get age {
    final now = DateTime.now();
    int age = now.year - birthdate.year;
    if (now.month < birthdate.month ||
        (now.month == birthdate.month && now.day < birthdate.day)) {
      age--;
    }
    return age;
  }
}
