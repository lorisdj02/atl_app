import 'base_repository.dart';
import '../../models/lobby_booking_participation.dart';
import '../../config/app_config.dart';

class LobbyBookingParticipationRepository
    extends BaseRepository<LobbyBookingParticipation> {
  @override
  String get endpoint => 'lobby_booking_participations';

  @override
  LobbyBookingParticipation fromJson(Map<String, dynamic> json) =>
      LobbyBookingParticipation.fromJson(json);

  @override
  Map<String, dynamic> toJson(LobbyBookingParticipation item) => item.toJson();

  List<LobbyBookingParticipation> _mockdata = [];

  @override
  List<LobbyBookingParticipation> get mockData => _mockdata;

  Future<List<LobbyBookingParticipation>> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return _mockdata
          .where((participation) => participation.playerId == playerId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<LobbyBookingParticipation>> getActiveByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return _mockdata
          .where((participation) =>
              participation.playerId == playerId &&
              !participation.isRefound)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<LobbyBookingParticipation>> getByLobbyBookingId(
    int lobbyBookingId,
  ) async {
    if (AppConfig.isDebug) {
      return _mockdata
          .where(
            (participation) => participation.lobbyBookingId == lobbyBookingId,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<LobbyBookingParticipation?> getByPlayerAndLobbyBookingId(
    int playerId,
    int lobbyBookingId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        return _mockdata.firstWhere(
          (participation) =>
              participation.playerId == playerId &&
              participation.lobbyBookingId == lobbyBookingId && !participation.isRefound,
        );
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeParticipation(int playerId, int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      final int index = _mockdata.indexWhere(
        (participation) =>
            participation.playerId == playerId &&
            participation.lobbyBookingId == lobbyBookingId && !participation.isRefound,
      );

      if (index != -1) {
        _mockdata[index].isRefound = true;
        return true;
      }

      return false;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isParticipating(int playerId, int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      final exists = _mockdata.any(
        (participation) =>
            participation.playerId == playerId &&
            participation.lobbyBookingId == lobbyBookingId && !participation.isRefound,
      );
      return exists;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addParticipation(
    int lobbyBookingId,
    int playerId,
    int? playersPaid,
    double price,
  ) async {
    if (AppConfig.isDebug) {
      final participation = LobbyBookingParticipation(
        id: _mockdata.length + 1,
        playerId: playerId,
        lobbyBookingId: lobbyBookingId,
        joinedAt: DateTime.now(),
        playersPaid: playersPaid ?? 1,
        price: price,
      );
      _mockdata.add(participation);


      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeLobbyParticipation(int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      final List<int> indexes = [];
      indexes.addAll(
        _mockdata.asMap().entries.where(
              (entry) =>
                  entry.value.lobbyBookingId == lobbyBookingId && !entry.value.isRefound,
            ).map((entry) => entry.key),
      );

      for(final index in indexes) {
        _mockdata[index].isRefound = true;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getParticipantCount(int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      int count = 0;
      for (var participation in _mockdata) {
        if (participation.lobbyBookingId == lobbyBookingId && !participation.isRefound) {
          count += participation.playersPaid;
        }
      }
      return Future.value(count);
    } else {
      throw UnimplementedError();
    }
  }
}
