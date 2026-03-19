//TODO: sicuramente sarà da cambiare

import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/tournament.dart';

class RoadToVictoryResponse {
  final Tournament tournament;
  final List<FootballMatch> matches;

  RoadToVictoryResponse({required this.tournament, required this.matches});

  factory RoadToVictoryResponse.fromJson(Map<String, dynamic> json) {
    final tournament = Tournament.fromJson(
      json[ApiJsonKeys.tournament] as Map<String, dynamic>,
    );
    final matches = List<FootballMatch>.from(
      (json[ApiJsonKeys.matches] as List<dynamic>).map(
        (matchJson) =>
            FootballMatch.fromJson(matchJson as Map<String, dynamic>),
      ),
    );

    return RoadToVictoryResponse(tournament: tournament, matches: matches);
  }
}
