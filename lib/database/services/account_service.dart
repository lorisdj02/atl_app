import 'dart:io';

import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/requests/register_account_request.dart';
import 'package:atl_app/database/requests/update_account_info_request.dart';
import 'package:atl_app/database/responses/has_notifications_response.dart';
import 'package:atl_app/database/responses/login_response.dart';
import 'package:atl_app/database/services/read/account_service_read.dart';
import 'package:atl_app/database/services/write/account_service_write.dart';
import 'package:atl_app/models/account.dart';
import 'package:atl_app/models/referee_license.dart';
import 'package:atl_app/models/review.dart';
import 'package:dio/dio.dart';

class AccountService {
  static final String apiUrl = "/accounts";
  static final Dio dio = ApiClient.instance;

  static final AccountServiceRead _read = AccountServiceRead(
    apiUrl: apiUrl,
    dio: dio,
  );
  static final AccountServiceWrite _write = AccountServiceWrite( 
    apiUrl: apiUrl,
    dio: dio,
  );

  static Future<int> getAccountLevel() async => await _read.getAccountLevel();

  static Future<HasNotificationsResponse> hasNotifications() async =>
      await _read.hasNotifications();

  static Future<LoginResponse> handleLogin() async => await _read.handleLogin();

  static Future<Account> updateAccountInfos(
    UpdateAccountInfoRequest request, {
    File? profileImage,
  }) async => await _write.updateAccountInfos(
        request,
        profileImage: profileImage,
      );

  static Future<void> deleteAccount() async => await _write.deleteAccount();

  static Future<RefereeLicense> insertRefereeLicense(
    RefereeLicense license,
  ) async => await _write.insertRefereeLicense(license);

  static Future<void> deleteRefereeLicense(double sportId) async =>
      await _write.deleteRefereeLicense(sportId);

    static Future<Review> commitReview(Review review) async =>
      await _write.commitReview(review);

  static Future<Account> registerAccount(
    RegisterAccountRequest request,
  ) async => await _write.registerAccount(request);

    static Future<String> uploadProfilePicture(File imageFile) async =>
      await _write.uploadProfilePicture(imageFile);
}
