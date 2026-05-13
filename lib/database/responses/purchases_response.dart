import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/purchase.dart';

class PurchasesResponse {
  final List<Purchase> purchases;

  PurchasesResponse({required this.purchases});

  factory PurchasesResponse.fromJson(Map<String, dynamic> json) {
    var purchasesJson = json[ApiJsonKeys.purchases] as List;
    List<Purchase> purchasesList =
        purchasesJson.map((e) => Purchase.fromJson(e)).toList();
    return PurchasesResponse(purchases: purchasesList);
  }
}