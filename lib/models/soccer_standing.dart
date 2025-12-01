class SoccerStanding {
  final int teamId;
  final int points;
  final int won;
  final int drawn;
  final int lost;
  final int tournamentId;
  final String group;

  SoccerStanding({
    required this.teamId,
    required this.points,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.tournamentId,
    required this.group,
  });

  factory SoccerStanding.fromJson(Map<String, dynamic> json) {
    return SoccerStanding(
      teamId: json['teamId'],
      points: json['points'],
      won: json['won'],
      drawn: json['drawn'],
      lost: json['lost'],
      tournamentId: json['tournamentId'],
      group: json['group'],
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
    };
  }
}