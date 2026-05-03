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
    final double id = (json['id'] as num).toDouble();
    print("Checkout session ID parsed: $id");

  final double accountId = (json['accountId'] as num).toDouble();
    print("Checkout session account ID parsed: $accountId");

  final CheckoutPayload payload = CheckoutPayload.fromJson(json['payload']);
    print("Checkout session payload parsed: ${payload.toString()}");

  final CheckoutType type = json['type'] != null
        ? CheckoutTypeExtension.fromJson(json['type'])
        : CheckoutType.shop;
    print("Checkout session type parsed: ${type.toString()}");

  final double amount = (json['amount'] as num).toDouble();
    print("Checkout session amount parsed: $amount");

    return CheckoutSession(
      id: id,
      accountId: accountId,
      type: type,
      payload: payload,
      amount: amount,
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
