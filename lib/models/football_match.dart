import 'match.dart';
import 'presence_status.dart';

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
  penaltyShootOut,
}

//TODO: implementare la fase penalty e anche la fine del match per le fasi finali

class FootballMatch extends Match {
  int? homeTeamId;
  int? awayTeamId;
  DateTime? halfTime;
  DateTime? startHalf;
  FootballMatchStatus status;
  int? penaltyScoreHome;
  int? missedPenaltyHome;
  int? penaltyScoreAway;
  int? missedPenaltyAway;

  FootballMatch({
    required super.id,
    this.homeTeamId,
    this.awayTeamId,
    super.matchDate,
    super.scoreHome,
    super.scoreAway,
    required super.tournamentId,
    super.day,
    required super.group,
    super.startMatch,
    this.halfTime,
    this.startHalf,
    super.endMatch,
    this.status = FootballMatchStatus.notScheduled,
    super.scheduledStart,
    super.coordinatorStatus = PresenceStatus.assigned,
    super.motmPlayerId,
    this.penaltyScoreHome,
    this.missedPenaltyHome,
    this.penaltyScoreAway,
    this.missedPenaltyAway,
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
      status: FootballMatchStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => FootballMatchStatus.notScheduled,
      ),
      halfTime: json['halfTime'] != null
          ? DateTime.parse(json['halfTime'])
          : null,
      startHalf: json['startHalf'] != null
          ? DateTime.parse(json['startHalf'])
          : null, 
      coordinatorStatus: PresenceStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['coordinatorStatus'],
        orElse: () => PresenceStatus.assigned,
      ),
      motmPlayerId: json['motmPlayerId'],
      penaltyScoreHome: json['penaltyScoreHome'],
      missedPenaltyHome: json['missedPenaltyHome'],
      penaltyScoreAway: json['penaltyScoreAway'],
      missedPenaltyAway: json['missedPenaltyAway'],
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
      'penaltyScoreHome': penaltyScoreHome,
      'missedPenaltyHome': missedPenaltyHome,
      'penaltyScoreAway': penaltyScoreAway,
      'missedPenaltyAway': missedPenaltyAway,
    };
  }
}
