
enum MatchStatus {
  scheduled,
  started,
  halftime,
  startHalf,
  finished,
  notScheduled,
  homeRetired,
  awayRetired,
  canceled
}

class SoccerMatch {
  final int id;
  final int homeTeamId;
  final int awayTeamId;
  final DateTime? matchDate;
  final int? refereeId;
  final MatchStatus status;
  int? scoreHome;
  int? scoreAway;
  final int tournamentId;
  final String? group;
  final int? day;
  DateTime? startMatch;
  DateTime? halfTime;
  DateTime? startHalf;
  DateTime? endMatch;

  SoccerMatch({
    required this.id,
    required this.homeTeamId,
    required this.awayTeamId,
    this.matchDate,
    this.refereeId,
    this.status = MatchStatus.notScheduled,
    this.scoreHome,
    this.scoreAway,
    required this.tournamentId,
    this.group,
    this.day,
    this.startMatch,
    this.halfTime,
    this.startHalf,
    this.endMatch,
  });


  factory SoccerMatch.fromJson(Map<String, dynamic> json) {
    return SoccerMatch(
      id: json['id'],
      homeTeamId: json['homeTeamId'],
      awayTeamId: json['awayTeamId'],
      matchDate: json['matchDate'] != null ? DateTime.parse(json['matchDate']) : null,
      refereeId: json['refereeId'],
      status: MatchStatus.values.firstWhere((e) => e.toString() == 'MatchStatus.' + json['status']),
      scoreHome: json['scoreHome'],
      scoreAway: json['scoreAway'],
      tournamentId: json['tournamentId'],
      group: json['group'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'matchDate': matchDate?.toIso8601String(),
      'refereeId': refereeId,
      'status': status.toString().split('.').last,
      'scoreHome': scoreHome,
      'scoreAway': scoreAway,
      'tournamentId': tournamentId,
      'group': group,
      'day': day,
    };
  }
}