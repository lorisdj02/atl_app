/// Modello per le statistiche dei giocatori nei team
class TeamStats {
  final int playerId;
  final int teamId;
  final int motm;
  final int goals;

  TeamStats({
    required this.playerId,
    required this.teamId,
    required this.motm,
    required this.goals,
  });

  factory TeamStats.fromJson(Map<String, dynamic> json) {
    return TeamStats(
      playerId: json['player_id'] as int,
      teamId: json['team_id'] as int,
      motm: json['motm'] as int,
      goals: json['goals'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'team_id': teamId,
      'motm': motm,
      'goals': goals,
    };
  }

  TeamStats copyWith({
    int? playerId,
    int? teamId,
    int? motm,
    int? goals,
  }) {
    return TeamStats(
      playerId: playerId ?? this.playerId,
      teamId: teamId ?? this.teamId,
      motm: motm ?? this.motm,
      goals: goals ?? this.goals,
    );
  }

  @override
  String toString() {
    return 'TeamStats(playerId: $playerId, teamId: $teamId, motm: $motm, goals: $goals)';
  }
}
