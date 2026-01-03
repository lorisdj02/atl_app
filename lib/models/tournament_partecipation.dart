class TournamentPartecipation {
  final int tournamentId;
  final int teamId;
  double? toPay;

  TournamentPartecipation({
    required this.tournamentId,
    required this.teamId,
    this.toPay,
  });

  factory TournamentPartecipation.fromJson(Map<String, dynamic> json) {
    return TournamentPartecipation(
      tournamentId: json['tournamentId'],
      teamId: json['teamId'],
      toPay: json['toPay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'tournamentId': tournamentId, 'teamId': teamId, 'toPay': toPay};
  }
}
