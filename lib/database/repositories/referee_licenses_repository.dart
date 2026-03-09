import '/../models/referee_license.dart';
import '../../config/app_config.dart';
import 'base_repository.dart';

class RefereeLicensesRepository extends BaseRepository<RefereeLicense> {
  @override
  String get endpoint => 'referee_licenses';

  @override
  RefereeLicense fromJson(Map<String, dynamic> json) =>
      RefereeLicense.fromJson(json);

  @override
  Map<String, dynamic> toJson(RefereeLicense item) => item.toJson();

  List<RefereeLicense> _mockData = [];

  @override
  List<RefereeLicense> get mockData => _mockData;

  Future<List<RefereeLicense>> getByRefereeId(int refereeId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where((license) => license.refereeId == refereeId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> revokeLicense(String licenseId) async {
    if (AppConfig.isDebug) {
      try {
        final license = _mockData.firstWhere(
          (license) => license.id == licenseId,
        );
        license.status = LicenseStatus.revoked;
        license.revokedAt = DateTime.now();
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addLicense(
    int refereeId,
    int sportId,
    String id,
    DateTime issuedAt,
  ) async {
    if (AppConfig.isDebug) {
      final existing = await getByRefereeId(refereeId);
      if (existing.any((license) => license.sportId == sportId)) {
        return false; // License for this sport already exists
      }
      final newLicense = RefereeLicense(
        refereeId: refereeId,
        sportId: sportId,
        id: id,
        issuedAt: issuedAt,
        createdAt: DateTime.now(),
        status: LicenseStatus.active,
      );

      _mockData.add(newLicense);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeLicense(int refereeId, int sportId) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere(
        (license) =>
            license.refereeId == refereeId &&
            license.sportId == sportId &&
            license.status == LicenseStatus.notVerified,
      );
      if (index == -1) {
        return false;
      }

      _mockData.removeAt(index);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> verifyLicense(int refereeId, int sportId) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere(
        (license) =>
            license.refereeId == refereeId &&
            license.sportId == sportId &&
            license.status == LicenseStatus.notVerified,
      );
      if (index == -1) {
        return false;
      }

      _mockData[index].status = LicenseStatus.active;
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isRefereeLicensed(int refereeId, int sportId) async {
    if (AppConfig.isDebug) {
      return _mockData.any(
        (license) =>
            license.sportId == sportId &&
            license.refereeId == refereeId &&
            license.status == LicenseStatus.active,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
