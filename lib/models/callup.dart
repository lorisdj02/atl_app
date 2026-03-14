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
      tournamentId: json['tournamentId'],
      teamId: json['teamId'],
      playerId: json['playerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'teamId': teamId,
      'playerId': playerId,
    };
  }
}
