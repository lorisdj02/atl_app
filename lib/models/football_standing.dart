class FootballStanding {
  final int tournamentId;
  final int teamId;
  int points;
  int won;
  int drawn;
  int lost;
  int goalsScored;
  int goalsConceded;
  final String group;
  int rank;
  bool qualified;

  FootballStanding({
    required this.teamId,
    this.points = 0,
    this.won = 0,
    this.drawn = 0,
    this.lost = 0,
    required this.tournamentId,
    required this.group,
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
      group: json['group'],
      rank: json['rank'],
      qualified: json['qualified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'points': points,
      'won': won,
      'draw': drawn,
      'lost': lost,
      'tournamentId': tournamentId,
      'group': group,
      'rank': rank,
      'qualified': qualified,
    };
  }
}
