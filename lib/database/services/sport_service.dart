import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/models/sport.dart';
import 'package:atl_app/models/sport_category.dart';
import 'package:dio/dio.dart';

class SportService {
  static final String apiUrl = "/sports";
  static final Dio dio = ApiClient.instance;

  static Future<List<Sport>> getSportsByCategory(SportCategory category) async {
    final response = await dio.get("$apiUrl/by-category/${category.apiName}");
    return (response.data as List).map((e) => Sport.fromJson(e)).toList();
  }
}