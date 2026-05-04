import 'enums/vip_type.dart';
/// Modello Player dal database
// OK
class Player {
  final double playerId;
  final double accountId;
  final String username;
  final String name;
  final String surname;
  final String? imageUrl;
  final bool vip;
  final VipType vipType;
  final DateTime? vipStart;
  final DateTime? vipEnd;
  final double prefferdCityId;
  final DateTime birthdate;

  Player({
    required this.accountId,
    required this.playerId,
    required this.name,
    required this.surname,
    required this.username,
    required this.imageUrl,
    required this.vip,
    required this.vipType,
    required this.vipStart,
    required this.vipEnd,
    required this.prefferdCityId,
    required this.birthdate,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['playerId'] != null ? (json['playerId'] as num).toDouble() : 0.0,
      accountId: json['accountId'] != null ? (json['accountId'] as num).toDouble() : 0.0,
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      imageUrl: json['imageUrl'],
      vip: json['vip'],
      vipType: VipTypeExtension.fromJson(json['vipType']),
      vipStart: json['vipStart'] != null ? DateTime.parse(json['vipStart']).toLocal() : null,
      vipEnd: json['vipEnd'] != null ? DateTime.parse(json['vipEnd']).toLocal() : null,
      prefferdCityId: json['prefferdCityId'] != null ? (json['prefferdCityId'] as num).toDouble() : 0.0,
      birthdate: DateTime.parse(json['birthdate']).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'accountId': accountId,
      'name': name,
      'surname': surname,
      'username': username,
      'imageUrl': imageUrl,
      'vip': vip,
      'vipType': vipType.apiName,
      'vipStart': vipStart?.toUtc().toIso8601String(),
      'vipEnd': vipEnd?.toUtc().toIso8601String(),
      'prefferdCityId': prefferdCityId,
      'birthdate': birthdate.toUtc().toIso8601String(),
    };
  }

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
