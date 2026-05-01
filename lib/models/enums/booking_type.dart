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

extension BookingTypeExtension on BookingType {
  static BookingType fromJson(String json) {
    final normalized = json.toUpperCase();
    return BookingType.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown booking type: $json'),
    );
  }
}
