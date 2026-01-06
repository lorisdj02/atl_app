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

/// Enum per la fase del torneo
enum TournamentPhase {
  group,
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
  final int cityId;
  final DateTime? startDate;
  final int sportId;
  final int numTeams;
  int paidTeams; // Numero team iscritti (deve essere <= numTeams)
  final int numGroups;
  final bool round2GroupStage;
  final bool round2FinalStage;
  final int qualified;
  final String description;
  final double payCoordinator;
  final bool isPublic;
  TournamentStatus status;
  final double fee;
  final double prize1;
  final double prize2;
  final bool isATL;
  TournamentPhase phase;
  final String? photoURL;

  bool? isFavorite;
  bool? isParticipating;

  Tournament({
    required this.id,
    required this.coordinatorId,
    required this.fieldId,
    required this.cityId,
    this.startDate,
    required this.sportId,
    required this.numTeams,
    required this.paidTeams,
    required this.numGroups,
    this.round2GroupStage = false,
    this.round2FinalStage = false,
    required this.qualified,
    required this.description,
    required this.payCoordinator,
    this.status = TournamentStatus.created,
    required this.fee,
    required this.prize1,
    this.prize2 = 0,
    this.isATL = false,
    this.phase = TournamentPhase.group,
    required this.name,
    this.photoURL,
    this.isFavorite = false,
    this.isParticipating = false,
    this.isPublic = true,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      coordinatorId: json['coordinator'] is int
          ? json['coordinator']
          : json['coordinator']['id'],
      fieldId: json['field'] is int ? json['field'] : json['field']['id'],
      cityId: json['city'] is int ? json['city'] : json['city']['id'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      sportId: json['sport_id'],
      numTeams: json['num_teams'] ?? 8,
      paidTeams: json['paid_teams'] ?? 0,
      numGroups: json['num_groups'] ?? 2,
      round2GroupStage: json['round2_group_stage'] ?? false,
      round2FinalStage: json['round2_final_stage'] ?? false,
      qualified: json['qualified'] ?? 4,
      description: json['description'] ?? '',
      payCoordinator: json['pay_coordinator'] ?? 0,
      status: _statusFromString(json['status'] ?? 'CREATED'),
      fee: double.parse(json['fee'].toString()),
      prize1: double.parse(json['prize1'].toString()),
      prize2: double.parse((json['prize2'] ?? 0).toString()),
      isATL: json['is_atl'] ?? false,
      phase: _phaseFromString(json['phase'] ?? 'GROUP'),
      name: json['name'] ?? '',
      photoURL: json['photo_url'],
      isPublic: json['is'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coordinator': coordinatorId,
      'field': fieldId,
      'city': cityId,
      'start_date': startDate?.toIso8601String(),
      'sport_id': sportId,
      'num_teams': numTeams,
      'paid_teams': paidTeams,
      'num_groups': numGroups,
      'round2_group_stage': round2GroupStage,
      'round2_final_stage': round2FinalStage,
      'qualified': qualified,
      'description': description,
      'pay_coordinator': payCoordinator,
      'status': status.name.toUpperCase(),
      'fee': fee,
      'prize1': prize1,
      'prize2': prize2,
      'is_atl': isATL,
      'phase': phase.name.toUpperCase(),
      'name': name,
      'photo_url': photoURL,
      'isPublic': isPublic,
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

  Tournament copyWith({bool? isFavorite, bool? isParticipating}) {
    return Tournament(
      id: id,
      coordinatorId: coordinatorId,
      fieldId: fieldId,
      cityId: cityId,
      startDate: startDate,
      sportId: sportId,
      numTeams: numTeams,
      paidTeams: paidTeams,
      numGroups: numGroups,
      round2GroupStage: round2GroupStage,
      round2FinalStage: round2FinalStage,
      qualified: qualified,
      description: description,
      payCoordinator: payCoordinator,
      status: status,
      fee: fee,
      prize1: prize1,
      prize2: prize2,
      isATL: isATL,
      phase: phase,
      name: name,
      photoURL: photoURL,
      isFavorite: isFavorite ?? this.isFavorite,
      isParticipating: isParticipating ?? this.isParticipating,
    );
  }

  bool get isGroupStage {
    return phase == TournamentPhase.group;
  }

  bool get isFinalStage {
    return phase != TournamentPhase.group;
  }
}
