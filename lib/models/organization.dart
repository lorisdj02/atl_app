import 'user.dart';

/// Modello Organization dal database
class Organization extends User {
  final int organizationId;
  final String orgName;
  final String name;
  final String surname;

  Organization({
    required super.id,
    required super.username,
    required super.email,
    required super.firebaseUid,
    required super.createdAt,
    required super.balance,
    super.lastWithdraw,
    super.stripeId,
    super.isVip = false,
    required super.phone,
    required this.organizationId,
    required this.orgName,
    required this.name,
    required this.surname,
    super.passwordMD5,
  }) : super(role: UserRole.organization);

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
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
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      organizationId: json['organization_id'],
      orgName: json['org_name'],
      name: json['name'],
      surname: json['surname'],
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
