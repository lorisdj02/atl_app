import 'package:atl_app/config/app_config.dart';
import 'base_repository.dart';
import '../../models/lobby_booking.dart';
import '../db_controller.dart';
import '../../models/booking_status.dart';

/// Repository per gestire le PrivateBooking nel database

class LobbyBookingsRepository extends BaseRepository<LobbyBooking> {
  @override
  String get endpoint => 'lobby_bookings';

  @override
  LobbyBooking fromJson(Map<String, dynamic> json) => LobbyBooking.fromJson(json);

  @override
  Map<String, dynamic> toJson(LobbyBooking item) => item.toJson();

  List<LobbyBooking> _mockData = [
  ];

  @override
  List<LobbyBooking> get mockData => _mockData;

  /// Ottieni private bookings per player
  Future<List<LobbyBooking>?> getByPlayerId(int playerId) async {
    if(AppConfig.isDebug) {
      return _mockData.where((booking) => booking.ownerId == playerId).toList();
    }
    else {
      throw UnimplementedError();
    }
  }

  /// Ottieni private bookings per torneo
  Future<List<LobbyBooking>?> getByFieldId(int fieldId) async {
    if(AppConfig.isDebug) {
      return _mockData.where((booking) => booking.fieldId == fieldId).toList();
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<bool> isFieldBooked(int fieldId, DateTime startTime, DateTime finishTime) async {
    if(AppConfig.isDebug) {
      for(var booking in _mockData) {
        if(booking.fieldId == fieldId) {
          // Controlla se gli orari si sovrappongono
          if(!(finishTime.isBefore(booking.startTime) || startTime.isAfter(booking.finishTime))) {
            return true;
          }
        }
      }
      return false;
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<List<LobbyBooking>?> getByStatus(BookingStatus status) async {
    if(AppConfig.isDebug) {
      return _mockData.where((booking) => booking.status == status).toList();
    }
    else {
      throw UnimplementedError();
    }
  }


  bool _isOverlapping(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    // Due intervalli si sovrappongono se:
    // start1 < end2 AND start2 < end1
    // Questo copre tutti i casi di sovrapposizione possibili
    return start1.isBefore(end2) && start2.isBefore(end1);
  }

  Future<List<int>?> getFreeFieldIds(DateTime startTime, DateTime finishTime, List<int> allFieldIds) async {
    if(AppConfig.isDebug) {
      List<int> bookedFieldIds = [];
      List<LobbyBooking> bookings = await getByStatus(BookingStatus.booked) ?? [];
      List<LobbyBooking> inProgressBookings = await getByStatus(BookingStatus.inProgress) ?? [];
      List<LobbyBooking> allBookings = [];

      allBookings.addAll(bookings);
      allBookings.addAll(inProgressBookings);

      for(var booking in allBookings) {
        // Controlla se gli orari si sovrappongono
        if(_isOverlapping(startTime, finishTime, booking.startTime, booking.finishTime) && !bookedFieldIds.contains(booking.fieldId)) {
          bookedFieldIds.add(booking.fieldId);
        }
      }
      List<int> freePrivateBookingsFieldIds = (await DB.PrivateBookings.getFreeFieldIds(startTime, finishTime, allFieldIds)) ?? [];

      return allFieldIds.where((id) => !bookedFieldIds.contains(id)).toList()..addAll(freePrivateBookingsFieldIds);
    }
    else {
      throw UnimplementedError();
    }
  }
}