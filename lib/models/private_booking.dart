import 'booking.dart';
import 'sport_category.dart';
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
    super.sportCategory = SportCategory.football,
  }) : super(startTime: startTime, finishTime: finishTime, type: BookingType.private);

  factory PrivateBooking.fromJson(Map<String, dynamic> json) {
    return PrivateBooking(
      id: json['id'],
      fieldId: json['fieldId'],
      playerId: json['playerId'],
      startTime: DateTime.parse(json['startTime']),
      finishTime: DateTime.parse(json['finishTime']),
      status: BookingStatusExtension.fromString(json['status']),
      cost: json['cost'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'playerId': playerId,
      'startTime': startTime.toIso8601String(),
      'finishTime': finishTime.toIso8601String(),
      'status': status.toShortString(),
      'cost': cost,
    };
  }
}
