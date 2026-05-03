import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';

class PastAssignedMatchesResponse {
  final List<FootballMatch> footballMatches;
  final Map<double, Team> teamsCache;
  final Map<double, int> minutesRoundPerTournament;
  final Map<double, int> minutesPausePerTournament;

  PastAssignedMatchesResponse({
    required this.footballMatches,
    required this.teamsCache,
    required this.minutesRoundPerTournament,
    required this.minutesPausePerTournament,
  });

  factory PastAssignedMatchesResponse.fromJson(Map<String, dynamic> json) {
    final List<FootballMatch> footballMatches =
        (json[ApiJsonKeys.footballMatches] as List<dynamic>)
            .map((e) => FootballMatch.fromJson(e))
            .toList();
    print("Football matches parsed: ${footballMatches.length}");

    final Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        );
    print("Teams cache parsed: ${teamsCache.length}");

    final Map<double, int> minutesRoundPerTournament =
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value as int));
    print(
      "Minutes round per tournament parsed: ${minutesRoundPerTournament.length}",
    );

    final Map<double, int> minutesPausePerTournament =
        (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value as int));
    print(
      "Minutes pause per tournament parsed: ${minutesPausePerTournament.length}",
    );

    return PastAssignedMatchesResponse(
      footballMatches: footballMatches,
      teamsCache: teamsCache,
      minutesRoundPerTournament: minutesRoundPerTournament,
      minutesPausePerTournament: minutesPausePerTournament,
    );
  }
}
