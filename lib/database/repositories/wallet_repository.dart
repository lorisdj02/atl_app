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
    Wallet(
      id: 1,
      userId: 1,
      balance: 150,
      prizeBalance: 100,
    ),
    Wallet(
      id: 2,
      userId: 2,
      balance: 300,
    ),
    Wallet(
      id: 3,
      userId: 3,
      balance: 50,
    ),
    Wallet(
      id: 4,
      userId: 4,
      balance: 75,
    ),
    Wallet(
      id: 5,
      userId: 5,
      balance: 500,
    ),
    Wallet(
      id: 6,
      userId: 6,
      balance: 20,
    ),
    Wallet(
      id: 7,
      userId: 7,
      balance: 0,
    ),
    Wallet(
      id: 8,
      userId: 8,
      balance: 425,
    ),
    Wallet(
      id: 9,
      userId: 9,
      balance: 600,
    ),
    Wallet(
      id: 10,
      userId: 10,
      balance: 110,
    ),
    Wallet(
      id: 11,
      userId: 11,
      balance: 350,
    ),
    Wallet(
      id: 100,
      userId: 100,
      balance: 275,
    ),
    Wallet(
      id: 101,
      userId: 101,
      balance: 425,
    ),
    Wallet(
      id: 102,
      userId: 102,
      balance: 80,
    ),
    Wallet(
      id: 1000,
      userId: 1000,
      balance: 95,
    ),
    Wallet(
      id: 10000,
      userId: 10000,
      balance: 150,
    ),
    Wallet(
      id: 10001,
      userId: 10001,
      balance: 220,
    ),
  ];

  @override
  List<Wallet> get mockData => _mockData;

  Future<Wallet?> getByUserId(int userId) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((wallet) => wallet.userId == userId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }
}