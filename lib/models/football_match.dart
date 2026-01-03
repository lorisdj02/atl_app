import 'match.dart';

class FootballMatch extends Match {
  int? refereeId;

  FootballMatch({
    this.refereeId,
    required super.id,
    required super.homeTeamId,
    required super.awayTeamId,
    super.matchDate,
    super.scoreHome,
    super.scoreAway,
    required super.tournamentId,
    super.day,
    super.group,
    super.startMatch,
    super.halfTime,
    super.startHalf,
    super.endMatch,
    super.status = MatchStatus.notScheduled,
  });

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    return FootballMatch(
      id: json['id'],
      homeTeamId: json['homeTeamId'],
      awayTeamId: json['awayTeamId'],
      matchDate: json['matchDate'] != null
          ? DateTime.parse(json['matchDate'])
          : null,
      refereeId: json['refereeId'],
      status: MatchStatus.values.firstWhere(
        (e) => e.toString() == 'MatchStatus.' + json['status'],
      ),
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
