/// Modello per le richieste di accesso ai team
/// OK
class TeamRequest {
  final double teamId;
  final double playerId;

  TeamRequest({required this.teamId, required this.playerId});

  factory TeamRequest.fromJson(Map<String, dynamic> json) {
    return TeamRequest(
      teamId: json['teamId'] != null ? (json['teamId'] as num).toDouble() : 0.0,
      playerId: json['playerId'] != null
          ? (json['playerId'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'teamId': teamId, 'playerId': playerId};
  }
}
