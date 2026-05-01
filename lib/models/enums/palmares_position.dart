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

extension PalmaresPositionExtension on PalmaresPosition {
  static PalmaresPosition fromJson(String json) {
    final normalized = json.toUpperCase();
    return PalmaresPosition.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown palmares position: $json'),
    );
  }
}