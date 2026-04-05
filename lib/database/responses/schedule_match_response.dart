import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/booking.dart';

class ScheduleMatchResponse {
  final int minutesPerRound;
  final int minutesPerPause;
  final List<Booking> bookings;

  ScheduleMatchResponse({
    required this.minutesPerRound,
    required this.minutesPerPause,
    required this.bookings,
  });

  factory ScheduleMatchResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleMatchResponse(
      minutesPerRound: json[ApiJsonKeys.minutesPerRound] as int,
      minutesPerPause: json[ApiJsonKeys.minutesPerPause] as int,
      bookings: List<Booking>.from(
        (json[ApiJsonKeys.generalBookings] as List<dynamic>).map(
          (bookingJson) =>
              Booking.fromJson(bookingJson as Map<String, dynamic>),
        ),
      ),
    );
  }
}
