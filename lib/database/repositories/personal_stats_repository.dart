import '../../models/personal_stats.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

class PersonalStatsRepository extends BaseRepository<PersonalStats> {
  @override
  String get endpoint => 'personal_stats';

  @override
  PersonalStats fromJson(Map<String, dynamic> json) =>
      PersonalStats.fromJson(json);

  @override
  Map<String, dynamic> toJson(PersonalStats item) => item.toJson();

  List<PersonalStats> _mockData = [];

  @override
  List<PersonalStats> get mockData => _mockData;

  Future<PersonalStats?> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere(
        (stats) => stats.playerId == playerId,
        orElse: () => PersonalStats(playerId: playerId, goals: 0, motm: 0),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> incrementStats(
    int playerId, {
    int goalsIncrement = 0,
    int motmIncrement = 0,
  }) async {
    if (AppConfig.isDebug) {
      final int index = _mockData.indexWhere((s) => s.playerId == playerId);

      if (index == -1) {
        // Non esiste, crealo
        _mockData.add(
          PersonalStats(
            playerId: playerId,
            goals: goalsIncrement,
            motm: motmIncrement,
          ),
        );
      } else {
        // Esiste, aggiornalo
        _mockData[index].goals += goalsIncrement;
        _mockData[index].motm += motmIncrement;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
