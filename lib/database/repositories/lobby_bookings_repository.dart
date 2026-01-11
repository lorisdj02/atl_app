import 'package:atl_app/config/app_config.dart';
import 'base_repository.dart';
import '../../models/lobby_booking.dart';
import '../db_controller.dart';
import '../../models/booking.dart';

/// Repository per gestire le PrivateBooking nel database

class LobbyBookingsRepository extends BaseRepository<LobbyBooking> {
  @override
  String get endpoint => 'lobby_bookings';

  @override
  LobbyBooking fromJson(Map<String, dynamic> json) =>
      LobbyBooking.fromJson(json);

  @override
  Map<String, dynamic> toJson(LobbyBooking item) => item.toJson();

  List<LobbyBooking> _mockData = [];

  @override
  List<LobbyBooking> get mockData => _mockData;

  Future<LobbyBooking?> getById(int id) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere((booking) => booking.id == id);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni private bookings per player
  Future<List<LobbyBooking>?> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((booking) => booking.ownerId == playerId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeLobbyBooking(int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere((booking) => booking.id == lobbyBookingId);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> addLobbyBooking(
    int ownerId,
    int fieldId,
    DateTime startTime,
    DateTime finishTime,
    int maxPlayers,
    int playerToFind,
    double feePerPlayer,
  ) async {
    if (AppConfig.isDebug) {
      List<int> freeFieldIds =
          await DB.Bookings.getFreeFieldIds(startTime, finishTime, [fieldId]) ??
          [];

      if (!freeFieldIds.contains(fieldId)) {
        return -1; // Il campo non è libero in quel periodo
      }

      final double baseCost = (await DB.Fields.getById(fieldId)).hourlyCostPrivate *
          finishTime.difference(startTime).inHours;

      LobbyBooking newLobbyBooking = LobbyBooking(
        id: DB.Bookings.mockGetNextId(),
        ownerId: ownerId,
        fieldId: fieldId,
        startTime: startTime,
        finishTime: finishTime,
        maxPlayers: maxPlayers,
        playerToFind: playerToFind,
        feePerPlayer: (baseCost / maxPlayers * 100).ceil() / 100,
        status: BookingStatus.booked,
      );
      _mockData.add(newLobbyBooking);
      return newLobbyBooking.id;
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni private bookings per torneo
  Future<List<LobbyBooking>?> getByFieldId(int fieldId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((booking) => booking.fieldId == fieldId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<LobbyBooking>?> getByStatus(BookingStatus status) async {
    if (AppConfig.isDebug) {
      return _mockData.where((booking) => booking.status == status).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<int>?> getFreeFieldIds(
    DateTime startTime,
    DateTime finishTime,
    List<int> allFieldIds,
  ) async {
    if (AppConfig.isDebug) {
      return DB.Bookings.getFreeFieldIds(startTime, finishTime, allFieldIds);
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<LobbyBooking>> getBookedLobbyBookings(
    int? totalPlayers,
    int? cityId,
    DateTime? startTime,
    DateTime? endTime,
    int? playersToPay,
  ) async {
    if (AppConfig.isDebug) {
      if (totalPlayers == null &&
          cityId == null &&
          startTime == null &&
          endTime == null) {
        return _mockData
            .where((booking) => booking.status == BookingStatus.booked)
            .toList();
      } else {
        List<LobbyBooking> results = [];
        for (LobbyBooking booking in _mockData) {
          int bookingCityId = (await DB.Fields.getById(booking.fieldId)).cityId;
          if (booking.status == BookingStatus.booked) {
            if (totalPlayers != null && booking.maxPlayers < totalPlayers) {
              continue;
            }
            if (cityId != null && bookingCityId != cityId) {
              continue;
            }
            if (startTime != null && startTime.isBefore(booking.startTime)) {
              continue;
            }
            if (endTime != null && endTime.isAfter(booking.finishTime)) {
              continue;
            }
            if (playersToPay != null && booking.playerToFind != playersToPay) {
              continue;
            }
            results.add(booking);
          }
        }
        return results;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateLobbyBookingStatus(
    int lobbyBookingId,
    BookingStatus status,
  ) async {
    if (AppConfig.isDebug) {
      _mockData.firstWhere((booking) => booking.id == lobbyBookingId).status =
          status;
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> decreasePlayersToFind(
    int lobbyBookingId,
    int playersFound,
  ) async {
    if (AppConfig.isDebug) {
      _mockData
              .firstWhere((booking) => booking.id == lobbyBookingId)
              .playerToFind -=
          playersFound;
      if (_mockData
              .firstWhere((booking) => booking.id == lobbyBookingId)
              .playerToFind <=
          0) {
        updateLobbyBookingStatus(lobbyBookingId, BookingStatus.full);
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> increasePlayersToFind(
    int lobbyBookingId,
    int playersLeft,
  ) async {
    if (AppConfig.isDebug) {
      _mockData
              .firstWhere((booking) => booking.id == lobbyBookingId)
              .playerToFind +=
          playersLeft;
      if (_mockData
              .firstWhere((booking) => booking.id == lobbyBookingId)
              .playerToFind >
          0) {
        updateLobbyBookingStatus(lobbyBookingId, BookingStatus.booked);
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getMaxParticipants(int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .firstWhere((booking) => booking.id == lobbyBookingId)
          .maxPlayers;
    } else {
      throw UnimplementedError();
    }
  }
}
