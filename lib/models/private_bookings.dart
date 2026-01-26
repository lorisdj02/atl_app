import 'booking.dart';

/// Modello PrivateBooking dal database

class PrivateBooking extends Booking {
  final int playerId;
  final double cost;

  PrivateBooking({
    required super.id,
    required super.fieldId,
    required this.playerId,
    required DateTime startTime,
    required DateTime finishTime,
    required this.cost,
    super.status = BookingStatus.booked,
  }) : super(startTime: startTime, finishTime: finishTime, type: BookingType.private);

  factory PrivateBooking.fromJson(Map<String, dynamic> json) {
    return PrivateBooking(
      id: json['id'],
      fieldId: json['field_id'],
      playerId: json['player_id'],
      startTime: DateTime.parse(json['start_time']),
      finishTime: DateTime.parse(json['finish_time']),
      status: BookingStatusExtension.fromString(json['status']),
      cost: json['cost'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'player_id': playerId,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime.toIso8601String(),
      'status': status.toShortString(),
      'cost': cost,
    };
  }
}
