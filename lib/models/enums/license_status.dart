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

extension LicenseStatusExtension on LicenseStatus {
  static LicenseStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return LicenseStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown license status: $json'),
    );
  }
}