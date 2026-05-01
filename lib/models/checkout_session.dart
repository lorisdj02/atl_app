import 'package:atl_app/models/checkout_payload.dart';
import 'enums/checkout_type.dart';

// OK
class CheckoutSession {
  final double id;
  final double accountId;
  final CheckoutPayload payload;
  final CheckoutType type;
  final double amount;

  CheckoutSession({
    required this.id,
    required this.accountId,
    required this.payload,
    required this.type,
    required this.amount,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: (json['id'] as num).toDouble(),
      accountId: (json['accountId'] as num).toDouble(),
      type: json['type'] != null
          ? CheckoutTypeExtension.fromJson(json['type'])
          : CheckoutType.shop,
      payload: CheckoutPayload.fromJson(json['payload']),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type.apiName,
      'payload': payload.toJson(),
      'amount': amount,
    };
  }
}
