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
    Coordinator(
      id: 2,
      username: 'coordinator_lucy',
      email: 'lucy@example.com',
      firebaseUid: 'firebase_uid_coord_2',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      balance: 300.00,
      phone: '2223334444',
      coordinatorId: 2,
      name: 'Lucy',
      surname: 'Smith',
      level: 3,
    ),
    Coordinator(
      id: 3,
      username: 'coordinator_alex',
      email: 'alex@example.com',
      firebaseUid: 'firebase_uid_coord_3',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      balance: 400.00,
      phone: '3334445555',
      coordinatorId: 3,
      name: 'Alex',
      surname: 'Brown',
      level: 1,
    ),
  ];
}
