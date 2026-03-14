/// Modello per le statistiche dei giocatori nei team
class FootballTeamStats {
  final int id;
  final int playerId;
  final int teamId;
  int motm;
  int goals;
  int redCards;
  int yellowCards;

  FootballTeamStats({
    required this.id,
    required this.playerId,
    required this.teamId,
    this.motm = 0,
    this.goals = 0,
    this.redCards = 0,
    this.yellowCards = 0,
  });

  factory FootballTeamStats.fromJson(Map<String, dynamic> json) {
    return FootballTeamStats(
      id: json['id'] as int,
      playerId: json['playerId'] as int,
      teamId: json['teamId'] as int,
      motm: json['motm'] as int,
      goals: json['goals'] as int,
      redCards: json['redCards'] as int,
      yellowCards: json['yellowCards'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'teamId': teamId,
      'motm': motm,
      'goals': goals,
      'redCards': redCards,
      'yellowCards': yellowCards,
    };
  }

  FootballTeamStats copyWith({int? playerId, int? teamId, int? motm, int? goals, int? redCards, int? yellowCards  }) {
    return FootballTeamStats(
      id: id,
      playerId: playerId ?? this.playerId,
      teamId: teamId ?? this.teamId,
      motm: motm ?? this.motm,
      goals: goals ?? this.goals,
      redCards: redCards ?? this.redCards,
      yellowCards: yellowCards ?? this.yellowCards,
    );
  }

  @override
  String toString() {
    return 'FootballTeamStats(id: $id, playerId: $playerId, teamId: $teamId, motm: $motm, goals: $goals, redCards: $redCards, yellowCards: $yellowCards)';
  }
}
