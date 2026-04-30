import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament_participation.dart';

class TournamentDetailsResponse {
  final Field field;
  final String cityName;
  final Map<double, Team> teamsCache;
  final Player? currentPlayer;
  final Team? accountTeam;
  final TournamentParticipation? teamParticipation;
  final Coordinator coordinator;

  TournamentDetailsResponse({
    required this.field,
    required this.cityName,
    required this.teamsCache,
    required this.currentPlayer,
    required this.accountTeam,
    required this.teamParticipation,
    required this.coordinator,
  });

  factory TournamentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TournamentDetailsResponse(
      field: Field.fromJson(json[ApiJsonKeys.field]),
      cityName: json[ApiJsonKeys.cityName],
      teamsCache: Map<double, Team>.from(
        json[ApiJsonKeys.teamsCache].map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        ),
      ),
      currentPlayer: json[ApiJsonKeys.currentPlayer] != null
          ? Player.fromJson(json[ApiJsonKeys.currentPlayer])
          : null,
      accountTeam: json[ApiJsonKeys.accountTeam] != null
          ? Team.fromJson(json[ApiJsonKeys.accountTeam])
          : null,
      teamParticipation: json[ApiJsonKeys.teamParticipation] != null
          ? TournamentParticipation.fromJson(
              json[ApiJsonKeys.teamParticipation],
            )
          : null,
      coordinator: Coordinator.fromJson(json[ApiJsonKeys.coordinator]),
    );
  }
}
