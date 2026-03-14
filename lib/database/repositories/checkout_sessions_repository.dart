import 'base_repository.dart';
import '../../models/checkout_session.dart';
import '../../config/app_config.dart';

class CheckoutSessionsRepository extends BaseRepository<CheckoutSession> {
  @override
  String get endpoint => 'checkout_sessions';

  List<CheckoutSession> _mockData = [];

  @override
  List<CheckoutSession> get mockData => _mockData;

  @override
  CheckoutSession fromJson(Map<String, dynamic> json) {
    return CheckoutSession.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(CheckoutSession item) {
    return item.toJson();
  }

  Future<CheckoutSession?> getById(int id) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((session) => session.id == id);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateStatus(int id, CheckoutSessionStatus newStatus) async {
    if (AppConfig.isDebug) {
      try {
        final int index = _mockData.indexWhere((session) => session.id == id);
        if (index == -1) {
          return false; // Sessione non trovata
        }
        _mockData[index].status = newStatus;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteById(int id) async {
    if (AppConfig.isDebug) {
      try {
        final int index = _mockData.indexWhere((session) => session.id == id);
        if (index == -1) {
          return false; // Sessione non trovata
        }
        _mockData.removeWhere((session) => session.id == id);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> createCheckoutSession({
    required int userId,
    required String payload,
    required double amount,
    required CheckoutType type,
  }) async {
    if (AppConfig.isDebug) {
      final CheckoutSession newSession = CheckoutSession(
        id: mockData.length + 1,
        userId: userId,
        payload: payload,
        amount: amount,
        createdAt: DateTime.now(),
        status: CheckoutSessionStatus.pending,
        type: type, // Sostituire con il tipo appropriato
        expiresAt: DateTime.now().add(Duration(minutes: 10)), // Sostituire con la data di scadenza appropriata
      );
      _mockData.add(newSession);
      print('Created new checkout session: ${newSession.toJson()}');
      return newSession.id;
    } else {
      throw UnimplementedError();
    }
  }
}
