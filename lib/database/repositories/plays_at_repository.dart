import 'package:atl_app/models/sport_category.dart';

import '../../config/app_config.dart';
import '../../models/plays_at.dart';
import 'base_repository.dart';
import '../../models/player.dart';
import '../../models/team.dart';

class PlaysAtRepository extends BaseRepository<PlaysAt> {
  static final PlaysAtRepository _instance = PlaysAtRepository._internal();
  factory PlaysAtRepository() => _instance;
  PlaysAtRepository._internal();

  @override
  String get endpoint => 'plays_at';

  @override
  PlaysAt fromJson(Map<String, dynamic> json) => PlaysAt.fromJson(json);

  @override
  Map<String, dynamic> toJson(PlaysAt item) => item.toJson();

  List<PlaysAt> _mockData = [
        PlaysAt(
          teamId: 1,
          playerId: 1,
          joined: DateTime(2024, 1, 15),
        ),
        PlaysAt(
          teamId: 1,
          playerId: 7,
          joined: DateTime(2024, 1, 20),
        ),
        PlaysAt(
          teamId: 1,
          playerId: 8,
          joined: DateTime(2024, 2, 10),
        ),
        PlaysAt(
          teamId: 1,
          playerId: 9,
          joined: DateTime(2024, 3, 5),
        ),
        PlaysAt(
          teamId: 1,
          playerId: 10,
          joined: DateTime(2024, 3, 15),
        ),
        PlaysAt(
          teamId: 1,
          playerId: 6,
          joined: DateTime(2024, 4, 1),
        ),
      ];

  @override
  List<PlaysAt> get mockData => _mockData;


  Future<bool> isPlayerInTeam(int playerId){
    if(AppConfig.isDebug){
      return Future.value(_mockData.any((pa) => pa.playerId == playerId));
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<List<PlaysAt>> getByTeamId(int teamId) {
    if (AppConfig.isDebug) {
      return Future.value(
          _mockData.where((playsAt) => playsAt.teamId == teamId).toList());
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<PlaysAt>> getByPlayerId(int playerId) {
    if (AppConfig.isDebug) {
      return Future.value(
          _mockData.where((playsAt) => playsAt.playerId == playerId).toList());
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getTeamIdByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      final playsAt = _mockData.firstWhere(
          (pa) => pa.playerId == playerId,
          orElse: () => throw Exception('Player with ID $playerId not found in any team'));
      final teamId = playsAt.teamId;
      return teamId;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addPlaysAt(int teamId, int playerId) {
    if (AppConfig.isDebug) {
      _mockData.add(PlaysAt(teamId: teamId, playerId: playerId, joined: DateTime.now()));
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> removePlaysAt(int teamId, int playerId) {
    if (AppConfig.isDebug) {
      _mockData.removeWhere(
          (pa) => pa.teamId == teamId && pa.playerId == playerId);
      return Future.value();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<int>> getPlayersIdinTeam(int teamId) async {
    if (AppConfig.isDebug) {
      // This method can be implemented to return players in a team if needed
      List<int> playersId = _mockData.where((pa) => pa.teamId == teamId).map((pa) => pa.playerId).toList();
      print('🔧 [DEBUG] Players in team $teamId: $playersId');
      return Future.value(playersId);
    } else {
      throw UnimplementedError();
    }
  }

}
