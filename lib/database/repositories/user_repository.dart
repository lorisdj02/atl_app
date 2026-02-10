import 'package:atl_app/config/app_config.dart';
import '../../models/user.dart';
import 'base_repository.dart';
import '../db_controller.dart';

class UserRepository extends BaseRepository<User> {
  @override
  String get endpoint => 'users';

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User item) => item.toJson();

  @override
  List<User> get mockData => [
    ...DB.Players.mockData,
    ...DB.Coordinators.mockData,
    ...DB.Referees.mockData,
    ...DB.Organizations.mockData,
  ];

  Future<T?> getByUserId<T extends User>(int id) async {
    if (AppConfig.isDebug) {
      try {
        final user = mockData.firstWhere((user) => user.id == id);
        if (user is T) {
          return user;
        } else {
          return null;
        }
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<int?> getRoleId(int userId) async {
    if (AppConfig.isDebug) {
      try {
        final user = mockData.firstWhere((user) => user.id == userId);
        if (user.role == UserRole.player) {
          return DB.Players.getPlayerIdByUserId(user.id);
        } else if (user.role == UserRole.coordinator) {
          return DB.Coordinators.getCoordinatorIdByUserId(user.id);
        } else if (user.role == UserRole.referee) {
          return DB.Referees.getRefereeIdByUserId(user.id);
        } else if (user.role == UserRole.organization) {
          return DB.Organizations.getOrganizationIdByUserId(user.id);
        } else {
          return null;
        }
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  /// Metodo custom: ottieni user per username
  Future<User?> getByUsername(String username) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((user) => user.username == username);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  /// Metodo custom: ottieni user per email
  Future<User?> getByEmail(String email) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((user) => user.email == email);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  /// Metodo custom: ottieni user per email o username
  Future<User?> getByEmailOrUsername(String identifier, String password) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere(
          (u) =>
              u.passwordMD5 == password &&
              (u.email == identifier || u.username == identifier),
        );
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
  }) async {
    if (AppConfig.isDebug) {
      // Update mock data

      return await DB.Players.updateUserInfo(
            id: id,
            username: username,
            phone: phone,
            oldPasswordMD5: oldPasswordMD5,
            newPasswordMD5: newPasswordMD5,
            birthdate: birthdate,
            imgUrl: imgUrl,
          ) ||
          await DB.Coordinators.updateUserInfo(
            id: id,
            username: username,
            phone: phone,
            oldPasswordMD5: oldPasswordMD5,
            newPasswordMD5: newPasswordMD5,
            birthdate: birthdate,
            imgUrl: imgUrl,
          );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteAccount(int id, String passwordMD5) async {
    if (AppConfig.isDebug) {
      return await DB.Players.deletePlayer(id, passwordMD5) ||
          await DB.Coordinators.deleteCoordinator(id, passwordMD5);
    } else {
      throw UnimplementedError();
    }
  }
}
