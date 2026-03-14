import 'booking.dart';
import 'sport_category.dart';
class MatchBooking extends Booking{
  final int coordinatorId;
  final int matchId;

  MatchBooking({
    required super.id,
    required super.fieldId,
    required this.coordinatorId,
    required this.matchId,
    required DateTime startTime,
    required DateTime finishTime,
    super.status = BookingStatus.booked,
    super.sportCategory = SportCategory.football,
  }) : super(startTime: startTime, finishTime: finishTime, type: BookingType.match);

  factory MatchBooking.fromJson(Map<String, dynamic> json) {
    return MatchBooking(
      id: json['id'],
      fieldId: json['fieldId'],
      coordinatorId: json['coordinatorId'],
      matchId: json['matchId'],
      startTime: DateTime.parse(json['startTime']),
      finishTime: DateTime.parse(json['finishTime']),
      status: BookingStatusExtension.fromString(json['status']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'coordinatorId': coordinatorId,
      'matchId': matchId,
      'startTime': startTime.toIso8601String(),
      'finishTime': finishTime.toIso8601String(),
      'status': status.toShortString(),
    };
  }
}