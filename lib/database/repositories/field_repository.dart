import '../../models/field.dart';
import 'base_repository.dart';
import '../../models/sport_category.dart';

/// Repository per la gestione dei campi sportivi
class FieldRepository extends BaseRepository<Field> {
  @override
  String get endpoint => 'fields';

  @override
  Field fromJson(Map<String, dynamic> json) => Field.fromJson(json);

  @override
  Map<String, dynamic> toJson(Field item) => item.toJson();

  @override
  List<Field> get mockData => [
        Field(
          id: 1,
          organizationId: 1,
          name: 'Campo Centrale',
          locationX: 45.4642,
          locationY: 9.1900,
          costTournament: 150.00,
          costPrivate: 80.00,
          city: 'Milano',
          sportCategory: SportCategory.football,
        ),
        Field(
          id: 2,
          organizationId: 1,
          name: 'Campo Nord',
          locationX: 45.4654,
          locationY: 9.1910,
          costTournament: 120.00,
          costPrivate: 60.00,
          city: 'Milano',
          sportCategory: SportCategory.football,
        ),
        Field(
          id: 3,
          organizationId: 2,
          name: 'Arena Roma',
          locationX: 41.9028,
          locationY: 12.4964,
          costTournament: 200.00,
          costPrivate: 100.00,
          city: 'Roma',
          sportCategory: SportCategory.football,
        ),
        Field(
          id: 4,
          organizationId: 2,
          name: 'Campo Sud',
          locationX: 41.9020,
          locationY: 12.4950,
          costTournament: 130.00,
          costPrivate: 70.00,
          city: 'Roma',
          sportCategory: SportCategory.football,
        ),
      ];

  /// Ottieni campi per organizzazione
  Future<List<Field>> getByOrganization(int organizationId) async {
    final allFields = await getAll();
    return allFields
        .where((field) => field.organizationId == organizationId)
        .toList();
  }

  /// Ottieni campi per città
  Future<List<Field>> getByCity(String city) async {
    final allFields = await getAll();
    return allFields
        .where((field) => field.city.toLowerCase() == city.toLowerCase())
        .toList();
  }
}
