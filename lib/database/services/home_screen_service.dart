import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/coordinator_home_response.dart';
import 'package:atl_app/database/responses/organization_home_response.dart';
import 'package:atl_app/database/responses/player_home_response.dart';
import 'package:atl_app/database/responses/referee_home_response.dart';
import 'package:atl_app/models/sport_category.dart';
import 'package:dio/dio.dart';

class HomeScreenService {
  static final String apiUrl = "/homes";
  static final Dio dio = ApiClient.instance;

  static Future<PlayerHomeResponse> getPlayerHomeScreen(
    SportCategory sportCategory,
  ) {
    final response = dio.get("$apiUrl/player/${sportCategory.apiName}");
    return response.then((value) => PlayerHomeResponse.fromJson(value.data));
  }

  static Future<CoordinatorHomeResponse> getCoordinatorHomeScreen(
    SportCategory sportCategory,
  ) {
    final response = dio.get("$apiUrl/coordinator/${sportCategory.apiName}");
    return response.then((value) => CoordinatorHomeResponse.fromJson(value.data));
  }

  static Future<RefereeHomeResponse> getRefereeHomeScreen(
    SportCategory sportCategory,
  ) {
    final response = dio.get("$apiUrl/referee/${sportCategory.apiName}");
    return response.then((value) => RefereeHomeResponse.fromJson(value.data));
  }

  static Future<OrganizationHomeResponse> getOrganizationHomeScreen(
    SportCategory sportCategory,
  ) {
    final response = dio.get("$apiUrl/organization/${sportCategory.apiName}");
    return response.then((value) => OrganizationHomeResponse.fromJson(value.data));
  }
}
