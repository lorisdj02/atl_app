enum PalmaresPosition {
  winner,
  finalist,
  semi,
  round8,
  round16,
  groupStage;

  String get apiName {
    switch (this) {
      case PalmaresPosition.winner:
        return 'WINNER';
      case PalmaresPosition.finalist:
        return 'FINALIST';
      case PalmaresPosition.semi:
        return 'SEMI';
      case PalmaresPosition.round8:
        return 'ROUND8';
      case PalmaresPosition.round16:
        return 'ROUND16';
      case PalmaresPosition.groupStage:
        return 'GROUP_STAGE';
    }
  }

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
      case PalmaresPosition.groupStage:
        return 'Group Stage';
    }
  }

  static PalmaresPosition fromString(String value) {
    return PalmaresPosition.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PalmaresPosition.groupStage,
    );
  }
}
// OK
class Palmares {
  final double tournamentId;
  final PalmaresPosition position;

  Palmares({required this.tournamentId, required this.position});

  factory Palmares.fromJson(Map<String, dynamic> json) {
    return Palmares(
      tournamentId: json['tournamentId'],
      position: PalmaresPosition.values.firstWhere(
        (e) => e.apiName == json['position'],
        orElse: () => PalmaresPosition.groupStage,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'tournamentId': tournamentId, 'position': position.apiName};
  }
}
