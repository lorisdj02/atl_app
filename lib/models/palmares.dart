enum PalmaresPosition {
  WINNER,
  FINALIST,
  SEMI,
  ROUND8,
  ROUND16,
  GROUP_STAGE;

  String get displayName {
    switch (this) {
      case PalmaresPosition.WINNER:
        return '1st';
      case PalmaresPosition.FINALIST:
        return '2nd';
      case PalmaresPosition.SEMI:
        return 'Semi';
      case PalmaresPosition.ROUND8:
        return 'Round of 8';
      case PalmaresPosition.ROUND16:
        return 'Round of 16';
      case PalmaresPosition.GROUP_STAGE:
        return 'Group Stage';
    }
  }

  static PalmaresPosition fromString(String value) {
    return PalmaresPosition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PalmaresPosition.GROUP_STAGE,
    );
  }
}

class Palmares {
  final int tournamentId;
  final int teamId;
  final PalmaresPosition position;

  Palmares({
    required this.tournamentId,
    required this.teamId,
    required this.position,
  });

  factory Palmares.fromJson(Map<String, dynamic> json) {
    return Palmares(
      tournamentId: json['tournament_id'],
      teamId: json['team_id'],
      position: PalmaresPosition.fromString(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournament_id': tournamentId,
      'team_id': teamId,
      'position': position.name,
    };
  }
}
