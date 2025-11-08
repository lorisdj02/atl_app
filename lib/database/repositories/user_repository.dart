import '../../models/user.dart';
import '../../models/player.dart';
import 'base_repository.dart';

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
      username: 'john_player',
      email: 'john@example.com',
      firebaseUid: 'firebase_uid_1',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      balance: 150.50,
      phone: '1234567890',
      playerId: 1,
      name: 'John',
      surname: 'Doe',
      birthdate: DateTime(1995, 5, 15),
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
      vip: true,
      vipStart: DateTime.now().subtract(const Duration(days: 5)),
      vipEnd: DateTime.now().add(const Duration(days: 25)),
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
}
