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
  final Map<int, String> cityNamePerField;
  final Map<int, LobbyBooking> lobbyBookingsCache;
  final Map<int, PrivateBooking> privateBookingsCache;
  final Map<int, MatchBooking> matchBookingsCache;
  final Map<int, FootballMatch> footballMatchPerBooking;
  final Map<int, Team> teamsCache;
  final Map<int, String> usernamePerBooking;

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
    return OrganizationHomeResponse(
      fields: (json[ApiJsonKeys.fields] as List)
          .map((e) => Field.fromJson(e))
          .toList(),
      generalBookings: (json[ApiJsonKeys.generalBookings] as List)
          .map((e) => Booking.fromJson(e))
          .toList(),
      cityNamePerField: Map<int, String>.from(
        json[ApiJsonKeys.cityNamePerField],
      ),
      lobbyBookingsCache: Map<int, LobbyBooking>.from(
        (json[ApiJsonKeys.lobbyBookingsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(int.parse(key), LobbyBooking.fromJson(value)),
        ),
      ),
      privateBookingsCache: Map<int, PrivateBooking>.from(
        (json[ApiJsonKeys.privateBookingsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(int.parse(key), PrivateBooking.fromJson(value)),
        ),
      ),
      matchBookingsCache: Map<int, MatchBooking>.from(
        (json[ApiJsonKeys.matchBookingsCache] as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(int.parse(key), MatchBooking.fromJson(value)),
        ),
      ),
      footballMatchPerBooking:
          (json[ApiJsonKeys.footballMatchPerBooking] as Map<String, dynamic>)
              .map(
                (key, value) =>
                    MapEntry(int.parse(key), FootballMatch.fromJson(value)),
              ),
      teamsCache: (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
        (key, value) => MapEntry(int.parse(key), Team.fromJson(value)),
      ),
      usernamePerBooking: Map<int, String>.from(
        json[ApiJsonKeys.usernamePerBooking],
      ),
    );
  }
}
