enum BookingStatus { booked, full, inProgress, finished, refound }

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

  Booking({
    required this.id,
    required this.fieldId,
    required DateTime startTime,
    required DateTime finishTime,
    this.status = BookingStatus.booked,
  }) : startTime = startTime.toUtc(),
       finishTime = finishTime.toUtc();

  fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      fieldId: json['field_id'],
      startTime: DateTime.parse(json['start_time']),
      finishTime: DateTime.parse(json['finish_time']),
      status: BookingStatusExtension.fromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime.toIso8601String(),
      'status': status.toShortString(),
    };
  }
}
