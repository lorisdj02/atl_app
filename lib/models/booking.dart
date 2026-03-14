import 'sport_category.dart';

enum BookingStatus { booked, full, inProgress, finished, refound }

enum BookingType { private, lobby, match }

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.booked:
        return 'Booked';
      case BookingStatus.full:
        return 'Full';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.finished:
        return 'Finished';
      case BookingStatus.refound:
        return 'Refound';
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }

  static BookingStatus fromString(String status) {
    return BookingStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => BookingStatus.booked,
    );
  }

  fromJson(Map<String, dynamic> json) {
    return BookingStatusExtension.fromString(json['bookingStatus']);
  }

  Map<String, dynamic> toJson() {
    return {'bookingStatus': toShortString()};
  }
}

class Booking {
  final int id;
  final int fieldId;
  final DateTime startTime;
  final DateTime finishTime;
  BookingStatus status;
  final BookingType type;
  final DateTime createdAt;
  final SportCategory sportCategory;

  Booking({
    required this.id,
    required this.fieldId,
    required DateTime startTime,
    required DateTime finishTime,
    this.status = BookingStatus.booked,
    required this.type,
    this.sportCategory = SportCategory.football,
  }) : startTime = startTime.toUtc(),
       finishTime = finishTime.toUtc(),
       createdAt = DateTime.now().toUtc();

  fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      fieldId: json['fieldId'],
      startTime: DateTime.parse(json['startDateTime']),
      finishTime: DateTime.parse(json['finishDateTime']),
      status: BookingStatusExtension.fromString(json['status']),
      type: BookingType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => BookingType.match,
      ),
      sportCategory: SportCategoryExtension.fromJson(json['sportCategory']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'startDateTime': startTime.toIso8601String(),
      'finishDateTime': finishTime.toIso8601String(),
      'status': status.toShortString(),
      'type': type.toString(),
      'sportCategory': sportCategory.toString(),
    };
  }
}
