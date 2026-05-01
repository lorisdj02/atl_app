import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/utils/json_long_print.dart';

class PlayerHomeResponse {
  final List<LobbyBooking> lobbies;
  final List<PrivateBooking> privateBookings;
  final List<Tournament> activeTournaments;
  final Map<double, int> minutesRoundPerTournament;
  final Map<double, int> minutesPausePerTournament;
  final Map<double, List<FootballMatch>> footballMatchesPerTournament;
  final Map<double, List<FootballStanding>> footballStandingsPerTournament;
  final Map<double, Team> teamsCache;
  final Team? accountTeam;
  final Map<double, String> usernamePerBooking;
  final Map<double, Field> fieldsCache;
  final Map<double, int> maxPlayersPerLobby;
  final Map<double, int> currentPlayersPerLobby;
  final Map<double, String> completeAddressPerField;
  final Map<double, int> playersPaidPerBooking;

  PlayerHomeResponse({
    required this.privateBookings,
    required this.lobbies,
    required this.activeTournaments,
    required this.minutesRoundPerTournament,
    required this.minutesPausePerTournament,
    required this.footballMatchesPerTournament,
    required this.footballStandingsPerTournament,
    required this.teamsCache,
    required this.accountTeam,
    required this.usernamePerBooking,
    required this.fieldsCache,
    required this.maxPlayersPerLobby,
    required this.currentPlayersPerLobby,
    required this.completeAddressPerField,
    required this.playersPaidPerBooking,
  });

  factory PlayerHomeResponse.fromJson(Map<String, dynamic> json) {
    //JsonLongPrint.printLongJson(json);
    final List<LobbyBooking> lobbies = (json[ApiJsonKeys.lobbies] as List)
        .map((e) => LobbyBooking.fromJson(e))
        .toList();
    print("Lobbies deserialized: ${lobbies.length}");

    final List<PrivateBooking> privateBookings =
        (json[ApiJsonKeys.privateBookings] as List)
            .map((e) => PrivateBooking.fromJson(e))
            .toList();
    print("PrivateBookings deserialized: ${privateBookings.length}");

    final List<Tournament> activeTournaments =
        (json[ApiJsonKeys.activeTournaments] as List)
            .map((e) => Tournament.fromJson(e))
            .toList();
    print("ActiveTournaments deserialized: ${activeTournaments.length}");

    final Map<double, int> minutesRoundPerTournament =
        (json[ApiJsonKeys.minutesRoundPerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value));
    print(
      "MinutesRoundPerTournament deserialized: ${minutesRoundPerTournament.keys.length}",
    );

    final Map<double, int> minutesPausePerTournament =
        (json[ApiJsonKeys.minutesPausePerTournament] as Map<String, dynamic>)
            .map((key, value) => MapEntry(double.parse(key), value));
    print(
      "MinutesPausePerTournament deserialized: ${minutesPausePerTournament.keys.length}",
    );

    final Map<double, List<FootballMatch>> footballMatchesPerTournament =
        (json[ApiJsonKeys.footballMatchesPerTournament] as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                double.parse(key),
                value == null
                    ? <FootballMatch>[]
                    : (value as List)
                          .map((e) => FootballMatch.fromJson(e))
                          .toList(),
              ),
            );
    print(
      "FootballMatchesPerTournament deserialized: ${footballMatchesPerTournament.keys.length}",
    );

    final Map<double, List<FootballStanding>> footballStandingsPerTournament =
        (json[ApiJsonKeys.footballStandingsPerTournament]
                as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                double.parse(key),
                (value as List)
                    .map((e) => FootballStanding.fromJson(e))
                    .toList(),
              ),
            );
    print(
      "FootballStandingsPerTournament deserialized: ${footballStandingsPerTournament.length}",
    );

    final Map<double, Team> teamsCache =
        (json[ApiJsonKeys.teamsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Team.fromJson(value)),
        );
    print("TeamsCache deserialized: ${teamsCache.length}");

    final Team? accountTeam = json[ApiJsonKeys.accountTeam] != null
        ? Team.fromJson(json[ApiJsonKeys.accountTeam])
        : null;
    print(
      "AccountTeam deserialized: ${accountTeam?.name ?? 'null'} ${accountTeam != null ? '(ID: ${accountTeam.id})' : ''}",
    );

    final Map<double, String> usernamePerBooking =
        (json[ApiJsonKeys.usernamePerBooking] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print("UsernamePerBooking deserialized: ${usernamePerBooking.length}");

    final Map<double, Field> fieldsCache =
        (json[ApiJsonKeys.fieldsCache] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), Field.fromJson(value)),
        );
    print("FieldsCache deserialized: ${fieldsCache.length}");

    final Map<double, int> maxPlayersPerLobby =
        (json[ApiJsonKeys.maxPlayersPerLobby] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print("MaxPlayersPerLobby deserialized: ${maxPlayersPerLobby.length}");

    final Map<double, int> currentPlayersPerLobby =
        (json[ApiJsonKeys.currentPlayersPerLobby] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print(
      "CurrentPlayersPerLobby deserialized: ${currentPlayersPerLobby.length}",
    );

    final Map<double, String> completeAddressPerField =
        (json[ApiJsonKeys.completeAddressPerField] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print(
      "CompleteAddressPerField deserialized: ${completeAddressPerField.length}",
    );

    final Map<double, int> playersPaidPerBooking =
        (json[ApiJsonKeys.playersPaidPerBooking] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), value),
        );
    print(
      "PlayersPaidPerBooking deserialized: ${playersPaidPerBooking.length}",
    );

    return PlayerHomeResponse(
      lobbies: lobbies,
      privateBookings: privateBookings,
      activeTournaments: activeTournaments,
      minutesRoundPerTournament: minutesRoundPerTournament,
      minutesPausePerTournament: minutesPausePerTournament,
      footballMatchesPerTournament: footballMatchesPerTournament,
      footballStandingsPerTournament: footballStandingsPerTournament,
      teamsCache: teamsCache,
      accountTeam: accountTeam,
      usernamePerBooking: usernamePerBooking,
      fieldsCache: fieldsCache,
      maxPlayersPerLobby: maxPlayersPerLobby,
      currentPlayersPerLobby: currentPlayersPerLobby,
      completeAddressPerField: completeAddressPerField,
      playersPaidPerBooking: playersPaidPerBooking,
    );
  }
}
