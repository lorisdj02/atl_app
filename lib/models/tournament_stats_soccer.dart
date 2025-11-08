/// Modello per le statistiche dei giocatori nei tornei di calcio
class TournamentStatsSoccer {
  final int playerId;
  final int tournamentId;
  final int goals;
  final int motm; // Man of the Match

  TournamentStatsSoccer({
    required this.playerId,
    required this.tournamentId,
    this.goals = 0,
    this.motm = 0,
  });

  factory TournamentStatsSoccer.fromJson(Map<String, dynamic> json) {
    return TournamentStatsSoccer(
      playerId: json['player_id'],
      tournamentId: json['tournament_id'],
      goals: json['goals'] ?? 0,
      motm: json['motm'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'tournament_id': tournamentId,
      'goals': goals,
      'motm': motm,
    };
  }

  /// Media gol per partita (da calcolare con numero partite giocate)
  // TODO: Aggiungere goalsPerMatch quando disponibili i dati delle partite
}
