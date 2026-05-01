// OK
class FootballStanding {
  final double tournamentId;
  final double teamId;
  final String groupName;
  final int pts;
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
    required this.pts,
  });

  factory FootballStanding.fromJson(Map<String, dynamic> json) {
    return FootballStanding(
      tournamentId: (json['tournamentId'] as num?)?.toDouble() ?? 0.0,
      teamId: (json['teamId'] as num?)?.toDouble() ?? 0.0,
      groupName: json['groupName'] ?? '',
      won: (json['won'] as num?)?.toInt() ?? 0,
      drawn: (json['drawn'] as num?)?.toInt() ?? 0,
      lost: (json['lost'] as num?)?.toInt() ?? 0,
      goalsScored: (json['goalsScored'] as num?)?.toInt() ?? 0,
      goalsConceded: (json['goalsConceded'] as num?)?.toInt() ?? 0,
      rankPos: (json['rankPos'] as num?)?.toInt() ?? 0,
      qualified: json['qualified'] ?? false,
      pts: (json['pts'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'teamId': teamId,
      'groupName': groupName,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'goalsScored': goalsScored,
      'goalsConceded': goalsConceded,
      'rankPos': rankPos,
      'qualified': qualified,
      'pts': pts,
    };
  }
}
