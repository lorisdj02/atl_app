import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/team.dart';

class TeamsResponse {
  final Map<int, Team> teamsCache;
  final Map<int, String> captainNamePerTeam;

  TeamsResponse({required this.teamsCache, required this.captainNamePerTeam});

  factory TeamsResponse.fromJson(Map<String, dynamic> json) {
    return TeamsResponse(
      teamsCache: Map<int, Team>.from(
        json[ApiJsonKeys.teamsCache].map(
          (key, value) => MapEntry(int.parse(key), Team.fromJson(value)),
        ),
      ),
      captainNamePerTeam: Map<int, String>.from(
        json[ApiJsonKeys.captainNamePerTeam].map(
          (key, value) => MapEntry(int.parse(key), value),
        ),
      ),
    );
  }
}
