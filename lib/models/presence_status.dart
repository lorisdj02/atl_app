enum PresenceStatus {
  assigned,
  present,
  absent,
  late}

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
    return {
      'presenceStatus': toShortString(),
    };
  }
}