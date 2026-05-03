import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';

class RefereeHomeResponse {
  final List<FootballMatch> assignedFootballMatches;
  final Map<double, Team> teamsCache;
  final Map<double, int> minutesRoundPerTournament;
  final Map<double, int> minutesPausePerTournament;

  RefereeHomeResponse({
    required this.assignedFootballMatches,
    required this.teamsCache,
    required this.minutesRoundPerTournament,
    required this.minutesPausePerTournament,
  });

  factory RefereeHomeResponse.fromJson(Map<String, dynamic> json) {
    final List<FootballMatch> assignedFootballMatches =
        (json[ApiJsonKeys.assignedFootballMatches] as List)
            .map((m) => FootballMatch.fromJson(m))
            .toList();
    print(
      "Assigned football matches deserialized: ${assignedFootballMatches.length}",
    );

    final Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        );
    print("Teams cache deserialized: ${teamsCache.length}");

    final Map<double, int> minutesRoundPerTournament =
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value));
    print(
      "Minutes round per tournament deserialized: ${minutesRoundPerTournament.length}",
    );

    final Map<double, int> minutesPausePerTournament =
        (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value));
    print(
      "Minutes pause per tournament deserialized: ${minutesPausePerTournament.length}",
    );

    return RefereeHomeResponse(
      assignedFootballMatches: assignedFootballMatches,
      teamsCache: teamsCache,
      minutesRoundPerTournament: minutesRoundPerTournament,
      minutesPausePerTournament: minutesPausePerTournament,
    );
  }
}
