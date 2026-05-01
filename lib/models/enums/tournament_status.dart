import 'package:atl_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum TournamentStatus {
  created,
  scheduled,
  finished,
  pendingPayments,
  canceled;

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case TournamentStatus.created:
        return l10n.statusCreated;
      case TournamentStatus.scheduled:
        return l10n.statusScheduled;
      case TournamentStatus.finished:
        return l10n.statusFinished;
      case TournamentStatus.canceled:
        return l10n.statusCanceled;
      case TournamentStatus.pendingPayments:
        return l10n.statusPendingPayments;
    }
  }

  String get apiName {
    switch (this) {
      case TournamentStatus.created:
        return 'CREATED';
      case TournamentStatus.scheduled:
        return 'SCHEDULED';
      case TournamentStatus.finished:
        return 'FINISHED';
      case TournamentStatus.canceled:
        return 'CANCELED';
      case TournamentStatus.pendingPayments:
        return 'PENDING_PAYMENTS';
    }
  }
}

extension TournamentStatusExtension on TournamentStatus {
  static TournamentStatus fromJson(String json) {
    final normalized = json.toUpperCase();
    return TournamentStatus.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown tournament status: $json'),
    );
  }
}