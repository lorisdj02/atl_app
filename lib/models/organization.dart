import 'user.dart';

/// Modello Organization dal database
class Organization extends User {
  final int organizationId;
  final String orgName;

  Organization({
    required super.id,
    required super.username,
    required super.email,
    required super.firebaseUid,
    required super.createdAt,
    super.stripeId,
    super.isVip = false,
    required super.phone,
    required this.organizationId,
    required this.orgName,
    required super.name,
    required super.surname,
    super.passwordMD5,
    super.imageUrl,
    required super.birthdate,
  }) : super(role: UserRole.organization);

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebase_uid'],
      createdAt: DateTime.parse(json['created_at']),
      stripeId: json['stripe_id'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      organizationId: json['organization_id'],
      orgName: json['org_name'],
      name: json['name'],
      surname: json['surname'],
      passwordMD5: json['password_md5'],
      imageUrl: json['image_url'],
      birthdate: DateTime.parse(json['birthdate']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'organization_id': organizationId,
      'org_name': orgName,
      'name': name,
      'surname': surname,
    };
  }

  String get contactFullName => '$name $surname';
}
