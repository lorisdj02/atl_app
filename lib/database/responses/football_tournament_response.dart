import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';

class FootballTournamentResponse {
  final List<FootballMatch> matches;
  final List<FootballStanding> standings;
  final List<Player> players;
  final Map<double, Team> teamsCache;
  final Map<double, FootballTeamStats> footballPlayerStatsCache;
  final int minutesPerRound;
  final int minutesPerPause;
  final bool? canContinue;

  FootballTournamentResponse({
    required this.matches,
    required this.standings,
    required this.players,
    required this.teamsCache,
    required this.footballPlayerStatsCache,
    required this.minutesPerRound,
    required this.minutesPerPause,
    this.canContinue,
  });

  factory FootballTournamentResponse.fromJson(Map<String, dynamic> json) {
    return FootballTournamentResponse(
      matches: List<FootballMatch>.from(
        (json[ApiJsonKeys.matches] as List).map(
          (m) => FootballMatch.fromJson(m),
        ),
      ),
      standings: List<FootballStanding>.from(
        (json[ApiJsonKeys.standings] as List).map(
          (s) => FootballStanding.fromJson(s),
        ),
      ),
      players: List<Player>.from(
        (json[ApiJsonKeys.players] as List).map(
          (p) => Player.fromJson(p),
        ),
      ),
      teamsCache: Map<double, Team>.from(
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        ),
      ),
      footballPlayerStatsCache: Map<double, FootballTeamStats>.from(
        (json[ApiJsonKeys.footballPlayerStatsCache] as Map<String, dynamic>)
            .map(
          (key, value) =>
              MapEntry(double.parse(key), FootballTeamStats.fromJson(value)),
        ),
      ),
      minutesPerRound: json[ApiJsonKeys.minutesPerRound] as int,
      minutesPerPause: json[ApiJsonKeys.minutesPerPause] as int,
      canContinue: json[ApiJsonKeys.canContinue] as bool?,
    );
  }
}
