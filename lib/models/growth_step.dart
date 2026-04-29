enum GrowthStepType {
  referee,
  coordinator;

  String get apiName {
    switch (this) {
      case GrowthStepType.referee:
        return 'REFEREE';
      case GrowthStepType.coordinator:
        return 'COORDINATOR';
    }
  }
}

// OK
class GrowthStep {
  final String title;
  final int level;
  final int x;

  final double? minRatingOverLastXMatches;
  final int? minRefereedMatches;

  final double? minRatingOverLastXTournaments;
  final int? minCoordinatedTournaments;
  final double? coordinatorPayPerMatch;

  GrowthStep({
    required this.title,
    required this.level,
    required this.x,
    required this.minRatingOverLastXMatches,
    required this.minRefereedMatches,
    required this.minRatingOverLastXTournaments,
    required this.minCoordinatedTournaments,
    required this.coordinatorPayPerMatch,
  });

  factory GrowthStep.fromJson(Map<String, dynamic> json) {
    return GrowthStep(
      title: json['title'] ?? '',
      level: json['level'] ?? 0,
      x: json['x'] ?? 0,
      minRatingOverLastXMatches: (json['min_rating_over_last_x_matches'] as num?)?.toDouble(),
      minRefereedMatches: json['min_refereed_matches'],
      minRatingOverLastXTournaments: (json['min_rating_over_last_x_tournaments'] as num?)?.toDouble(),
      minCoordinatedTournaments: json['min_coordinated_tournaments'],
      coordinatorPayPerMatch: (json['coordinator_pay_per_match'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'level': level,
      'x': x,
      'min_rating_over_last_x_matches': minRatingOverLastXMatches,
      'min_refereed_matches': minRefereedMatches,
      'min_rating_over_last_x_tournaments': minRatingOverLastXTournaments,
      'min_coordinated_tournaments': minCoordinatedTournaments,
      'coordinator_pay_per_match': coordinatorPayPerMatch,
    };
  }
}
