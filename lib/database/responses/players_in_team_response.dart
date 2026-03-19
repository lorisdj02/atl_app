

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
    return PlayersInTeamResponse(
      players: (json[ApiJsonKeys.players] as List<dynamic>)
          .map((playerJson) => Player.fromJson(playerJson as Map<String, dynamic>))
          .toList(),
      historicalPlayers: (json[ApiJsonKeys.historicalPlayers] as List<dynamic>)
          .map((playerJson) => Player.fromJson(playerJson as Map<String, dynamic>))
          .toList(),
    );
  }
}