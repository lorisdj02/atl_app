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
}