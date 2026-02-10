import 'base_repository.dart';
import '../../config/app_config.dart';
import '../../models/referee_assignment.dart';

class RefereeAssignmentRepository extends BaseRepository<RefereeAssignment> {
  @override
  String get endpoint => 'referee_assignments';

  @override
  RefereeAssignment fromJson(Map<String, dynamic> json) =>
      RefereeAssignment.fromJson(json);

  @override
  Map<String, dynamic> toJson(RefereeAssignment item) => item.toJson();

  List<RefereeAssignment> _mockData = [
    RefereeAssignment(
      matchId: 1,
      refereeId: 1,
      role: 'MAIN',
    ),
  ];

  @override
  List<RefereeAssignment> get mockData => _mockData;

  Future<bool> insertAssignment(int matchId, int refereeId, String role) async {
    if (AppConfig.isDebug) {
      final newAssignment = RefereeAssignment(
        matchId: matchId,
        refereeId: refereeId,
        role: role,
      );
      _mockData.add(newAssignment);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<RefereeAssignment?> getByMatchIdAndRefereeId(
    int matchId,
    int refereeId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        final assignment = _mockData.firstWhere(
          (assignment) =>
              assignment.matchId == matchId &&
              assignment.refereeId == refereeId,
        );
        return assignment;
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<RefereeAssignment>> getByMatchId(int matchId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where((assignment) => assignment.matchId == matchId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<RefereeAssignment>> getByRefereeId(int refereeId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where((assignment) => assignment.refereeId == refereeId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> countRefereesPerMatch(int matchId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where((assignment) => assignment.matchId == matchId)
          .length;
    } else {
      throw UnimplementedError();
    }
  }
}
