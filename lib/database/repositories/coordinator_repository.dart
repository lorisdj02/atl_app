import '../../models/coordinator.dart';
import 'base_repository.dart';
import '../db_controller.dart';
import '../../config/app_config.dart';

class CoordinatorRepository extends BaseRepository<Coordinator> {
  @override
  String get endpoint => 'coordinators';

  @override
  Coordinator fromJson(Map<String, dynamic> json) => Coordinator.fromJson(json);

  @override
  Map<String, dynamic> toJson(Coordinator item) => item.toJson();

  @override
  List<Coordinator> get mockData =>
      DB.Users.mockData.whereType<Coordinator>().toList();

  Future<Coordinator?> getByUserId(int id) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere((coordinator) => coordinator.id == id);
    } else {
      throw UnimplementedError();
    }
  }

  Future<Coordinator> getByCoordinatorId(int coordinatorId) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere(
        (coordinator) => coordinator.coordinatorId == coordinatorId,
      );
    } else {
      throw UnimplementedError();
    }
  }
}
