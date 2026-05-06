import 'package:atl_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TransactionStatus {
  pending,
  confirmed,
  failed,
  partialRefund,
  refunded;

  String get apiName {
    switch (this) {
      case TransactionStatus.pending:
        return 'PENDING';
      case TransactionStatus.confirmed:
        return 'CONFIRMED';
      case TransactionStatus.failed:
        return 'FAILED';
      case TransactionStatus.partialRefund:
        return 'PARTIAL_REFUND';
      case TransactionStatus.refunded:
        return 'REFUNDED';
    }
  }

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (this) {
      case TransactionStatus.confirmed:
        return l10n.transactionStatusConfirmed;
      case TransactionStatus.refunded:
        return l10n.transactionStatusRefunded;
      case TransactionStatus.pending:
      case TransactionStatus.failed:
      case TransactionStatus.partialRefund:
        return _formatEnumLabel(toShortString());
    }
  }

  static String _formatEnumLabel(String raw) {
    if (raw.isEmpty) return raw;

    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final char = raw[i];
      final isUpper = char.toUpperCase() == char && char.toLowerCase() != char;
      if (i > 0 && isUpper) {
        buffer.write(' ');
      }
      buffer.write(char);
    }
    final formatted = buffer.toString().replaceAll('_', ' ').toLowerCase();
    return formatted.isEmpty
        ? formatted
        : formatted[0].toUpperCase() + formatted.substring(1);
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static TransactionStatus fromString(String status) {
    return TransactionStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => throw ArgumentError('Unknown transaction status: $status'),
    );
  }

  static TransactionStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return TransactionStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown transaction status: $json'),
    );
  }

  Map<String, dynamic> toJson() {
    return {'transactionStatus': toShortString()};
  }
}
