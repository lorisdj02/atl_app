import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/booking.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/match_booking.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/team.dart';

class OrganizationHomeResponse {
  final List<Field> fields;
  final List<Booking> generalBookings;
  final Map<double, String> cityNamePerField;
  final Map<double, LobbyBooking> lobbyBookingsCache;
  final Map<double, PrivateBooking> privateBookingsCache;
  final Map<double, MatchBooking> matchBookingsCache;
  final Map<double, FootballMatch> footballMatchPerBooking;
  final Map<double, Team> teamsCache;
  final Map<double, String> usernamePerBooking;

  OrganizationHomeResponse({
    required this.fields,
    required this.generalBookings,
    required this.cityNamePerField,
    required this.lobbyBookingsCache,
    required this.privateBookingsCache,
    required this.matchBookingsCache,
    required this.footballMatchPerBooking,
    required this.teamsCache,
    required this.usernamePerBooking,
  });

  factory OrganizationHomeResponse.fromJson(Map<String, dynamic> json) {
    final List<Field> fields = (json[ApiJsonKeys.fields] as List)
        .map((e) => Field.fromJson(e))
        .toList();
    print("Fields parsed: ${fields.length}");

    final List<Booking> generalBookings =
        (json[ApiJsonKeys.generalBookings] as List)
            .map((e) => Booking.fromJson(e))
            .toList();
    print("General bookings parsed: ${generalBookings.length}");

    final Map<double, String> cityNamePerField =
        (json[ApiJsonKeys.cityNamePerField] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print("City name per field parsed: ${cityNamePerField.length}");

    final Map<double, LobbyBooking> lobbyBookingsCache =
        (json[ApiJsonKeys.lobbyBookingsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(double.parse(key), LobbyBooking.fromJson(value)),
        );
    print("Lobby bookings cache parsed: ${lobbyBookingsCache.length}");

    final Map<double, PrivateBooking> privateBookingsCache =
        (json[ApiJsonKeys.privateBookingsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(double.parse(key), PrivateBooking.fromJson(value)),
        );
    print("Private bookings cache parsed: ${privateBookingsCache.length}");

    final Map<double, MatchBooking> matchBookingsCache =
        (json[ApiJsonKeys.matchBookingsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(double.parse(key), MatchBooking.fromJson(value)),
        );
    print("Match bookings cache parsed: ${matchBookingsCache.length}");

    final Map<double, FootballMatch> footballMatchPerBooking =
        (json[ApiJsonKeys.footballMatchPerBooking] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(double.parse(key), FootballMatch.fromJson(value)),
        );
    print(
      "Football matches per booking parsed: ${footballMatchPerBooking.length}",
    );

    final Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        );
    print("Teams cache parsed: ${teamsCache.length}");

    final Map<double, String> usernamePerBooking =
        (json[ApiJsonKeys.usernamePerBooking] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print("Usernames per booking parsed: ${usernamePerBooking.length}");

    return OrganizationHomeResponse(
      fields: fields,
      generalBookings: generalBookings,
      cityNamePerField: cityNamePerField,
      lobbyBookingsCache: lobbyBookingsCache,
      privateBookingsCache: privateBookingsCache,
      matchBookingsCache: matchBookingsCache,
      footballMatchPerBooking: footballMatchPerBooking,
      teamsCache: teamsCache,
      usernamePerBooking: usernamePerBooking,
    );
  }
}
