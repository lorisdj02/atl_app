import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/team.dart';

class TeamsResponse {
  final Map<double, Team> teamsCache;
  final Map<double, String> captainNamePerTeam;

  TeamsResponse({required this.teamsCache, required this.captainNamePerTeam});

  factory TeamsResponse.fromJson(Map<String, dynamic> json) {
    Map<double, Team> teamsCache = Map<double, Team>.from(
      json[ApiJsonKeys.teamsCache].map(
        (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
      ),
    );
    print("TeamsCache size: ${teamsCache.length}");

    Map<double, String> captainNamePerTeam = Map<double, String>.from(
      json[ApiJsonKeys.captainNamePerTeam].map(
        (key, value) => MapEntry(double.parse(key), value),
      ),
    );
    print("CaptainNamePerTeam size: ${captainNamePerTeam.length}");

    return TeamsResponse(
      teamsCache: teamsCache,
      captainNamePerTeam: captainNamePerTeam,
    );
  }
}
