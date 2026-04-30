import 'package:atl_app/models/sport_category.dart';

import 'presence_status.dart';

enum LegOrderType {
  firstLeg,
  secondLeg;

  String get apiName {
    switch (this) {
      case LegOrderType.firstLeg:
        return 'FIRST_LEG';
      case LegOrderType.secondLeg:
        return 'SECOND_LEG';
    }
  }
}

// OK
class Match {
  final double id;
  final DateTime? scheduledStart;
  final DateTime? startMatch;
  final DateTime? finishMatch;
  final double tournamentId;
  final double? motmPlayerId;
  final String groupName;
  final SportCategory sportCategory;
  final LegOrderType legOrder;
  final PresenceStatus coordinatorStatus;
  final double? finalStageBracketId;
  final int? day;

  Match({
    required this.id,
    required this.scheduledStart,
    required this.startMatch,
    required this.finishMatch,
    required this.tournamentId,
    required this.motmPlayerId,
    required this.groupName,
    required this.sportCategory,
    required this.legOrder,
    required this.coordinatorStatus,
    required this.finalStageBracketId,
    required this.day,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'])
          : null,
      startMatch: json['startMatch'] != null
          ? DateTime.parse(json['startMatch'])
          : null,
      finishMatch: json['finishMatch'] != null
          ? DateTime.parse(json['finishMatch'])
          : null,
      tournamentId: json['tournamentId'],
      motmPlayerId: json['motmPlayerId'],
      groupName: json['groupName'],
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.apiName == json['sportCategory'],
      ),
      legOrder: LegOrderType.values.firstWhere(
        (e) => e.apiName == json['legOrder'],
      ),
      coordinatorStatus: PresenceStatus.values.firstWhere(
        (e) => e.apiName == json['coordinatorStatus'],
      ),
      finalStageBracketId: json['finalStageBracketId'],
      day: json['day'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduledStart': scheduledStart?.toIso8601String(),
      'startMatch': startMatch?.toIso8601String(),
      'finishMatch': finishMatch?.toIso8601String(),
      'tournamentId': tournamentId,
      'motmPlayerId': motmPlayerId,
      'groupName': groupName,
      'sportCategory': sportCategory.apiName,
      'legOrder': legOrder.apiName,
      'coordinatorStatus': coordinatorStatus.apiName,
      'finalStageBracketId': finalStageBracketId,
      'day': day,
    };
  }
}
