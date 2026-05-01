
import 'enums/match_slot_type.dart';
// OK
class FinalStageBracket {
  final double id;
  final double tournamentId;
  final String groupName;
  final int aggregateScoreHome;
  final int aggregateScoreAway;
  final double nextFinalStageBracketId;
  final MatchSlotType? nextFinalStageBracketSlot;

  FinalStageBracket({
    required this.id,
    required this.tournamentId,
    required this.groupName,
    required this.aggregateScoreHome,
    required this.aggregateScoreAway,
    required this.nextFinalStageBracketId,
    required this.nextFinalStageBracketSlot,
  });

  factory FinalStageBracket.fromJson(Map<String, dynamic> json) {
    return FinalStageBracket(
      id: (json['id'] as num).toDouble(),
      tournamentId: (json['tournamentId'] as num).toDouble(),
      groupName: json['groupName'],
      aggregateScoreHome: (json['aggregateScoreHome'] as num).toInt(),
      aggregateScoreAway: (json['aggregateScoreAway'] as num).toInt(),
      nextFinalStageBracketId: (json['nextFinalStageBracketId'] as num).toDouble(),
      nextFinalStageBracketSlot: json['nextFinalStageBracketSlot'] != null
          ? MatchSlotTypeExtension.fromJson(json['nextFinalStageBracketSlot'])
          : null, // Valore di default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'groupName': groupName,
      'aggregateScoreHome': aggregateScoreHome,
      'aggregateScoreAway': aggregateScoreAway,
      'nextFinalStageBracketId': nextFinalStageBracketId,
      'nextFinalStageBracketSlot': nextFinalStageBracketSlot?.apiName,
    };
  }
}