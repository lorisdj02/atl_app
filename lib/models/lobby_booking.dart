import 'booking.dart';
import 'sport_category.dart';
/// Modello PrivateBooking dal database

class LobbyBooking extends Booking {
  final int ownerPlayerId;
  int
  playersToFind; //numero di giocatori da trovare -> questo man mano che si iscrivono diminuisce. L'owner paga maxPlayers - playerToFind fees
  final int maxPlayers; //numero di giocatori totali -> prezzo per giocatore
  final double feePerPlayer;

  LobbyBooking({
    required super.id,
    required super.fieldId,
    required this.ownerPlayerId,
    required DateTime startTime,
    required DateTime finishTime,
    super.status = BookingStatus.booked,
    required this.playersToFind,
    required this.maxPlayers,
    required this.feePerPlayer,
    super.sportCategory = SportCategory.football,
  }) : super(startTime: startTime, finishTime: finishTime, type: BookingType.lobby);

  factory LobbyBooking.fromJson(Map<String, dynamic> json) {
    return LobbyBooking(
      id: json['id'],
      fieldId: json['fieldId'],
      ownerPlayerId: json['ownerPlayerId'],
      startTime: DateTime.parse(json['startTime']),
      finishTime: DateTime.parse(json['finishTime']),
      status: BookingStatusExtension.fromString(json['status']),
      playersToFind: json['playersToFind'],
      maxPlayers: json['maxPlayers'],
      feePerPlayer: json['feePerPlayer'],
      sportCategory: SportCategoryExtension.fromJson(json['sportCategory']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldId': fieldId,
      'ownerPlayerId': ownerPlayerId,
      'startTime': startTime.toIso8601String(),
      'finishTime': finishTime.toIso8601String(),
      'status': status.toShortString(),
      'playersToFind': playersToFind,
      'maxPlayers': maxPlayers,
      'feePerPlayer': feePerPlayer,
      'sportCategory': sportCategory.toString(),
    };
  }
}
