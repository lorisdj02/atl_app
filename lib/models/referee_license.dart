enum LicenseStatus{
  active,
  revoked,
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
  DateTime? revokedAt;

  RefereeLicense({
    required this.refereeId,
    required this.sportId,
    required this.id,
    this.status = LicenseStatus.active,
    required this.createdAt,
    required this.issuedAt,
    this.verifiedAt,
    this.revokedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'refereeId': refereeId,
      'sportId': sportId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'issuedAt': issuedAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'revokedAt': revokedAt?.toIso8601String(),
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
      revokedAt: json['revokedAt'] != null ? DateTime.parse(json['revokedAt']) : null,
    );
  }
}