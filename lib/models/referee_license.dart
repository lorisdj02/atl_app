enum LicenseStatus {
  notVerified,
  active,
  revoked,
  suspended;

  String get apiName {
    switch (this) {
      case LicenseStatus.notVerified:
        return 'NOT_VERIFIED';
      case LicenseStatus.active:
        return 'ACTIVE';
      case LicenseStatus.revoked:
        return 'REVOKED';
      case LicenseStatus.suspended:
        return 'SUSPENDED';
    }
  }
}

// OK
class RefereeLicense {
  final double sportId;
  final double refereeId;
  final String? photoUrl;
  final LicenseStatus status;
  final DateTime createdAt;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final DateTime? verifiedAt;
  final String licenseId;

  RefereeLicense({
    required this.refereeId,
    required this.sportId,
    required this.licenseId,
    required this.status,
    required this.createdAt,
    required this.issuedAt,
    required this.verifiedAt,
    required this.expiresAt,
    required this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'refereeId': refereeId,
      'sportId': sportId,
      'licenseId': licenseId,
      'status': status.apiName,
      'createdAt': createdAt.toIso8601String(),
      'issuedAt': issuedAt.toIso8601String(),
      'verifiedAt': verifiedAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  factory RefereeLicense.fromJson(Map<String, dynamic> json) {
    return RefereeLicense(
      refereeId: json['refereeId'],
      sportId: json['sportId'],
      licenseId: json['licenseId'],
      status: LicenseStatus.values.firstWhere(
        (e) => e.apiName == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      issuedAt: DateTime.parse(json['issuedAt']),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'])
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'])
          : null,
      photoUrl: json['photoUrl'],
    );
  }
}
