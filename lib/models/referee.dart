import 'user.dart';

/// Modello Referee dal database
class Referee extends User {
  final int refereeId;
  final String name;
  final String surname;
  final int level;

  Referee({
    required super.id,
    required super.username,
    required super.email,
    required super.firebaseUid,
    required super.createdAt,
    required super.balance,
    super.lastWithdraw,
    super.stripeId,
    super.vip = false,
    super.vipStart,
    super.vipEnd,
    super.lastLogin,
    required super.phone,
    required this.refereeId,
    required this.name,
    required this.surname,
    required this.level,
  }) : super(role: UserRole.referee);

  factory Referee.fromJson(Map<String, dynamic> json) {
    return Referee(
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
      vip: json['vip'] ?? false,
      vipStart: json['vip_start'] != null
          ? DateTime.parse(json['vip_start'])
          : null,
      vipEnd: json['vip_end'] != null
          ? DateTime.parse(json['vip_end'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      phone: json['phone'],
      refereeId: json['referee_id'],
      name: json['name'],
      surname: json['surname'],
      level: json['level'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'referee_id': refereeId,
      'name': name,
      'surname': surname,
      'level': level,
    };
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
