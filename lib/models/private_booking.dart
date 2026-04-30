import 'booking.dart';
import 'sport_category.dart';

/// Modello PrivateBooking dal database
// OK
class PrivateBooking extends Booking {
  final double playerId;
  final double cost;

  PrivateBooking({
    required super.id,
    required super.fieldId,
    required super.startTime,
    required super.finishTime,
    required super.status,
    required super.bookingType,
    required super.sportCategory,
    required this.playerId,
    required this.cost,
  });

  factory PrivateBooking.fromJson(Map<String, dynamic> json) {
    return PrivateBooking(
      id: json['id'],
      fieldId: json['fieldId'],
      startTime: DateTime.parse(json['startDateTime']),
      finishTime: DateTime.parse(json['finishDateTime']),
      status: BookingStatus.values.firstWhere(
        (e) => e.apiName == json['status'],
        orElse: () => BookingStatus.booked,
      ),
      bookingType: BookingType.values.firstWhere(
        (e) => e.apiName == json['bookingType'],
        orElse: () => BookingType.private,
      ),
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.apiName == json['sportCategory'],
        orElse: () => SportCategory.football,
      ),
      playerId: json['playerId']?.toDouble() ?? 0.0,
      cost: json['cost']?.toDouble() ?? 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'startDateTime': startTime.toIso8601String(),
      'finishDateTime': finishTime.toIso8601String(),
      'status': status.apiName,
      'bookingType': bookingType.apiName,
      'sportCategory': sportCategory.apiName,
      'playerId': playerId,
      'cost': cost,
    };
  }
}
