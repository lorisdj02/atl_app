import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/sport_category.dart';

class CheckoutPayload {
  final int? tournamentId;
  final int? lobbyId;
  final int? playersPaid;

  final int? ownerPlayerId;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int? totalPlayers;
  final int? playersToFind;

  final int? fieldId;

  final SportCategory? sportCategory;

  final double amount;
  final CheckoutType type;

  CheckoutPayload({
    this.tournamentId,
    this.lobbyId,
    this.playersPaid,
    this.ownerPlayerId,
    this.startTime,
    this.finishTime,
    this.totalPlayers,
    this.playersToFind,
    this.fieldId,
    this.sportCategory,
    required this.amount,
    required this.type,
  });

  factory CheckoutPayload.fromJson(Map<String, dynamic> json) {
    return CheckoutPayload(
      tournamentId: json['tournamentId'],
      lobbyId: json['lobbyId'],
      playersPaid: json['playersPaid'],
      ownerPlayerId: json['ownerPlayerId'],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      finishTime: json['finishTime'] != null
          ? DateTime.parse(json['finishTime'])
          : null,
      totalPlayers: json['totalPlayers'],
      playersToFind: json['playersToFind'],
      fieldId: json['fieldId'],
      sportCategory: json['sportCategory'] != null
          ? SportCategory.values.byName(json['sportCategory'])
          : null,
      amount: json['amount']?.toDouble() ?? 0.0,
      type: json['type'] != null
          ? CheckoutType.values.byName(json['type'])
          : CheckoutType.tournamentFee, // Valore di default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tournamentId': tournamentId,
      'lobbyId': lobbyId,
      'playersPaid': playersPaid,
      'ownerPlayerId': ownerPlayerId,
      'startTime': startTime?.toIso8601String(),
      'finishTime': finishTime?.toIso8601String(),
      'totalPlayers': totalPlayers,
      'playersToFind': playersToFind,
      'fieldId': fieldId,
      'sportCategory': sportCategory?.name,
      'amount': amount,
      'type': type.name,
    };
  }
}
