/// Enum per lo stato del torneo
enum TournamentStatus {
  created,
  scheduled,
  finished,
  canceled;

  String get displayName {
    switch (this) {
      case TournamentStatus.created:
        return 'Created';
      case TournamentStatus.scheduled:
        return 'Scheduled';
      case TournamentStatus.finished:
        return 'Finished';
      case TournamentStatus.canceled:
        return 'Canceled';
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

  String get displayName {
    switch (this) {
      case TournamentPhase.group:
        return 'Group Stage';
      case TournamentPhase.ro32:
        return 'Round of 32';
      case TournamentPhase.ro16:
        return 'Round of 16';
      case TournamentPhase.ro8:
        return 'Round of 8';
      case TournamentPhase.quarter:
        return 'Quarter Finals';
      case TournamentPhase.semi:
        return 'Semi Finals';
      case TournamentPhase.final_:
        return 'Final';
    }
  }
}

/// Modello Tournament dal database
class Tournament {
  final int id;
  final int coordinatorId;
  final int fieldId;
  final int cityId;
  final DateTime? startDate;
  final bool public;
  final bool profit;
  final String sportId;
  final int numTeams;
  final int paidTeams; // Numero team iscritti (deve essere <= numTeams)
  final int numGroups;
  final int round2;
  final int qualified;
  final String description;
  final int payCoordinator;
  final int payField;
  final TournamentStatus status;
  final double fee;
  final double prize1;
  final double prize2;
  final bool atlEvent;
  final TournamentPhase phase;
  final String cityName; // Nome città per mock/display

  Tournament({
    required this.id,
    required this.coordinatorId,
    required this.fieldId,
    required this.cityId,
    this.startDate,
    this.public = true,
    this.profit = true,
    required this.sportId,
    this.numTeams = 8,
    this.paidTeams = 0,
    this.numGroups = 2,
    this.round2 = 0,
    this.qualified = 4,
    required this.description,
    required this.payCoordinator,
    required this.payField,
    this.status = TournamentStatus.created,
    required this.fee,
    required this.prize1,
    this.prize2 = 0,
    this.atlEvent = false,
    this.phase = TournamentPhase.group,
    this.cityName = '',
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      coordinatorId: json['coordinator_id'],
      fieldId: json['field_id'],
      cityId: json['city_id'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      public: json['public'] ?? true,
      profit: json['profit'] ?? true,
      sportId: json['sport_id'],
      numTeams: json['num_teams'] ?? 8,
      paidTeams: json['paid_teams'] ?? 0,
      numGroups: json['num_groups'] ?? 2,
      round2: json['round2'] ?? 0,
      qualified: json['qualified'] ?? 4,
      description: json['description'],
      payCoordinator: json['pay_coordinator'],
      payField: json['pay_field'],
      status: _statusFromString(json['status']),
      fee: double.parse(json['fee'].toString()),
      prize1: double.parse(json['prize1'].toString()),
      prize2: double.parse(json['prize2'].toString()),
      atlEvent: json['atl_event'] ?? false,
      phase: _phaseFromString(json['phase']),
      cityName: json['city_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coordinator_id': coordinatorId,
      'field_id': fieldId,
      'city_id': cityId,
      'start_date': startDate?.toIso8601String(),
      'public': public,
      'profit': profit,
      'sport_id': sportId,
      'num_teams': numTeams,
      'paid_teams': paidTeams,
      'num_groups': numGroups,
      'round2': round2,
      'qualified': qualified,
      'description': description,
      'pay_coordinator': payCoordinator,
      'pay_field': payField,
      'status': status.name.toUpperCase(),
      'fee': fee,
      'prize1': prize1,
      'prize2': prize2,
      'atl_event': atlEvent,
      'phase': phase.name.toUpperCase(),
      'city_name': cityName,
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
