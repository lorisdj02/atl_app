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
    return JoinLobbyResponse(
      usernamePerBooking: Map<double, String>.from(
        json[ApiJsonKeys.usernamePerBooking].map(
          (k, v) => MapEntry(double.parse(k), v),
        ),
      ),
      lobbies: List<LobbyBooking>.from(
        json[ApiJsonKeys.lobbies].map((x) => LobbyBooking.fromJson(x)),
      ),
      maxPlayersPerLobby: Map<double, int>.from(
        json[ApiJsonKeys.maxPlayersPerLobby].map(
          (k, v) => MapEntry(double.parse(k), v),
        ),
      ),
      currentPlayersPerLobby: Map<double, int>.from(
        json[ApiJsonKeys.currentPlayersPerLobby].map(
          (k, v) => MapEntry(double.parse(k), v),
        ),
      ),
      playersPaidPerBooking: Map<double, int>.from(
        json[ApiJsonKeys.playersPaidPerBooking].map(
          (k, v) => MapEntry(double.parse(k), v),
        ),
      ),
      fieldsCache: Map<double, Field>.from(
        json[ApiJsonKeys.fieldsCache].map(
          (k, v) => MapEntry(double.parse(k), Field.fromJson(v)),
        ),
      ),
      completeAddressPerField: Map<double, String>.from(
        json[ApiJsonKeys.completeAddressPerField].map(
          (k, v) => MapEntry(double.parse(k), v),
        ),
      ),
      cities: List<City>.from(
        json[ApiJsonKeys.cities].map((x) => City.fromJson(x)),
      ),
    );
  }
}
