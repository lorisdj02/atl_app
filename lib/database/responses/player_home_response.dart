

import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';

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
    return PlayerHomeResponse(
      privateBookings: (json[ApiJsonKeys.privateBookings] as List)
          .map((b) => PrivateBooking.fromJson(b))
          .toList(),
      lobbies: (json[ApiJsonKeys.lobbies] as List)
          .map((l) => LobbyBooking.fromJson(l))
          .toList(),
      activeTournaments: (json[ApiJsonKeys.activeTournaments] as List)
          .map((t) => Tournament.fromJson(t))
          .toList(),
      minutesRoundPerTournament: Map<double, int>.from(json[ApiJsonKeys.minutesRoundPerTournament]),
      minutesPausePerTournament: Map<double, int>.from(json[ApiJsonKeys.minutesPausePerTournament]),
      footballMatchesPerTournament: Map<double, List<FootballMatch>>.from(json[ApiJsonKeys.footballMatchesPerTournament].map((key, value) => MapEntry(double.parse(key), (value as List).map((m) => FootballMatch.fromJson(m)).toList()))),
      footballStandingsPerTournament: Map<double, List<FootballStanding>>.from(json[ApiJsonKeys.footballStandingsPerTournament].map((key, value) => MapEntry(double.parse(key), (value as List).map((s) => FootballStanding.fromJson(s)).toList()))),
      teamsCache: Map<double, Team>.from(json[ApiJsonKeys.teamsCache].map((key, value) => MapEntry(double.parse(key), Team.fromJson(value)))),
      accountTeam: json[ApiJsonKeys.accountTeam] != null ? Team.fromJson(json[ApiJsonKeys.accountTeam]) : null,
      usernamePerBooking: Map<double, String>.from(json[ApiJsonKeys.usernamePerBooking].map((key, value) => MapEntry(double.parse(key), value))),
      fieldsCache: Map<double, Field>.from(json[ApiJsonKeys.fieldsCache].map((key, value) => MapEntry(double.parse(key), Field.fromJson(value)))),
      maxPlayersPerLobby: Map<double, int>.from(json[ApiJsonKeys.maxPlayersPerLobby].map((key, value) => MapEntry(double.parse(key), value))),
      currentPlayersPerLobby: Map<double, int>.from(json[ApiJsonKeys.currentPlayersPerLobby].map((key, value) => MapEntry(double.parse(key), value))),
      completeAddressPerField: Map<double, String>.from(json[ApiJsonKeys.completeAddressPerField].map((key, value) => MapEntry(double.parse(key), value))),
      playersPaidPerBooking: Map<double, int>.from(json[ApiJsonKeys.playersPaidPerBooking].map((key, value) => MapEntry(double.parse(key), value))),
    );
  }
}

