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

  @override
  List<Player> get mockData => DB.Users.mockData.whereType<Player>().toList();

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
