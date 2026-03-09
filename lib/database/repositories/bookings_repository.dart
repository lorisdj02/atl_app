import '../../models/booking.dart';
import '../../models/lobby_booking.dart';
import '../../models/private_booking.dart';
import '../db_controller.dart';
import '../../models/match_booking.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

class BookingsRepository extends BaseRepository<Booking> {
  @override
  String get endpoint => 'bookings';

  @override
  List<Booking> get mockData => [
    ...DB.MatchBookings.mockData,
    ...DB.PrivateBookings.mockData,
    ...DB.LobbyBookings.mockData,
  ];

  @override
  Booking fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'match':
        return MatchBooking.fromJson(json);
      case 'private':
        return PrivateBooking.fromJson(json);
      case 'lobby':
        return LobbyBooking.fromJson(json);
      default:
        throw UnimplementedError('Unknown booking type: ${json['type']}');
    }
  }

  @override
  Map<String, dynamic> toJson(Booking item) {
    return item.toJson();
  }

  bool isTimeOverlapping(
    DateTime start1,
    DateTime end1,
    DateTime start2,
    DateTime end2,
  ) {
    // Due intervalli si sovrappongono se:
    // start1 < end2 AND start2 < end1
    // Questo copre tutti i casi di sovrapposizione possibili
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  Future<List<Booking>?> getByStatus(BookingStatus status) async {
    if (AppConfig.isDebug) {
      return mockData.where((booking) => booking.status == status).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<int>> getFreeFieldIds(
    DateTime startTime,
    DateTime finishTime,
    List<int> allFieldIds, {
    bool checkLobby = true,
  }) async {
    if (AppConfig.isDebug) {
      List<int> bookedFieldIds = [];
      List<Booking> bookings = await getByStatus(BookingStatus.booked) ?? [];
      List<Booking> inProgressBookings =
          await getByStatus(BookingStatus.inProgress) ?? [];
      List<Booking> allBookings = [];
      allBookings.addAll(bookings);
      allBookings.addAll(inProgressBookings);

      for (var booking in allBookings) {
        // Controlla se gli orari si sovrappongono
        if (isTimeOverlapping(
              startTime,
              finishTime,
              booking.startTime,
              booking.finishTime,
            ) &&
            !bookedFieldIds.contains(booking.fieldId)) {
          bookedFieldIds.add(booking.fieldId);
        }
      }

      return allFieldIds.where((id) => !bookedFieldIds.contains(id)).toList();
    } else {
      throw UnimplementedError();
    }
  }

  int mockGetNextId() {
    if (AppConfig.isDebug) {
      int maxIndex = 0;
      for (var booking in mockData) {
        if (booking.id > maxIndex) {
          maxIndex = booking.id;
        }
      }
      return maxIndex + 1;
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Booking>> getByFieldId(int fieldId) async {
    if (AppConfig.isDebug) {
      return mockData.where((booking) => booking.fieldId == fieldId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isFieldFree(
    int fieldId,
    DateTime startTime,
    DateTime finishTime,
  ) async {
    if (AppConfig.isDebug) {
      List<Booking> bookings = await getByFieldId(fieldId);
      for (var booking in bookings) {
        if (isTimeOverlapping(
          startTime,
          finishTime,
          booking.startTime,
          booking.finishTime,
        )) {
          return false;
        }
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }


}
