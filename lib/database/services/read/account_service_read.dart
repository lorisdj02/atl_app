import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/login_response.dart';
import 'package:atl_app/models/account.dart';
import 'package:atl_app/providers/account_provider.dart';
import 'package:dio/dio.dart';

class AccountServiceRead {
  final String apiUrl = "/accounts";
  final Dio dio = ApiClient.instance;

  Future<int> getAccountLevel() async {
    final response = await dio.get("$apiUrl/account/level");
    return response.data;
  }

  Future<bool> hasNotifications() async {
    final response = await dio.get("$apiUrl/account/has-notifications");
    return response.data;
  }

  Future<LoginResponse> handleLogin() async {
    final response = await dio.post("$apiUrl/login");
    return LoginResponse.fromJson(response.data);
  }

}
