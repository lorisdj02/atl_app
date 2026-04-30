import 'package:flutter/material.dart';
import 'package:atl_app/l10n/app_localizations.dart';

/// Enum per lo stato del torneo
/// OK
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

/// Modello Tournament dal database
class Tournament {
  final double id;
  final String name;
  final String description;
  final double coordinatorId;
  final double fieldId;
  final double cityId;
  final double sportId;
  bool isFavorite;
  bool isParticipating;
  final int numGroups;
  final int numTeams;
  final int paidTeams;
  final TournamentStatus status;
  final bool atlEvent;
  final double prize1;
  final double prize2;
  final DateTime? startDate;
  final double fee;
  final String? photoUrl;
  final bool round2GroupStage;
  final bool round2FinalStage;
  final int numTeamsQualified;
  final bool isPublic;
  final TournamentPhase phase;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinatorId,
    required this.fieldId,
    required this.cityId,
    required this.sportId,
    required this.isFavorite,
    required this.isParticipating,
    required this.numGroups,
    required this.numTeams,
    required this.paidTeams,
    required this.status,
    required this.atlEvent,
    required this.prize1,
    required this.prize2,
    required this.startDate,
    required this.fee,
    required this.photoUrl,
    required this.round2GroupStage,
    required this.round2FinalStage,
    required this.numTeamsQualified,
    required this.isPublic,
    required this.phase,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      coordinatorId: json['coordinatorId'],
      fieldId: json['fieldId'],
      cityId: json['cityId'],
      sportId: json['sportId'],
      isFavorite: json['isFavorite'] ?? false,
      isParticipating: json['isParticipating'] ?? false,
      numGroups: json['numGroups'],
      numTeams: json['numTeams'],
      paidTeams: json['paidTeams'],
      status: TournamentStatus.values.firstWhere(
        (e) => e.apiName == json['status'],
      ),
      atlEvent: json['atlEvent'],
      prize1: json['prize1'].toDouble(),
      prize2: json['prize2'].toDouble(),
      startDate: DateTime.tryParse(json['startDate'] ?? ''),
      fee: json['fee'].toDouble(),
      photoUrl: json['photoUrl'],
      round2GroupStage: json['round2GroupStage'] ?? false,
      round2FinalStage: json['round2FinalStage'] ?? false,
      numTeamsQualified: json['numTeamsQualified'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      phase: TournamentPhase.values.firstWhere(
        (e) => e.apiName == json['phase'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coordinatorId': coordinatorId,
      'fieldId': fieldId,
      'cityId': cityId,
      'sportId': sportId,
      'isFavorite': isFavorite,
      'isParticipating': isParticipating,
      'numGroups': numGroups,
      'numTeams': numTeams,
      'paidTeams': paidTeams,
      'status': status.apiName,
      'atlEvent': atlEvent,
      'prize1': prize1,
      'prize2': prize2,
      'startDate': startDate?.toIso8601String(),
      'fee': fee,
      'photoUrl': photoUrl,
      'round2GroupStage': round2GroupStage,
      'round2FinalStage': round2FinalStage,
      'numTeamsQualified': numTeamsQualified,
      'isPublic': isPublic,
      'phase': phase.apiName,
    };
  }

  bool get isGroupStage {
    return phase == TournamentPhase.group;
  }

  bool get isFinalStage {
    return phase != TournamentPhase.group;
  }
}
