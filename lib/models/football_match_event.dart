
enum FootballMatchEventType {
  redCard,
  yellowCard,
  redYellowCard,
  goal,
  penalty,
  ownGoal,
  start,
  half,
  finish,
}

class FootballMatchEvent{
  final int id;
  final FootballMatchEventType type;
  final int? playerId;
  final int minute;
  final int matchId;

  FootballMatchEvent({
    required this.id,
    required this.type,
    this.playerId,
    required this.minute,
    required this.matchId,
  });

  factory FootballMatchEvent.fromJson(Map<String, dynamic> json) {
    return FootballMatchEvent(
      id: json['id'],
      type: FootballMatchEventType.values.firstWhere(
          (e) => e.toString().split('.').last == json['type']),
      playerId: json['playerId'],
      minute: json['minute'],
      matchId: json['matchId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'playerId': playerId,
      'minute': minute,
      'matchId': matchId,
    };
  }
}