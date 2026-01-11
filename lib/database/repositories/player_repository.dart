import 'package:atl_app/config/app_config.dart';

import '../../models/player.dart';
import 'base_repository.dart';
import '../db_controller.dart';

class PlayerRepository extends BaseRepository<Player> {
  @override
  String get endpoint => 'players';

  @override
  Player fromJson(Map<String, dynamic> json) => Player.fromJson(json);

  @override
  Map<String, dynamic> toJson(Player item) => item.toJson();

  List<Player> _mockData = [
    Player(
      id: 1,
      username: 'loris',
      email: 'loris@example.com',
      firebaseUid: 'firebase_uid_1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      balance: 150.50,
      phone: '1234567890',
      playerId: 1,
      name: 'John',
      surname: 'Doe',
      birthdate: DateTime(1995, 5, 15),
      passwordMD5: 'a',
      isVip: true,
    ),
    Player(
      id: 2,
      username: 'lorisNO',
      email: 'loris2@example.com',
      firebaseUid: 'firebase_uid_2',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      balance: 200.00,
      phone: '0987654321',
      playerId: 2,
      name: 'Jane',
      surname: 'Smith',
      birthdate: DateTime(1998, 8, 22),
      isVip: true,
      passwordMD5: 'a',
    ),
    Player(
      id: 6,
      username: 'player_mike',
      email: 'mike@example.com',
      firebaseUid: 'firebase_uid_player_1',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      balance: 75.00,
      phone: '5556667777',
      playerId: 3,
      name: 'Mike',
      surname: 'Taylor',
      birthdate: DateTime(1992, 3, 10),
      passwordMD5: 'a',
      //teamId: 1,
    ),
    Player(
      id: 7,
      username: 'asia',
      email: 'asia@example.com',
      firebaseUid: 'firebase_uid_player_2',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      balance: 80.00,
      phone: '6667778888',
      playerId: 4,
      name: 'Sara',
      surname: 'Connor',
      birthdate: DateTime(1994, 7, 20),
      passwordMD5: 'a',
    ),
    Player(
      id: 8,
      username: 'player_david',
      email: 'david@example.com',
      firebaseUid: 'firebase_uid_player_3',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      balance: 90.00,
      phone: '7778889999',
      playerId: 5,
      name: 'David',
      surname: 'Wilson',
      birthdate: DateTime(1990, 12, 5),
      passwordMD5: 'a',
    ),
    Player(
      id: 9,
      username: 'player_emma',
      email: 'emma@example.com',
      firebaseUid: 'firebase_uid_player_4',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      balance: 95.00,
      phone: '8889990000',
      playerId: 6,
      name: 'Emma',
      surname: 'Johnson',
      birthdate: DateTime(1991, 11, 25),
      passwordMD5: 'a',
    ),
    Player(
      id: 10,
      username: 'player_sophia',
      email: 'sophia@example.com',
      firebaseUid: 'firebase_uid_player_5',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      balance: 100.00,
      phone: '9990001111',
      playerId: 7,
      name: 'Sophia',
      surname: 'Davis',
      birthdate: DateTime(1993, 4, 18),
      passwordMD5: 'a',
    ),
    Player(
      id: 11,
      username: 'player_james',
      email: 'james@example.com',
      firebaseUid: 'firebase_uid_player_6',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      balance: 110.00,
      phone: '0001112222',
      playerId: 8,
      name: 'James',
      surname: 'Miller',
      birthdate: DateTime(1989, 9, 30),
      passwordMD5: 'a',
    ),
    Player(
      id: 12,
      username: 'player_olivia',
      email: 'olivia@example.com',
      firebaseUid: 'firebase_uid_player_7',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      balance: 120.00,
      phone: '1112223334',
      playerId: 9,
      name: 'Olivia',
      surname: 'Garcia',
      birthdate: DateTime(1996, 6, 12),
      passwordMD5: 'a',
    ),
    Player(
      id: 13,
      username: 'player_benjamin',
      email: 'benjamin@example.com',
      firebaseUid: 'firebase_uid_player_8',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      balance: 130.00,
      phone: '2223334445',
      playerId: 10,
      name: 'Benjamin',
      surname: 'Martinez',
      birthdate: DateTime(1997, 2, 28),
      passwordMD5: 'a',
    ),
    Player(
      id: 14,
      username: 'leone',
      email: 'leone@example.com',
      firebaseUid: 'firebase_uid_player_9',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      balance: 140.00,
      phone: '3334445556',
      playerId: 11,
      name: 'Leone',
      surname: 'Senatore',
      birthdate: DateTime(1995, 8, 15),
      passwordMD5: 'a',
    ),
  ];

  @override
  List<Player> get mockData => _mockData;

  Future<bool> deletePlayer(int id, String passwordMD5) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere(
        (u) => u.id == id && u.passwordMD5 == passwordMD5,
      );
      if (index == -1) return false;

      _mockData.removeAt(index);
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
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateBalance(int id, double newBalance) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere((u) => u.id == id);
      if (index == -1) return false;

      _mockData[index].balance = newBalance;
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<Player?> getByUserId(int id) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((player) => player.id == id);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Player>> getByTeam(int teamId) async {
    final List playerIds = await DB.PlaysAt.getPlayersIdinTeam(teamId);
    List<Player> players = [];
    for (final playerId in playerIds) {
      final player = await getByPlayerId(playerId);
      if (player != null) {
        players.add(player);
      }
    }
    return players;
  }

  Future<Player?> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere((player) => player.playerId == playerId);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> joinTeam(int playerId, int teamId) async {
    if ((await DB.PlaysAt.addPlaysAt(teamId, playerId)) == false) {
      return false;
    }
    return true;
  }
}
