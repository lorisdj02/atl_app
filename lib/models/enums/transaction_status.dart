enum TransactionStatus{
  pending,
    confirmed,
    failed,
    partialRefund,
    refunded;

    String get apiName {
      switch (this) {
        case TransactionStatus.pending:
          return 'PENDING';
        case TransactionStatus.confirmed:
          return 'CONFIRMED';
        case TransactionStatus.failed:
          return 'FAILED';
        case TransactionStatus.partialRefund:
          return 'PARTIAL_REFUND';
        case TransactionStatus.refunded:
          return 'REFUNDED';
      }
    }
}

extension TransactionStatusExtension on TransactionStatus {
  String toShortString() {
    return toString().split('.').last;
  }
  static TransactionStatus fromString(String status) {
    return TransactionStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => throw ArgumentError('Unknown transaction status: $status'),
    );
  }

  static TransactionStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return TransactionStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown transaction status: $json'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'transactionStatus': toShortString()};
  }
}