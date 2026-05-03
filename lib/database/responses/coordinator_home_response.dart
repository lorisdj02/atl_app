import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';

class CoordinatorHomeResponse {
  final List<Tournament> activeTournaments;
  final Map<double, List<FootballMatch>> footballMatchesPerTournament;
  final Map<double, Team> teamsCache;
  final Map<double, int> minutesRoundPerTournament;
  final Map<double, int> minutesPausePerTournament;

  CoordinatorHomeResponse({
    required this.activeTournaments,
    required this.footballMatchesPerTournament,
    required this.teamsCache,
    required this.minutesRoundPerTournament,
    required this.minutesPausePerTournament,
  });

  factory CoordinatorHomeResponse.fromJson(Map<String, dynamic> json) {
    final List<Tournament> activeTournaments =
        (json[ApiJsonKeys.activeTournaments] as List)
            .map((t) => Tournament.fromJson(t))
            .toList();
    print("Active tournaments parsed: ${activeTournaments.length}");

    final Map<double, List<FootballMatch>> footballMatchesPerTournament =
        (json[ApiJsonKeys.footballMatchesPerTournament] as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                double.parse(key),
                (value as List).map((m) => FootballMatch.fromJson(m)).toList(),
              ),
            );
    print(
      "Football matches per tournament parsed: ${footballMatchesPerTournament.length}",
    );

    final Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        );
    print("Teams cache parsed: ${teamsCache.length}");

    final Map<double, int> minutesRoundPerTournament =
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value));
    print(
      "Minutes round per tournament parsed: ${minutesRoundPerTournament.length}",
    );

    final Map<double, int> minutesPausePerTournament =
        (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value));
    print(
      "Minutes pause per tournament parsed: ${minutesPausePerTournament.length}",
    );

    return CoordinatorHomeResponse(
      activeTournaments: activeTournaments,
      footballMatchesPerTournament: footballMatchesPerTournament,
      teamsCache: teamsCache,
      minutesRoundPerTournament: minutesRoundPerTournament,
      minutesPausePerTournament: minutesPausePerTournament,
    );
  }
}
