import 'package:atl_app/models/checkout_payload.dart';
import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/purchase.dart';
import 'package:dio/dio.dart';

class PaymentServiceWrite {
  final String apiUrl;
  final Dio dio;

  PaymentServiceWrite(this.apiUrl, this.dio);

  Future<CheckoutSession> createCheckoutSession(CheckoutPayload payload) async {
    final response = await dio.post(
      "$apiUrl/create-checkout-session",
      data: payload.toJson(),
    );
    return CheckoutSession.fromJson(response.data);
  }

  Future<Purchase> payCheckoutSession(double sessionId, bool? useWallet) async {
    final response = await dio.patch(
      "$apiUrl/pay-checkout-session/$sessionId",
      queryParameters: {"useWallet": useWallet},
    );
    return Purchase.fromJson(response.data);
  }
}
