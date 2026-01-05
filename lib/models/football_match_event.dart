enum FootballMatchEventType {
  redCard,
  yellowCard,
  redYellowCard,
  goal,
  penalty,
  ownGoal,
  start,
  halftime,
  startHalf,
  finish,
}

class FootballMatchEvent {
  final int id;
  final FootballMatchEventType type;
  final int? playerId;
  final int? teamId;
  final int minute;
  final int additionalMinute;
  final int matchId;
  final DateTime eventTime;

  FootballMatchEvent({
    required this.id,
    required this.type,
    this.playerId,
    required this.minute,
    required this.matchId,
    required this.eventTime,
    this.additionalMinute = 0,
    this.teamId,
  });

  factory FootballMatchEvent.fromJson(Map<String, dynamic> json) {
    return FootballMatchEvent(
      id: json['id'],
      type: FootballMatchEventType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      playerId: json['playerId'],
      minute: json['minute'],
      matchId: json['matchId'],
      eventTime: DateTime.parse(json['eventTime']),
      additionalMinute: json['additionalMinute'] ?? 0,
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'playerId': playerId,
      'minute': minute,
      'matchId': matchId,
      'eventTime': eventTime.toIso8601String(),
      'additionalMinute': additionalMinute,
      'teamId': teamId,
    };
  }

}
