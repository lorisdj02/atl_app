import 'package:atl_app/config/app_config.dart';
import 'package:atl_app/models/sport.dart';
import 'package:atl_app/models/sport_category.dart';
import 'base_repository.dart';
import '../../models/lobby_booking.dart';
import '../db_controller.dart';
import '../../models/booking.dart';
import '../../models/field.dart';

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
  Future<List<LobbyBooking>> getByOwnerId(int playerId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((booking) => booking.ownerPlayerId == playerId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeLobbyBooking(int lobbyBookingId) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere((booking) => booking.id == lobbyBookingId);
      if (index == -1) {
        return false; // Prenotazione non trovata
      }

      _mockData[index].status = BookingStatus.refound;
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> addLobbyBooking(
    int ownerPlayerId,
    int fieldId,
    DateTime startTime,
    DateTime finishTime,
    int maxPlayers,
    int playersToFind,
    double feePerPlayer,
    SportCategory sportCategory,
  ) async {
    if (AppConfig.isDebug) {
      List<int> freeFieldIds =
          await DB.Bookings.getFreeFieldIds(startTime, finishTime, [fieldId]);

      if (!freeFieldIds.contains(fieldId)) {
        return -1; // Il campo non è libero in quel periodo
      }

      final Field? field = await DB.Fields.getById(fieldId);
      if (field == null) {
        return -1; // Campo non trovato
      }

      final double baseCost =
          field.hourlyCostPrivate *
          finishTime.difference(startTime).inHours;

      LobbyBooking newLobbyBooking = LobbyBooking(
        id: DB.Bookings.mockGetNextId(),
        ownerPlayerId: ownerPlayerId,
        fieldId: fieldId,
        startTime: startTime,
        finishTime: finishTime,
        maxPlayers: maxPlayers,
        playersToFind: playersToFind,
        feePerPlayer: (baseCost / maxPlayers * 100).ceil() / 100,
        status: BookingStatus.booked,
        sportCategory: sportCategory,
      );
      _mockData.add(newLobbyBooking);
      return newLobbyBooking.id;
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni private bookings per torneo
  Future<List<LobbyBooking>> getByFieldId(int fieldId) async {
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

  Future<List<int>> getFreeFieldIds(
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
          final Field? field = await DB.Fields.getById(booking.fieldId);
          if (field == null) {
            continue; // Campo non trovato, salta questa prenotazione
          }
          int bookingCityId = field.cityId;
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
            if (playersToPay != null && booking.playersToFind != playersToPay) {
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
              .playersToFind -=
          playersFound;
      if (_mockData
              .firstWhere((booking) => booking.id == lobbyBookingId)
              .playersToFind <=
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
              .playersToFind +=
          playersLeft;
      if (_mockData
              .firstWhere((booking) => booking.id == lobbyBookingId)
              .playersToFind >
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

  Future<int> getNumFinishedByownerPlayerIdAndFields(
    int playerId,
    List<int> fieldIds,
  ) async {
    if (AppConfig.isDebug) {
      List<Booking> bookings = mockData.where((booking) {
        return booking.status == BookingStatus.finished &&
            booking.ownerPlayerId == playerId &&
            fieldIds.contains(booking.fieldId);
      }).toList();
      return bookings.length;
    } else {
      throw UnimplementedError();
    }
  }
}
