import 'package:atl_app/database/responses/login_response.dart';
import 'package:dio/dio.dart';

class AccountServiceRead {
  final String apiUrl;
  final Dio dio;

  AccountServiceRead({required this.apiUrl, required this.dio});

  Future<int> getAccountLevel() async {
    final response = await dio.get("$apiUrl/account/level");
    return (response.data as num).toInt();
  }

  Future<bool> hasNotifications() async {
    final response = await dio.get("$apiUrl/account/has-notifications");
    return (response.data as bool);
  }

  Future<LoginResponse> handleLogin() async {
    final response = await dio.post("$apiUrl/login");
    return LoginResponse.fromJson(response.data);
  }
}
