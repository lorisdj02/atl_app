import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/city.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/lobby_booking.dart';

class JoinLobbyResponse {
  final Map<double, String> usernamePerBooking;
  final List<LobbyBooking> lobbies;
  final Map<double, int> maxPlayersPerLobby;
  final Map<double, int> currentPlayersPerLobby;
  final Map<double, int> playersPaidPerBooking;
  final Map<double, Field> fieldsCache;
  final Map<double, String> completeAddressPerField;
  final List<City> cities;

  JoinLobbyResponse({
    required this.usernamePerBooking,
    required this.lobbies,
    required this.maxPlayersPerLobby,
    required this.currentPlayersPerLobby,
    required this.playersPaidPerBooking,
    required this.fieldsCache,
    required this.completeAddressPerField,
    required this.cities,
  });

  factory JoinLobbyResponse.fromJson(Map<String, dynamic> json) {
    final Map<double, String> usernamePerBooking =
        (json[ApiJsonKeys.usernamePerBooking] as Map<String, dynamic>).map(
          (k, v) => MapEntry(double.parse(k), v),
        );
    print("Username per booking parsed: ${usernamePerBooking.length}");

    final List<LobbyBooking> lobbies = (json[ApiJsonKeys.lobbies] as List)
        .map((x) => LobbyBooking.fromJson(x))
        .toList();
    print("Lobbies parsed: ${lobbies.length}");

    final Map<double, int> maxPlayersPerLobby =
        (json[ApiJsonKeys.maxPlayersPerLobby] as Map<String, dynamic>).map(
          (k, v) => MapEntry(double.parse(k), (v as num).toInt()),
        );
    print("Max players per lobby parsed: ${maxPlayersPerLobby.length}");

    final Map<double, int> currentPlayersPerLobby =
        (json[ApiJsonKeys.currentPlayersPerLobby] as Map<String, dynamic>).map(
          (k, v) => MapEntry(double.parse(k), (v as num).toInt()),
        );
    print("Current players per lobby parsed: ${currentPlayersPerLobby.length}");

    final Map<double, int> playersPaidPerBooking =
        (json[ApiJsonKeys.playersPaidPerBooking] as Map<String, dynamic>).map(
          (k, v) => MapEntry(double.parse(k), (v as num).toInt()),
        );
    print("Players paid per booking parsed: ${playersPaidPerBooking.length}");

    final Map<double, Field> fieldsCache =
        (json[ApiJsonKeys.fieldsCache] as Map<String, dynamic>).map(
          (k, v) => MapEntry(double.parse(k), Field.fromJson(v)),
        );
    print("Fields cache parsed: ${fieldsCache.length}");

    final Map<double, String> completeAddressPerField =
        (json[ApiJsonKeys.completeAddressPerField] as Map<String, dynamic>).map(
          (k, v) => MapEntry(double.parse(k), v),
        );
    print(
      "Complete addresses per field parsed: ${completeAddressPerField.length}",
    );

    final List<City> cities = (json[ApiJsonKeys.cities] as List)
        .map((x) => City.fromJson(x))
        .toList();
    print("Cities parsed: ${cities.length}");

    return JoinLobbyResponse(
      usernamePerBooking: usernamePerBooking,
      lobbies: lobbies,
      maxPlayersPerLobby: maxPlayersPerLobby,
      currentPlayersPerLobby: currentPlayersPerLobby,
      playersPaidPerBooking: playersPaidPerBooking,
      fieldsCache: fieldsCache,
      completeAddressPerField: completeAddressPerField,
      cities: cities,
    );
  }
}
