enum VipType {
  none,
  monthly,
  yearly;

  String get apiName {
    switch (this) {
      case VipType.none:
        return 'NONE';
      case VipType.monthly:
        return 'MONTHLY';
      case VipType.yearly:
        return 'YEARLY';
    }
  }
}

extension VipTypeExtension on VipType {
  static VipType fromJson(String json) {
    final normalized = json.toUpperCase();
    return VipType.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown VIP type: $json'),
    );
  }
}
