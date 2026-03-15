import 'base_repository.dart';
import '../../models/referee_roles.dart';
import '../../config/app_config.dart';

class RefereeRolesRepository extends BaseRepository<RefereeRoles> {
  @override
  String get endpoint => 'referee_roles';

  @override
  RefereeRoles fromJson(Map<String, dynamic> json) {
    return RefereeRoles.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(RefereeRoles item) {
    return item.toJson();
  }


  @override
  List<RefereeRoles> get mockData => [
    RefereeRoles(
      sportId: 1,
      name: 'MAIN',
      level: 1,
      payPerMatch: 15.0,
    ),
    RefereeRoles(
      sportId: 1,
      name: 'MAIN',
      level: 2,
      payPerMatch: 20.0,
    ),
    RefereeRoles(
      sportId: 1,
      name: 'MAIN',
      level: 3,
      payPerMatch: 25.0,
    ),
    RefereeRoles(
      sportId: 1,
      name: 'MAIN',
      level: 4,
      payPerMatch: 30.0,
    ),
    RefereeRoles(
      sportId: 2,
      name: 'MAIN',
      level: 1,
      payPerMatch: 18.0,
    ),
    RefereeRoles(
      sportId: 2,
      name: 'MAIN',
      level: 2,
      payPerMatch: 22.0,
    ),
    RefereeRoles(
      sportId: 2,
      name: 'MAIN',
      level: 3,
      payPerMatch: 28.0,
    ),
    RefereeRoles(
      sportId: 2,
      name: 'MAIN',
      level: 4,
      payPerMatch: 35.0,
    ),
    RefereeRoles(
      sportId: 3,
      name: 'MAIN',
      level: 1,
      payPerMatch: 20.0,
    ),
    RefereeRoles(
      sportId: 3,
      name: 'MAIN',
      level: 2,
      payPerMatch: 25.0,
    ),
    RefereeRoles(
      sportId: 3,
      name: 'MAIN',
      level: 3,
      payPerMatch: 30.0,
    ),
    RefereeRoles(
      sportId: 3,
      name: 'MAIN',
      level: 4,
      payPerMatch: 35.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'MAIN',
      level: 1,
      payPerMatch: 30.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'MAIN',
      level: 2,
      payPerMatch: 35.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'MAIN',
      level: 3,
      payPerMatch: 40.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'MAIN',
      level: 4,
      payPerMatch: 50.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'ASSISTANT1',
      level: 1,
      payPerMatch: 15.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'ASSISTANT1',
      level: 2,
      payPerMatch: 18.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'ASSISTANT1',
      level: 3,
      payPerMatch: 20.0,
    ),
      RefereeRoles(
        sportId: 4,
        name: 'ASSISTANT1',
        level: 4,
        payPerMatch: 25.0,
      ),
    RefereeRoles(
      sportId: 4,
      name: 'ASSISTANT2',
      level: 1,
      payPerMatch: 15.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'ASSISTANT2',
      level: 2,
      payPerMatch: 18.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'ASSISTANT2',
      level: 3,
      payPerMatch: 20.0,
    ),
    RefereeRoles(
      sportId: 4,
      name: 'ASSISTANT2',
      level: 4,
      payPerMatch: 25.0,
    ),
  ];

  Future<List<RefereeRoles>> getBySportId(int sportId) async {
    if (AppConfig.isDebug) {
      return mockData.where((role) => role.sportId == sportId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<double> getPayPerMatch(int sportId, String roleName, int level) async {
    if (AppConfig.isDebug) {
      try {
        final role = mockData.firstWhere((role) =>
            role.sportId == sportId &&
            role.name.toUpperCase() == roleName.toUpperCase() &&
            role.level == level);
        return role.payPerMatch;
      } catch (e) {
        throw Exception('Role not found for sportId: $sportId, roleName: $roleName, level: $level');
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> checkRoleExists(int sportId, String roleName) async {
    if (AppConfig.isDebug) {
      return mockData.any((role) =>
          role.sportId == sportId && role.name.toUpperCase() == roleName.toUpperCase());
    } else {
      throw UnimplementedError();
    }
  }
}