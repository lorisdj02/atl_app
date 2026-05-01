/// Modello per le statistiche dei giocatori nei team
/// OK
class FootballTeamStats {
  final double teamId;
  final double playerId;
  final int goals;
  final int motm;
  final int yellowCards;
  final int redCards;

  FootballTeamStats({
    required this.teamId,
    required this.playerId,
    required this.goals,
    required this.motm,
    required this.yellowCards,
    required this.redCards,
  });

  factory FootballTeamStats.fromJson(Map<String, dynamic> json) {
    return FootballTeamStats(
      teamId: (json['team_id'] as num?)?.toDouble() ?? 0.0,
      playerId: (json['player_id'] as num?)?.toDouble() ?? 0.0,
      goals: (json['goals'] as num?)?.toInt() ?? 0,
      motm: (json['motm'] as num?)?.toInt() ?? 0,
      yellowCards: (json['yellow_cards'] as num?)?.toInt() ?? 0,
      redCards: (json['red_cards'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'player_id': playerId,
      'goals': goals,
      'motm': motm,
      'yellow_cards': yellowCards,
      'red_cards': redCards,
    };
  }
}
