import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';

class AvailableMatchesResponse {
  final List<FootballMatch> footballMatches;
  final Map<int, Team> teamsCache;
  final Map<int, int> minutesRoundPerTournament;
  final Map<int, int> minutesPausePerTournament;
  final Map<int, List<FootballMatch>> footballMatchesPerSport;
  final Map<int, String> sportNames;

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
      teamsCache: Map<int, Team>.from(
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(int.parse(key), Team.fromJson(value as Map<String, dynamic>)),
        ),
      ),
      minutesRoundPerTournament:
          Map<int, int>.from(
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(int.parse(key), value as int)),
      ),
          minutesPausePerTournament:
          Map<int, int>.from(
            (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
                .map((key, value) => MapEntry(int.parse(key), value as int)),
          ),
      footballMatchesPerSport:
          Map<int, List<FootballMatch>>.from(
            (json[ApiJsonKeys.footballMatchesPerSport] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                int.parse(key),
                (value as List<dynamic>)
                    .map((e) => FootballMatch.fromJson(e as Map<String, dynamic>))
                    .toList(),
              ),
            ),
          ),
      sportNames: Map<int, String>.from(
        (json[ApiJsonKeys.sportNames] as Map<String, dynamic>).map(
          (key, value) => MapEntry(int.parse(key), value as String),
        ),
      ),
    );
  }
}
