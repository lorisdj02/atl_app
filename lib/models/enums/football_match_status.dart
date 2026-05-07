enum FootballMatchStatus {
  scheduled,
  started,
  halftime,
  startHalf,
  finished,
  notScheduled,
  homeRetired,
  awayRetired,
  canceled,
  penaltyShootout;

  String get apiName {
    switch (this) {
      case FootballMatchStatus.scheduled:
        return 'SCHEDULED';
      case FootballMatchStatus.started:
        return 'STARTED';
      case FootballMatchStatus.halftime:
        return 'HALFTIME';
      case FootballMatchStatus.startHalf:
        return 'START_HALF';
      case FootballMatchStatus.finished:
        return 'FINISHED';
      case FootballMatchStatus.notScheduled:
        return 'NOT_SCHEDULED';
      case FootballMatchStatus.homeRetired:
        return 'HOME_RETIRED';
      case FootballMatchStatus.awayRetired:
        return 'AWAY_RETIRED';
      case FootballMatchStatus.canceled:
        return 'CANCELED';
      case FootballMatchStatus.penaltyShootout:
        return 'PENALTY_SHOOTOUT';
    }
  }
}

extension FootballMatchStatusExtension on FootballMatchStatus {
  static FootballMatchStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return FootballMatchStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown football match status: $json'),
    );
  }
}