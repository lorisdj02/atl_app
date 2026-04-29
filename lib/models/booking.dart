import 'sport_category.dart';

enum BookingStatus {
  booked,
  full,
  inProgress,
  finished,
  refund,
  canceled;

  String get apiName {
    switch (this) {
      case BookingStatus.booked:
        return 'BOOKED';
      case BookingStatus.full:
        return 'FULL';
      case BookingStatus.inProgress:
        return 'IN_PROGRESS';
      case BookingStatus.finished:
        return 'FINISHED';
      case BookingStatus.refund:
        return 'REFUND';
      case BookingStatus.canceled:
        return 'CANCELED';
    }
  }
}

enum BookingType {
  private,
  lobby,
  match;

  String get apiName {
    switch (this) {
      case BookingType.private:
        return 'PRIVATE';
      case BookingType.lobby:
        return 'LOBBY';
      case BookingType.match:
        return 'MATCH';
    }
  }
}

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
      case BookingStatus.refund:
        return 'Refund';
      case BookingStatus.canceled: // Aggiunto per i match cancellati
        return 'Canceled';
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
