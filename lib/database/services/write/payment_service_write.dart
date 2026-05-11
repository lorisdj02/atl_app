import 'package:atl_app/models/checkout_payload.dart';
import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/purchase.dart';
import 'package:atl_app/models/stripe_payment_sheet_data.dart';
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

  Future<Purchase> payCheckoutSession(
    double sessionId,
    bool? useWallet, {
    String? paymentIntentId,
  }) async {
    final response = await dio.patch(
      "$apiUrl/pay-checkout-session/${sessionId.toStringAsFixed(0)}",
      queryParameters: {"useWallet": useWallet},
      data: paymentIntentId != null
          ? {"paymentIntentId": paymentIntentId}
          : null,
    );
    return Purchase.fromJson(response.data);
  }

  Future<StripePaymentSheetData> createStripePaymentSheet(
    double sessionId,
    bool? useWallet,
  ) async {
    final response = await dio.post(
      "$apiUrl/create-payment-intent/${sessionId.toStringAsFixed(0)}",
      queryParameters: {"useWallet": useWallet},
    );
    return StripePaymentSheetData.fromJson(response.data);
  }
}
