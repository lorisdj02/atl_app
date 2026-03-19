import 'package:atl_app/models/sport_category.dart';

import 'presence_status.dart';


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
  final String groupName;
  int? motmPlayerId;

  PresenceStatus coordinatorStatus;
  SportCategory sportCategory;

  Match({
    required this.id,
    this.matchDate,
    this.scoreHome,
    this.scoreAway,
    required this.tournamentId,
    this.day,
    required this.groupName,
    this.startMatch,
    this.endMatch,
    this.scheduledStart,
    this.coordinatorStatus = PresenceStatus.assigned,
    this.motmPlayerId,
      this.sportCategory = SportCategory.football,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchDate': matchDate?.toIso8601String(),
      'scoreHome': scoreHome,
      'scoreAway': scoreAway,
      'tournamentId': tournamentId,
      'day': day,
      'groupName': groupName,
      'startMatch': startMatch?.toIso8601String(),
      'endMatch': endMatch?.toIso8601String(),
      'scheduledStart': scheduledStart?.toIso8601String(),
      'presenceStatus': coordinatorStatus.toShortString(),
      'motmPlayerId': motmPlayerId,
      'sportCategory': sportCategory.toString(),
    };
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      matchDate:
          json['matchDate'] != null ? DateTime.parse(json['matchDate']) : null,
      scoreHome: json['scoreHome'],
      scoreAway: json['scoreAway'],
      tournamentId: json['tournamentId'],
      groupName: json['groupName'],
      day: json['day'],
      scheduledStart: json['scheduledStart'] != null
          ? DateTime.parse(json['scheduledStart'])
          : null,
      coordinatorStatus: PresenceStatusExtension.fromString(json['presenceStatus']),
      motmPlayerId: json['motmPlayerId'],
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.toString() == json['sportCategory'],
        orElse: () => SportCategory.football,
      ),

    );
  }
}
