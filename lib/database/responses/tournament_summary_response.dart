
import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/sport.dart';
import 'package:atl_app/models/tournament.dart';

class TournamentSummaryResponse {
  final Tournament tournament;
  final Sport sport;
  final Field field;
  final String cityName;

  TournamentSummaryResponse({
    required this.tournament,
    required this.sport,
    required this.field,
    required this.cityName,
  });

  factory TournamentSummaryResponse.fromJson(Map<String, dynamic> json) {
      final Tournament tournament = Tournament.fromJson(json[ApiJsonKeys.tournament] as Map<String, dynamic>);
  print("Tournament deserialized: ${tournament.name}");

  final Sport sport = Sport.fromJson(json[ApiJsonKeys.sport] as Map<String, dynamic>);
  print("Sport deserialized: ${sport.name}");

  final Field field = Field.fromJson(json[ApiJsonKeys.field] as Map<String, dynamic>);
  print("Field deserialized: ${field.name}");

  final String cityName = json[ApiJsonKeys.cityName] as String;
  print("City name deserialized: $cityName");

    return TournamentSummaryResponse(
      tournament: tournament,
      sport: sport,
      field: field,
      cityName: cityName,
    );
  }
}