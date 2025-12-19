import 'package:atl_app/config/app_config.dart';

import '../../models/team.dart';
import 'base_repository.dart';
import '../db_controller.dart';

/// Repository per la gestione dei team
class TeamRepository extends BaseRepository<Team> {
  @override
  String get endpoint => 'teams';

  @override
  Team fromJson(Map<String, dynamic> json) => Team.fromJson(json);

  @override
  Map<String, dynamic> toJson(Team item) => item.toJson();

  List<Team> _mockData = [
        Team(
          id: 1,
          cityId: '1',
          name: 'Team A',
          alias: 'TAL',
          description: 'Descrizione del Team A',
          captainId: 1,
          catId: 'FOOTBALL',
          vip: true,
          players: 15,
          rankPts: 250,
          imageUrl: null,
        ),
        Team(
          id: 2,
          cityId: '2',
          name: 'Team B',
          alias: 'TBA',
          description: 'Descrizione del Team B',
          captainId: 3,
          catId: 'FOOTBALL',
          vip: false,
          players: 12,
          rankPts: 180,
        ),
        Team(
          id: 3,
          cityId: '1',
          name: 'Team C',
          alias: 'TCC',
          description: 'Descrizione del Team C',
          captainId: 4,
          catId: 'FOOTBALL',
          vip: true,
          players: 18,
          rankPts: 220,
        ),
        Team(
          id: 4,
          cityId: '3',
          name: 'Team D',
          alias: 'TDD',
          description: 'Descrizione del Team D',
          captainId: 5,
          catId: 'FOOTBALL',
          vip: false,
          players: 14,
          rankPts: 195,
        ),
        Team(
          id: 5,
          cityId: '2',
          name: 'Team 1',
          alias: 'TE1',
          description: 'Descrizione del Team 1',
          captainId: 2,
          catId: 'FOOTBALL',
          vip: true,
          players: 16,
          rankPts: 230,
        ),
        Team(
          id: 6,
          cityId: '2',
          name: 'Team 2',
          alias: 'TE2',
          description: 'Descrizione del Team 2',
          captainId: 2,
          catId: 'FOOTBALL',
          vip: true,
          players: 16,
          rankPts: 230,
        ),
        Team(
          id: 7,
          cityId: '2',
          name: 'Team 3',
          alias: 'TE3',
          description: 'Descrizione del Team 3',
          captainId: 2,
          catId: 'FOOTBALL',
          vip: true,
          players: 16,
          rankPts: 230,
        ),
        Team(
          id: 8,
          cityId: '2',
          name: 'Team 4',
          alias: 'TE4',
          description: 'Descrizione del Team 4',
          captainId: 2,
          catId: 'FOOTBALL',
          vip: true,
          players: 16,
          rankPts: 230,
        ),
        Team(
          id: 9,
          cityId: '2',
          name: 'Team 5',
          alias: 'TE5',
          description: 'Descrizione del Team 5',
          captainId: 2,
          catId: 'FOOTBALL',
          vip: true,
          players: 16,
          rankPts: 230,
        ),
        Team(
          id: 10,
          cityId: '2',
          name: 'Team 6',
          alias: 'TE6',
          description: 'Descrizione del Team 6',
          captainId: 2,
          catId: 'FOOTBALL',
          vip: true,
          players: 16,
          rankPts: 230,
        ),
        Team(
          id: 11,
          cityId: '2',
          name: 'Team 7',
          alias: 'TE7',
          description: 'Descrizione del Team 7',
          captainId: 2,
          catId: 'FOOTBALL',
          vip: true,
          players: 16,
          rankPts: 230,
        ),
  ];

  @override
  List<Team> get mockData => _mockData;


  /// Ottieni team per categoria
  Future<List<Team>> getByCategory(String categoryId) async {
    if(AppConfig.isDebug) {
      return _mockData.where((team) => team.catId == categoryId).toList();
    }
    else{
      throw UnimplementedError();
    }
  }

  /// Ottieni team per città
  Future<List<Team>> getByCity(String cityId) async {
    if(AppConfig.isDebug) {
      return _mockData.where((team) => team.cityId == cityId).toList();
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<List<Team>> getVipTeams() async {
    if(AppConfig.isDebug) {
      return _mockData.where((team) => team.vip).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Team>> getNonVipTeams() async {
    if(AppConfig.isDebug) {
      return _mockData.where((team) => !team.vip).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<Team?> getByNameOrAlias(String name) async {
   if(AppConfig.isDebug) {
      for (var team in _mockData) {
        if (team.name.toLowerCase() == name.toLowerCase() ||
            team.alias.toLowerCase() == name.toLowerCase()) {
          return team;
        }
      }
      return null;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isNameUnique(String name) async {
    if(AppConfig.isDebug){
      for (var team in _mockData) {
        if (team.name.toLowerCase() == name.toLowerCase()) {
          return false;
        }
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> insertTeam(int id, String? cityId, String name, String alias, String? description, int captainId, String catId, String? imageUrl, bool vip, bool visibility) async {
    final newTeam = Team(
        id: id, // Temporary ID
        cityId: cityId,
        name: name,
        alias: alias,
        description: description,
        captainId: captainId, // Usa playerId dell'utente corrente
        catId: catId,
        imageUrl: imageUrl,
        vip: vip,
        players: 1, // Solo il capitano inizialmente
        visibility: visibility,
      );

    if(AppConfig.isDebug){
      _mockData.add(newTeam);
      return true;
    } else {
      UnimplementedError();
      return false;
    }
  }

}