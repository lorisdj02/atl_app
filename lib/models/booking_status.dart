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
    return {
      'bookingStatus': toShortString(),
    };
  }
}