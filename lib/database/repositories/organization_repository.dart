import 'base_repository.dart';
import '../../models/organization.dart';
import '../../config/app_config.dart';

class OrganizationRepository extends BaseRepository<Organization> {
  @override
  String get endpoint => 'organizations';

  @override
  Organization fromJson(Map<String, dynamic> json) =>
      Organization.fromJson(json);

  @override
  Map<String, dynamic> toJson(Organization item) => item.toJson();

  // 5 cifre -> organizations
  List<Organization> _mockData =[
    Organization(
      id: 10000,
      name: 'Asia',
      surname: 'Senatore',
      username: 'asiaOrg',
      email: 'asiaSenatore@scema.it',
      phone: '+391234567890',
      firebaseUid: '1',
      createdAt: DateTime.now(),
      organizationId: 1,
      orgName: 'OrgOne',
      birthdate: DateTime(1990, 5, 20),
      passwordMD5: 'a',
    ),
    Organization(
      id: 10001,
      name: 'Loris',
      surname: 'Rossi',
      username: 'lorisOrg',
      email: 'lorisRossi@scema.it',
      phone: '+391234567891',
      firebaseUid: '2',
      createdAt: DateTime.now(),
      organizationId: 2,
      orgName: 'OrgTwo',
      birthdate: DateTime(1985, 8, 15),
      passwordMD5: 'a',
    ),
  ];

  @override
  List<Organization> get mockData => _mockData;


  Future<int> getOrganizationIdByUserId(int userId) async{
    if (AppConfig.isDebug) {
      try {
        final organization = _mockData.firstWhere(
          (organization) => organization.id == userId,
        );
        return organization.organizationId;
      } catch (e) {
        return -1;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Organization>> getAllReferees() async {
    if (AppConfig.isDebug) {
      return _mockData;
    } else {
      throw UnimplementedError();
    }
  }

  Future<Organization?> getByOrganizationId(int organizationId) async {
    if (AppConfig.isDebug) {
      try {
        final organization = _mockData.firstWhere(
          (organization) => organization.organizationId == organizationId,
        );
        return organization;
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateUserInfo({
    required int id,
    String? username,
    String? phone,
    String? oldPasswordMD5,
    String? newPasswordMD5,
    DateTime? birthdate,
    String? imgUrl,
    int? preferredCityId,
  }) async {
    if (AppConfig.isDebug) {
      // Update mock data
      final index = _mockData.indexWhere((u) => u.id == id);
      if (index == -1) return false;

      if (username != null) {
        _mockData[index].username = username;
      }
      if (phone != null) {
        _mockData[index].phone = phone;
      }
      if (newPasswordMD5 != null &&
          oldPasswordMD5 != null &&
          _mockData[index].passwordMD5 == oldPasswordMD5) {
        _mockData[index].passwordMD5 = newPasswordMD5;
      }
      if (imgUrl != null) {
        _mockData[index].imageUrl = imgUrl;
      }
      if (preferredCityId != null) {
        _mockData[index].preferredCityId = preferredCityId;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}