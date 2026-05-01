import 'booking.dart';
import 'enums/sport_category.dart';
import 'enums/booking_status.dart';
import 'enums/booking_type.dart';

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
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      fieldId: json['fieldId'] != null
          ? (json['fieldId'] as num).toDouble()
          : 0.0,
      startTime: DateTime.parse(json['startDateTime']),
      finishTime: DateTime.parse(json['finishDateTime']),
      status: BookingStatusExtension.fromJson(json['status']),
      bookingType: BookingTypeExtension.fromJson(json['bookingType']),
      sportCategory: SportCategoryExtension.fromJson(json['sportCategory']),
      playerId: json['playerId'] != null
          ? (json['playerId'] as num).toDouble()
          : 0.0,
      cost: json['cost'] != null ? (json['cost'] as num).toDouble() : 0.0,
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
