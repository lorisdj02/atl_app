import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/invite_friends_response.dart';
import 'package:atl_app/database/responses/my_growth_response.dart';
import 'package:atl_app/database/responses/personal_player_stats_response.dart';
import 'package:atl_app/database/responses/referee_licenses_response.dart';
import 'package:atl_app/database/responses/reviews_response.dart';
import 'package:atl_app/database/responses/wallet_response.dart';
import 'package:dio/dio.dart';

class ProfileService {
  static final String apiUrl = "/profiles";
  static final Dio dio = ApiClient.instance;

  static Future<MyGrowthResponse> getMyGrowthScreen() async {
    final response = await dio.get("$apiUrl/growth-screen");
    return MyGrowthResponse.fromJson(response.data);
  }

  static Future<WalletResponse> getWalletScreen() async {
    final response = await dio.get("$apiUrl/wallet");
    return WalletResponse.fromJson(response.data);
  }

  static Future<RefereeLicensesResponse> getRefereeLicensesScreen() async {
    final response = await dio.get("$apiUrl/referee-licenses");
    return RefereeLicensesResponse.fromJson(response.data);
  }

  static Future<PersonalPlayerStatsResponse>
  getPersonalPlayerStatsScreen() async {
    final response = await dio.get("$apiUrl/personal-player-stats");
    return PersonalPlayerStatsResponse.fromJson(response.data);
  }

  static Future<ReviewsResponse> getReviewsScreen() async {
    final response = await dio.get("$apiUrl/reviews");
    return ReviewsResponse.fromJson(response.data);
  }

  static Future<InviteFriendsResponse> getInviteFriendsScreen() async {
    final response = await dio.get("$apiUrl/friend-invites");
    return InviteFriendsResponse.fromJson(response.data);
  }
}
