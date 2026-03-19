
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
    return TournamentSummaryResponse(
      tournament: Tournament.fromJson(json[ApiJsonKeys.tournament] as Map<String, dynamic>),
      sport: Sport.fromJson(json[ApiJsonKeys.sport] as Map<String, dynamic>),
      field: Field.fromJson(json[ApiJsonKeys.field] as Map<String, dynamic>),
      cityName: json[ApiJsonKeys.cityName] as String,
    );
  }
}