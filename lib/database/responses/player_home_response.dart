

import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament.dart';

class PlayerHomeResponse {
  final List<dynamic> bookings;
  final List<Tournament> activeTournaments;
  final Map<int, int> minutesRoundPerTournament;
  final Map<int, int> minutesPausePerTournament;
  final Map<int, List<FootballMatch>> footballMatchesPerTournament;
  final Map<int, List<FootballStanding>> footballStandingsPerTournament;
  final Map<int, Team> teamsCache;
  final Team? accountTeam;
  final Map<int, String> usernamePerBooking;
  final Map<int, Field> fieldsCache;
  final Map<int, int> maxPlayersPerLobby;
  final Map<int, int> currentPlayersPerLobby;
  final Map<int, String> completeAddressPerField;
  final Map<int, int> playersPaidPerBooking;

  PlayerHomeResponse({
    required this.bookings,
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
      bookings: List<dynamic>.from(json[ApiJsonKeys.bookings]),
      activeTournaments: (json[ApiJsonKeys.activeTournaments] as List)
          .map((t) => Tournament.fromJson(t))
          .toList(),
      minutesRoundPerTournament: Map<int, int>.from(json[ApiJsonKeys.minutesRoundPerTournament]),
      minutesPausePerTournament: Map<int, int>.from(json[ApiJsonKeys.minutesPausePerTournament]),
      footballMatchesPerTournament: Map<int, List<FootballMatch>>.from(json[ApiJsonKeys.footballMatchesPerTournament].map((key, value) => MapEntry(int.parse(key), (value as List).map((m) => FootballMatch.fromJson(m)).toList()))),
      footballStandingsPerTournament: Map<int, List<FootballStanding>>.from(json[ApiJsonKeys.footballStandingsPerTournament].map((key, value) => MapEntry(int.parse(key), (value as List).map((s) => FootballStanding.fromJson(s)).toList()))),
      teamsCache: Map<int, Team>.from(json[ApiJsonKeys.teamsCache].map((key, value) => MapEntry(int.parse(key), Team.fromJson(value)))),
      accountTeam: json[ApiJsonKeys.accountTeam] != null ? Team.fromJson(json[ApiJsonKeys.accountTeam]) : null,
      usernamePerBooking: Map<int, String>.from(json[ApiJsonKeys.usernamePerBooking].map((key, value) => MapEntry(int.parse(key), value))),
      fieldsCache: Map<int, Field>.from(json[ApiJsonKeys.fieldsCache].map((key, value) => MapEntry(int.parse(key), Field.fromJson(value)))),
      maxPlayersPerLobby: Map<int, int>.from(json[ApiJsonKeys.maxPlayersPerLobby].map((key, value) => MapEntry(int.parse(key), value))),
      currentPlayersPerLobby: Map<int, int>.from(json[ApiJsonKeys.currentPlayersPerLobby].map((key, value) => MapEntry(int.parse(key), value))),
      completeAddressPerField: Map<int, String>.from(json[ApiJsonKeys.completeAddressPerField].map((key, value) => MapEntry(int.parse(key), value))),
      playersPaidPerBooking: Map<int, int>.from(json[ApiJsonKeys.playersPaidPerBooking].map((key, value) => MapEntry(int.parse(key), value))),
    );
  }
}

