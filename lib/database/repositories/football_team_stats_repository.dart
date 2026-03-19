import '../../config/app_config.dart';
import '../../models/football_team_stats.dart';
import 'base_repository.dart';

class FootballTeamStatsRepository extends BaseRepository<FootballTeamStats> {
  @override
  String get endpoint => 'team_stats';

  @override
  FootballTeamStats fromJson(Map<String, dynamic> json) => FootballTeamStats.fromJson(json);

  @override
  Map<String, dynamic> toJson(FootballTeamStats item) => item.toJson();

  List<FootballTeamStats> _mockData = [
    FootballTeamStats(playerId: 1, teamId: 1, motm: 15, goals: 23),
    FootballTeamStats(playerId: 2, teamId: 1, motm: 12, goals: 18),
    FootballTeamStats(playerId: 3, teamId: 1, motm: 8, goals: 14),
    FootballTeamStats(playerId: 4, teamId: 1, motm: 10, goals: 12),
    FootballTeamStats(playerId: 5, teamId: 1, motm: 6, goals: 9),
    FootballTeamStats(playerId: 6, teamId: 2, motm: 14, goals: 21),
    FootballTeamStats(playerId: 7, teamId: 2, motm: 11, goals: 16),
    FootballTeamStats(playerId: 8, teamId: 3, motm: 9, goals: 15),
  ];

  @override
  List<FootballTeamStats> get mockData => _mockData;

  Future<List<FootballTeamStats>> getByTeamId(int teamId) async {
    if (AppConfig.isDebug) {
      return mockData.where((stats) => stats.teamId == teamId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<Map<String, dynamic>> incrementStats(
    int playerId,
    int teamId, {
    int goalsIncrement = 0,
    int motmIncrement = 0,
    int yellowCardsIncrement = 0,
    int redCardsIncrement = 0,
  }) async {
    if (AppConfig.isDebug) {
      final int index = _mockData.indexWhere(
        (s) => s.playerId == playerId && s.teamId == teamId,
      );

      Map<String, dynamic> result;

      if (index == -1) {
        // Non esiste, crealo
        FootballTeamStats newStats = FootballTeamStats(
          playerId: playerId,
          teamId: teamId,
          goals: goalsIncrement,
          motm: motmIncrement,
          yellowCards: yellowCardsIncrement,
          redCards: redCardsIncrement,
        );

        _mockData.add(newStats);

        result = {
          "table": "FootballTeamStats",
          "changes": [newStats.toJson()],
        };
      } else {
        // Esiste, aggiornalo usando copyWith
        result = {
          "table": "FootballTeamStats",
          "changes": [_mockData[index].toJson()],
        };
        _mockData[index].goals += goalsIncrement;
        _mockData[index].motm += motmIncrement;
        _mockData[index].yellowCards += yellowCardsIncrement;
        _mockData[index].redCards += redCardsIncrement;
      }
      return result;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> rollbackByJson(List<dynamic> jsonList) async {
    if (AppConfig.isDebug) {
      try {
        for (var json in jsonList) {
          FootballTeamStats stats = FootballTeamStats.fromJson(json);
          int index = _mockData.indexWhere(
            (s) => s.playerId == stats.playerId && s.teamId == stats.teamId,
          );

          if (index != -1) {
            _mockData[index] = stats;
          } else {
            _mockData.add(stats);
          }
        }
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballTeamStats>> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return mockData.where((stats) => stats.playerId == playerId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<FootballTeamStats>? getStatsForPlayerInTeam(int playerId, int teamId) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere(
        (stats) => stats.playerId == playerId && stats.teamId == teamId,
        orElse: () =>
            FootballTeamStats(playerId: playerId, teamId: teamId, motm: 0, goals: 0),
      );
    } else {
      throw UnimplementedError();
    }
  }


  Future<bool> createStats({
    required int playerId,
    required int teamId,
    required int motm,
    required int goals,
  }) async {
    if (await getStatsForPlayerInTeam(playerId, teamId) != null) {
      return true;
    }

    final stats = FootballTeamStats(
      playerId: playerId,
      teamId: teamId,
      motm: motm,
      goals: goals,
    );

    if (AppConfig.isDebug) {
      _mockData.add(stats);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<FootballTeamStats> getAggregatedStatsByPlayer(int playerId) async{
    if(AppConfig.isDebug){
      List<FootballTeamStats> playerStats = mockData.where((stats) => stats.playerId == playerId).toList();
      int totalMotm = playerStats.fold(0, (sum, stats) => sum + stats.motm);
      int totalGoals = playerStats.fold(0, (sum, stats) => sum + stats.goals);
      int totalYellowCards = playerStats.fold(0, (sum, stats) => sum + stats.yellowCards);
      int totalRedCards = playerStats.fold(0, (sum, stats) => sum + stats.redCards);

      return FootballTeamStats(
        playerId: playerId,
        teamId: 0,
        motm: totalMotm,
        goals: totalGoals,
        yellowCards: totalYellowCards,
        redCards: totalRedCards,
      );
    }else{
      throw UnimplementedError();
    }
  }
}
