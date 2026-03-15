enum GrowthStepType {
  referee,
  coordinator
}

class GrowthStep{
  final GrowthStepType type;
  final String title;
  final int level;
  final int x; // Number of games or tournaments to consider for the average rating

  final double? minRatingOverLastXGames; // For referee: minimum average rating over the last x games
  final int? minRefereedGames;

  final double? minRatingOverLastXTournaments; // For coordinator: minimum average rating over the last x tournaments
  final int? minCoordinatedTournaments;
  final double? coordinatorPayPerGame;


  GrowthStep({
    required this.type,
    required this.title,
    required this.level,
    required this.x,
    this.minRatingOverLastXGames,
    this.minRatingOverLastXTournaments,
    this.minRefereedGames,
    this.minCoordinatedTournaments,
    this.coordinatorPayPerGame,
  });

  factory GrowthStep.fromJson(Map<String, dynamic> json) {
    return GrowthStep(
      type: GrowthStepType.values.firstWhere((e) => e.toString() == 'GrowthStepType.' + json['type']),
      title: json['title'],
      level: json['level'],
      x: json['x'],
      minRatingOverLastXGames: json['minRatingOverLastXGames'] != null ? (json['minRatingOverLastXGames'] as num).toDouble() : null,
      minRatingOverLastXTournaments: json['minRatingOverLastXTournaments'] != null ? (json['minRatingOverLastXTournaments'] as num).toDouble() : null,
      minRefereedGames: json['minRefereedGames'],
      minCoordinatedTournaments: json['minCoordinatedTournaments'],
      coordinatorPayPerGame: json['coordinatorPayPerGame'] != null ? (json['coordinatorPayPerGame'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'title': title,
      'level': level,
      'x': x,
      'minRatingOverLastXGames': minRatingOverLastXGames,
      'minRatingOverLastXTournaments': minRatingOverLastXTournaments,
      'minRefereedGames': minRefereedGames,
      'minCoordinatedTournaments': minCoordinatedTournaments,
      'coordinatorPayPerGame': coordinatorPayPerGame,
    };
  }

}