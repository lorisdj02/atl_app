import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/checkout_response.dart';
import 'package:dio/dio.dart';

class PaymentServiceRead {
  final String apiUrl = "/payments";
  final Dio dio = ApiClient.instance;

  Future<CheckoutResponse> getCheckoutScreen(double sessionId) async {
    final response = await dio.get("$apiUrl/checkout-session/$sessionId");
    return CheckoutResponse.fromJson(response.data);
  }
}
