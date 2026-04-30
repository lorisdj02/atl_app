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

enum TransactionSource{
  prizeWallet,
    personalWallet,
    inviteWallet,
    stripe,
    other;

    String get apiName {
      switch (this) {
        case TransactionSource.prizeWallet:
          return 'PRIZE_WALLET';
        case TransactionSource.personalWallet:
          return 'PERSONAL_WALLET';
        case TransactionSource.inviteWallet:
          return 'INVITE_WALLET';
        case TransactionSource.stripe:
          return 'STRIPE';
        case TransactionSource.other:
          return 'OTHER';
      }
    }
}

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

// OK
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