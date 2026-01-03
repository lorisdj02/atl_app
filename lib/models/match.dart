import 'presence_status.dart';



class Match {
  final int id;

  final DateTime? matchDate;
  int? scoreHome;
  int? scoreAway;
  final int tournamentId;
  DateTime? startMatch;
  DateTime? endMatch;
  final int? day;
  final String? group;

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
    this.coordinatorStatus = PresenceStatus.assigned,
  });
}
