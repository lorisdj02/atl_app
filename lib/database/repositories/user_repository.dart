import '../../models/user.dart';
import '../../models/player.dart';
import 'base_repository.dart';
import '../../models/coordinator.dart';
import '../db_controller.dart';

class UserRepository extends BaseRepository<User> {
  @override
  String get endpoint => 'users';

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User item) => item.toJson();

  List<User> _mockData = [
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
      //teamId: DB.Teams.mockData[0].id,
    ),
    Coordinator(
      id: 3,
      username: 'giuseppe',
      email: 'giuseppe@example.com',
      firebaseUid: 'firebase_uid_coord_1',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      balance: 500.00,
      phone: '1112223333',
      coordinatorId: 1,
      name: 'Mark',
      surname: 'Johnson',
      level: 2,
      passwordMD5: 'a',
    ),
    Coordinator(
      id: 4,
      username: 'coordinator_lucy',
      email: 'lucy@example.com',
      firebaseUid: 'firebase_uid_coord_2',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      balance: 300.00,
      phone: '2223334444',
      coordinatorId: 2,
      name: 'Lucy',
      surname: 'Smith',
      level: 3,
      passwordMD5: 'a',
    ),
    Coordinator(
      id: 5,
      username: 'coordinator_alex',
      email: 'alex@example.com',
      firebaseUid: 'firebase_uid_coord_3',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      balance: 400.00,
      phone: '3334445555',
      coordinatorId: 3,
      name: 'Alex',
      surname: 'Brown',
      level: 1,
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
    )
  ];

  @override
  List<User> get mockData => _mockData;

  /// Metodo custom: ottieni user per username
  Future<User?> getByUsername(String username) async {
    final users = await getAll();
    try {
      return users.firstWhere((u) => u.username == username);
    } catch (e) {
      return null;
    }
  }

  /// Metodo custom: ottieni user per email
  Future<User?> getByEmail(String email) async {
    final users = await getAll();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  /// Metodo custom: ottieni user per email o username
  Future<User?> getByEmailOrUsername(String identifier, String password) async {
    final users = await getAll();
    try {
      return users.firstWhere((u) => u.passwordMD5 == password && (u.email == identifier || u.username == identifier));
    } catch (e) {
      return null;
    }
  }
}
