import '../../models/wallet.dart';
import '../../config/app_config.dart';
import 'base_repository.dart';

class WalletRepository extends BaseRepository<Wallet> {
  @override
  String get endpoint => 'wallets';

  @override
  Wallet fromJson(Map<String, dynamic> json) => Wallet.fromJson(json);

  @override
  Map<String, dynamic> toJson(Wallet item) => item.toJson();

  // 5 cifre -> wallets
  List<Wallet> _mockData = [
    Wallet(id: 1, accountId: 1, personalBalance: 150, prizeBalance: 100),
    Wallet(id: 2, accountId: 2, personalBalance: 300),
    Wallet(id: 3, accountId: 3, personalBalance: 50),
    Wallet(id: 4, accountId: 4, personalBalance: 75),
    Wallet(id: 5, accountId: 5, personalBalance: 500),
    Wallet(id: 6, accountId: 6, personalBalance: 20),
    Wallet(id: 7, accountId: 7, personalBalance: 0),
    Wallet(id: 8, accountId: 8, personalBalance: 425),
    Wallet(id: 9, accountId: 9, personalBalance: 600),
    Wallet(id: 10, accountId: 10, personalBalance: 110),
    Wallet(id: 11, accountId: 11, personalBalance: 350),
    Wallet(id: 100, accountId: 100, personalBalance: 275),
    Wallet(id: 101, accountId: 101, personalBalance: 425),
    Wallet(id: 102, accountId: 102, personalBalance: 80),
    Wallet(id: 1000, accountId: 1000, personalBalance: 95),
    Wallet(id: 10000, accountId: 10000, personalBalance: 150),
    Wallet(id: 10001, accountId: 10001, personalBalance: 220),
  ];

  @override
  List<Wallet> get mockData => _mockData;

  Future<Wallet?> getByAccountId(int accountId) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((wallet) => wallet.accountId == accountId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addWallet({required int accountId, bool hasBeenInvited = false}) async {
    if (AppConfig.isDebug) {
      final newId =
          mockData
              .map((w) => w.id)
              .fold(0, (prev, curr) => curr > prev ? curr : prev) +
          1;
      _mockData.add(
        Wallet(
          id: newId,
          accountId: accountId,
          personalBalance: 0,
          inviteBalance: hasBeenInvited ? 2.5 : 0,
          prizeBalance: 0,
        ),
      );
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> modifyBalance(int accountId, double amount, {String? type}) async {
    if (AppConfig.isDebug) {
      final wallet = await getByAccountId(accountId);
      if (wallet == null) return false;

      if (type == 'prize') {
        wallet.prizeBalance += amount;
      } else if (type == 'invite') {
        wallet.inviteBalance += amount;
      } else {
        wallet.personalBalance += amount;
      }
      wallet.updatedAt = DateTime.now();
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
