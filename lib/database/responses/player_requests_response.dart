
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
    return PlayerRequestsResponse(
      teamRequests: List<TeamRequest>.from(
        (json[ApiJsonKeys.teamRequests] as List<dynamic>).map(
          (e) => TeamRequest.fromJson(e as Map<String, dynamic>),
        ),
      ),
      playersCache: Map<double, Player>.from(
        (json[ApiJsonKeys.playersCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            double.parse(key),
            Player.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
    );
  }
}