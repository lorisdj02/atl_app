import 'package:atl_app/database/requests/register_account_request.dart';
import 'package:atl_app/database/requests/update_account_info_request.dart';
import 'package:atl_app/models/account.dart';
import 'package:atl_app/models/referee_license.dart';
import 'package:atl_app/models/review.dart';
import 'package:dio/dio.dart';

class AccountServiceWrite {
  final String apiUrl;
  final Dio dio;

  AccountServiceWrite({required this.apiUrl, required this.dio});

  Future<Account> updateAccountInfos(UpdateAccountInfoRequest request) async {
    final response = await dio.patch("$apiUrl/update-infos", data: request.toJson());
    return Account.fromJson(response.data);
  }

  Future<void> deleteAccount() async {
    await dio.delete("$apiUrl/delete");
  }

  Future<RefereeLicense> insertRefereeLicense(RefereeLicense license) async {
    final response = await dio.post("$apiUrl/referee/insert-referee-license", data: license.toJson());
    return RefereeLicense.fromJson(response.data);
  }

  Future<void> deleteRefereeLicense(double sportId) async {
    await dio.delete("$apiUrl/referee/delete-referee-license/${sportId.toStringAsFixed(0)}");
  }

  Future<void> commitReview(Review review) async {
    await dio.patch("$apiUrl/reviews/commit", data: review.toJson());
  }

  Future<Account> registerAccount(RegisterAccountRequest request) async {
    final response = await dio.post("$apiUrl/register", data: request.toJson());
    return Account.fromJson(response.data);
  }
}
