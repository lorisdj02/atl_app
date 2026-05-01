import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/checkout_response.dart';
import 'package:atl_app/database/services/read/payment_service_read.dart';
import 'package:atl_app/database/services/write/payment_service_write.dart';
import 'package:atl_app/models/checkout_payload.dart';
import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/purchase.dart';
import 'package:dio/dio.dart';

class PaymentService {
  static final String apiUrl = "/payments";
  static final Dio dio = ApiClient.instance;

  static final PaymentServiceRead _read = PaymentServiceRead(apiUrl, dio);
  static final PaymentServiceWrite _write = PaymentServiceWrite(apiUrl, dio);

  static Future<CheckoutResponse> getCheckoutScreen(double sessionId) async =>
      await _read.getCheckoutScreen(sessionId);

  static Future<CheckoutSession> createCheckoutSession(
    CheckoutPayload payload,
  ) async => await _write.createCheckoutSession(payload);

  static Future<Purchase> payCheckoutSession(
    double sessionId,
    bool? useWallet,
  ) async => await _write.payCheckoutSession(sessionId, useWallet);
}
