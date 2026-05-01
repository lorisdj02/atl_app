import 'package:atl_app/database/responses/fields_and_max_players_per_field_response.dart';
import 'package:atl_app/models/city.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:dio/dio.dart';

class FieldServiceRead {
  final String apiUrl;
  final Dio dio;

  FieldServiceRead({
    required this.apiUrl,
    required this.dio,
  });

  Future<List<City>> getAllCities() async {
    final response = await dio.get("$apiUrl/all-cities");
    return (response.data as List).map((json) => City.fromJson(json)).toList();
  }

  Future<FieldsAndMaxPlayersPerFieldResponse>
  getFieldsByMaxPlayersAndCityAndSportCategory({
    required SportCategory sportCategory,
    required double cityId,
    required int maxPlayers,
  }) async {
    final response = await dio.get(
      "$apiUrl/${sportCategory.apiName}/city/$cityId/max-players/$maxPlayers",
    );
    return FieldsAndMaxPlayersPerFieldResponse.fromJson(response.data);
  }
}
