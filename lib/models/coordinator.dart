import 'user.dart';

/// Modello Coordinator dal database
class Coordinator extends User {
  final int coordinatorId;
  final int level;

  Coordinator({
    required super.id,
    required super.username,
    required super.email,
    required super.firebaseUid,
    required super.createdAt,
    super.stripeId,
    super.isVip = false,
    required super.phone,
    required this.coordinatorId,
    required super.name,
    required super.surname,
    required this.level,
    super.passwordMD5,
    super.imageUrl,
    required super.birthdate,
    super.startVip,
    super.endVip,
    super.vipType = VipType.none,
  }) : super(role: UserRole.coordinator);

  factory Coordinator.fromJson(Map<String, dynamic> json) {
    return Coordinator(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
      createdAt: DateTime.parse(json['created_at']),
      stripeId: json['stripe_id'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      coordinatorId: json['coordinator_id'],
      name: json['name'],
      surname: json['surname'],
      level: json['level'],
      passwordMD5: json['password_md5'],
      imageUrl: json['image_url'],
      birthdate: DateTime.parse(json['birthdate']),
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
