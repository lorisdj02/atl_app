import 'base_repository.dart';
import '../../models/football_tournament_stats.dart';
import '../../config/app_config.dart';

class FootballTournamentStatsRepository
    extends BaseRepository<FootballTournamentStats> {
  @override
  String get endpoint => 'football_tournament_stats';

  @override
  FootballTournamentStats fromJson(Map<String, dynamic> json) =>
      FootballTournamentStats.fromJson(json);

  @override
  Map<String, dynamic> toJson(FootballTournamentStats item) => item.toJson();

  List<FootballTournamentStats> _mockData = [
    FootballTournamentStats(
      playerId: 1,
      teamId: 1,
      tournamentId: 8,
      motm: 0,
      goals: 1,
    ),
  ];

  @override
  List<FootballTournamentStats> get mockData => _mockData;

  Future<List<FootballTournamentStats>> getByTeamIdTournamentId(
    int teamId,
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      return mockData
          .where(
            (stats) =>
                stats.teamId == teamId && stats.tournamentId == tournamentId,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<Map<String, dynamic>> incrementStatsInTournament(
    int playerId,
    int teamId,
    int tournamentId, {
    int goalsIncrement = 0,
    int motmIncrement = 0,
  }) async {
    if (AppConfig.isDebug) {
      FootballTournamentStats stats = mockData.firstWhere(
        (s) =>
            s.playerId == playerId &&
            s.teamId == teamId &&
            s.tournamentId == tournamentId,
        orElse: () => FootballTournamentStats(
          playerId: playerId,
          teamId: teamId,
          tournamentId: tournamentId,
          motm: 0,
          goals: 0,
        ),
      );

      Map<String, dynamic> result = {"table": "FootballTournamentStats", "changes": [stats.toJson()]};
      stats.goals += goalsIncrement;
      stats.motm += motmIncrement;
      final int index = mockData.indexWhere(
        (s) =>
            s.playerId == playerId &&
            s.teamId == teamId &&
            s.tournamentId == tournamentId,
      );

      if (index == -1) {
        _mockData.add(stats);
        return result;
      }
      _mockData[index] = stats;
      return result;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> rollbackByJson(List<dynamic> jsonList) async {
    if (AppConfig.isDebug) {
      try {
        for (var json in jsonList) {
          FootballTournamentStats stats =
              FootballTournamentStats.fromJson(json);
          int index = _mockData.indexWhere(
            (s) =>
                s.playerId == stats.playerId &&
                s.teamId == stats.teamId &&
                s.tournamentId == stats.tournamentId,
          );

          if (index != -1) {
            _mockData[index] = stats;
          } else {
            return false;
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

  Future<List<FootballTournamentStats>> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return mockData.where((stats) => stats.playerId == playerId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballTournamentStats>> getByTeamId(int teamId) async {
    if (AppConfig.isDebug) {
      return mockData.where((stats) => stats.teamId == teamId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballTournamentStats>> getByTournamentId(
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      return mockData
          .where((stats) => stats.tournamentId == tournamentId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<FootballTournamentStats>? getStatsForPlayerInTeamInTournament(
    int playerId,
    int teamId,
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      return mockData.firstWhere(
        (stats) =>
            stats.playerId == playerId &&
            stats.teamId == teamId &&
            stats.tournamentId == tournamentId,
        orElse: () => FootballTournamentStats(
          playerId: playerId,
          teamId: teamId,
          tournamentId: tournamentId,
          motm: 0,
          goals: 0,
        ),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteByPlayerIdInTeamInTournament(
    int playerId,
    int teamId,
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      mockData.removeWhere(
        (s) =>
            s.playerId == playerId &&
            s.teamId == teamId &&
            s.tournamentId == tournamentId,
      );
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> createStats({
    required int playerId,
    required int teamId,
    required int tournamentId,
    required int motm,
    required int goals,
  }) async {
    final stats = FootballTournamentStats(
      playerId: playerId,
      teamId: teamId,
      tournamentId: tournamentId,
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
}
