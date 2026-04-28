import 'package:atl_app/database/api_client.dart';
import 'package:dio/dio.dart';

class BookingServiceWrite {
  final String apiUrl = "/bookings";
  final Dio dio = ApiClient.instance;

  Future<void> leaveLobbyBooking(double bookingId) async {
    await dio.delete("$apiUrl/lobby-booking/$bookingId/leave");
  }

  Future<void> refundPrivateBooking(double bookingId) async {
    await dio.delete("$apiUrl/private-booking/$bookingId/refund");
  }

  Future<void> scheduleMatch(double matchId, DateTime scheduledStart) async {
    await dio.post(
      "$apiUrl/match-booking/$matchId/schedule/${scheduledStart.toIso8601String()}",
    );
  }
}
