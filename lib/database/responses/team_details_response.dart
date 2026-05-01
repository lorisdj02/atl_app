import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/database/responses/abstract_team_response.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/palmares.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/models/tournament.dart';

class TeamDetailsResponse extends AbstractTeamResponse {
  final bool isPlayerInTeam;
  final TeamRequest? existingRequest;

  TeamDetailsResponse({
    required super.team,
    required super.players,
    required super.palmares,
    required super.tournaments,
    required super.coordinatorsCache,
    required super.fieldsCache,
    required super.footballPlayerStatsCache,
    required super.cityNamePerField,
    required super.historicalPlayers,
    required this.existingRequest,
    required this.isPlayerInTeam,
  });

  factory TeamDetailsResponse.fromJson(Map<String, dynamic> json) {
    Team team = Team.fromJson(json[ApiJsonKeys.team]);
    print(
      "TeamDetailsResponse.fromJson: teamId=${team.id}, teamName=${team.name}",
    );

    List<Player> players = List<Player>.from(
      (json[ApiJsonKeys.players] as List).map((e) => Player.fromJson(e)),
    );
    print("TeamDetailsResponse.fromJson: players count=${players.length}");

    List<Palmares> palmares = List<Palmares>.from(
      (json[ApiJsonKeys.palmares] as List).map((e) => Palmares.fromJson(e)),
    );
    print("TeamDetailsResponse.fromJson: palmares count=${palmares.length}");

    List<Tournament> tournaments = List<Tournament>.from(
      (json[ApiJsonKeys.tournaments] as List).map(
        (e) => Tournament.fromJson(e),
      ),
    );
    print(
      "TeamDetailsResponse.fromJson: tournaments count=${tournaments.length}",
    );

    Map<double, FootballTeamStats> footballPlayerStatsCache =
        Map<double, FootballTeamStats>.from(
          (json[ApiJsonKeys.footballPlayerStatsCache] as Map).map(
            (key, value) =>
                MapEntry(double.parse(key), FootballTeamStats.fromJson(value)),
          ),
        );
    print(
      "TeamDetailsResponse.fromJson: footballPlayerStatsCache count=${footballPlayerStatsCache.length}",
    );

    Map<double, String> cityNamePerField = Map<double, String>.from(
      (json[ApiJsonKeys.cityNamePerField] as Map).map(
        (key, value) => MapEntry(double.parse(key), value as String),
      ),
    );
    print(
      "TeamDetailsResponse.fromJson: cityNamePerField count=${cityNamePerField.length}",
    );

    List<Player> historicalPlayers = List<Player>.from(
      (json[ApiJsonKeys.historicalPlayers] as List).map(
        (e) => Player.fromJson(e),
      ),
    );
    print(
      "TeamDetailsResponse.fromJson: historicalPlayers count=${historicalPlayers.length}",
    );

    Map<double, Coordinator> coordinatorsCache = Map<double, Coordinator>.from(
      (json[ApiJsonKeys.coordinatorsCache] as Map).map(
        (key, value) =>
            MapEntry(double.parse(key), Coordinator.fromJson(value)),
      ),
    );
    print(
      "TeamDetailsResponse.fromJson: coordinatorsCache count=${coordinatorsCache.length}",
    );

    Map<double, Field> fieldsCache = Map<double, Field>.from(
      (json[ApiJsonKeys.fieldsCache] as Map).map(
        (key, value) => MapEntry(double.parse(key), Field.fromJson(value)),
      ),
    );
    print(
      "TeamDetailsResponse.fromJson: fieldsCache count=${fieldsCache.length}",
    );

    bool isPlayerInTeam = json[ApiJsonKeys.isPlayerInTeam] as bool;
    print("TeamDetailsResponse.fromJson: isPlayerInTeam=$isPlayerInTeam");

    TeamRequest? existingRequest = json[ApiJsonKeys.existingRequest] != null
        ? TeamRequest.fromJson(json[ApiJsonKeys.existingRequest])
        : null;
    print(
      "TeamDetailsResponse.fromJson: existingRequest=${existingRequest != null ? 'exists' : 'null'}",
    );

    return TeamDetailsResponse(
      team: team,
      players: players,
      palmares: palmares,
      tournaments: tournaments,
      coordinatorsCache: coordinatorsCache,
      fieldsCache: fieldsCache,
      footballPlayerStatsCache: footballPlayerStatsCache,
      cityNamePerField: cityNamePerField,
      isPlayerInTeam: isPlayerInTeam,
      existingRequest: existingRequest,
      historicalPlayers: historicalPlayers,
    );
  }
}
