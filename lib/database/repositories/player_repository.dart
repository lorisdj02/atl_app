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
    final allPlayers = await getAll();
    return allPlayers.where(
      (player) => player.teamId == teamId, // Cambiato da playerId a team
    ).toList();
  }

  Future<Player> getByPlayerId(int playerId) async {
    final allPlayers = await getAll();
    return allPlayers.firstWhere(
      (player) => player.playerId == playerId,
    );
  }

  Future<void> joinTeam (int playerId, int teamId) async {
    final allPlayers = await getAll();
    for (var player in allPlayers) {
      if (player.playerId == playerId) {
        player.teamId = teamId;
        await update(player.id, player);
        if(AppConfig.isDebug) {
          print('🔧 [DEBUG] Player $playerId joined team $teamId');
          DB.Players._mockData
              .firstWhere((p) => p.playerId == playerId)
              .teamId = teamId;
        }
        break;
      }
    }
  }

  @override
  Future<Player> getById(int id) async {
    final allPlayers = await getAll();
    return allPlayers.firstWhere(
      (player) => player.id == id,
    );
  }
}
