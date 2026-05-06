
enum TransactionType {
    deposit, // NOT USED
    payment, // OUT PERSONAL, PRIZE, INVITE WALLET
    prize, // IN PRIZE WALLET
    withdraw, // OUT PRIZE, PERSONAL WALLET
    refund, // IN PRIZE, PERSONAL, INVITE WALLET
    fee, // IN PERSONAL WALLET
    invite; // IN INVITE WALLET

    String get apiName {
      switch (this) {
        case TransactionType.deposit:
          return 'DEPOSIT';
        case TransactionType.payment:
          return 'PAYMENT';
        case TransactionType.prize:
          return 'PRIZE';
        case TransactionType.withdraw:
          return 'WITHDRAW';
        case TransactionType.refund:
          return 'REFUND';
        case TransactionType.fee:
          return 'FEE';
        case TransactionType.invite:
          return 'INVITE';
      }
    }
}

extension TransactionTypeExtension on TransactionType {
  static TransactionType fromJson(String json) {
    final normalized = json.toUpperCase();
    return TransactionType.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown transaction type: $json'),
    );
  }
}