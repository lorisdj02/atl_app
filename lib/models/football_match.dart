import 'package:atl_app/models/sport_category.dart';

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
  penaltyShootOut;

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
      case FootballMatchStatus.penaltyShootOut:
        return 'PENALTY_SHOOTOUT';
    }
  }
}

// OK
class FootballMatch extends Match {
  double? homeTeamId;
  double? awayTeamId;
  int? scoreHome;
  int? penaltyScoreHome;
  int? missedPenaltyHome;
  int? scoreAway;
  int? penaltyScoreAway;
  int? missedPenaltyAway;
  FootballMatchStatus status;
  DateTime? halfTime;
  DateTime? startHalf;

  FootballMatch({
    required super.id,
    required this.homeTeamId,
    required this.awayTeamId,
    required super.tournamentId,
    required super.groupName,
    required super.startMatch,
    required this.halfTime,
    required this.startHalf,
    required this.status,
    required super.scheduledStart,
    required super.coordinatorStatus,
    required super.motmPlayerId,
    required this.scoreHome,
    required this.penaltyScoreHome,
    required this.missedPenaltyHome,
    required this.scoreAway,
    required this.penaltyScoreAway,
    required this.missedPenaltyAway,
    required super.sportCategory,
    required super.legOrder,
    required super.finalStageBracketId,
    required super.finishMatch,
  });

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    return FootballMatch(
      id: json['id'],
      homeTeamId: json['homeTeamId'],
      awayTeamId: json['awayTeamId'],
      tournamentId: json['tournamentId'],
      groupName: json['groupName'],
      startMatch: DateTime.parse(json['startMatch']),
      halfTime: json['halfTime'] != null
          ? DateTime.parse(json['halfTime'])
          : null,
      startHalf: json['startHalf'] != null
          ? DateTime.parse(json['startHalf'])
          : null,
      status: FootballMatchStatus.values.firstWhere(
        (e) => e.apiName == json['status'],
      ),
      scheduledStart: DateTime.parse(json['scheduledStart']),
      coordinatorStatus: PresenceStatus.values.firstWhere(
        (e) => e.apiName == json['coordinatorStatus'],
      ),
      motmPlayerId: json['motmPlayerId'],
      scoreHome: json['scoreHome'],
      penaltyScoreHome: json['penaltyScoreHome'],
      missedPenaltyHome: json['missedPenaltyHome'],
      scoreAway: json['scoreAway'],
      penaltyScoreAway: json['penaltyScoreAway'],
      missedPenaltyAway: json['missedPenaltyAway'],
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.apiName == json['sportCategory'],
      ),
      legOrder: LegOrderType.values.firstWhere(
        (e) => e.apiName == json['legOrder'],
      ),
      finalStageBracketId: json['finalStageBracketId'],
      finishMatch: DateTime.parse(json['finishMatch']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'tournamentId': tournamentId,
      'groupName': groupName,
      'startMatch': startMatch?.toIso8601String(),
      'halfTime': halfTime?.toIso8601String(),
      'startHalf': startHalf?.toIso8601String(),
      'status': status.apiName,
      'scheduledStart': scheduledStart?.toIso8601String(),
      'coordinatorStatus': coordinatorStatus.apiName,
      'motmPlayerId': motmPlayerId,
      'scoreHome': scoreHome,
      'penaltyScoreHome': penaltyScoreHome,
      'missedPenaltyHome': missedPenaltyHome,
      'scoreAway': scoreAway,
      'penaltyScoreAway': penaltyScoreAway,
      'missedPenaltyAway': missedPenaltyAway,
      'sportCategory': sportCategory.apiName,
      'legOrder': legOrder.apiName,
      'finalStageBracketId': finalStageBracketId,
      'finishMatch': finishMatch?.toIso8601String(),
    };
  }
}
