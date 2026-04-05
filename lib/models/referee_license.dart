enum LicenseStatus{
  notVerified,
  active,
  expired,
  suspended
}

class RefereeLicense {
  final int refereeId;
  final int sportId;
  final String id;
  LicenseStatus status;
  final DateTime createdAt;
  final DateTime issuedAt;
  DateTime? verifiedAt;
  DateTime? expiresAt;
  final String photoUrl;

  RefereeLicense({
    required this.refereeId,
    required this.sportId,
    required this.id,
    this.status = LicenseStatus.notVerified,
    required this.createdAt,
    required this.issuedAt,
    this.verifiedAt,
    this.expiresAt,
    this.photoUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'refereeId': refereeId,
      'sportId': sportId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'issuedAt': issuedAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory RefereeLicense.fromJson(Map<String, dynamic> json) {
    return RefereeLicense(
      refereeId: json['refereeId'],
      sportId: json['sportId'],
      id: json['id'],
      status: LicenseStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LicenseStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      issuedAt: DateTime.parse(json['issuedAt']),
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }
}