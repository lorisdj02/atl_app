

import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/palmares.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';

class AbstractTeamResponse {
  final Team team;
  final List<Player> players;
  final List<Palmares> palmares;
  final List<Tournament> tournaments;
  final Map<int, Coordinator> coordinatorsCache;
  final Map<int, Field> fieldsCache;
  final Map<int, FootballTeamStats> footballPlayerStatsCache;
  final Map<int, String> cityNamePerField;
  final List<Player> historicalPlayers;

  AbstractTeamResponse({
    required this.team,
    required this.players,
    required this.palmares,
    required this.tournaments,
    required this.coordinatorsCache,
    required this.fieldsCache,
    required this.footballPlayerStatsCache,
    required this.cityNamePerField,
    required this.historicalPlayers,
  });

  factory AbstractTeamResponse.fromJson(Map<String, dynamic> json) {
    return AbstractTeamResponse(
      team: Team.fromJson(json[ApiJsonKeys.team]),
      players: List<Player>.from(json[ApiJsonKeys.players].map((x) => Player.fromJson(x))),
      palmares: List<Palmares>.from(json[ApiJsonKeys.palmares].map((x) => Palmares.fromJson(x))),
      tournaments: List<Tournament>.from(json[ApiJsonKeys.tournaments].map((x) => Tournament.fromJson(x))),
      coordinatorsCache:
          Map<int, Coordinator>.from(json[ApiJsonKeys.coordinatorsCache].map((key, value) => MapEntry(int.parse(key), Coordinator.fromJson(value)))),
      fieldsCache: Map<int, Field>.from(json[ApiJsonKeys.fieldsCache].map((key, value) => MapEntry(int.parse(key), Field.fromJson(value)))),
      footballPlayerStatsCache: Map<int, FootballTeamStats>.from(json[ApiJsonKeys.footballPlayerStatsCache].map((key, value) => MapEntry(int.parse(key), FootballTeamStats.fromJson(value)))),
      cityNamePerField:
          Map<int, String>.from(json[ApiJsonKeys.cityNamePerField].map((key, value) => MapEntry(int.parse(key), value as String))),
      historicalPlayers:
          List<Player>.from(json[ApiJsonKeys.historicalPlayers].map((x) => Player.fromJson(x))),
    );
  }

}