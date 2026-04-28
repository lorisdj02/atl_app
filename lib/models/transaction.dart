enum TransactionStatus{
  PENDING,
    CONFIRMED,
    FAILED,
    PARTIAL_REFUND,
    REFUNDED
}

enum TransactionSource{
  PRIZE_WALLET,
    PERSONAL_WALLET,
    INVITE_WALLET,
    STRIPE,
    OTHER
}

enum TransactionType {
    DEPOSIT, // NOT USED
    PAYMENT, // OUT PERSONAL, PRIZE, INVITE WALLET
    PRIZE, // IN PRIZE WALLET
    WITHDRAW, // OUT PRIZE, PERSONAL WALLET
    REFUND, // IN PRIZE, PERSONAL, INVITE WALLET
    FEE, // IN PERSONAL WALLET
    INVITE // IN INVITE WALLET
}

class Transaction {
  final double accountId;
  final TransactionStatus status;
  final TransactionType type;
  final double amount;
  final String currency;

  Transaction({
    required this.accountId,
    required this.status,
    required this.type,
    required this.amount,
    required this.currency,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      accountId: json['accountId'],
      status: TransactionStatus.values.firstWhere((e) => e.toString() == 'TransactionStatus.${json['status']}'),
      type: TransactionType.values.firstWhere((e) => e.toString() == 'TransactionType.${json['type']}'),
      amount: json['amount'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'amount': amount,
      'currency': currency,
    };
  }
}