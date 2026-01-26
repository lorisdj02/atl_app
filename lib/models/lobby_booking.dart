import 'booking.dart';

/// Modello PrivateBooking dal database

class LobbyBooking extends Booking {
  final int ownerId;
  int
  playersToFind; //numero di giocatori da trovare -> questo man mano che si iscrivono diminuisce. L'owner paga maxPlayers - playerToFind fees
  final int maxPlayers; //numero di giocatori totali -> prezzo per giocatore
  final double feePerPlayer;

  LobbyBooking({
    required super.id,
    required super.fieldId,
    required this.ownerId,
    required DateTime startTime,
    required DateTime finishTime,
    super.status = BookingStatus.booked,
    required this.playersToFind,
    required this.maxPlayers,
    required this.feePerPlayer,
  }) : super(startTime: startTime, finishTime: finishTime, type: BookingType.lobby);

  factory LobbyBooking.fromJson(Map<String, dynamic> json) {
    return LobbyBooking(
      id: json['id'],
      fieldId: json['field_id'],
      ownerId: json['owner_id'],
      startTime: DateTime.parse(json['start_time']),
      finishTime: DateTime.parse(json['finish_time']),
      status: BookingStatusExtension.fromString(json['status']),
      playersToFind: json['players_to_find'],
      maxPlayers: json['max_players'],
      feePerPlayer: json['fee_per_player'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'owner_id': ownerId,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime.toIso8601String(),
      'status': status.toShortString(),
      'players_to_find': playersToFind,
      'max_players': maxPlayers,
      'fee_per_player': feePerPlayer,
    };
  }
}
