import 'booking.dart';
import 'enums/sport_category.dart';
import 'enums/booking_status.dart';
import 'enums/booking_type.dart';
// OK
class MatchBooking extends Booking {
  final double coordinatorId;
  final double matchId;

  MatchBooking({
    required super.id,
    required super.fieldId,
    required super.startTime,
    required super.finishTime,
    required super.status,
    required super.bookingType,
    required super.sportCategory,
    required this.coordinatorId,
    required this.matchId,
  });

  factory MatchBooking.fromJson(Map<String, dynamic> json) {
    return MatchBooking(
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      fieldId: json['fieldId'] != null ? (json['fieldId'] as num).toDouble() : 0.0,
      startTime: DateTime.parse(json['startTime']),
      finishTime: DateTime.parse(json['finishTime']),
      status: BookingStatusExtension.fromJson(json['status']),
      bookingType: BookingTypeExtension.fromJson(json['bookingType']),
      sportCategory: SportCategoryExtension.fromJson(json['sportCategory']),
      coordinatorId: json['coordinatorId'] != null ? (json['coordinatorId'] as num).toDouble() : 0.0,
      matchId: json['matchId'] != null ? (json['matchId'] as num).toDouble() : 0.0,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'startTime': startTime.toIso8601String(),
      'finishTime': finishTime.toIso8601String(),
      'status': status.apiName,
      'bookingType': bookingType.apiName,
      'sportCategory': sportCategory.apiName,
      'coordinatorId': coordinatorId,
      'matchId': matchId,
    };
  }
}
