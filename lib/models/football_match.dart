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
  int? homeTeamId;
  int? awayTeamId;
  DateTime? halfTime;
  DateTime? startHalf;
  MatchStatus status;

  FootballMatch({
    required super.id,
    this.homeTeamId,
    this.awayTeamId,
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
    super.scheduledStart,
    super.coordinatorStatus = PresenceStatus.assigned,
    super.motmPlayerId,
  });

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    return FootballMatch(
      id: json['id'],
      matchDate:
          json['matchDate'] != null ? DateTime.parse(json['matchDate']) : null,
      scoreHome: json['scoreHome'],
      scoreAway: json['scoreAway'],
      tournamentId: json['tournamentId'],
      group: json['group'],
      day: json['day'],
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'])
          : null,
      homeTeamId: json['homeTeamId'],
      awayTeamId: json['awayTeamId'],
      status: MatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => MatchStatus.notScheduled,
      ),
      halfTime: json['halfTime'] != null
          ? DateTime.parse(json['halfTime'])
          : null,
      startHalf: json['startHalf'] != null
          ? DateTime.parse(json['startHalf'])
          : null, 
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'status': status.toString().split('.').last,
      'halfTime': halfTime?.toIso8601String(),
      'startHalf': startHalf?.toIso8601String(),
      'coordinatorStatus': coordinatorStatus.toString().split('.').last,
      'motmPlayerId': motmPlayerId,
    };
  }
}
