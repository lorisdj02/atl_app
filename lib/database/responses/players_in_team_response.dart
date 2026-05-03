

import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/player.dart';

class PlayersInTeamResponse {
  List<Player> players;
  List<Player> historicalPlayers;

  PlayersInTeamResponse({
    required this.players,
    required this.historicalPlayers,
  });

  factory PlayersInTeamResponse.fromJson(Map<String, dynamic> json) {
      List<Player> players = (json[ApiJsonKeys.players] as List)
        .map((playerJson) => Player.fromJson(playerJson as Map<String, dynamic>))
        .toList();
    print("Players in team deserialized: ${players.length}");

  List<Player> historicalPlayers  = (json[ApiJsonKeys.historicalPlayers] as List)
        .map((playerJson) => Player.fromJson(playerJson as Map<String, dynamic>))
        .toList();
    print("Historical players in team deserialized: ${historicalPlayers.length}");

    return PlayersInTeamResponse(
      players: players,
      historicalPlayers: historicalPlayers,
    );
  }
}