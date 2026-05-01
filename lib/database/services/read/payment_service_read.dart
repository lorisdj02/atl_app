import 'package:atl_app/database/responses/checkout_response.dart';
import 'package:dio/dio.dart';

class PaymentServiceRead {
  final String apiUrl;
  final Dio dio;

  PaymentServiceRead(this.apiUrl, this.dio);

  Future<CheckoutResponse> getCheckoutScreen(double sessionId) async {
    final response = await dio.get("$apiUrl/checkout-session/$sessionId");
    return CheckoutResponse.fromJson(response.data);
  }
}
