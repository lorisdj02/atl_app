import 'base_repository.dart';
import '../../models/growth_step.dart';
import 'package:atl_app/config/app_config.dart';

class GrowthStepsRepository extends BaseRepository<GrowthStep> {
  @override
  String get endpoint => 'growth_steps';

  List<GrowthStep> _mockData = [
    GrowthStep(
      type: GrowthStepType.referee,
      title: 'Noob Referee',
      level: 1,
      x: 0,
      minRatingOverLastXGames: 3.5,
      minRefereedGames: 0,
    ),
    GrowthStep(
      type: GrowthStepType.referee,
      title: 'Pro Referee',
      level: 2,
      x: 10,
      minRatingOverLastXGames: 4.0,
      minRefereedGames: 30,
    ),
    GrowthStep(
      type: GrowthStepType.referee,
      title: 'Elite Referee',
      level: 3,
      x: 20,
      minRatingOverLastXGames: 4.5,
      minRefereedGames: 60,
    ),
    GrowthStep(
      type: GrowthStepType.referee,
      title: 'ATL Referee',
      level: 4,
      x: 30,
      minRatingOverLastXGames: 4.8,
      minRefereedGames: 100,
    ),
    GrowthStep(
      type: GrowthStepType.coordinator,
      title: 'Noob Coordinator',
      level: 1,
      x: 0,
      minRatingOverLastXTournaments: 0,
      minCoordinatedTournaments: 0,
      coordinatorPayPerGame: 12.5,
    ),
    GrowthStep(
      type: GrowthStepType.coordinator,
      title: 'Pro Coordinator',
      level: 2,
      x: 3,
      minRatingOverLastXTournaments: 3.5,
      minCoordinatedTournaments: 3,
      coordinatorPayPerGame: 15,
    ),
    GrowthStep(
      type: GrowthStepType.coordinator,
      title: 'Elite Coordinator',
      level: 3,
      x: 5,
      minRatingOverLastXTournaments: 4.0,
      minCoordinatedTournaments: 10,
      coordinatorPayPerGame: 17.5,
    ),
    GrowthStep(
      type: GrowthStepType.coordinator,
      title: 'ATL Coordinator',
      level: 4,
      x: 10,
      minRatingOverLastXTournaments: 4.5,
      minCoordinatedTournaments: 20,
      coordinatorPayPerGame: 20,
    ),
  ];

  @override
  List<GrowthStep> get mockData => _mockData;

  @override
  GrowthStep fromJson(Map<String, dynamic> json) {
    return GrowthStep.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(GrowthStep item) {
    return item.toJson();
  }

  Future<List<GrowthStep>> getGrowthStepByType(GrowthStepType type) async {
    if (AppConfig.isDebug) {
      return _mockData.where((step) => step.type == type).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<double> getPayForCoordinatorLevel(int level) async {
    if (AppConfig.isDebug) {
      final step = _mockData.firstWhere(
        (step) =>
            step.type == GrowthStepType.coordinator && step.level == level,
        orElse: () => throw Exception('Growth step not found'),
      );
      return step.coordinatorPayPerGame ?? 0.0;
    } else {
      throw UnimplementedError();
    }
  }
}
