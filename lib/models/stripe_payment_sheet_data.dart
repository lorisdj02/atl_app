class StripePaymentSheetData {
  final String paymentIntentId;
  final String clientSecret;
  final String customerId;
  final String ephemeralKey;
  final String publishableKey;

  StripePaymentSheetData({
    required this.paymentIntentId,
    required this.clientSecret,
    required this.customerId,
    required this.ephemeralKey,
    required this.publishableKey,
  });

  factory StripePaymentSheetData.fromJson(Map<String, dynamic> json) {
    return StripePaymentSheetData(
      paymentIntentId: json['paymentIntentId'] as String,
      clientSecret: json['clientSecret'] as String,
      customerId: json['customerId'] as String,
      ephemeralKey: json['ephemeralKey'] as String,
      publishableKey: json['publishableKey'] as String,
    );
  }
}
