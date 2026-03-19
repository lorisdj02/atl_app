class FootballStanding {
  final int tournamentId;
  final int teamId;
  int points;
  int won;
  int drawn;
  int lost;
  int goalsScored;
  int goalsConceded;
  final String groupName;
  int rank;
  bool qualified;

  FootballStanding({
    required this.teamId,
    this.points = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    required this.tournamentId,
    required this.groupName,
    this.goalsScored = 0,
    this.goalsConceded = 0,
    required this.rank,
    this.qualified = false,
  });

  factory FootballStanding.fromJson(Map<String, dynamic> json) {
    return FootballStanding(
      teamId: json['teamId'],
      points: json['points'],
      won: json['won'],
      drawn: json['drawn'],
      lost: json['lost'],
      tournamentId: json['tournamentId'],
      groupName: json['groupName'],
      rank: json['rank'],
      qualified: json['qualified'],
      goalsScored: json['goalsScored'] ?? 0,
      goalsConceded: json['goalsConceded'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'points': points,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'tournamentId': tournamentId,
      'groupName': groupName,
      'rank': rank,
      'qualified': qualified,
      'goalsScored': goalsScored,
      'goalsConceded': goalsConceded,
    };
  }
}
