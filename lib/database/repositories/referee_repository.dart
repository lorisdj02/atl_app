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
}