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

  fromJson(Map<String, dynamic> json) {
    return PresenceStatusExtension.fromString(json['presenceStatus']);
  }

  Map<String, dynamic> toJson() {
    return {'presenceStatus': toShortString()};
  }
}
