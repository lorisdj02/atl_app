import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/purchase_detail.dart';

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

// OK
class Purchase {
  final double id;
  final double accountId;
  final CheckoutType type;
  final PurchaseDetail detail;
  final PurchaseStatus status;
  final double amount;
  final DateTime createdAt;

  Purchase({
    required this.id,
    required this.accountId,
    required this.type,
    required this.detail,
    required this.status,
    required this.amount,
    required this.createdAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      accountId: json['accountId'],
      type: CheckoutType.values.firstWhere(
        (e) => e.toString() == 'CheckoutType.${json['type']}',
      ),
      detail: PurchaseDetail.fromJson(json['detail']),
      status: PurchaseStatus.values.firstWhere(
        (e) => e.toString() == 'PurchaseStatus.${json['status']}',
      ),
      amount: json['amount'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type.toString().split('.').last,
      'detail': detail.toJson(),
      'status': status.toString().split('.').last,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
