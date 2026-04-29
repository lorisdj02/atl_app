import 'booking.dart';
import 'sport_category.dart';

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
        orElse: () => BookingType.match,
      ),
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.apiName == json['sportCategory'],
        orElse: () => SportCategory.football,
      ),
      coordinatorId: json['coordinatorId']?.toDouble() ?? 0.0,
      matchId: json['matchId']?.toDouble() ?? 0.0,
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
      'coordinatorId': coordinatorId,
      'matchId': matchId,
    };
  }
}
