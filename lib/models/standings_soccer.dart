/// Modello per le classifiche dei tornei di calcio
class StandingsSoccer {
  final int tournamentId;
  final int teamId;
  final String group;
  final int points;
  final int wins;
  final int draw;
  final int loss;

  StandingsSoccer({
    required this.tournamentId,
    required this.teamId,
    this.group = 'A',
    this.points = 0,
    this.wins = 0,
    this.draw = 0,
    this.loss = 0,
  });

  factory StandingsSoccer.fromJson(Map<String, dynamic> json) {
    return StandingsSoccer(
      tournamentId: json['tournament_id'],
      teamId: json['team_id'],
      group: json['group'] ?? 'A',
      points: json['points'] ?? 0,
      wins: json['wins'] ?? 0,
      draw: json['draw'] ?? 0,
      loss: json['loss'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'team_id': teamId,
      'group': group,
      'points': points,
      'wins': wins,
      'draw': draw,
      'loss': loss,
    };
  }

  /// Numero totale di partite giocate
  int get played => wins + draw + loss;

  /// Differenza reti (da implementare con goals for/against)
  // TODO: Aggiungere goalDifference quando disponibili i dati
}
