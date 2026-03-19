class TournamentParticipation {
  final int tournamentId;
  final int teamId;
  double toPay;

  TournamentParticipation({
    required this.tournamentId,
    required this.teamId,
    required this.toPay,
  });

  factory TournamentParticipation.fromJson(Map<String, dynamic> json) {
    return TournamentParticipation(
      tournamentId: json['tournamentId'],
      teamId: json['teamId'],
      toPay: json['toPay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'tournamentId': tournamentId, 'teamId': teamId, 'toPay': toPay};
  }
}
