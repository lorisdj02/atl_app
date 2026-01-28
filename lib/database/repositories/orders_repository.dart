import '../../models/order.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

class OrdersRepository extends BaseRepository<Order> {
  @override
  String get endpoint => 'orders';

  @override
  Order fromJson(Map<String, dynamic> json) {
    return Order.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Order item) {
    return item.toJson();
  }

  List<Order> _mockdata = [];

  @override
  List<Order> get mockData => _mockdata;

  Future<List<Order>> getByClientUserId(int clientUserId) async {
    if (AppConfig.isDebug) {
      return mockData
          .where((order) => order.clientUserId == clientUserId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<Order?> getById(int orderId) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((order) => order.id == orderId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }
}
