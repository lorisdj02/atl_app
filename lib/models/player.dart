import 'account.dart';

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
      playerId: json['playerId'],
      accountId: json['accountId'],
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      imageUrl: json['imageUrl'],
      vip: json['vip'],
      vipType: VipType.values.firstWhere(
        (e) => e.apiName == json['vipType'],
        orElse: () => VipType.none,
      ),
      vipStart: json['vipStart'] != null ? DateTime.parse(json['vipStart']) : null,
      vipEnd: json['vipEnd'] != null ? DateTime.parse(json['vipEnd']) : null,
      prefferdCityId: json['prefferdCityId'],
      birthdate: DateTime.parse(json['birthdate']),
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
      'vipStart': vipStart?.toIso8601String(),
      'vipEnd': vipEnd?.toIso8601String(),
      'prefferdCityId': prefferdCityId,
      'birthdate': birthdate.toIso8601String(),
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
