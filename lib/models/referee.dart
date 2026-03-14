import 'user.dart';

/// Modello Referee dal database
class Referee extends User {
  final int refereeId;
  final int level;

  Referee({
    required super.id,
    required super.username,
    required super.email,
    required super.firebaseUid,
    required super.createdAt,
    super.stripeId,
    super.isVip = false,
    required super.phone,
    required this.refereeId,
    required super.name,
    required super.surname,
    required this.level,
    super.passwordMD5,
    super.imageUrl,
    required super.birthdate,
    super.startVip,
    super.endVip,
    super.vipType = VipType.none,
  }) : super(role: UserRole.referee);

  factory Referee.fromJson(Map<String, dynamic> json) {
    return Referee(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebaseUid'],
      createdAt: DateTime.parse(json['createdAt']),
      stripeId: json['stripeId'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      refereeId: json['refereeId'],
      name: json['name'],
      surname: json['surname'],
      level: json['level'],
      passwordMD5: json['passwordMd5'],
      imageUrl: json['imageUrl'],
      birthdate: DateTime.parse(json['birthdate']),
      startVip: json['startVip'] != null ? DateTime.parse(json['startVip']) : null,
      endVip: json['endVip'] != null ? DateTime.parse(json['endVip']) : null,
      vipType: json['vipType'] != null ? VipType.values.firstWhere((e) => e.name == json['vipType']) : VipType.none,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'refereeId': refereeId, 'level': level};
  }

  String get fullName => '$name $surname';

  String get levelDescription {
    switch (level) {
      case 1:
        return 'Junior Referee';
      case 2:
        return 'Senior Referee';
      case 3:
        return 'International Referee';
      default:
        return 'Level $level';
    }
  }
}
