import 'package:atl_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum PurchaseStatus {
  confirmed,
  redeemed,
  refunded,
  partialRefund,
  canceled;

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case PurchaseStatus.confirmed:
        return l10n.purchaseStatusConfirmed;
      case PurchaseStatus.redeemed:
        return l10n.purchaseStatusRedeemed;
      case PurchaseStatus.refunded:
        return l10n.purchaseStatusRefunded;
      case PurchaseStatus.partialRefund:
        return l10n.purchaseStatusPartialRefund;
      case PurchaseStatus.canceled:
        return l10n.purchaseStatusCanceled;
    }
  }

  String get apiName {
    switch (this) {
      case PurchaseStatus.confirmed:
        return 'CONFIRMED';
      case PurchaseStatus.redeemed:
        return 'REDEEMED';
      case PurchaseStatus.refunded:
        return 'REFUNDED';
      case PurchaseStatus.partialRefund:
        return 'PARTIAL_REFUND';
      case PurchaseStatus.canceled:
        return 'CANCELED';
    }
  }
}

extension PurchaseStatusExtension on PurchaseStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static PurchaseStatus fromString(String status) {
    return PurchaseStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => throw ArgumentError('Unknown purchase status: $status'),
    );
  }

  static PurchaseStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return PurchaseStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown purchase status: $json'),
    );
  }
}
