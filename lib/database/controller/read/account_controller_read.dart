import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/login_response.dart';
import 'package:dio/dio.dart';

class AccountControllerRead {
  final String apiUrl = "/accounts";
  final Dio dio = ApiClient.instance;

  Future<int> getAccountLevel() async {
    final response = await dio.get("$apiUrl/level");
    return response.data;
  }

  Future<bool> hasNotifications() async {
    final response = await dio.get("$apiUrl/has-notifications");
    return response.data;
  }

  Future<LoginResponse> handleLogin() async {
    final response = await dio.post("$apiUrl/login");
    return LoginResponse.fromJson(response.data);
  }

}
