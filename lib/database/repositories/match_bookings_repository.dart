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

  List<MatchBooking> _mockData = [
    MatchBooking(
      id: 1,
      coordinatorId: 1,
      matchId: 1,
      fieldId: 1,
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      finishTime: DateTime.now().add(const Duration(hours: 2)),
      status: BookingStatus.inProgress,
    )
  ];

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

  Future<MatchBooking?> getById(int id) async {
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

  Future<bool> startMatch(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final booking =
            _mockData.firstWhere((booking) => booking.matchId == matchId);
        booking.status = BookingStatus.inProgress;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> finishMatch(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final booking =
            _mockData.firstWhere((booking) => booking.matchId == matchId);
        booking.status = BookingStatus.finished;
        return true;
      } catch (e) {
        return false;
      }
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
  Future<List<MatchBooking>> getByFieldId(int fieldId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((booking) => booking.fieldId == fieldId).toList();
    } else {
      throw UnimplementedError();
    }
  }
}
