import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/city.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/tournament.dart';

class AllTournamentsResponse {
  final List<Tournament> tournaments;
  final List<Tournament> myTournaments;
  final Map<double, Coordinator> coordinatorsCache;
  final Map<double, Field> fieldsCache;
  final List<City> cities;
  final Map<double, String> cityNamePerField;
  final double prizeMin;
  final double prizeMax;
  final double feeMin;
  final double feeMax;

  AllTournamentsResponse({
    required this.tournaments,
    required this.myTournaments,
    required this.coordinatorsCache,
    required this.fieldsCache,
    required this.cities,
    required this.cityNamePerField,
    required this.prizeMin,
    required this.prizeMax,
    required this.feeMin,
    required this.feeMax,
  });

  factory AllTournamentsResponse.fromJson(Map<String, dynamic> json) {
    return AllTournamentsResponse(
      tournaments: (json[ApiJsonKeys.tournaments] as List)
          .map((e) => Tournament.fromJson(e))
          .toList(),
      myTournaments: (json[ApiJsonKeys.myTournaments] as List)
          .map((e) => Tournament.fromJson(e))
          .toList(),
      coordinatorsCache:
          (json[ApiJsonKeys.coordinatorsCache] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(double.parse(key), Coordinator.fromJson(value)),
          ),
      fieldsCache: (json[ApiJsonKeys.fieldsCache] as Map<String, dynamic>).map(
        (key, value) => MapEntry(double.parse(key), Field.fromJson(value)),
      ),
      cities: (json[ApiJsonKeys.cities] as List)
          .map((e) => City.fromJson(e))
          .toList(),
      cityNamePerField:
          (json[ApiJsonKeys.cityNamePerField] as Map<String, dynamic>).map(
            (key, value) => MapEntry(double.parse(key), value as String),
          ),
      prizeMin: json[ApiJsonKeys.prizeMin] as double,
      prizeMax: json[ApiJsonKeys.prizeMax] as double,
      feeMin: json[ApiJsonKeys.feeMin] as double,
      feeMax: json[ApiJsonKeys.feeMax] as double,
    );
  }
}
