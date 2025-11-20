

class TournamentPartecipation {
  final String tournamentId;
  final String teamId;

  TournamentPartecipation({
    required this.tournamentId,
    required this.teamId,
  });

  factory TournamentPartecipation.fromJson(Map<String, dynamic> json) {
    return TournamentPartecipation(
      tournamentId: json['tournamentId'],
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'teamId': teamId,
    };
  }
}