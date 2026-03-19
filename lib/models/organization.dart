import 'account.dart';

/// Modello Organization dal database
class Organization extends Account {
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
    super.startVip,
    super.endVip,
    super.vipType = VipType.none,
  }) : super(role: AccountRole.organization);

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firebaseUid: json['firebaseUid'],
      createdAt: DateTime.parse(json['createdAt']),
      stripeId: json['stripeId'],
      isVip: json['isVip'] ?? false,
      phone: json['phone'],
      organizationId: json['organizationId'],
      orgName: json['orgName'],
      name: json['name'],
      surname: json['surname'],
      passwordMD5: json['passwordMd5'],
      imageUrl: json['imageUrl'],
      birthdate: DateTime.parse(json['birthdate']),
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
    return {
      ...super.toJson(),
      'organizationId': organizationId,
      'orgName': orgName,
    };
  }

  String get contactFullName => '$name $surname';
}
