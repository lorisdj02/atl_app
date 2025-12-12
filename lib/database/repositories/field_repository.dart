import '../../models/field.dart';
import 'base_repository.dart';
import '../../models/sport_category.dart';
import '../../config/app_config.dart';

/// Repository per la gestione dei campi sportivi
class FieldRepository extends BaseRepository<Field> {
  @override
  String get endpoint => 'fields';

  @override
  Field fromJson(Map<String, dynamic> json) => Field.fromJson(json);

  @override
  Map<String, dynamic> toJson(Field item) => item.toJson();

  List<Field> _mockData = [
        Field(
          id: 1,
          organizationId: 1,
          name: 'Campo Centrale',
          locationX: 45.4642,
          locationY: 9.1900,
          costTournament: 150.00,
          hourlyCostPrivate: 80.00,
          city: 'Milano',
          sportCategory: SportCategory.football,
          maxPlayers: 22,
        ),
        Field(
          id: 2,
          organizationId: 1,
          name: 'Campo Nord',
          locationX: 45.4654,
          locationY: 9.1910,
          costTournament: 120.00,
          hourlyCostPrivate: 60.00,
          city: 'Milano',
          sportCategory: SportCategory.football,
          maxPlayers: 14,
        ),
        Field(
          id: 3,
          organizationId: 2,
          name: 'Arena Roma',
          locationX: 41.9028,
          locationY: 12.4964,
          costTournament: 200.00,
          hourlyCostPrivate: 100.00,
          city: 'Roma',
          sportCategory: SportCategory.football,
          maxPlayers: 10,
        ),
        Field(
          id: 4,
          organizationId: 2,
          name: 'Campo Sud',
          locationX: 41.9020,
          locationY: 12.4950,
          costTournament: 130.00,
          hourlyCostPrivate: 70.00,
          city: 'Roma',
          sportCategory: SportCategory.football,
          maxPlayers: 16,
        ),
      ];

  @override
  List<Field> get mockData => _mockData;

  /// Ottieni campi per organizzazione
  Future<List<Field>> getByOrganization(int organizationId) async {
    if (AppConfig.isDebug) {
    return _mockData
        .where((field) => field.organizationId == organizationId)
        .toList();
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni campi per città
  Future<List<Field>> getByCity(String city) async {
    if (AppConfig.isDebug) {
      return _mockData
        .where((field) => field.city.toLowerCase() == city.toLowerCase())
        .toList();
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<List<Field>> getBySportCategory(SportCategory category) async {
    if(AppConfig.isDebug) {
      return _mockData
        .where((field) => field.sportCategory == category)
        .toList();
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<List<Field>> getByMaxPlayersAndCity(int maxPlayers, String city) async {
    if(AppConfig.isDebug) {
      return _mockData
        .where((field) => field.maxPlayers >= maxPlayers && field.city.toLowerCase() == city.toLowerCase())
        .toList();
    }
    else {
      throw UnimplementedError();
    }
  }
}