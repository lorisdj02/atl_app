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

  @override
  List<Team> get mockData => [
        Team(
          id: 1,
          cityId: '1',
          name: 'Team A',
          alias: 'TA',
          description: 'Descrizione del Team A',
          captain: DB.Players.mockData[0],
          catId: '1',
          vip: true,
          players: 15,
          imageUrl: null, // TODO: Replace with actual image URL
        ),
        Team(
          id: 2,
          cityId: '2',
          name: 'Team B',
          alias: 'TB',
          description: 'Descrizione del Team B',
          captain: DB.Players.mockData[1],
          catId: '1',
          vip: false,
          players: 12,
        ),
      ];

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

}