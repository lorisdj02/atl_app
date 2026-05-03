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
    Field field = Field.fromJson(json[ApiJsonKeys.field]);
    print("Field parsed: ${field.name}");

    String cityName = json[ApiJsonKeys.cityName];
    print("City name parsed: $cityName");

    Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        );
    print("Teams cache parsed: $teamsCache");

    Player? currentPlayer = json[ApiJsonKeys.currentPlayer] != null
        ? Player.fromJson(json[ApiJsonKeys.currentPlayer])
        : null;
    print("Current player parsed: $currentPlayer");

    Team? accountTeam = json[ApiJsonKeys.accountTeam] != null
        ? Team.fromJson(json[ApiJsonKeys.accountTeam])
        : null;
    print("Account team parsed: $accountTeam");

    TournamentParticipation? teamParticipation =
        json[ApiJsonKeys.teamParticipation] != null
        ? TournamentParticipation.fromJson(json[ApiJsonKeys.teamParticipation])
        : null;
    print("Team participation parsed: $teamParticipation");

    Coordinator coordinator = Coordinator.fromJson(
      json[ApiJsonKeys.coordinator],
    );
    print("Coordinator parsed: $coordinator");

    return TournamentDetailsResponse(
      field: field,
      cityName: cityName,
      teamsCache: teamsCache,
      currentPlayer: currentPlayer,
      accountTeam: accountTeam,
      teamParticipation: teamParticipation,
      coordinator: coordinator,
    );
  }
}
