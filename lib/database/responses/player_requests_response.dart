
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team_request.dart';

class PlayerRequestsResponse {
  final List<TeamRequest> teamRequests;
  final Map<int, Player> playersCache;

  PlayerRequestsResponse({
    required this.teamRequests,
    required this.playersCache,
  });

  factory PlayerRequestsResponse.fromJson(Map<String, dynamic> json) {
    return PlayerRequestsResponse(
      teamRequests: List<TeamRequest>.from(
        (json['teamRequests'] as List<dynamic>).map(
          (e) => TeamRequest.fromJson(e as Map<String, dynamic>),
        ),
      ),
      playersCache: Map<int, Player>.from(
        (json['playersCache'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            int.parse(key),
            Player.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
    );
  }
}