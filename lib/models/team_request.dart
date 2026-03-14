/// Modello per le richieste di accesso ai team
class TeamRequest {
  final int teamId;
  final int playerId;

  TeamRequest({required this.teamId, required this.playerId});

  factory TeamRequest.fromJson(Map<String, dynamic> json) {
    return TeamRequest(
      teamId: json['teamId'] as int,
      playerId: json['playerId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'teamId': teamId, 'playerId': playerId};
  }

  TeamRequest copyWith({int? teamId, int? playerId}) {
    return TeamRequest(
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
    );
  }

  @override
  String toString() {
    return 'TeamRequest(teamId: $teamId, playerId: $playerId)';
  }
}
