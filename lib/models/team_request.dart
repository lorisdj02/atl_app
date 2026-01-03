/// Modello per le richieste di accesso ai team
class TeamRequest {
  final int teamId;
  final int playerId;

  TeamRequest({required this.teamId, required this.playerId});

  factory TeamRequest.fromJson(Map<String, dynamic> json) {
    return TeamRequest(
      teamId: json['team_id'] as int,
      playerId: json['player_id'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'team_id': teamId, 'player_id': playerId};
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
