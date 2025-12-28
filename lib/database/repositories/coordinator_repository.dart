import '../../models/coordinator.dart';
import 'base_repository.dart';
import '../db_controller.dart';

class CoordinatorRepository extends BaseRepository<Coordinator> {
  @override
  String get endpoint => 'coordinators';

  @override
  Coordinator fromJson(Map<String, dynamic> json) => Coordinator.fromJson(json);

  @override
  Map<String, dynamic> toJson(Coordinator item) => item.toJson();

  @override
  List<Coordinator> get mockData => DB.Users.mockData.whereType<Coordinator>().toList();

  Future<Coordinator> getByCoordinatorId(int coordinatorId) async {
    final allCoordinators = await getAll();
    return allCoordinators.firstWhere(
      (coordinator) => coordinator.coordinatorId == coordinatorId,
    );
  }
}
