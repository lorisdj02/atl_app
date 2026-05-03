import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/tournament.dart';

class ApplyTournamentFiltersResponse {
  List<Tournament> tournaments;
  Map<double, String> cityNamePerField;
  Map<double, Field> fieldsCache;
  Map<double, Coordinator> coordinatorsCache;

  ApplyTournamentFiltersResponse({
    required this.tournaments,
    required this.cityNamePerField,
    required this.fieldsCache,
    required this.coordinatorsCache,
  });

  factory ApplyTournamentFiltersResponse.fromJson(Map<String, dynamic> json) {
    List<Tournament> tournaments = (json[ApiJsonKeys.tournaments] as List)
        .map((e) => Tournament.fromJson(e))
        .toList();
    print("Tournaments: ${tournaments.length}");

    Map<double, String> cityNamePerField =
        (json[ApiJsonKeys.cityNamePerField] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print("City Names per Field: ${cityNamePerField.length}");

    Map<double, Field> fieldsCache =
        (json[ApiJsonKeys.fieldsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Field.fromJson(value)),
        );
    print("Fields Cache: ${fieldsCache.length}");

    Map<double, Coordinator> coordinatorsCache =
        (json[ApiJsonKeys.coordinatorsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(double.parse(key), Coordinator.fromJson(value)),
        );
    print("Coordinators Cache: ${coordinatorsCache.length}");

    return ApplyTournamentFiltersResponse(
      tournaments: tournaments,
      cityNamePerField: cityNamePerField,
      fieldsCache: fieldsCache,
      coordinatorsCache: coordinatorsCache,
    );
  }
}
