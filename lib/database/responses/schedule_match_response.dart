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
    final int minutesPerRound = (json[ApiJsonKeys.minutesPerRound] as num)
        .toInt();
    print("Minutes per round deserialized: $minutesPerRound");

    final int minutesPerPause = (json[ApiJsonKeys.minutesPerPause] as num)
        .toInt();
    print("Minutes per pause deserialized: $minutesPerPause");

    final List<Booking> bookings = (json[ApiJsonKeys.generalBookings] as List)
        .map(
          (bookingJson) =>
              Booking.fromJson(bookingJson as Map<String, dynamic>),
        )
        .toList();
    print("Bookings deserialized: ${bookings.length}");

    return ScheduleMatchResponse(
      minutesPerRound: minutesPerRound,
      minutesPerPause: minutesPerPause,
      bookings: bookings,
    );
  }
}
