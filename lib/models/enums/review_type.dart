enum ReviewType {
  refereeToCoordinator,
  coordinatorToReferee,
  playerToCoordinator;

  String get apiName {
    switch (this) {
      case ReviewType.refereeToCoordinator:
        return 'REFEREE_TO_COORDINATOR';
      case ReviewType.coordinatorToReferee:
        return 'COORDINATOR_TO_REFEREE';
      case ReviewType.playerToCoordinator:
        return 'PLAYER_TO_COORDINATOR';
    }
  }
}

extension ReviewTypeExtension on ReviewType {
  String toShortString() {
    return toString().split('.').last;
  }

  static ReviewType fromString(String type) {
    return ReviewType.values.firstWhere(
      (e) => e.toShortString() == type,
      orElse: () => throw ArgumentError('Unknown review type: $type'),
    );
  }

  static ReviewType fromJson(String json) {
    final normalized = json.toUpperCase();
    return ReviewType.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown review type: $json'),
    );
  }
}