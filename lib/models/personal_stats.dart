
class PersonalStats{
  final int playerId;
  int goals;
  int motm;

  PersonalStats({
    required this.playerId,
    this.goals = 0,
    this.motm = 0,
  });

  factory PersonalStats.fromJson(Map<String, dynamic> json) {
    return PersonalStats(
      playerId: json['player_id'],
      goals: json['goals'] ?? 0,
      motm: json['motm'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'goals': goals,
      'motm': motm,
    };
  }
}