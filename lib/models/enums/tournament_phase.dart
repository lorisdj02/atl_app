import 'package:atl_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum TournamentPhase {
  group,
  ro32,
  ro16,
  ro8,
  quarter,
  semi,
  final_;

  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case TournamentPhase.group:
        return l10n.phaseGroupStage;
      case TournamentPhase.ro32:
        return l10n.phaseRoundOf32;
      case TournamentPhase.ro16:
        return l10n.phaseRoundOf16;
      case TournamentPhase.ro8:
        return l10n.phaseRoundOf8;
      case TournamentPhase.quarter:
        return l10n.phaseQuarterFinals;
      case TournamentPhase.semi:
        return l10n.phaseSemiFinals;
      case TournamentPhase.final_:
        return l10n.phaseFinal;
    }
  }

  String get apiName {
    switch (this) {
      case TournamentPhase.group:
        return 'GROUP';
      case TournamentPhase.ro32:
        return 'RO32';
      case TournamentPhase.ro16:
        return 'RO16';
      case TournamentPhase.ro8:
        return 'RO8';
      case TournamentPhase.quarter:
        return 'QUARTER';
      case TournamentPhase.semi:
        return 'SEMI';
      case TournamentPhase.final_:
        return 'FINAL';
    }
  }
}

extension TournamentPhaseExtension on TournamentPhase {
  static TournamentPhase fromJson(String json) {
    final normalized = json.toUpperCase();
    return TournamentPhase.values.firstWhere(
      (e) => e.apiName == normalized,
      orElse: () => throw ArgumentError('Unknown tournament phase: $json'),
    );
  }
}