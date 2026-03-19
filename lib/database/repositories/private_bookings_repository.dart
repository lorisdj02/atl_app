import 'package:atl_app/config/app_config.dart';
import 'package:atl_app/models/sport_category.dart';
import 'base_repository.dart';
import '../../models/private_booking.dart';
import '../db_controller.dart';
import '../../models/booking.dart';
import '../../models/field.dart';

/// Repository per gestire le PrivateBooking nel database

class PrivateBookingsRepository extends BaseRepository<PrivateBooking> {
  @override
  String get endpoint => 'private_bookings';

  @override
  PrivateBooking fromJson(Map<String, dynamic> json) =>
      PrivateBooking.fromJson(json);

  @override
  Map<String, dynamic> toJson(PrivateBooking item) => item.toJson();

  List<PrivateBooking> _mockData = [];

  @override
  List<PrivateBooking> get mockData => _mockData;

  /// Ottieni private bookings per player
  Future<List<PrivateBooking>> getByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where((booking) => booking.playerId == playerId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<PrivateBooking>> getActiveByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where(
            (booking) =>
                booking.playerId == playerId &&
                booking.status != BookingStatus.refund &&
                booking.status != BookingStatus.finished,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addPrivateBooking(
    int playerId,
    int fieldId,
    DateTime startTime,
    DateTime finishTime,
    SportCategory sportCategory,
  ) async {
    if (AppConfig.isDebug) {
      List<int> freeFieldIds = await DB.Bookings.getFreeFieldIds(
        startTime,
        finishTime,
        [fieldId],
      );

      if (!freeFieldIds.contains(fieldId)) {
        return false; // Il campo non è libero in quel periodo
      }

      final Field? field = await DB.Fields.getById(fieldId);
      if (field == null) {
        return false; // Campo non trovato
      }
      final double baseCost =
          field.hourlyCostPrivate * finishTime.difference(startTime).inHours;

      final PrivateBooking newBooking = PrivateBooking(
        id: DB.Bookings.mockGetNextId(),
        playerId: playerId,
        fieldId: fieldId,
        startTime: startTime,
        finishTime: finishTime,
        cost: baseCost,
        status: BookingStatus.booked,
        sportCategory: sportCategory,
      );
      _mockData.add(newBooking);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni private bookings per torneo
  Future<List<PrivateBooking>> getByFieldId(int fieldId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((booking) => booking.fieldId == fieldId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<PrivateBooking?> getById(int bookingId) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere((booking) => booking.id == bookingId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<PrivateBooking>> getByStatus(BookingStatus status) async {
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

  Future<bool> deletePrivateBooking(int privateBookingId) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere(
        (booking) => booking.id == privateBookingId,
      );
      if (index == -1) {
        return false; // Prenotazione non trovata
      }
      _mockData[index].status = BookingStatus.refund;
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getNumFinishedByPlayerIdAndFields(
    int playerId,
    List<int> fieldIds,
  ) async {
    if (AppConfig.isDebug) {
      List<Booking> bookings = mockData.where((booking) {
        return booking.status == BookingStatus.finished &&
            booking.playerId == playerId &&
            fieldIds.contains(booking.fieldId);
      }).toList();
      return bookings.length;
    } else {
      throw UnimplementedError();
    }
  }
}
