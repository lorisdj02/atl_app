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

  Future<bool> removeLobbyBooking(int lobbyBookingId) async {
    if(AppConfig.isDebug) {
      _mockData.removeWhere((booking) => booking.id == lobbyBookingId);
      return true;
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<int> addLobbyBooking(int ownerId, int fieldId, DateTime startTime, DateTime finishTime, int maxPlayers, int playerToFind, double feePerPlayer) async {

    if(AppConfig.isDebug) {
      LobbyBooking newLobbyBooking = LobbyBooking(
      id: _mockData.length + 1,
      ownerId: ownerId,
      fieldId: fieldId,
      startTime: startTime,
      finishTime: finishTime,
      maxPlayers: maxPlayers,
      playerToFind: playerToFind,
      feePerPlayer: feePerPlayer,
      status: BookingStatus.booked,
    );
      _mockData.add(newLobbyBooking);
      return newLobbyBooking.id;
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

//TODO: devi controllare la data
  bool _isOverlapping(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    // Due intervalli si sovrappongono se:
    // start1 < end2 AND start2 < end1
    // Questo copre tutti i casi di sovrapposizione possibili
    return start1.isBefore(end2) && start2.isBefore(end1) ;
  }

  Future<List<int>?> getFreeFieldIds(DateTime startTime, DateTime finishTime, List<int> allFieldIds, {bool checkPrivate = true}) async {
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
      
      if(!checkPrivate) {
        return allFieldIds.where((id) => !bookedFieldIds.contains(id)).toList();
      }
      List<int> freePrivateBookingsFieldIds = (await DB.PrivateBookings.getFreeFieldIds(startTime, finishTime, allFieldIds, checkLobby: false)) ?? [];
      List<int> freeLobbyFieldIds = allFieldIds.where((id) => !bookedFieldIds.contains(id)).toList();
      // Restituisci solo i campi liberi in ENTRAMBI
      return freeLobbyFieldIds.where((id) => freePrivateBookingsFieldIds.contains(id)).toList();
    }
    else {
      throw UnimplementedError();
    }
  }


  Future<List<LobbyBooking>> getBookedLobbyBookings(int? totalPlayers, String? city, DateTime? startTime, DateTime? endTime, int? playersToPay) async {
    if(AppConfig.isDebug) {
      if(totalPlayers == null && city == null && startTime == null && endTime == null) {
        return _mockData.where((booking) => booking.status == BookingStatus.booked).toList();
      }
      else {
        List<LobbyBooking> results = [];
        for(LobbyBooking booking in _mockData) {
          String bookingCity = (await DB.Fields.getById(booking.fieldId))!.city;
          if(booking.status == BookingStatus.booked) {
            if(totalPlayers != null && booking.maxPlayers < totalPlayers) {
              continue;
            }
            if(city != null && bookingCity != city) {
              continue;
            }
            if(startTime != null && startTime.isBefore(booking.startTime)) {
              continue;
            }
            if(endTime != null && endTime.isAfter(booking.finishTime)) {
              continue;
            }
            if(playersToPay != null && booking.playerToFind != playersToPay) {
              continue;
            }
            results.add(booking);
          }
        }
        return results;
      }
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateLobbyBookingStatus(int lobbyBookingId, BookingStatus status) async {
    if(AppConfig.isDebug) {
      _mockData.firstWhere((booking) => booking.id == lobbyBookingId).status = status;
      return true;
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<bool> decreasePlayersToFind(int lobbyBookingId, int playersFound) async {
    if(AppConfig.isDebug) {
      _mockData.firstWhere((booking) => booking.id == lobbyBookingId).playerToFind -= playersFound;
      if(_mockData.firstWhere((booking) => booking.id == lobbyBookingId).playerToFind <= 0) {
        updateLobbyBookingStatus(lobbyBookingId, BookingStatus.full);
      }
      return true;
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<bool> increasePlayersToFind(int lobbyBookingId, int playersLeft) async {
    if(AppConfig.isDebug) {
      _mockData.firstWhere((booking) => booking.id == lobbyBookingId).playerToFind += playersLeft;
      if(_mockData.firstWhere((booking) => booking.id == lobbyBookingId).playerToFind > 0) {
        updateLobbyBookingStatus(lobbyBookingId, BookingStatus.booked);
      }
      return true;
    }
    else {
      throw UnimplementedError();
    }
  }

  Future<int> getMaxParticipants(int lobbyBookingId) async {
    if(AppConfig.isDebug) {
      return _mockData.firstWhere((booking) => booking.id == lobbyBookingId).maxPlayers;
    }
    else {
      throw UnimplementedError();
    }
  } 
}