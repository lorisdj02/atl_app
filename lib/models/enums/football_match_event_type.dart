enum FootballMatchEventType {
  redCard,
  yellowCard,
  redYellowCard,
  goal,
  penalty,
  missedPenalty,
  ownGoal,
  start,
  halftime,
  startHalf,
  penaltyShootout,
  finish;

  String get apiName {
    switch (this) {
      case FootballMatchEventType.redCard:
        return 'RED_CARD';
      case FootballMatchEventType.yellowCard:
        return 'YELLOW_CARD';
      case FootballMatchEventType.redYellowCard:
        return 'RED_YELLOW_CARD';
      case FootballMatchEventType.goal:
        return 'GOAL';
      case FootballMatchEventType.penalty:
        return 'PENALTY';
      case FootballMatchEventType.missedPenalty:
        return 'MISSED_PENALTY';
      case FootballMatchEventType.ownGoal:
        return 'OWN_GOAL';
      case FootballMatchEventType.start:
        return 'START';
      case FootballMatchEventType.halftime:
        return 'HALFTIME';
      case FootballMatchEventType.startHalf:
        return 'START_HALF';
      case FootballMatchEventType.penaltyShootout:
        return 'PENALTY_SHOOTOUT';
      case FootballMatchEventType.finish:
        return 'FINISH';
    }
  }
}

extension FootballMatchEventTypeExtension on FootballMatchEventType {
  static FootballMatchEventType fromJson(String json) {
    final normalized = json.toUpperCase();
    return FootballMatchEventType.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown football match event type: $json'),
    );
  }
}