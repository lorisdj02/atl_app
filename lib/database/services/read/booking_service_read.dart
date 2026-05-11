import 'package:atl_app/database/responses/book_field_response.dart';
import 'package:atl_app/database/responses/fields_and_max_players_per_field_response.dart';
import 'package:atl_app/database/responses/join_lobby_response.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:dio/dio.dart';

class BookingServiceRead {
  final String apiUrl;
  final Dio dio;

  BookingServiceRead({required this.apiUrl, required this.dio});

  Future<BookFieldResponse> getBookFieldScreen(
    SportCategory sportCategory,
  ) async {
    final response = await dio.get("${apiUrl}/book-a-field/${sportCategory.apiName}");
    return BookFieldResponse.fromJson(response.data);
  }

  Future<JoinLobbyResponse> getJoinLobbyScreen({
    required SportCategory sportCategory,
    int? totalPlayers,
    double? selectedCityId,
    DateTime? startTime,
    DateTime? finishTime,
  }) async {
    final response = await dio.get(
      "${apiUrl}/join-lobby-screen/${sportCategory.apiName}",
      queryParameters: {
        "totalPlayers": totalPlayers,
        "selectedCityId": selectedCityId,
        "startTime": startTime?.toIso8601String(),
        "finishTime": finishTime?.toIso8601String(),
      },
    );
    return JoinLobbyResponse.fromJson(response.data);
  }

  Future<FieldsAndMaxPlayersPerFieldResponse>
  getFreeFieldsByPlayerAndCityAndDate({
    required SportCategory sportCategory,
    required int maxPlayers,
    required double cityId,
    required DateTime startTime,
    required DateTime finishTime,
  }) async {
    final response = await dio.get(
      "${apiUrl}/free-fields/${sportCategory.apiName}/max-players/${maxPlayers.toString()}/city/${cityId.toStringAsFixed(0)}/start-time/${startTime.toIso8601String()}/finish-time/${finishTime.toIso8601String()}",
    );
    return FieldsAndMaxPlayersPerFieldResponse.fromJson(response.data);
  }
}
