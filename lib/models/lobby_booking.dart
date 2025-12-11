import 'sport_category.dart';
import 'booking_status.dart';
/// Modello PrivateBooking dal database


class LobbyBooking {
  final int id;
  final int fieldId;
  final int ownerId;
  final DateTime startTime;
  final DateTime finishTime;
  BookingStatus status;
  int playerToFind;
  final int maxPlayers;
  final int feePerPlayer;

  LobbyBooking({
    required this.id,
    required this.fieldId,
    required this.ownerId,
    required DateTime startTime,
    required DateTime finishTime,
    this.status = BookingStatus.booked,
    required this.playerToFind,
    required this.maxPlayers,
    required this.feePerPlayer,
  })  : startTime = startTime.toUtc(),
        finishTime = finishTime.toUtc();

  factory LobbyBooking.fromJson(Map<String, dynamic> json) {
    return LobbyBooking(
      id: json['id'],
      fieldId: json['field_id'],
      ownerId: json['owner_id'],
      startTime: DateTime.parse(json['start_time']),
      finishTime: DateTime.parse(json['finish_time']),
      status: BookingStatus.values.firstWhere((e) => e.toString() == 'BookingStatus.' + json['status']),
      playerToFind: json['player_to_find'],
      maxPlayers: json['max_players'],
      feePerPlayer: json['fee_per_player'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_id': fieldId,
      'owner_id': ownerId,
      'start_time': startTime.toIso8601String(),
      'finish_time': finishTime.toIso8601String(),
      'status': status.toString().split('.').last,
      'player_to_find': playerToFind,
      'max_players': maxPlayers,
      'fee_per_player': feePerPlayer,
    };
  }
}