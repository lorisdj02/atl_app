import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/book_field_response.dart';
import 'package:atl_app/database/responses/fields_and_max_players_per_field_response.dart';
import 'package:atl_app/database/responses/join_lobby_response.dart';
import 'package:atl_app/database/services/read/booking_service_read.dart';
import 'package:atl_app/database/services/write/booking_service_write.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:dio/dio.dart';

class BookingService {
  static final String apiUrl = "/bookings";
  static final Dio dio = ApiClient.instance;


  static final BookingServiceRead _read = BookingServiceRead(
    apiUrl: apiUrl,
    dio: dio,
  );
  static final BookingServiceWrite _write = BookingServiceWrite(
    apiUrl: apiUrl,
    dio: dio,
  );

  static Future<BookFieldResponse> getBookFieldScreen(
    SportCategory sportCategory,
  ) async => await _read.getBookFieldScreen(sportCategory);

  static Future<JoinLobbyResponse> getJoinLobbyScreen({
    required SportCategory sportCategory,
    int? totalPlayers,
    double? selectedCityId,
    DateTime? startTime,
    DateTime? finishTime,
  }) async => await _read.getJoinLobbyScreen(
    sportCategory: sportCategory,
    totalPlayers: totalPlayers,
    selectedCityId: selectedCityId,
    startTime: startTime,
    finishTime: finishTime,
  );

  static Future<FieldsAndMaxPlayersPerFieldResponse>
  getFreeFieldsByPlayerAndCityAndDate({
    required SportCategory sportCategory,
    required int maxPlayers,
    required double cityId,
    required DateTime startTime,
    required DateTime finishTime,
  }) async => await _read.getFreeFieldsByPlayerAndCityAndDate(
    sportCategory: sportCategory,
    maxPlayers: maxPlayers,
    cityId: cityId,
    startTime: startTime,
    finishTime: finishTime,
  );

  static Future<void> leaveLobbyBooking(double bookingId) async =>
      await _write.leaveLobbyBooking(bookingId);

  static Future<void> refundPrivateBooking(double bookingId) async =>
      await _write.refundPrivateBooking(bookingId);

  static Future<void> scheduleMatch(double matchId, DateTime scheduledStart) async =>
      await _write.scheduleMatch(matchId, scheduledStart);
}
