import 'package:atl_app/models/purchase_detail.dart';
import 'enums/checkout_type.dart';
import 'enums/purchase_status.dart';

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
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      accountId: json['accountId'] != null ? (json['accountId'] as num).toDouble() : 0.0,
      type: CheckoutTypeExtension.fromJson(json['type']),
      detail: PurchaseDetail.fromJson(json['detail']),
      status: PurchaseStatusExtension.fromJson(json['status']),
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : 0.0,
      createdAt: DateTime.parse(json['createdAt']).toLocal(),
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
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
