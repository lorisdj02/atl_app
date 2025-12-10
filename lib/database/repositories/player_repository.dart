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
    ...DB.Users.mockData.whereType<Player>(),
  ];

  @override
  List<Player> get mockData => _mockData;

  Future<List<Player>> getByTeam(int teamId) async {
    final List playerIds = await DB.PlaysAt.getPlayersinTeam(teamId);
    List<Player> players = [];
    for(final playerId in playerIds){
      players.add(await getByPlayerId(playerId));
    }
    return players;
  }

  Future<Player> getByPlayerId(int playerId) async {
    final allPlayers = await getAll();
    return allPlayers.firstWhere(
      (player) => player.playerId == playerId,
    );
  }

  Future<void> joinTeam (int playerId, int teamId) async {
    await DB.PlaysAt.addPlaysAt(teamId, playerId);
  }


}
