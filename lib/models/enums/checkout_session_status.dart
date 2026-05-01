enum CheckoutSessionStatus {
  pending,
  completed,
  expired,
  failed;

  String get apiName {
    switch (this) {
      case CheckoutSessionStatus.pending:
        return 'PENDING';
      case CheckoutSessionStatus.completed:
        return 'COMPLETED';
      case CheckoutSessionStatus.expired:
        return 'EXPIRED';
      case CheckoutSessionStatus.failed:
        return 'FAILED';
    }
  }
}