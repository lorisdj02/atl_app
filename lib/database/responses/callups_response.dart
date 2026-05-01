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
    return CallupsResponse(
      players: List<Player>.from(
        (json[ApiJsonKeys.players] as List<dynamic>).map(
          (e) => Player.fromJson(e as Map<String, dynamic>),
        ),
      ),
      sport: Sport.fromJson(json[ApiJsonKeys.sport] as Map<String, dynamic>),
      calledUpPlayerIds: List<double>.from(
        (json[ApiJsonKeys.calledUpPlayerIds] as List<dynamic>)
            .map((e) => e as double)
            .toList(),
      ),
      tournament: Tournament.fromJson(
        json[ApiJsonKeys.tournament] as Map<String, dynamic>,
      ),
    );
  }
}
