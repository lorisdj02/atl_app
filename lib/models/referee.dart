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
  }) : super(role: UserRole.referee);

  factory Referee.fromJson(Map<String, dynamic> json) {
    return Referee(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
      createdAt: DateTime.parse(json['created_at']),
      stripeId: json['stripe_id'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      refereeId: json['referee_id'],
      name: json['name'],
      surname: json['surname'],
      level: json['level'],
      passwordMD5: json['password_md5'],
      imageUrl: json['image_url'],
      birthdate: DateTime.parse(json['birthdate']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {...super.toJson(), 'referee_id': refereeId, 'level': level};
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
