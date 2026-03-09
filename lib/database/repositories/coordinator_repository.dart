import '../../models/coordinator.dart';
import '../../models/user.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

class CoordinatorRepository extends BaseRepository<Coordinator> {
  @override
  String get endpoint => 'coordinators';

  @override
  Coordinator fromJson(Map<String, dynamic> json) => Coordinator.fromJson(json);

  @override
  Map<String, dynamic> toJson(Coordinator item) => item.toJson();

  // 3 cifre -> coordinators
  List<Coordinator> _mockData = [
    Coordinator(
      id: 100,
      username: 'giuseppe',
      email: 'giuseppe@example.com',
      firebaseUid: 'firebase_uid_coord_1',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      phone: '1112223333',
      coordinatorId: 1,
      name: 'Mark',
      surname: 'Johnson',
      level: 2,
      passwordMD5: 'a',
      birthdate: DateTime(1988, 2, 14),
    ),
    Coordinator(
      id: 101,
      username: 'coordinator_lucy',
      email: 'lucy@example.com',
      firebaseUid: 'firebase_uid_coord_2',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      phone: '2223334444',
      coordinatorId: 2,
      name: 'Lucy',
      surname: 'Smith',
      level: 3,
      passwordMD5: 'a',
      birthdate: DateTime(1985, 1, 1),
    ),
    Coordinator(
      id: 102,
      username: 'coordinator_alex',
      email: 'alex@example.com',
      firebaseUid: 'firebase_uid_coord_3',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      phone: '3334445555',
      coordinatorId: 3,
      name: 'Alex',
      surname: 'Brown',
      level: 1,
      passwordMD5: 'a',
      birthdate: DateTime(1990, 10, 10),
    ),
  ];

  @override
  List<Coordinator> get mockData => _mockData;

  Future<int> getLevelByCoordinatorId(int coordinatorId) async {
    if (AppConfig.isDebug) {
      try {
        final coordinator = mockData.firstWhere(
          (coordinator) => coordinator.coordinatorId == coordinatorId,
        );
        return coordinator.level;
      } catch (e) {
        return -1;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getCoordinatorIdByUserId(int userId) async {
    if (AppConfig.isDebug) {
      try {
        final coordinator = mockData.firstWhere(
          (coordinator) => coordinator.id == userId,
        );
        return coordinator.coordinatorId;
      } catch (e) {
        return -1;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteCoordinator(int id, String passwordMD5) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere(
        (u) => u.id == id && u.passwordMD5 == passwordMD5,
      );
      if (index == -1) return false;

      _mockData[index].status = UserStatus.deleted;
      _mockData[index].username = 'deleted_user_${_mockData[index].id}';
      _mockData[index].email = 'deleted_user_${_mockData[index].id}';
      _mockData[index].phone = '';
      _mockData[index].imageUrl = null;
      _mockData[index].surname = '';

      return true;
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

  Future<Coordinator?> getByUserId(int id) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere((coordinator) => coordinator.id == id);
    } else {
      throw UnimplementedError();
    }
  }

  Future<Coordinator?> getByCoordinatorId(int coordinatorId) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere(
        (coordinator) => coordinator.coordinatorId == coordinatorId,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
