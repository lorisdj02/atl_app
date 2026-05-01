import 'enums/football_match_event_type.dart';

// OK
class FootballMatchEvent {
  final double id;
  final double matchId;
  final double? teamId;
  final double? playerId;
  final FootballMatchEventType type;
  final int minute;
  final int additionalMinute;
  final DateTime createdAt;

  FootballMatchEvent({
    required this.id,
    required this.type,
    this.playerId,
    required this.minute,
    required this.matchId,
    required this.createdAt,
    this.additionalMinute = 0,
    this.teamId,
  });

  factory FootballMatchEvent.fromJson(Map<String, dynamic> json) {
    return FootballMatchEvent(
      id: (json['id'] as num).toDouble(),
      type: FootballMatchEventTypeExtension.fromJson(json['type']),
      playerId: json['playerId'] != null ? (json['playerId'] as num).toDouble() : null,
      minute: (json['minute'] as num).toInt(),
      matchId: (json['matchId'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      additionalMinute: (json['additionalMinute'] as num).toInt(),
      teamId: json['teamId'] != null ? (json['teamId'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.apiName,
      'playerId': playerId,
      'minute': minute,
      'matchId': matchId,
      'createdAt': createdAt.toIso8601String(),
      'additionalMinute': additionalMinute,
      'teamId': teamId,
    };
  }
}
