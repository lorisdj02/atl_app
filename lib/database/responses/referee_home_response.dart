
import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/referee_assignment.dart';
import 'package:atl_app/models/team.dart';

class RefereeHomeResponse {
  final List<RefereeAssignment> assignments;
  final List<FootballMatch> assignedFootballMatches;
  final Map<int, Team> teamsCache;
  final Map<int, int> minutesRoundPerTournament;
  final Map<int, int> minutesPausePerTournament;

  RefereeHomeResponse({
    required this.assignments,
    required this.assignedFootballMatches,
    required this.teamsCache,
    required this.minutesRoundPerTournament,
    required this.minutesPausePerTournament,
  });

  factory RefereeHomeResponse.fromJson(Map<String, dynamic> json) {
    return RefereeHomeResponse(
      assignments: List<RefereeAssignment>.from(json[ApiJsonKeys.assignments].map((a) => RefereeAssignment.fromJson(a))),
      assignedFootballMatches: List<FootballMatch>.from(json[ApiJsonKeys.assignedFootballMatches].map((m) => FootballMatch.fromJson(m))),
      teamsCache: Map<int, Team>.from(json[ApiJsonKeys.teamsCache].map((key, value) => MapEntry(int.parse(key), Team.fromJson(value)))),
      minutesRoundPerTournament: Map<int, int>.from(json[ApiJsonKeys.minutesRoundPerTournament].map((key, value) => MapEntry(int.parse(key), value))),
      minutesPausePerTournament: Map<int, int>.from(json[ApiJsonKeys.minutesPausePerTournament].map((key, value) => MapEntry(int.parse(key), value))),
    );
  }
}