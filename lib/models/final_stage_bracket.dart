enum MatchSlotType{
  home,
  away;

  String get apiName {
    switch (this) {
      case MatchSlotType.home:
        return 'HOME';
      case MatchSlotType.away:
        return 'AWAY';
    }
  }
}

// OK
class FinalStageBracket {
  final double id;
  final double tournamentId;
  final String groupName;
  final int aggregateScoreHome;
  final int aggregateScoreAway;
  final double nextFinalStageBracketId;
  final MatchSlotType nextFinalStageBracketSlot;

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
      id: json['id'],
      tournamentId: json['tournamentId'],
      groupName: json['groupName'],
      aggregateScoreHome: json['aggregateScoreHome'],
      aggregateScoreAway: json['aggregateScoreAway'],
      nextFinalStageBracketId: json['nextFinalStageBracketId'],
      nextFinalStageBracketSlot: MatchSlotType.values.firstWhere((e) => e.apiName == json['nextFinalStageBracketSlot']),
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
      'nextFinalStageBracketSlot': nextFinalStageBracketSlot.apiName,
    };
  }
}