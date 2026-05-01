import 'enums/sport_category.dart';
import 'enums/booking_status.dart';
import 'enums/booking_type.dart';

// OK
class Booking {
  final double id;
  final DateTime startTime;
  final DateTime finishTime;
  BookingStatus status;
  final SportCategory sportCategory;
  final double fieldId;
  final BookingType bookingType;

  Booking({
    required this.id,
    required this.fieldId,
    required DateTime startTime,
    required DateTime finishTime,
    required this.status,
    required this.bookingType,
    this.sportCategory = SportCategory.football,
  }) : startTime = startTime.toUtc(),
       finishTime = finishTime.toUtc();

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: (json['id'] as num).toDouble(),
      fieldId: (json['fieldId'] as num).toDouble(),
      startTime: DateTime.parse(json['startDateTime']),
      finishTime: DateTime.parse(json['finishDateTime']),
      status: json['status'] != null
          ? BookingStatusExtension.fromJson(json['status'])
          : BookingStatus.canceled,
      bookingType: json['bookingType'] != null
          ? BookingTypeExtension.fromJson(json['bookingType'])
          : BookingType.private,
      sportCategory: json['sportCategory'] != null
          ? SportCategoryExtension.fromJson(json['sportCategory'])
          : SportCategory.football,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'startDateTime': startTime.toIso8601String(),
      'finishDateTime': finishTime.toIso8601String(),
      'status': status.apiName,
      'bookingType': bookingType.apiName,
      'sportCategory': sportCategory.apiName,
    };
  }
}
