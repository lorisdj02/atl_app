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
    return ApplyTournamentFiltersResponse(
      tournaments: List<Tournament>.from(
        json[ApiJsonKeys.tournaments].map((x) => Tournament.fromJson(x)),
      ),
      cityNamePerField: Map<double, String>.from(
        json[ApiJsonKeys.cityNamePerField].map(
          (key, value) => MapEntry(double.parse(key), value),
        ),
      ),
      fieldsCache: Map<double, Field>.from(
        json[ApiJsonKeys.fieldsCache].map(
          (key, value) => MapEntry(double.parse(key), Field.fromJson(value)),
        ),
      ),
      coordinatorsCache:
          Map<double, Coordinator>.from(
            json[ApiJsonKeys.coordinatorsCache].map(
              (key, value) =>
                  MapEntry(double.parse(key), Coordinator.fromJson(value)),
            ),
          ),
    );
  }
}
