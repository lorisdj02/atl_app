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

extension BookingStatusExtension on BookingStatus {
  static BookingStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return BookingStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown booking status: $json'),
    );
  }

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

  Map<String, dynamic> toJson() {
    return {'bookingStatus': toShortString()};
  }
}
