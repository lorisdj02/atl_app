import 'match.dart';
import 'presence_status.dart';

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

class FootballMatch extends Match {
  final int homeTeamId;
  final int awayTeamId;
  DateTime? halfTime;
  DateTime? startHalf;
  final MatchStatus status;

  FootballMatch({
    required super.id,
    required this.homeTeamId,
    required this.awayTeamId,
    super.matchDate,
    super.scoreHome,
    super.scoreAway,
    required super.tournamentId,
    super.day,
    super.group,
    super.startMatch,
    this.halfTime,
    this.startHalf,
    super.endMatch,
    this.status = MatchStatus.notScheduled,
    super.coordinatorStatus = PresenceStatus.assigned,
  });

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    return FootballMatch(
      id: json['id'],
      homeTeamId: json['homeTeamId'],
      awayTeamId: json['awayTeamId'],
      matchDate: json['matchDate'] != null
          ? DateTime.parse(json['matchDate'])
          : null,
      status: MatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MatchStatus.notScheduled,
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
      'status': status.toString().split('.').last,
      'scoreHome': scoreHome,
      'scoreAway': scoreAway,
      'tournamentId': tournamentId,
      'group': group,
      'day': day,
    };
  }
}
