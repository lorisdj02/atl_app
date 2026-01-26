import 'booking.dart';

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
  }) : super(startTime: startTime, finishTime: finishTime, type: BookingType.match);

  factory MatchBooking.fromJson(Map<String, dynamic> json) {
    return MatchBooking(
      id: json['id'],
      fieldId: json['field_id'],
      coordinatorId: json['coordinator_id'],
      matchId: json['match_id'],
      startTime: DateTime.parse(json['start_time']),
      finishTime: DateTime.parse(json['finish_time']),
      status: BookingStatusExtension.fromString(json['status']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'coordinator_id': coordinatorId,
      'match_id': matchId,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime.toIso8601String(),
      'status': status.toShortString(),
    };
  }
}