import '../../models/coordinator.dart';
import 'base_repository.dart';

class CoordinatorRepository extends BaseRepository<Coordinator> {
  @override
  String get endpoint => 'coordinators';

  @override
  Coordinator fromJson(Map<String, dynamic> json) => Coordinator.fromJson(json);

  @override
  Map<String, dynamic> toJson(Coordinator item) => item.toJson();

  @override
  List<Coordinator> get mockData => [
    Coordinator(
      id: 1,
      username: 'coordinator_mark',
      email: 'mark@example.com',
      firebaseUid: 'firebase_uid_coord_1',
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      balance: 500.00,
      phone: '1112223333',
      coordinatorId: 1,
      name: 'Mark',
      surname: 'Johnson',
      level: 2,
    ),
  ];
}
