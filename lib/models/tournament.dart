import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:flutter/material.dart';
import 'package:atl_app/l10n/app_localizations.dart';

/// Enum per lo stato del torneo
enum TournamentStatus {
  created,
  scheduled,
  finished,
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
    }
  }
}

enum TournamentFormat {
  // 1. Solo partite secche
  singleMatchOnly,
  
  // 2. Andata e ritorno solo nei gironi
  homeAndAwayGroupStage, 
  
  // 3. Andata e ritorno solo nelle fasi finali
  homeAndAwayKnockoutStage, 
  
  // 4. Andata e ritorno totale
  fullHomeAndAway,
}

// Estensione per aggiungere funzionalità all'enum
extension TournamentFormatExtension on TournamentFormat {
  String displayName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case TournamentFormat.singleMatchOnly:
        return l10n.formatSingleMatchOnly;
      case TournamentFormat.homeAndAwayGroupStage:
        return l10n.formatHomeAndAwayGroupStage;
      case TournamentFormat.homeAndAwayKnockoutStage:
        return l10n.formatHomeAndAwayKnockoutStage;
      case TournamentFormat.fullHomeAndAway:
        return l10n.formatFullHomeAndAway;
    }
  }
}


/// Enum per la fase del torneo
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
}

/// Modello Tournament dal database
class Tournament {
  final int id;
  final String name;
  final int coordinatorId;
  final int fieldId;
  final String city;
  final DateTime? startDate;
  final String sportName;
  final int numTeams;
  final int paidTeams; // Numero team iscritti (deve essere <= numTeams)
  final int numGroups;
  final int round2;
  final int qualified;
  final String description;
  final int payCoordinator;
  final TournamentStatus status;
  final double fee;
  final double prize1;
  final double prize2;
  final bool atlEvent;
  final TournamentPhase phase;
  final String? photoURL;
  bool? isFavorite;
  bool? isParticipating;

  Tournament({
    required this.id,
    required this.coordinatorId,
    required this.fieldId,
    required this.city,
    this.startDate,
    required this.sportName,
    required this.numTeams,
    required this.paidTeams,
    required this.numGroups,
    required this.round2,
    required this.qualified,
    required this.description,
    required this.payCoordinator,
    this.status = TournamentStatus.created,
    required this.fee,
    required this.prize1,
    this.prize2 = 0,
    this.atlEvent = false,
    this.phase = TournamentPhase.group,
    required this.name,
    this.photoURL,
    this.isFavorite = false,
    this.isParticipating = false,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      coordinatorId: json['coordinator'] is int 
          ? json['coordinator'] 
          : json['coordinator']['id'],
      fieldId: json['field'] is int 
          ? json['field'] 
          : json['field']['id'],
      city: json['city'] ?? '',
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      sportName: json['sport_name'] ?? '',
      numTeams: json['num_teams'] ?? 8,
      paidTeams: json['paid_teams'] ?? 0,
      numGroups: json['num_groups'] ?? 2,
      round2: json['round2'] ?? 0,
      qualified: json['qualified'] ?? 4,
      description: json['description'] ?? '',
      payCoordinator: json['pay_coordinator'] ?? 0,
      status: _statusFromString(json['status'] ?? 'CREATED'),
      fee: double.parse(json['fee'].toString()),
      prize1: double.parse(json['prize1'].toString()),
      prize2: double.parse((json['prize2'] ?? 0).toString()),
      atlEvent: json['atl_event'] ?? false,
      phase: _phaseFromString(json['phase'] ?? 'GROUP'),
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coordinator': coordinatorId,
      'field': fieldId,
      'city': city,
      'start_date': startDate?.toIso8601String(),
      'sport_name': sportName,
      'num_teams': numTeams,
      'paid_teams': paidTeams,
      'num_groups': numGroups,
      'round2': round2,
      'qualified': qualified,
      'description': description,
      'pay_coordinator': payCoordinator,
      'status': status.name.toUpperCase(),
      'fee': fee,
      'prize1': prize1,
      'prize2': prize2,
      'atl_event': atlEvent,
      'phase': phase.name.toUpperCase(),
      'name': name,
    };
  }

  /// Formatta la quota come stringa con valuta
  String get formattedFee => '€${fee.toStringAsFixed(2)}';

  /// Formatta il premio come stringa con valuta
  String get formattedPrize1 => '€${prize1.toStringAsFixed(2)}';
  String get formattedPrize2 => '€${prize2.toStringAsFixed(2)}';

  /// Verifica se il torneo è iniziato
  bool get hasStarted {
    if (startDate == null) return false;
    return DateTime.now().isAfter(startDate!);
  }

  /// Verifica se il torneo è completato
  bool get isCompleted => status == TournamentStatus.finished;

  /// Verifica se il torneo è cancellato
  bool get isCanceled => status == TournamentStatus.canceled;

  /// Verifica se il torneo è pieno
  bool get isFull => paidTeams >= numTeams;

  static TournamentStatus _statusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'CREATED':
        return TournamentStatus.created;
      case 'SCHEDULED':
        return TournamentStatus.scheduled;
      case 'FINISHED':
        return TournamentStatus.finished;
      case 'CANCELED':
        return TournamentStatus.canceled;
      default:
        throw Exception('Unknown tournament status: $status');
    }
  }

  static TournamentPhase _phaseFromString(String phase) {
    switch (phase.toUpperCase()) {
      case 'GROUP':
        return TournamentPhase.group;
      case 'RO32':
        return TournamentPhase.ro32;
      case 'RO16':
        return TournamentPhase.ro16;
      case 'RO8':
        return TournamentPhase.ro8;
      case 'QUARTER':
        return TournamentPhase.quarter;
      case 'SEMI':
        return TournamentPhase.semi;
      case 'FINAL':
        return TournamentPhase.final_;
      default:
        throw Exception('Unknown tournament phase: $phase');
    }
  }
}
