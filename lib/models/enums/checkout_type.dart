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

extension CheckoutTypeExtension on CheckoutType {
  static CheckoutType fromJson(String json) {
    final normalized = json.toUpperCase();
    return CheckoutType.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown checkout type: $json'),
    );
  }
}