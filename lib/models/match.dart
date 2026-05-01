import 'package:atl_app/models/enums/sport_category.dart';
import 'enums/leg_order_type.dart';
import 'enums/presence_status.dart';



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
  final LegOrderType? legOrder;
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
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'])
          : null,
      startMatch: json['startMatch'] != null
          ? DateTime.parse(json['startMatch'])
          : null,
      finishMatch: json['finishMatch'] != null
          ? DateTime.parse(json['finishMatch'])
          : null,
      tournamentId: json['tournamentId'] != null
          ? (json['tournamentId'] as num).toDouble()
          : 0.0,
      motmPlayerId: json['motmPlayerId'] != null
          ? (json['motmPlayerId'] as num).toDouble()
          : 0.0,
      groupName: json['groupName'],
      sportCategory: SportCategoryExtension.fromJson(json['sportCategory']),
      legOrder: json['legOrder'] != null
          ? LegOrderTypeExtension.fromJson(json['legOrder'])
          : null,
      coordinatorStatus: PresenceStatusExtension.fromJson(json['coordinatorStatus']),
      finalStageBracketId: json['finalStageBracketId'] != null
          ? (json['finalStageBracketId'] as num).toDouble()
          : 0.0,
      day: json['day'] != null ? (json['day'] as num).toInt() : 0,
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
      'legOrder': legOrder?.apiName,
      'coordinatorStatus': coordinatorStatus.apiName,
      'finalStageBracketId': finalStageBracketId,
      'day': day,
    };
  }
}
