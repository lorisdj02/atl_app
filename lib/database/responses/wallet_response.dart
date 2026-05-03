import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/transaction.dart';
import 'package:atl_app/models/wallet.dart';

class WalletResponse {
  final Wallet wallet;
  final List<Transaction> transactions;

  WalletResponse({required this.wallet, required this.transactions});

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
      final Wallet wallet = Wallet.fromJson(json[ApiJsonKeys.wallet]);
  print("Wallet deserialized: ${wallet.id}");

  final List<Transaction> transactions = (json[ApiJsonKeys.transactionsHistory] as List)
      .map((e) => Transaction.fromJson(e))
      .toList();
  print("Transactions history deserialized: ${transactions.length}");

    return WalletResponse(
      wallet: wallet,
      transactions: transactions,
    );
  }
}
