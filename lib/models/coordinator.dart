import 'user.dart';

/// Modello Coordinator dal database
class Coordinator extends User {
  final int coordinatorId;
  final String name;
  final String surname;
  final int level;

  Coordinator({
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
    required this.coordinatorId,
    required this.name,
    required this.surname,
    required this.level,
  }) : super(role: UserRole.coordinator);

  factory Coordinator.fromJson(Map<String, dynamic> json) {
    return Coordinator(
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
      coordinatorId: json['coordinator_id'],
      name: json['name'],
      surname: json['surname'],
      level: json['level'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'coordinator_id': coordinatorId,
      'name': name,
      'surname': surname,
      'level': level,
    };
  }

  String get fullName => '$name $surname';

  /// Descrizione livello coordinatore
  String get levelDescription {
    switch (level) {
      case 1:
        return 'Junior Coordinator';
      case 2:
        return 'Senior Coordinator';
      case 3:
        return 'Expert Coordinator';
      default:
        return 'Level $level';
    }
  }
}
