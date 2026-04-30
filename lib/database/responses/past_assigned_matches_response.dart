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
    return PastAssignedMatchesResponse(
      footballMatches: List<FootballMatch>.from(
        (json[ApiJsonKeys.footballMatches] as List<dynamic>).map(
          (e) => FootballMatch.fromJson(e),
        ),
      ),
      teamsCache: Map<double, Team>.from(
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        ),
      ),
      minutesRoundPerTournament: Map<double, int>.from(
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value as int)),
      ),
      minutesPausePerTournament: Map<double, int>.from(
        (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value as int)),
      ),
    );
  }
}
