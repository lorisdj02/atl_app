import 'package:atl_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum CheckoutType {
  tournamentFee,
  lobbyBookingCreate,
  lobbyBookingParticipate,
  shop,
  privateBooking;

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case CheckoutType.tournamentFee:
        return l10n.purchaseTypeTournamentFee;
      case CheckoutType.lobbyBookingCreate:
        return l10n.purchaseTypeLobbyBookingCreate;
      case CheckoutType.lobbyBookingParticipate:
        return l10n.purchaseTypeLobbyBookingParticipate;
      case CheckoutType.shop:
        return l10n.purchaseTypeShop;
      case CheckoutType.privateBooking:
        return l10n.purchaseTypePrivateBooking;
    }
  }

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