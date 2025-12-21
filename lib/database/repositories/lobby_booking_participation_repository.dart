import 'base_repository.dart';
import '../../models/lobby_booking_participation.dart';
import '../../config/app_config.dart';

class LobbyBookingParticipationRepository extends BaseRepository<LobbyBookingParticipation> {
  @override
  String get endpoint => 'lobby_booking_participations';

  @override
  LobbyBookingParticipation fromJson(Map<String, dynamic> json) => LobbyBookingParticipation.fromJson(json);

  @override
  Map<String, dynamic> toJson(LobbyBookingParticipation item) => item.toJson();

  List<LobbyBookingParticipation> _mockdata = [
  ];

  @override
  List<LobbyBookingParticipation> get mockData => _mockdata;

  Future<List<LobbyBookingParticipation>> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockdata.where((participation) => participation.playerId == playerId).toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<LobbyBookingParticipation>> getByLobbyBookingId(int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockdata.where((participation) => participation.lobbyBookingId == lobbyBookingId).toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<LobbyBookingParticipation?> getByPlayerAndLobbyBookingId(int playerId, int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockdata.firstWhere(
          (participation) =>
              participation.playerId == playerId &&
              participation.lobbyBookingId == lobbyBookingId,
          orElse: () => Future.value(null) as LobbyBookingParticipation,
        ),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeParticipation(int playerId, int lobbyBookingId) async {
    if(AppConfig.isDebug) {
      _mockdata.removeWhere((participation) =>
        participation.playerId == playerId && participation.lobbyBookingId == lobbyBookingId);
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isParticipating(int playerId, int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      final exists = _mockdata.any((participation) =>
        participation.playerId == playerId && participation.lobbyBookingId == lobbyBookingId);
      return Future.value(exists);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addParticipation(int lobbyBookingId, int playerId, int? playersPaid) async {
    if(AppConfig.isDebug) {
      final participation = LobbyBookingParticipation(
        playerId: playerId,
        lobbyBookingId: lobbyBookingId,
        joinedAt: DateTime.now(),
        playersPaid: playersPaid ?? 1,
      );
      _mockdata.add(participation);
      
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeLobbyParticipation(int lobbyBookingId) async {
    if(AppConfig.isDebug) {
      _mockdata.removeWhere((participation) => participation.lobbyBookingId == lobbyBookingId);
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getParticipantCount(int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      int count = 0;
      for(var participation in _mockdata) {
        if(participation.lobbyBookingId == lobbyBookingId) {
          count += participation.playersPaid;
        }
      }
      return Future.value(count);
    } else {
      throw UnimplementedError();
    }
  }


}