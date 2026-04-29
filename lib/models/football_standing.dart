// OK
class FootballStanding {
  final double tournamentId;
  final double teamId;
  final String groupName;
  final int won;
  final int drawn;
  final int lost;
  final int goalsScored;
  final int goalsConceded;
  final int rankPos;
  final bool qualified;

  FootballStanding({
    required this.tournamentId,
    required this.teamId,
    required this.groupName,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsScored,
    required this.goalsConceded,
    required this.rankPos,
    required this.qualified,
  });

  factory FootballStanding.fromJson(Map<String, dynamic> json) {
    return FootballStanding(
      tournamentId: json['tournament_id']?.toDouble() ?? 0.0,
      teamId: json['team_id']?.toDouble() ?? 0.0,
      groupName: json['group_name'] ?? '',
      won: json['won'] ?? 0,
      drawn: json['drawn'] ?? 0,
      lost: json['lost'] ?? 0,
      goalsScored: json['goals_scored'] ?? 0,
      goalsConceded: json['goals_conceded'] ?? 0,
      rankPos: json['rank_pos'] ?? 0,
      qualified: json['qualified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'team_id': teamId,
      'group_name': groupName,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'goals_scored': goalsScored,
      'goals_conceded': goalsConceded,
      'rank_pos': rankPos,
      'qualified': qualified,
    };
  }
}
