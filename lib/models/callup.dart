class Callup {
  final int tournamentId;
  final int teamId;
  final int playerId;
  double? toRedeem;

  Callup({
    required this.tournamentId,
    required this.teamId,
    required this.playerId,
    this.toRedeem,
  });

  factory Callup.fromJson(Map<String, dynamic> json) {
    return Callup(
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
