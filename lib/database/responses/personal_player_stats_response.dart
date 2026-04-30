import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/sport_category.dart';

class PersonalPlayerStatsResponse {
  final FootballTeamStats footballStats;
  final Map<SportCategory, int> numTournamentPerCategory;
  final Map<SportCategory, int> numPrivateBookingPerCategory;
  final Map<SportCategory, int> numLobbyJoinedPerCategory;

  PersonalPlayerStatsResponse({
    required this.footballStats,
    required this.numTournamentPerCategory,
    required this.numPrivateBookingPerCategory,
    required this.numLobbyJoinedPerCategory,
  });

  factory PersonalPlayerStatsResponse.fromJson(Map<String, dynamic> json) {
    return PersonalPlayerStatsResponse(
      footballStats: FootballTeamStats.fromJson(
        json[ApiJsonKeys.footballStats],
      ),
      numTournamentPerCategory: Map<SportCategory, int>.from(
        json[ApiJsonKeys.numTournamentPerCategory].map(
          (key, value) => MapEntry(
            SportCategory.values.firstWhere((e) => e.apiName == key),
            value,
          ),
        ),
      ),
      numPrivateBookingPerCategory: Map<SportCategory, int>.from(
        json[ApiJsonKeys.numPrivateBookingPerCategory].map(
          (key, value) => MapEntry(
            SportCategory.values.firstWhere((e) => e.apiName == key),
            value,
          ),
        ),
      ),
      numLobbyJoinedPerCategory: Map<SportCategory, int>.from(
        json[ApiJsonKeys.numLobbyJoinedPerCategory].map(
          (key, value) => MapEntry(
            SportCategory.values.firstWhere((e) => e.apiName == key),
            value,
          ),
        ),
      ),
    );
  }
}
