import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/purchase.dart';

class PurchasesResponse {
  final List<Purchase> purchases;

  PurchasesResponse({required this.purchases});

  factory PurchasesResponse.fromJson(Map<String, dynamic> json) {
    final List<Purchase> purchases = (json[ApiJsonKeys.purchases] as List<dynamic>)
        .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
        .toList();
    return PurchasesResponse(purchases: purchases);
  }
}