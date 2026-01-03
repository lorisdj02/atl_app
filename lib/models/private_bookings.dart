import 'sport_category.dart';
import 'booking_status.dart';

/// Modello PrivateBooking dal database

class PrivateBooking {
  final int id;
  final int fieldId;
  final int playerId;
  final DateTime startTime;
  final DateTime finishTime;
  BookingStatus status;

  PrivateBooking({
    required this.id,
    required this.fieldId,
    required this.playerId,
    required DateTime startTime,
    required DateTime finishTime,
    this.status = BookingStatus.booked,
  }) : startTime = startTime.toUtc(),
       finishTime = finishTime.toUtc();

  factory PrivateBooking.fromJson(Map<String, dynamic> json) {
    return PrivateBooking(
      id: json['id'],
      fieldId: json['field_id'],
      playerId: json['player_id'],
      startTime: DateTime.parse(json['start_time']),
      finishTime: DateTime.parse(json['finish_time']),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.' + json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'player_id': playerId,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime.toIso8601String(),
      'status': status.toString().split('.').last,
    };
  }
}
