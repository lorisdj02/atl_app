import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';

class AvailableMatchesResponse {
  final List<FootballMatch> footballMatches;
  final Map<double, Team> teamsCache;
  final Map<double, int> minutesRoundPerTournament;
  final Map<double, int> minutesPausePerTournament;
  final Map<double, List<FootballMatch>> footballMatchesPerSport;
  final Map<double, String> sportNames;

  AvailableMatchesResponse({
    required this.footballMatches,
    required this.teamsCache,
    required this.minutesRoundPerTournament,
    required this.minutesPausePerTournament,
    required this.footballMatchesPerSport,
    required this.sportNames,
  });

  factory AvailableMatchesResponse.fromJson(Map<String, dynamic> json) {
    final List<FootballMatch> footballMatches =
        (json[ApiJsonKeys.footballMatches] as List<dynamic>)
            .map((e) => FootballMatch.fromJson(e as Map<String, dynamic>))
            .toList();
    print("Football matches parsed: ${footballMatches.length}");

    final Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            double.parse(key),
            Team.fromJson(value as Map<String, dynamic>),
          ),
        );
    print("Teams parsed: ${teamsCache.values.length}");

    final Map<double, int> minutesRoundPerTournament =
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value as int));
    print(
      "Minutes round per tournament parsed: ${minutesRoundPerTournament.values.length}",
    );

    final Map<double, int> minutesPausePerTournament =
        (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value as int));
    print(
      "Minutes pause per tournament parsed: ${minutesPausePerTournament.values.length}",
    );

    final Map<double, List<FootballMatch>> footballMatchesPerSport =
        (json[ApiJsonKeys.footballMatchesPerSport] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            double.parse(key),
            (value as List<dynamic>)
                .map((e) => FootballMatch.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
        );
    print(
      "Football matches per sport parsed: ${footballMatchesPerSport.values.length}",
    );

    final Map<double, String> sportNames =
        (json[ApiJsonKeys.sportNames] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value as String),
        );
    print("Sport names parsed: ${sportNames.values.length}");

    return AvailableMatchesResponse(
      footballMatches: footballMatches,
      teamsCache: teamsCache,
      minutesRoundPerTournament: minutesRoundPerTournament,
      minutesPausePerTournament: minutesPausePerTournament,
      footballMatchesPerSport: footballMatchesPerSport,
      sportNames: sportNames,
    );
  }
}
