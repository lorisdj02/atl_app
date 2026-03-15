import '../../models/field.dart';
import 'base_repository.dart';
import '../../models/sport_category.dart';
import '../../config/app_config.dart';
import '../db_controller.dart';

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
      locationLat: 45.4642,
      locationLng: 9.1900,
      costTournament: 150.00,
      hourlyCostPrivate: 80.00,
      cityId: 1,
    ),
    Field(
      id: 2,
      organizationId: 1,
      name: 'Campo Nord',
      locationLat: 45.4654,
      locationLng: 9.1910,
      costTournament: 120.00,
      hourlyCostPrivate: 60.00,
      cityId: 1,
    ),
    Field(
      id: 3,
      organizationId: 1,
      name: 'Arena Roma',
      locationLat: 41.9028,
      locationLng: 12.4964,
      costTournament: 200.00,
      hourlyCostPrivate: 100.00,
      cityId: 2,
    ),
    Field(
      id: 4,
      organizationId: 2,
      name: 'Campo Sud',
      locationLat: 41.9020,
      locationLng: 12.4950,
      costTournament: 130.00,
      hourlyCostPrivate: 70.00,
      cityId: 2,
    ),
  ];

  @override
  List<Field> get mockData => _mockData;

  Future<Field?> getById(int fieldId) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere((field) => field.id == fieldId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Field>> getAll() async {
    if (AppConfig.isDebug) {
      return _mockData;
    } else {
      throw UnimplementedError();
    }
  }

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
  Future<List<Field>> getByCity(int cityId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((field) => field.cityId == cityId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Field>> getBySportCategory(SportCategory category) async {
    if (AppConfig.isDebug) {
      List<int> fieldIds = await DB.FieldCategories.getFieldIdsBySportCategory(
        category,
      );
      return _mockData.where((field) => fieldIds.contains(field.id)).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Field>> getByMaxPlayersAndCityAndSportCategory(
    int maxPlayers,
    int cityId,
    SportCategory sportCategory,
  ) async {
    if (AppConfig.isDebug) {
      List<int> fieldIds =
          await DB.FieldCategories.getFieldIdsBySportCategoryAndMaxPlayers(
            sportCategory,
            maxPlayers,
          );
      return _mockData
          .where(
            (field) => fieldIds.contains(field.id) && field.cityId == cityId,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }
}
