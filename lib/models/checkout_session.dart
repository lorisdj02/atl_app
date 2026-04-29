import 'package:atl_app/models/checkout_payload.dart';

enum CheckoutSessionStatus {
  pending,
  completed,
  expired,
  failed;

  String get apiName {
    switch (this) {
      case CheckoutSessionStatus.pending:
        return 'PENDING';
      case CheckoutSessionStatus.completed:
        return 'COMPLETED';
      case CheckoutSessionStatus.expired:
        return 'EXPIRED';
      case CheckoutSessionStatus.failed:
        return 'FAILED';
    }
  }
}

enum CheckoutType {
  tournamentFee,
  lobbyBookingCreate,
  lobbyBookingParticipate,
  shop,
  privateBooking;

  String get apiName{
    switch (this) {
      case CheckoutType.tournamentFee:
        return 'TOURNAMENT_FEE';
      case CheckoutType.lobbyBookingCreate:
        return 'LOBBY_BOOKING_CREATE';
      case CheckoutType.lobbyBookingParticipate:
        return 'LOBBY_BOOKING_PARTICIPATE';
      case CheckoutType.privateBooking:
        return 'PRIVATE_BOOKING';
      case CheckoutType.shop:
        return 'SHOP';
    }
  }
}

// OK
class CheckoutSession {
  final double id;
  final double accountId;
  final CheckoutPayload payload;
  final CheckoutType type;
  final double amount;

  CheckoutSession({
    required this.id,
    required this.accountId,
    required this.payload,
    required this.type,
    required this.amount,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      id: json['id'],
      accountId: json['accountId'],
      type: CheckoutType.values.firstWhere(
        (e) => e.apiName == json['type'],
        orElse: () => CheckoutType.tournamentFee, // Valore di default
      ),
      payload: CheckoutPayload.fromJson(json['payload']),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type.apiName,
      'payload': payload.toJson(),
      'amount': amount,
    };
  }
}