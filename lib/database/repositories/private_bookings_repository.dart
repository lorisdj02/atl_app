import 'package:atl_app/config/app_config.dart';
import 'base_repository.dart';
import '../../models/private_bookings.dart';
import '../db_controller.dart';
import '../../models/booking_status.dart';

/// Repository per gestire le PrivateBooking nel database

class PrivateBookingsRepository extends BaseRepository<PrivateBooking> {
  @override
  String get endpoint => 'private_bookings';

  @override
  PrivateBooking fromJson(Map<String, dynamic> json) => PrivateBooking.fromJson(json);

  @override
  Map<String, dynamic> toJson(PrivateBooking item) => item.toJson();

  List<PrivateBooking> _mockData = [
  ];

  @override
  List<PrivateBooking> get mockData => _mockData;
  /// Ottieni private bookings per player
  Future<List<PrivateBooking>?> getByPlayerId(int playerId) async {
    if(AppConfig.isDebug) {
      return _mockData.where((booking) => booking.playerId == playerId).toList();
    }
    else {
      throw UnimplementedError();
    }
    
  }

  Future<bool> addPrivateBooking(int playerId, int fieldId, DateTime startTime, DateTime finishTime, BookingStatus status) async {
    if(AppConfig.isDebug) {
      final PrivateBooking newBooking = PrivateBooking(
        id: _mockData.length + 1,
        playerId: playerId,
        fieldId: fieldId,
        startTime: startTime,
        finishTime: finishTime,
        status: status,
      );
      _mockData.add(newBooking);
      return true;
    }
    else {
      throw UnimplementedError();
    }
  }

  /// Ottieni private bookings per torneo
  Future<List<PrivateBooking>?> getByFieldId(int fieldId) async {
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

  Future<List<PrivateBooking>?> getByStatus(BookingStatus status) async {
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

  Future<List<int>?> getFreeFieldIds(DateTime startTime, DateTime finishTime, List<int> allFieldIds, {bool checkLobby = true}) async {
    if(AppConfig.isDebug) {
      List<int> bookedFieldIds = [];
      List<PrivateBooking> bookings = await getByStatus(BookingStatus.booked) ?? [];
      List<PrivateBooking> inProgressBookings = await getByStatus(BookingStatus.inProgress) ?? [];
      List<PrivateBooking> allBookings = [];

      allBookings.addAll(bookings);
      allBookings.addAll(inProgressBookings);

      for(var booking in allBookings) {
        // Controlla se gli orari si sovrappongono
        if(_isOverlapping(startTime, finishTime, booking.startTime, booking.finishTime) && !bookedFieldIds.contains(booking.fieldId)) {
          bookedFieldIds.add(booking.fieldId);
        }
      }
      

      if(!checkLobby) {
        return allFieldIds.where((id) => !bookedFieldIds.contains(id)).toList();
      }
      else {
        List<int> freeLobbyBookingsFieldIds = (await DB.LobbyBookings.getFreeFieldIds(startTime, finishTime, allFieldIds, checkPrivate: false)) ?? [];
        return allFieldIds.where((id) => !bookedFieldIds.contains(id)).toList()..addAll(freeLobbyBookingsFieldIds);
      }
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<bool> deletePrivateBooking(int privateBookingId, int playerId) async {
    if(AppConfig.isDebug) {
      _mockData.removeWhere((booking) => booking.id == privateBookingId && booking.playerId == playerId);
      return true;
    }
    else {
      throw UnimplementedError();
    }
  }

  
}
