import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';

class AssignFootballPrizesResponse {
  final Tournament tournament;
  final Team team;
  final Map<String, Player> playersCache;
  final Map<double, FootballTeamStats> footballPlayerStatsCache;
  final bool isWinner;

  AssignFootballPrizesResponse({
    required this.tournament,
    required this.team,
    required this.playersCache,
    required this.footballPlayerStatsCache,
    required this.isWinner,
  });

  factory AssignFootballPrizesResponse.fromJson(Map<String, dynamic> json) {
    return AssignFootballPrizesResponse(
      tournament: Tournament.fromJson(json[ApiJsonKeys.tournament]),
      team: Team.fromJson(json[ApiJsonKeys.team]),
      playersCache: (json[ApiJsonKeys.playersCache] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Player.fromJson(value)),
      ),
      footballPlayerStatsCache: (json[ApiJsonKeys.footballPlayerStatsCache] as Map<String, dynamic>).map(
        (key, value) => MapEntry(double.parse(key), FootballTeamStats.fromJson(value)),
      ),
      isWinner: json[ApiJsonKeys.isWinner],
    );
  }
}