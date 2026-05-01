enum PresenceStatus {
  assigned,
  present,
  absent,
  late;

  String get apiName {
    switch (this) {
      case PresenceStatus.assigned:
        return 'ASSIGNED';
      case PresenceStatus.present:
        return 'PRESENT';
      case PresenceStatus.absent:
        return 'ABSENT';
      case PresenceStatus.late:
        return 'LATE';
    }
  }
}

extension PresenceStatusExtension on PresenceStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static PresenceStatus fromString(String status) {
    return PresenceStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => PresenceStatus.assigned,
    );
  }

  static PresenceStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return PresenceStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown presence status: $json'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'presenceStatus': toShortString()};
  }
}
