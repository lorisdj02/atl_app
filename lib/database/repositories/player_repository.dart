import '../../models/player.dart';
import 'base_repository.dart';

class PlayerRepository extends BaseRepository<Player> {
  @override
  String get endpoint => 'players';

  @override
  Player fromJson(Map<String, dynamic> json) => Player.fromJson(json);

  @override
  Map<String, dynamic> toJson(Player item) => item.toJson();

  @override
  List<Player> get mockData => [
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
}
