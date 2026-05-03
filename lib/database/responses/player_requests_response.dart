
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/config/api_json_keys.dart';

class PlayerRequestsResponse {
  final List<TeamRequest> teamRequests;
  final Map<double, Player> playersCache;

  PlayerRequestsResponse({
    required this.teamRequests,
    required this.playersCache,
  });

  factory PlayerRequestsResponse.fromJson(Map<String, dynamic> json) {
      final List<TeamRequest> teamRequests = (json[ApiJsonKeys.teamRequests] as List<dynamic>)
        .map((e) => TeamRequest.fromJson(e as Map<String, dynamic>))
        .toList();
    print("Team requests deserialized: ${teamRequests.length}");

  final Map<double, Player> playersCache = (json[ApiJsonKeys.playersCache] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        double.parse(key),
        Player.fromJson(value as Map<String, dynamic>),
      ),
    );
    print("Players cache deserialized: ${playersCache.length}");

    return PlayerRequestsResponse(
      teamRequests: teamRequests,
      playersCache: playersCache,
    );
  }
}
