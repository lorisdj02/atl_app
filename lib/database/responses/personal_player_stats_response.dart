import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/enums/sport_category.dart';

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
    final FootballTeamStats footballStats = FootballTeamStats.fromJson(
      json[ApiJsonKeys.footballStats],
    );
    print("Football stats parsed: ${footballStats.toString()}");

    final Map<SportCategory, int> numTournamentPerCategory =
        (json[ApiJsonKeys.numTournamentPerCategory] as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                SportCategory.values.firstWhere((e) => e.apiName == key),
                value as int,
              ),
            );
    print(
      "Number of tournaments per category parsed: ${numTournamentPerCategory.length}",
    );

    final Map<SportCategory, int> numPrivateBookingPerCategory =
        (json[ApiJsonKeys.numPrivateBookingPerCategory] as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                SportCategory.values.firstWhere((e) => e.apiName == key),
                value as int,
              ),
            );
    print(
      "Number of private bookings per category parsed: ${numPrivateBookingPerCategory.length}",
    );

    final Map<SportCategory, int> numLobbyJoinedPerCategory =
        (json[ApiJsonKeys.numLobbyJoinedPerCategory] as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                SportCategory.values.firstWhere((e) => e.apiName == key),
                value as int,
              ),
            );
    print(
      "Number of lobby joined per category parsed: ${numLobbyJoinedPerCategory.length}",
    );

    return PersonalPlayerStatsResponse(
      footballStats: footballStats,
      numTournamentPerCategory: numTournamentPerCategory,
      numPrivateBookingPerCategory: numPrivateBookingPerCategory,
      numLobbyJoinedPerCategory: numLobbyJoinedPerCategory,
    );
  }
}
