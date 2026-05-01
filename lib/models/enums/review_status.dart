enum ReviewStatus {
  waiting,
  pending,
  committed;

  String get apiName {
    switch (this) {
      case ReviewStatus.waiting:
        return 'WAITING';
      case ReviewStatus.pending:
        return 'PENDING';
      case ReviewStatus.committed:
        return 'COMMITTED';
    }
  }
}

extension ReviewStatusExtension on ReviewStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static ReviewStatus fromString(String status) {
    return ReviewStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => throw ArgumentError('Unknown review status: $status'),
    );
  }

  static ReviewStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return ReviewStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown review status: $json'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'reviewStatus': toShortString()};
  }
}
