enum PurchaseStatus {
  confirmed,
  redeemed,
  refunded,
  partialRefund,
  canceled;

  String get apiName {
    switch (this) {
      case PurchaseStatus.confirmed:
        return 'CONFIRMED';
      case PurchaseStatus.redeemed:
        return 'REDEEMED';
      case PurchaseStatus.refunded:
        return 'REFUNDED';
      case PurchaseStatus.partialRefund:
        return 'PARTIAL_REFUND';
      case PurchaseStatus.canceled:
        return 'CANCELED';
    }
  }
}

extension PurchaseStatusExtension on PurchaseStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static PurchaseStatus fromString(String status) {
    return PurchaseStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => throw ArgumentError('Unknown purchase status: $status'),
    );
  }

  static PurchaseStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return PurchaseStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown purchase status: $json'),
    );
  }
}
