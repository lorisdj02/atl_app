import 'package:atl_app/config/app_config.dart';
import 'base_repository.dart';
import '../../models/private_booking.dart';
import '../db_controller.dart';
import '../../models/booking.dart';

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

  Future<bool> addPrivateBooking(
    int playerId,
    int fieldId,
    double cost,
    DateTime startTime,
    DateTime finishTime,
  ) async {
    if (AppConfig.isDebug) {
      List<int> freeFieldIds =
          await DB.Bookings.getFreeFieldIds(startTime, finishTime, [fieldId]) ??
          [];

      if (!freeFieldIds.contains(fieldId)) {
        return false; // Il campo non è libero in quel periodo
      }

      final double baseCost =
          (await DB.Fields.getById(fieldId)).hourlyCostPrivate *
          finishTime.difference(startTime).inHours;

      final PrivateBooking newBooking = PrivateBooking(
        id: DB.Bookings.mockGetNextId(),
        playerId: playerId,
        fieldId: fieldId,
        startTime: startTime,
        finishTime: finishTime,
        cost: baseCost,
        status: BookingStatus.booked,
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

  Future<bool> deletePrivateBooking(int privateBookingId, int playerId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere(
        (booking) =>
            booking.id == privateBookingId && booking.playerId == playerId,
      );
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
