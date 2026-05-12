import 'package:atl_app/database/requests/payment_intent_request.dart';
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
      "$apiUrl/checkout-session/create",
      data: payload.toJson(),
    );
    return CheckoutSession.fromJson(response.data);
  }

  Future<Purchase> payCheckoutSession(
    double sessionId,
    bool? useWallet, {
    PaymentIntentRequest? paymentIntentRequest,
  }) async {
    final response = await dio.patch(
      "$apiUrl/checkout-session/${sessionId.toStringAsFixed(0)}/pay",
      queryParameters: {"useWallet": useWallet},
      data: paymentIntentRequest?.toJson(),
    );
    return Purchase.fromJson(response.data);
  }

  Future<StripePaymentSheetData> createStripePaymentSheet(
    double sessionId,
    bool? useWallet,
  ) async {
    final response = await dio.post(
      "$apiUrl/checkout-session/${sessionId.toStringAsFixed(0)}/create-payment-intent",
      queryParameters: {"useWallet": useWallet},
    );
    return StripePaymentSheetData.fromJson(response.data);
  }
}
