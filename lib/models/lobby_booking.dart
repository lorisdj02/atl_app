import 'booking.dart';
import 'enums/sport_category.dart';
import 'enums/booking_status.dart';
import 'enums/booking_type.dart';
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
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      ownerPlayerId: (json['ownerPlayerId'] as num).toDouble(),
      playersToFind: (json['playersToFind'] as num).toInt(),
      totalPlayers: (json['totalPlayers'] as num).toInt(),
      feePerPlayer: (json['feePerPlayer'] as num).toDouble(),
      fieldId: json['fieldId'] != null ? (json['fieldId'] as num).toDouble() : 0.0,
      startTime: DateTime.parse(json['startDateTime']),
      finishTime: DateTime.parse(json['finishDateTime']),
      status: BookingStatusExtension.fromJson(json['status']),
      bookingType: BookingTypeExtension.fromJson(json['bookingType']),
      sportCategory: SportCategoryExtension.fromJson(json['sportCategory']),
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
