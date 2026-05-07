import 'enums/tournament_phase.dart';
import 'enums/tournament_status.dart';

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
  TournamentStatus status;
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
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      name: json['name'],
      description: json['description'],
      coordinatorId: json['coordinatorId'] != null ? (json['coordinatorId'] as num).toDouble() : 0.0,
      fieldId: json['fieldId'] != null ? (json['fieldId'] as num).toDouble() : 0.0,
      cityId: json['cityId'] != null ? (json['cityId'] as num).toDouble() : 0.0,
      sportId: json['sportId'] != null ? (json['sportId'] as num).toDouble() : 0.0,
      isFavorite: json['isFavorite'] != null ? json['isFavorite'] as bool : false,
      isParticipating: json['isParticipating'] != null ? json['isParticipating'] as bool : false,
      numGroups: json['numGroups'] != null ? (json['numGroups'] as num).toInt() : 0,
      numTeams: json['numTeams'] != null ? (json['numTeams'] as num).toInt() : 0,
      paidTeams: json['paidTeams'] != null ? (json['paidTeams'] as num).toInt() : 0,
      status: TournamentStatus.values.firstWhere(
        (e) => e.apiName == json['status'],
      ),
      atlEvent: json['atlEvent'] != null ? json['atlEvent'] as bool : false,
      prize1: json['prize1'] != null ? (json['prize1'] as num).toDouble().abs() : 0.0,
      prize2: json['prize2'] != null ? (json['prize2'] as num).toDouble().abs() : 0.0,
      startDate: DateTime.tryParse(json['startDate'] ?? ''),
      fee: json['fee'] != null ? (json['fee'] as num).toDouble() : 0.0,
      photoUrl: json['photoUrl'],
      round2GroupStage: json['round2GroupStage'] != null ? json['round2GroupStage'] as bool : false,
      round2FinalStage: json['round2FinalStage'] != null ? json['round2FinalStage'] as bool : false,
      numTeamsQualified: json['numTeamsQualified'] != null ? (json['numTeamsQualified'] as num).toInt() : 0,
      isPublic: json['isPublic'] != null ? json['isPublic'] as bool : true,
      phase: TournamentPhaseExtension.fromJson(json['phase']),
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

  String get formattedPrize1 {
    return '${prize1.toStringAsFixed(2)}€';
  }

  String get formattedPrize2 {
    return '${prize2.toStringAsFixed(2)}€';
  }

  String get formattedFee {
    return '${fee.toStringAsFixed(2)}€';
  }
}
