import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/wallet.dart';

class WalletResponse {
  final Wallet wallet;

  WalletResponse({required this.wallet});

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(wallet: Wallet.fromJson(json[ApiJsonKeys.wallet]));
  }
}
