import 'presence_status.dart';
import 'sport.dart';


class Match {
  final int id;

  final DateTime? matchDate;
  int? scoreHome;
  int? scoreAway;
  final int tournamentId;
  DateTime? startMatch;
  DateTime? endMatch;
  DateTime? scheduledStart;
  final int? day;
  final String? group;
  int? motmPlayerId;

  PresenceStatus coordinatorStatus;

  Match({
    required this.id,
    this.matchDate,
    this.scoreHome,
    this.scoreAway,
    required this.tournamentId,
    this.day,
    this.group,
    this.startMatch,
    this.endMatch,
    this.scheduledStart,
    this.coordinatorStatus = PresenceStatus.assigned,
    this.motmPlayerId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchDate': matchDate?.toIso8601String(),
      'scoreHome': scoreHome,
      'scoreAway': scoreAway,
      'tournamentId': tournamentId,
      'day': day,
      'group': group,
      'scheduledStart': scheduledStart?.toIso8601String(),
    };
  }

  fromJson(Map<String, dynamic> json) {
    return Match(
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
    );
  }
}
