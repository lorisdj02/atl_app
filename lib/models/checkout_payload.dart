import 'package:atl_app/models/enums/sport_category.dart';
import 'enums/checkout_type.dart';

// OK
class CheckoutPayload {
  final double? tournamentId;
  final double? lobbyId;
  final int? playersPaid;

  final double? ownerPlayerId;
  final DateTime? startTime;
  final DateTime? finishTime;
  final int? totalPlayers;
  final int? playersToFind;

  final double? fieldId;

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
      tournamentId: (json['tournamentId'] as num?)?.toDouble(),
      lobbyId: (json['lobbyId'] as num?)?.toDouble(),
      playersPaid: (json['playersPaid'] as num?)?.toInt(),
      ownerPlayerId: (json['ownerPlayerId'] as num?)?.toDouble(),
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : null,
      finishTime: json['finishTime'] != null
          ? DateTime.parse(json['finishTime'])
          : null,
      totalPlayers: (json['totalPlayers'] as num?)?.toInt(),
      playersToFind: (json['playersToFind'] as num?)?.toInt(),
      fieldId: (json['fieldId'] as num?)?.toDouble(),
      sportCategory: json['sportCategory'] != null
          ? SportCategory.values.firstWhere(
              (e) => e.apiName == json['sportCategory'],
              orElse: () =>
                  SportCategory.football, // Valore di default se non trovato
            )
          : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] != null
          ? CheckoutTypeExtension.fromJson(json['type'])
          : CheckoutType.shop, // Valore di default
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
      'sportCategory': sportCategory?.apiName,
      'amount': amount,
      'type': type.apiName,
    };
  }
}
