import 'enums/license_status.dart';
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
      'createdAt': createdAt.toUtc().toIso8601String(),
      'issuedAt': issuedAt.toUtc().toIso8601String(),
      'verifiedAt': verifiedAt?.toUtc().toIso8601String(),
      'expiresAt': expiresAt?.toUtc().toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  factory RefereeLicense.fromJson(Map<String, dynamic> json) {
    return RefereeLicense(
      refereeId: json['refereeId'] != null ? (json['refereeId'] as num).toDouble() : 0.0,
      sportId: json['sportId'] != null ? (json['sportId'] as num).toDouble() : 0.0,
      licenseId: json['licenseId'],
      status: LicenseStatusExtension.fromJson(json['status']),
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
      issuedAt: DateTime.parse(json['issuedAt']).toLocal(),
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt']).toLocal()
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt']).toLocal()
          : null,
      photoUrl: json['photoUrl'],
    );
  }
}
