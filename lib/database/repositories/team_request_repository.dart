import '../../config/app_config.dart';
import '../../models/team_request.dart';
import 'base_repository.dart';

class TeamRequestRepository extends BaseRepository<TeamRequest> {

  @override
  String get endpoint => 'team_requests';

  @override
  TeamRequest fromJson(Map<String, dynamic> json) => TeamRequest.fromJson(json);

  @override
  Map<String, dynamic> toJson(TeamRequest item) => item.toJson();

  List<TeamRequest> _mockdata = [
    TeamRequest(teamId: 1, playerId: 4),
    TeamRequest(teamId: 1, playerId: 11),
  ];

  @override
  List<TeamRequest> get mockData => _mockdata;

  Future<List<TeamRequest>> getByTeamId(int teamId) async {
    if (AppConfig.isDebug) {
      return _mockdata.where((request) => request.teamId == teamId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<TeamRequest>> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return _mockdata
          .where((request) => request.playerId == playerId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<TeamRequest?> getByTeamAndPlayer(int teamId, int playerId) async {
    if (AppConfig.isDebug) {
      print(
        "Searching for request with teamId: $teamId and playerId: $playerId",
      );
      try {
        return _mockdata.firstWhere(
          (request) => request.teamId == teamId && request.playerId == playerId,
        );
      } catch (e) {
        print("No matching request found.");
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addRequest(int teamId, int playerId) async {
    final TeamRequest newRequest = TeamRequest(
      teamId: teamId,
      playerId: playerId,
    );

    if (AppConfig.isDebug) {
      if (await getByTeamAndPlayer(teamId, playerId) != null) {
        return false;
      }
      _mockdata.add(newRequest);
      print("Mockdata after adding request: $_mockdata");
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteRequest(int teamId, int playerId) async {
    if (await getByTeamAndPlayer(teamId, playerId) == null) {
      return false;
    }

    if (AppConfig.isDebug) {
      _mockdata.removeWhere(
        (r) => r.teamId == teamId && r.playerId == playerId,
      );
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteByTeam(int teamId) async {
    if (AppConfig.isDebug) {
      _mockdata.removeWhere((r) => r.teamId == teamId);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      _mockdata.removeWhere((r) => r.playerId == playerId);
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
