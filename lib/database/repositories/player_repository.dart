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

  @override
  List<Player> get mockData => [
    ...DB.Users.mockData.whereType<Player>(),
  ];

  Future<List<Player>> getByTeam(int teamId) async {
    final allPlayers = await getAll();
    return allPlayers.where(
      (player) => player.playerId == teamId,
    ).toList();
  }
}
