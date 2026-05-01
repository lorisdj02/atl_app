import 'enums/transaction_type.dart';
import 'enums/transaction_status.dart';



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
      accountId: json['accountId'] != null ? (json['accountId'] as num).toDouble() : 0.0,
      status: TransactionStatusExtension.fromJson(json['status']),
      type: TransactionTypeExtension.fromJson(json['type']),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'status': status.apiName,
      'type': type.apiName,
      'amount': amount,
      'currency': currency,
    };
  }
}