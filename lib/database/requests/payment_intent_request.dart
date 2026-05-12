import 'package:atl_app/config/api_json_keys.dart';

class PaymentIntentRequest {
  final String paymentIntentId;

  PaymentIntentRequest({
    required this.paymentIntentId,
  });

  Map<String, dynamic> toJson() {
    return {
      ApiJsonKeys.paymentIntentId: paymentIntentId,
    };
  }
}