import 'booking.dart';
import 'sport_category.dart';

/// Modello LobbyBooking dal database
// OK
class LobbyBooking extends Booking {
  final double ownerPlayerId;
  final int playersToFind;
  final int totalPlayers;
  final double feePerPlayer;

  LobbyBooking({
    required super.id,
    required this.ownerPlayerId,
    required this.playersToFind,
    required this.totalPlayers,
    required this.feePerPlayer,
    required super.fieldId,
    required super.sportCategory,
    required super.startTime,
    required super.finishTime,
    required super.status,
    super.bookingType = BookingType.lobby,
  });

  factory LobbyBooking.fromJson(Map<String, dynamic> json) {
    return LobbyBooking(
      id: json['id'],
      ownerPlayerId: json['ownerPlayerId'],
      playersToFind: json['playersToFind'],
      totalPlayers: json['totalPlayers'],
      feePerPlayer: (json['feePerPlayer'] as num).toDouble(),
      fieldId: json['fieldId'],
      startTime: DateTime.parse(json['startDateTime']),
      finishTime: DateTime.parse(json['finishDateTime']),
      status: BookingStatus.values.firstWhere(
        (e) => e.apiName == json['status'],
        orElse: () => BookingStatus.booked,
      ),
      bookingType: BookingType.values.firstWhere(
        (e) => e.apiName == json['bookingType'],
        orElse: () => BookingType.lobby,
      ),
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.apiName == json['sportCategory'],
        orElse: () => SportCategory.football,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerPlayerId': ownerPlayerId,
      'playersToFind': playersToFind,
      'totalPlayers': totalPlayers,
      'feePerPlayer': feePerPlayer,
      'fieldId': fieldId,
      'startDateTime': startTime.toIso8601String(),
      'finishDateTime': finishTime.toIso8601String(),
      'status': status.apiName,
      'bookingType': bookingType.apiName,
      'sportCategory': sportCategory.apiName,
    };
  }
}
