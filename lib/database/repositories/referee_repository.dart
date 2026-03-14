import 'package:atl_app/models/user.dart';

import 'base_repository.dart';
import '../../models/referee.dart';
import '../../config/app_config.dart';

class RefereeRepository extends BaseRepository<Referee> {
  @override
  String get endpoint => 'referees';

  @override
  Referee fromJson(Map<String, dynamic> json) =>
      Referee.fromJson(json);

  @override
  Map<String, dynamic> toJson(Referee item) => item.toJson();

  // 4 cifre -> referees
  List<Referee> _mockData =[
    Referee(
      id: 1000,
      name: 'Loris',
      surname: 'Di Girolamo',
      username: 'lorisA',
      email: 'lorisDiGirolamo@reply.it',
      phone: '+391234567890',
      firebaseUid: '1',
      createdAt: DateTime.now(),
      refereeId: 1,
      level: 1,
      birthdate: DateTime(1990, 5, 20),
      passwordMD5: 'a',
    ),
    Referee(
      id: 1001,
      name: 'Laura',
      surname: 'Bianchi',
      username: 'lbianchi',
      email: 'lbianchi@example.com',
      phone: '+391234567891',
      firebaseUid: '2',
      createdAt: DateTime.now(),
      refereeId: 2,
      level: 2,
      birthdate: DateTime(1985, 8, 15),
    ),
  ];

  @override
  List<Referee> get mockData => _mockData;

  Future<int> getLevelByRefereeId(int refereeId) async{
    if (AppConfig.isDebug) {
      try {
        final referee = _mockData.firstWhere(
          (referee) => referee.refereeId == refereeId,
        );
        return referee.level;
      } catch (e) {
        return -1;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getRefereeIdByUserId(int userId) async{
    if (AppConfig.isDebug) {
      try {
        final referee = _mockData.firstWhere(
          (referee) => referee.id == userId,
        );
        return referee.refereeId;
      } catch (e) {
        return -1;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Referee>> getAllReferees() async {
    if (AppConfig.isDebug) {
      return _mockData;
    } else {
      throw UnimplementedError();
    }
  }

  Future<Referee?> getByRefereeId(int refereeId) async {
    if (AppConfig.isDebug) {
      try {
        final referee = _mockData.firstWhere(
          (referee) => referee.refereeId == refereeId,
        );
        return referee;
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<Referee?> getByUserId(int userId) async{
    if (AppConfig.isDebug) {
      try {
        final referee = _mockData.firstWhere(
          (referee) => referee.id == userId,
        );
        return referee;
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


  Future<bool> registerReferee({required String email,
    required int id,
    required String username,
    required String password,
    required String name,
    required String surname,
    required String phone,
    required DateTime birthdate,
    String? profilePictureUrl,})async{
      if(AppConfig.isDebug){

        final int nextRefereeId = (_mockData
               .map((u) => u.refereeId)
               .fold(0, (prev, curr) => curr > prev ? curr : prev)) +
           1;
        final Referee newReferee = Referee(
          id: id,
          name: name,
          surname: surname,
          username: username,
          email: email,
          phone: phone,
          firebaseUid: '',
          createdAt: DateTime.now(),
          refereeId: nextRefereeId,
          level: 1, // Default level
          birthdate: birthdate, // Default birthdate
          passwordMD5: password, // In a real implementation, you would hash the password
        );

        _mockData.add(newReferee);
        return true;
      }else{
        throw UnimplementedError();
      }
    }

  Future<bool> deleteReferee(int id, String passwordMD5) async {
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
}