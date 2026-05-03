import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/final_stage_bracket.dart';

class FootballTournamentResponse {
  final List<FootballMatch> matches;
  final List<FootballStanding> standings;
  final List<Player> players;
  final Map<double, Team> teamsCache;
  final Map<double, FootballTeamStats> footballPlayerStatsCache;
  final List<FinalStageBracket> finalStageBrackets;
  final int minutesPerRound;
  final int minutesPerPause;
  final bool? canContinue;

  FootballTournamentResponse({
    required this.matches,
    required this.standings,
    required this.players,
    required this.teamsCache,
    required this.footballPlayerStatsCache,
    required this.finalStageBrackets,
    required this.minutesPerRound,
    required this.minutesPerPause,
    this.canContinue,
  });

  factory FootballTournamentResponse.fromJson(Map<String, dynamic> json) {
    final List<FootballMatch> matches = (json[ApiJsonKeys.matches] as List)
        .map((m) => FootballMatch.fromJson(m))
        .toList();
    print("Matches parsed: ${matches.length}");

    final List<FootballStanding> standings = (json[ApiJsonKeys.standings] as List)
        .map((s) => FootballStanding.fromJson(s))
        .toList();
    print("Standings parsed: ${standings.length}");

    final List<Player> players = (json[ApiJsonKeys.players] as List)
        .map((p) => Player.fromJson(p))
        .toList();
    print("Players parsed: ${players.length}");

    final Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        );
    print("Teams cache parsed: ${teamsCache.length}");

    final Map<double, FootballTeamStats> footballPlayerStatsCache =
        (json[ApiJsonKeys.footballPlayerStatsCache] as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                double.parse(key),
                FootballTeamStats.fromJson(value),
              ),
            );
    print(
      "Football player stats cache parsed: ${footballPlayerStatsCache.length}",
    );

    final int minutesPerRound = (json[ApiJsonKeys.minutesPerRound] as num).toInt();
    final int minutesPerPause = (json[ApiJsonKeys.minutesPerPause] as num).toInt();
    print(
      "Minutes per round: $minutesPerRound, minutes per pause: $minutesPerPause",
    );

    final bool? canContinue = json[ApiJsonKeys.canContinue] as bool?;
    print("Can continue: $canContinue");

    final List<FinalStageBracket> finalStageBrackets = (json[ApiJsonKeys.finalStageBrackets] as List)
        .map((b) => FinalStageBracket.fromJson(b))
        .toList();
    print("Final stage brackets parsed: ${finalStageBrackets.length}");

    return FootballTournamentResponse(
      matches: matches,
      standings: standings,
      players: players,
      teamsCache: teamsCache,
      footballPlayerStatsCache: footballPlayerStatsCache,
      minutesPerRound: minutesPerRound,
      minutesPerPause: minutesPerPause,
      canContinue: canContinue,
      finalStageBrackets: finalStageBrackets,
    );
  }
}
