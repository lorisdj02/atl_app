enum MatchStatus {
  scheduled,
  started,
  halftime,
  startHalf,
  finished,
  notScheduled,
  homeRetired,
  awayRetired,
  canceled,
}

class Match {
  final int id;
  final int homeTeamId;
  final int awayTeamId;
  final DateTime? matchDate;
  int? scoreHome;
  int? scoreAway;
  final int tournamentId;
  DateTime? startMatch;
  DateTime? halfTime;
  DateTime? startHalf;
  DateTime? endMatch;
  final int? day;
  final String? group;
  final MatchStatus status;

  Match({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    this.matchDate,
    this.scoreHome,
    this.scoreAway,
    required this.tournamentId,
    this.day,
    this.group,
    this.startMatch,
    this.halfTime,
    this.startHalf,
    this.endMatch,
    this.status = MatchStatus.notScheduled,
  });
}
