

import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';

class CoordinatorHomeResponse {
  final List<Tournament> activeTournaments;
  final Map<int, List<FootballMatch>> footballMatchesPerTournament;
  final Map<int, Team> teamsCache;
  final Map<int, int> minutesRoundPerTournament;
  final Map<int, int> minutesPausePerTournament;

  CoordinatorHomeResponse({
    required this.activeTournaments,
    required this.footballMatchesPerTournament,
    required this.teamsCache,
    required this.minutesRoundPerTournament,
    required this.minutesPausePerTournament,
  });

  factory CoordinatorHomeResponse.fromJson(Map<String, dynamic> json) {
    return CoordinatorHomeResponse(
      activeTournaments: (json[ApiJsonKeys.activeTournaments] as List)
          .map((t) => Tournament.fromJson(t))
          .toList(),
      footballMatchesPerTournament: Map<int, List<FootballMatch>>.from(json[ApiJsonKeys.footballMatchesPerTournament].map((key, value) => MapEntry(int.parse(key), (value as List).map((m) => FootballMatch.fromJson(m)).toList()))),
      teamsCache: Map<int, Team>.from(json[ApiJsonKeys.teamsCache].map((key, value) => MapEntry(int.parse(key), Team.fromJson(value)))),
      minutesRoundPerTournament: Map<int, int>.from(json[ApiJsonKeys.minutesRoundPerTournament].map((key, value) => MapEntry(int.parse(key), value))),
      minutesPausePerTournament: Map<int, int>.from(json[ApiJsonKeys.minutesPausePerTournament].map((key, value) => MapEntry(int.parse(key), value))),
    );
  }
}