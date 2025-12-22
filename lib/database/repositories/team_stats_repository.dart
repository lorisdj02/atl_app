import 'package:atl_app/models/team.dart';
import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/team_stats.dart';
import '../api_client.dart';
import 'base_repository.dart';

class TeamStatsRepository extends BaseRepository<TeamStats> {
  final Dio _dio = ApiClient.instance;

  @override
  String get endpoint => 'team_stats';

  @override
  TeamStats fromJson(Map<String, dynamic> json) => TeamStats.fromJson(json);

  @override
  Map<String, dynamic> toJson(TeamStats item) => item.toJson();

  List<TeamStats> _mockData = [
    TeamStats(playerId: 1, teamId: 1, motm: 15, goals: 23),
    TeamStats(playerId: 2, teamId: 1, motm: 12, goals: 18),
    TeamStats(playerId: 3, teamId: 1, motm: 8, goals: 14),
    TeamStats(playerId: 4, teamId: 1, motm: 10, goals: 12),
    TeamStats(playerId: 5, teamId: 1, motm: 6, goals: 9),
    TeamStats(playerId: 6, teamId: 2, motm: 14, goals: 21),
    TeamStats(playerId: 7, teamId: 2, motm: 11, goals: 16),
    TeamStats(playerId: 8, teamId: 3, motm: 9, goals: 15),
  ];

  @override
  List<TeamStats> get mockData => _mockData;

  Future<List<TeamStats>> getByTeamId(int teamId) async{
    if(AppConfig.isDebug){
      return mockData.where((stats) => stats.teamId == teamId).toList();
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<List<TeamStats>> getByPlayerId(int playerId) async{
    if(AppConfig.isDebug){
      return mockData.where((stats) => stats.playerId == playerId).toList();
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<TeamStats>? getStatsForPlayerInTeam(int playerId, int teamId ) async {
    if(AppConfig.isDebug){
      return mockData.firstWhere(
        (stats) => stats.playerId == playerId && stats.teamId == teamId,
        orElse: () => TeamStats(playerId: playerId, teamId: teamId, motm: 0, goals: 0),
      );
    }
    else{
      throw UnimplementedError();
    }
  }

Future<bool> deleteByPlayerIdInTeam(int playerId, int teamId) async {
    if(AppConfig.isDebug){
      mockData.removeWhere((s) => s.playerId == playerId && s.teamId == teamId);
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> createStats({required int playerId, required int teamId, required int motm, required int goals}) async {

    if(await getStatsForPlayerInTeam(playerId, teamId) != null){
      await deleteByPlayerIdInTeam(playerId, teamId);
    }

    final stats = TeamStats(
      playerId: playerId,
      teamId: teamId,
      motm: motm,
      goals: goals,
    );

    if(AppConfig.isDebug){
      _mockData.add(stats);
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }
}
