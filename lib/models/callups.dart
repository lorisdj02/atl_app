class CallUps {
  final int tournamentId;
  final int teamId;
  final int playerId;

  CallUps({
    required this.tournamentId,
    required this.teamId,
    required this.playerId,
  });

  factory CallUps.fromJson(Map<String, dynamic> json) {
    return CallUps(
      tournamentId: json['tournament_id'],
      teamId: json['team_id'],
      playerId: json['player_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'team_id': teamId,
      'player_id': playerId,
    };
  }
}
