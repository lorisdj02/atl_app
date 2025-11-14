import 'package:atl_app/models/organization.dart';

import '../../models/user.dart';
import '../../models/player.dart';
import 'base_repository.dart';
import '../../models/coordinator.dart';

class UserRepository extends BaseRepository<User> {
  @override
  String get endpoint => 'users';

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User item) => item.toJson();

  @override
  List<User> get mockData => [
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
      username: 'jane_player',
      email: 'jane@example.com',
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
  ];

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
