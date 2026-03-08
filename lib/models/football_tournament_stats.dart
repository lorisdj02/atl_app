/// Modello per le statistiche dei giocatori nei tornei di calcio
class FootballTournamentStats {
  final int playerId;
  final int tournamentId;
  final int teamId;
  int goals;
  int motm; // Man of the Match
  int yellowCards;
  int redCards;

  FootballTournamentStats({
    required this.playerId,
    required this.tournamentId,
    required this.teamId,
    this.goals = 0,
    this.motm = 0,
    this.yellowCards = 0,
    this.redCards = 0,
  });

  factory FootballTournamentStats.fromJson(Map<String, dynamic> json) {
    return FootballTournamentStats(
      playerId: json['player_id'],
      tournamentId: json['tournament_id'],
      teamId: json['team_id'],
      goals: json['goals'] ?? 0,
      motm: json['motm'] ?? 0,
      yellowCards: json['yellow_cards'] ?? 0,
      redCards: json['red_cards'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'tournament_id': tournamentId,
      'team_id': teamId,
      'goals': goals,
      'motm': motm,
      'yellow_cards': yellowCards,
      'red_cards': redCards,
    };
  }

  @override
  String toString(){
    return 'FootballTournamentStats(playerId: $playerId, tournamentId: $tournamentId, teamId: $teamId, goals: $goals, motm: $motm, yellowCards: $yellowCards, redCards: $redCards)';
  }
  /// Media gol per partita (da calcolare con numero partite giocate)
  // TODO: Aggiungere goalsPerMatch quando disponibili i dati delle partite
}
