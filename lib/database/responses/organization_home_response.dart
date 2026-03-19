
import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/booking.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';

class OrganizationHomeResponse {
  final List<Field> fields;
  final List<Booking> generalBookings;
  final Map<int, String> cityNamePerField;
  final Map<int, dynamic> detailedBookings;
  final Map<int, FootballMatch> footballMatchPerBooking;
  final Map<int, Team> teamsCache;
  final Map<int, String> usernamePerBooking;
  
  OrganizationHomeResponse({
    required this.fields,
    required this.generalBookings,
    required this.cityNamePerField,
    required this.detailedBookings,
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
      cityNamePerField: Map<int, String>.from(json[ApiJsonKeys.cityNamePerField]),
      detailedBookings: Map<int, dynamic>.from(json[ApiJsonKeys.detailedBookings]),
      footballMatchPerBooking: (json[ApiJsonKeys.footballMatchPerBooking] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), FootballMatch.fromJson(value))),
      teamsCache: (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), Team.fromJson(value))),
      usernamePerBooking: Map<int, String>.from(json[ApiJsonKeys.usernamePerBooking]),
    );
  }
}