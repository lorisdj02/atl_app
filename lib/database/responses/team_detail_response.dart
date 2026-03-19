import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/database/responses/abstract_team_response.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/palmares.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/models/tournament.dart';

class TeamDetailResponse extends AbstractTeamResponse {
  final bool isPlayerInTeam;
  final TeamRequest? existingRequest;
  
  TeamDetailResponse({
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

  factory TeamDetailResponse.fromJson(Map<String, dynamic> json) {
    return TeamDetailResponse(
      team: Team.fromJson(json[ApiJsonKeys.team]),
      players: List<Player>.from(
        (json[ApiJsonKeys.players] as List).map((e) => Player.fromJson(e)),
      ),
      palmares: List<Palmares>.from(
        (json[ApiJsonKeys.palmares] as List).map((e) => Palmares.fromJson(e)),
      ),
      tournaments: List<Tournament>.from(
        (json[ApiJsonKeys.tournaments] as List).map(
          (e) => Tournament.fromJson(e),
        ),
      ),
      coordinatorsCache: json[ApiJsonKeys.coordinatorsCache] ?? {},
      fieldsCache: json[ApiJsonKeys.fieldsCache] ?? {},
      footballPlayerStatsCache: Map<int, FootballTeamStats>.from(
        (json[ApiJsonKeys.footballPlayerStatsCache] as Map).map(
          (key, value) =>
              MapEntry(int.parse(key), FootballTeamStats.fromJson(value)),
        ),
      ),
      cityNamePerField: json[ApiJsonKeys.cityNamePerField] ?? {},
      isPlayerInTeam: json[ApiJsonKeys.isPlayerInTeam],
      existingRequest: json[ApiJsonKeys.existingRequest] != null
          ? TeamRequest.fromJson(json[ApiJsonKeys.existingRequest])
          : null,
      historicalPlayers: List<Player>.from(
        (json[ApiJsonKeys.historicalPlayers] as List).map(
          (e) => Player.fromJson(e),
        ),
      ),
    );
  }
}
