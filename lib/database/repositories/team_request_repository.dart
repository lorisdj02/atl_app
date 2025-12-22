import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/team_request.dart';
import '../api_client.dart';
import 'base_repository.dart';

class TeamRequestRepository extends BaseRepository<TeamRequest> {
  final Dio _dio = ApiClient.instance;

  @override
  String get endpoint => 'team_requests';

  @override
  TeamRequest fromJson(Map<String, dynamic> json) => TeamRequest.fromJson(json);

  @override
  Map<String, dynamic> toJson(TeamRequest item) => item.toJson();

  List<TeamRequest> _mockdata = [TeamRequest(
      teamId: 1,
      playerId: 4,
    ),
    TeamRequest(
      teamId: 1,
      playerId: 11,
    ),
  ];

  @override
  List<TeamRequest> get mockData => _mockdata;

  Future<List<TeamRequest>> getByTeamId(int teamId) async{
    if(AppConfig.isDebug){
      return _mockdata.where((request) => request.teamId == teamId).toList();
      }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> addRequest(TeamRequest request) async {
    if(AppConfig.isDebug){
      _mockdata.add(request);
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> deleteRequest(TeamRequest request) async {
    if(AppConfig.isDebug){
      _mockdata.removeWhere((r) =>
          r.teamId == request.teamId && r.playerId == request.playerId);
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> deleteByTeam(int teamId) async {
    if(AppConfig.isDebug){
      _mockdata.removeWhere((r) => r.teamId == teamId);
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<bool> deleteByPlayerId(int playerId) async {
    if(AppConfig.isDebug){
      _mockdata.removeWhere((r) => r.playerId == playerId);
      return true;
    }
    else{
      throw UnimplementedError();
    }
  }
}
