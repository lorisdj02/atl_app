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
          standingPts: 45,
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
          standingPts: 38,
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
          standingPts: 42,
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
          standingPts: 40,
        ),
  ];

  @override
  List<Team> get mockData => _mockData;


  /// Ottieni team per categoria
  Future<List<Team>> getByCategory(String categoryId) async {
    final allTeams = await getAll();
    return allTeams.where((team) => team.catId == categoryId).toList();
  }

  /// Ottieni team per città
  Future<List<Team>> getByCity(String cityId) async {
    final allTeams = await getAll();
    return allTeams.where((team) => team.cityId == cityId).toList();
  }

  Future<List<Team>> getVipTeams() async {
    final allTeams = await getAll();
    return allTeams.where((team) => team.vip).toList();
  }

  Future<List<Team>> getNonVipTeams() async {
    final allTeams = await getAll();
    return allTeams.where((team) => !team.vip).toList();
  }

  Future<Team?> getByNameOrAlias(String name) async {
    final allTeams = await getAll();
    try {
      return allTeams.firstWhere(
        (team) => team.name.toLowerCase() == name.toLowerCase() || (team.alias?.toLowerCase() == name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }

  /// POST - Crea un nuovo team e inizializza le statistiche del capitano
  @override
  Future<Team> create(Team team) async {

    if (AppConfig.isDebug) {
      _mockData.add(team);
      print('🔧 [DEBUG] Created team: ${team.name}');
      return team;
    }
    else{
      return super.create(team);
    }

  }

}