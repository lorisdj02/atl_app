// OK
class TournamentParticipation {
  final double tournamentId;
  final double teamId;
  double toPay;

  TournamentParticipation({
    required this.tournamentId,
    required this.teamId,
    required this.toPay,
  });

  factory TournamentParticipation.fromJson(Map<String, dynamic> json) {
    return TournamentParticipation(
      tournamentId: json['tournamentId'] != null ? (json['tournamentId'] as num).toDouble() : 0.0,
      teamId: json['teamId'] != null ? (json['teamId'] as num).toDouble() : 0.0,
      toPay: json['toPay'] != null ? (json['toPay'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'tournamentId': tournamentId, 'teamId': teamId, 'toPay': toPay};
  }
}
