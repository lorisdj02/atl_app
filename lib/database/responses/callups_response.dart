import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/sport.dart';
import 'package:atl_app/models/tournament.dart';

import '../../config/api_json_keys.dart';

class CallupsResponse {
  final List<Player> players;
  final Sport sport;
  final List<double> calledUpPlayerIds;
  final Tournament tournament;

  CallupsResponse({
    required this.players,
    required this.sport,
    required this.calledUpPlayerIds,
    required this.tournament,
  });

  factory CallupsResponse.fromJson(Map<String, dynamic> json) {
    final List<Player> players = (json[ApiJsonKeys.players] as List<dynamic>)
        .map((e) => Player.fromJson(e as Map<String, dynamic>))
        .toList();
    print("Players parsed: ${players.length}");

    final Sport sport = Sport.fromJson(json[ApiJsonKeys.sport] as Map<String, dynamic>);
    print("Sport parsed: ${sport.name}");

    final List<double> calledUpPlayerIds = (json[ApiJsonKeys.calledUpPlayerIds] as List<dynamic>)
        .map((e) => e as double)
        .toList();
    print("Called up player IDs parsed: ${calledUpPlayerIds.length}");

    final Tournament tournament = Tournament.fromJson(json[ApiJsonKeys.tournament] as Map<String, dynamic>);
    print("Tournament parsed: ${tournament.name}");

    return CallupsResponse(
      players: players,
      sport: sport,
      calledUpPlayerIds: calledUpPlayerIds,
      tournament: tournament,
    );
  }
}
