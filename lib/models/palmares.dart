enum PalmaresPosition {
  winner,
  finalist,
  semi,
  round8,
  round16,
  group_stage;

  String get displayName {
    switch (this) {
      case PalmaresPosition.winner:
        return '1st';
      case PalmaresPosition.finalist:
        return '2nd';
      case PalmaresPosition.semi:
        return 'Semi';
      case PalmaresPosition.round8:
        return 'Round of 8';
      case PalmaresPosition.round16:
        return 'Round of 16';
      case PalmaresPosition.group_stage:
        return 'Group Stage';
    }
  }

  static PalmaresPosition fromString(String value) {
    return PalmaresPosition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PalmaresPosition.group_stage,
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
      tournamentId: json['tournamentId'],
      teamId: json['teamId'],
      position: PalmaresPosition.fromString(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'teamId': teamId,
      'position': position.name,
    };
  }
}
