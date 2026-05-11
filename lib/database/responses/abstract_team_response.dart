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
  final Map<double, Coordinator> coordinatorsCache;
  final Map<double, Field> fieldsCache;
  final Map<double, FootballTeamStats> footballPlayerStatsCache;
  final Map<double, String> cityNamePerField;
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
    Team team = Team.fromJson(json[ApiJsonKeys.team]);
    print("Team parsed: ${team.name}");

    List<Player> players = (json[ApiJsonKeys.players] as List)
        .map((e) => Player.fromJson(e))
        .toList();
    print("Players parsed: ${players.length}");

    List<Palmares> palmares = (json[ApiJsonKeys.palmares] as List)
        .map((e) => Palmares.fromJson(e))
        .toList();
    print("Palmares parsed: ${palmares.length}");

    List<Tournament> tournaments = (json[ApiJsonKeys.tournaments] as List)
        .map((e) => Tournament.fromJson(e))
        .toList();
    print("Tournaments parsed: ${tournaments.length}");

    Map<double, Coordinator> coordinatorsCache =
        (json[ApiJsonKeys.coordinatorsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(double.parse(key), Coordinator.fromJson(value)),
        );
    print("CoordinatorsCache parsed: ${coordinatorsCache.length}");

    Map<double, Field> fieldsCache = Map<double, Field>.from(
      json[ApiJsonKeys.fieldsCache].map(
        (key, value) => MapEntry(double.parse(key), Field.fromJson(value)),
      ),
    );
    print("FieldsCache parsed: ${fieldsCache.length}");

    Map<double, FootballTeamStats> footballPlayerStatsCache =
        Map<double, FootballTeamStats>.from(
          json[ApiJsonKeys.footballPlayerStatsCache].map(
            (key, value) =>
                MapEntry(double.parse(key), FootballTeamStats.fromJson(value)),
          ),
        );
    print(
      "FootballPlayerStatsCache parsed: ${footballPlayerStatsCache.length}",
    );

    Map<double, String> cityNamePerField = Map<double, String>.from(
      json[ApiJsonKeys.cityNamePerField].map(
        (key, value) => MapEntry(double.parse(key), value as String),
      ),
    );
    print("CityNamePerField parsed: ${cityNamePerField.length}");

    List<Player> historicalPlayers = List<Player>.from(
      json[ApiJsonKeys.historicalPlayers].map((x) => Player.fromJson(x)),
    );
    print("HistoricalPlayers parsed: ${historicalPlayers.length}");

    return AbstractTeamResponse(
      team: team,
      players: players,
      palmares: palmares,
      tournaments: tournaments,
      coordinatorsCache: coordinatorsCache,
      fieldsCache: fieldsCache,
      footballPlayerStatsCache: footballPlayerStatsCache,
      cityNamePerField: cityNamePerField,
      historicalPlayers: historicalPlayers,
    );
  }
}
