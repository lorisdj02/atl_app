import 'package:atl_app/models/enums/sport_category.dart';
import 'enums/football_match_status.dart';
import 'match.dart';
import 'enums/presence_status.dart';
import 'enums/leg_order_type.dart';

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
    required super.day,
  });

  factory FootballMatch.fromJson(Map<String, dynamic> json) {
    return FootballMatch(
      id: (json['id'] as num).toDouble(),
      homeTeamId: json['homeTeamId'] != null
          ? (json['homeTeamId'] as num).toDouble()
          : null,
      awayTeamId: json['awayTeamId'] != null
          ? (json['awayTeamId'] as num).toDouble()
          : null,
      tournamentId: (json['tournamentId'] as num).toDouble(),
      groupName: json['groupName'],
      startMatch: json['startMatch'] != null
          ? DateTime.parse(json['startMatch']).toLocal()
          : null,
      halfTime: json['halfTime'] != null
          ? DateTime.parse(json['halfTime']).toLocal()
          : null,
      startHalf: json['startHalf'] != null
          ? DateTime.parse(json['startHalf']).toLocal()
          : null,
      status: json['status'] != null
          ? FootballMatchStatusExtension.fromJson(json['status'])
          : FootballMatchStatus.notScheduled,
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart']).toLocal()
          : null,
      coordinatorStatus: json['coordinatorStatus'] != null
          ? PresenceStatusExtension.fromJson(json['coordinatorStatus'])
          : PresenceStatus.assigned,
      motmPlayerId: json['motmPlayerId'] != null
          ? (json['motmPlayerId'] as num).toDouble()
          : null,
      scoreHome:  json['scoreHome'] != null ? (json['scoreHome'] as num).toInt() : null,
      penaltyScoreHome: json['penaltyScoreHome'] != null ? (json['penaltyScoreHome'] as num).toInt() : null,
      missedPenaltyHome: json['missedPenaltyHome'] != null ? (json['missedPenaltyHome'] as num).toInt() : null,
      scoreAway: json['scoreAway'] != null ? (json['scoreAway'] as num).toInt() : null,
      penaltyScoreAway: json['penaltyScoreAway'] != null ? (json['penaltyScoreAway'] as num).toInt() : null,
      missedPenaltyAway: json['missedPenaltyAway'] != null ? (json['missedPenaltyAway'] as num).toInt() : null,
      sportCategory: json['sportCategory'] != null
          ? SportCategoryExtension.fromJson(json['sportCategory'])
          : SportCategory.football,
      legOrder: json['legOrder'] != null
          ? LegOrderTypeExtension.fromJson(json['legOrder'])
      : null,
      finalStageBracketId: json['finalStageBracketId'] != null
          ? (json['finalStageBracketId'] as num).toDouble()
          : null,
      finishMatch: json['finishMatch'] != null
          ? DateTime.parse(json['finishMatch']).toLocal()
          : null,
      day: json['day'] != null ? (json['day'] as num).toInt() : null,
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
      'startMatch': startMatch?.toUtc().toIso8601String(),
      'halfTime': halfTime?.toUtc().toIso8601String(),
      'startHalf': startHalf?.toUtc().toIso8601String(),
      'status': status.apiName,
      'scheduledStart': scheduledStart?.toUtc().toIso8601String(),
      'coordinatorStatus': coordinatorStatus.apiName,
      'motmPlayerId': motmPlayerId,
      'scoreHome': scoreHome,
      'penaltyScoreHome': penaltyScoreHome,
      'missedPenaltyHome': missedPenaltyHome,
      'scoreAway': scoreAway,
      'penaltyScoreAway': penaltyScoreAway,
      'missedPenaltyAway': missedPenaltyAway,
      'sportCategory': sportCategory.apiName,
      'legOrder': legOrder?.apiName,
      'finalStageBracketId': finalStageBracketId,
      'finishMatch': finishMatch?.toUtc().toIso8601String(),
      'day': day,
    };
  }
}
