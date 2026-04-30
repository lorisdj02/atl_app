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
    return AvailableMatchesResponse(
      footballMatches: List<FootballMatch>.from(
        (json[ApiJsonKeys.footballMatches] as List<dynamic>).map(
          (e) => FootballMatch.fromJson(e as Map<String, dynamic>),
        ),
      ),
      teamsCache: Map<double, Team>.from(
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value as Map<String, dynamic>)),
        ),
      ),
      minutesRoundPerTournament:
          Map<double, int>.from(
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value as int)),
      ),
          minutesPausePerTournament:
          Map<double, int>.from(
            (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
                .map((key, value) => MapEntry(double.parse(key), value as int)),
          ),
      footballMatchesPerSport:
          Map<double, List<FootballMatch>>.from(
            (json[ApiJsonKeys.footballMatchesPerSport] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                double.parse(key),
                (value as List<dynamic>)
                    .map((e) => FootballMatch.fromJson(e as Map<String, dynamic>))
                    .toList(),
              ),
            ),
          ),
      sportNames: Map<double, String>.from(
        (json[ApiJsonKeys.sportNames] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value as String),
        ),
      ),
    );
  }
}
