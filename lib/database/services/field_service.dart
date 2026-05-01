import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/fields_and_max_players_per_field_response.dart';
import 'package:atl_app/database/services/read/field_service_read.dart';
import 'package:atl_app/database/services/write/field_service_write.dart';
import 'package:atl_app/models/city.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:dio/dio.dart';

class FieldService {
  static final String apiUrl = "/fields";
  static final Dio dio = ApiClient.instance;


  static final FieldServiceRead _read = FieldServiceRead(
    apiUrl: apiUrl,
    dio: dio,
  );
  static final FieldServiceWrite _write = FieldServiceWrite(
    apiUrl: apiUrl,
    dio: dio,
  );

  static Future<List<City>> getAllCities() async => await _read.getAllCities();

  static Future<FieldsAndMaxPlayersPerFieldResponse>
  getFieldsByMaxPlayersAndCityAndSportCategory({
    required SportCategory sportCategory,
    required double cityId,
    required int maxPlayers,
  }) async =>
      await _read.getFieldsByMaxPlayersAndCityAndSportCategory(
        sportCategory: sportCategory,
        cityId: cityId,
        maxPlayers: maxPlayers,
      );
}