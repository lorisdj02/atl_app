import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';

class AssignFootballPrizesResponse {
  final Tournament tournament;
  final Team team;
  final Map<double, Player> playersCache;
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
    Tournament tournament = Tournament.fromJson(json[ApiJsonKeys.tournament]);
    print('Parsed tournament: ${tournament.id} - ${tournament.name}');

    Team team = Team.fromJson(json[ApiJsonKeys.team]);
    print('Parsed team: ${team.id} - ${team.name}');

    Map<double, Player> playersCache = (json[ApiJsonKeys.playersCache] as Map<String, dynamic>).map(
      (key, value) => MapEntry(double.parse(key), Player.fromJson(value)),
    );
    print("Parsed players cache: $playersCache");

    Map<double, FootballTeamStats> footballPlayerStatsCache = (json[ApiJsonKeys.footballPlayerStatsCache] as Map<String, dynamic>).map(
      (key, value) => MapEntry(double.parse(key), FootballTeamStats.fromJson(value)),
    );
    print("Parsed football player stats cache: $footballPlayerStatsCache");

    bool isWinner = json[ApiJsonKeys.isWinner];
    print("Parsed isWinner: $isWinner");


    return AssignFootballPrizesResponse(
      tournament: tournament,
      team: team,
      playersCache: playersCache,
      footballPlayerStatsCache: footballPlayerStatsCache,
      isWinner: isWinner,
    );
  }
}