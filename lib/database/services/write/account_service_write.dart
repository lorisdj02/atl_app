import 'dart:io';

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

  Future<Account> updateAccountInfos(
    UpdateAccountInfoRequest request, {
    File? profileImage,
  }) async {
    final Object payload;
    if (profileImage != null) {
      payload = FormData.fromMap({
        ...request.toMap(),
        'file': await MultipartFile.fromFile(
          profileImage.path,
          filename: profileImage.uri.pathSegments.last,
        ),
      });
    } else {
      payload = request.toJson();
    }

    final response = await dio.post(
      "$apiUrl/account/update-infos",
      data: payload,
    );
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

  Future<Review> commitReview(Review review) async {
    final response = await dio.patch(
      "$apiUrl/review/commit",
      data: review.toJson(),
    );
    return Review.fromJson(response.data);
  }

  Future<Account> registerAccount(RegisterAccountRequest request) async {
    final response = await dio.post("$apiUrl/register", data: request.toJson());
    return Account.fromJson(response.data);
  }
  
  Future<String> uploadProfilePicture(File imageFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.uri.pathSegments.last,
      ),
    });

    final response = await dio.post(
      "$apiUrl/account/upload-profile-picture",
      data: formData,
    );

    final data = response.data;
    if (data is Map<String, dynamic> && data['imageUrl'] is String) {
      return data['imageUrl'] as String;
    }
    if (data is String) return data;

    throw Exception('Invalid upload response');
  }
}
