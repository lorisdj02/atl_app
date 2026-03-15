import 'package:atl_app/models/presence_status.dart';

class RefereeAssignment {
  final int refereeId;
  final String role;
  final int matchId;
  PresenceStatus presenceStatus;
  final double pay;

  RefereeAssignment({
    required this.refereeId,
    this.role = 'MAIN',
    required this.matchId,
    required this.pay,
    this.presenceStatus = PresenceStatus.assigned,
  });

  factory RefereeAssignment.fromJson(Map<String, dynamic> json) {
    return RefereeAssignment(
      refereeId: json['refereeId'],
      role: json['role'],
      matchId: json['matchId'],
      pay: json['pay'],
      presenceStatus: PresenceStatusExtension.fromString(json['presenceStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refereeId': refereeId,
      'role': role,
      'matchId': matchId,
      'presenceStatus': presenceStatus.toShortString(),
      'pay': pay,
    };
  }
}