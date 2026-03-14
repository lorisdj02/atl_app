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
      firebaseUid: json['firebaseUid'],
      createdAt: DateTime.parse(json['createdAt']),
      stripeId: json['stripeId'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      playerId: json['playerId'],
      name: json['name'],
      surname: json['surname'],
      birthdate: DateTime.parse(json['birthdate']),
      passwordMD5: json['passwordMd5'],
      imageUrl: json['imageUrl'],
      startVip: json['startVip'] != null
          ? DateTime.parse(json['startVip'])
          : null,
      endVip: json['endVip'] != null ? DateTime.parse(json['endVip']) : null,
      vipType: json['vipType'] != null
          ? VipType.values.firstWhere((e) => e.name == json['vipType'])
          : VipType.none,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'playerId': playerId};
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
