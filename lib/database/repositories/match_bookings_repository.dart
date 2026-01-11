import 'base_repository.dart';
import '../../models/match_booking.dart';
import '../../config/app_config.dart';
import '../../models/booking.dart';
import '../db_controller.dart';

class MatchBookingsRepository extends BaseRepository<MatchBooking> {
  @override
  String get endpoint => 'match_bookings';

  @override
  MatchBooking fromJson(Map<String, dynamic> json) =>
      MatchBooking.fromJson(json);

  @override
  Map<String, dynamic> toJson(MatchBooking item) => item.toJson();

  List<MatchBooking> _mockData = [];

  @override
  List<MatchBooking> get mockData => _mockData;

  /// Ottieni match bookings per coordinatore
  Future<List<MatchBooking>?> getByCoordinatorId(int coordinatorId) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where((booking) => booking.coordinatorId == coordinatorId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<MatchBooking?> getByMatchId(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere((booking) => booking.matchId == matchId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteByMatchId(int matchId) async {
    if (AppConfig.isDebug) {
      if (_mockData.where((m) => matchId == m.matchId).isEmpty) {
        return false;
      }

      _mockData.removeWhere((booking) => booking.matchId == matchId);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addMatchBooking(
    int coordinatorId,
    int matchId,
    int fieldId,
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

      final MatchBooking newBooking = MatchBooking(
        id: DB.Bookings.mockGetNextId(),
        coordinatorId: coordinatorId,
        matchId: matchId,
        fieldId: fieldId,
        startTime: startTime,
        finishTime: finishTime,
        status: BookingStatus.booked,
      );
      _mockData.add(newBooking);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni match bookings per campo
  Future<List<MatchBooking>?> getByFieldId(int fieldId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((booking) => booking.fieldId == fieldId).toList();
    } else {
      throw UnimplementedError();
    }
  }
}
