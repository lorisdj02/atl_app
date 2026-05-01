import 'enums/sport_category.dart';

// OK
class Sport {
  final double id;
  final String name;
  final SportCategory sportCategory;
  final int minPlayersPerTeam;
  final int maxPlayersPerTeam;
  final int minutesPerRound;
  final int minutesPerPause;
  final int numRefereesPerMatch;

  Sport({
    required this.id,
    required this.name,
    required this.sportCategory,
    required this.minPlayersPerTeam,
    required this.maxPlayersPerTeam,
    required this.minutesPerRound,
    required this.minutesPerPause,
    required this.numRefereesPerMatch,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sportCategory': sportCategory.apiName,
      'minPlayersPerTeam': minPlayersPerTeam,
      'maxPlayersPerTeam': maxPlayersPerTeam,
      'minutesPerRound': minutesPerRound,
      'minutesPerPause': minutesPerPause,
      'numRefereesPerMatch': numRefereesPerMatch,
      'id': id,
    };
  }

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      name: json['name'],
      sportCategory: SportCategoryExtension.fromJson(json['sportCategory']),
      minPlayersPerTeam: json['minPlayersPerTeam'] != null
          ? (json['minPlayersPerTeam'] as num).toInt()
          : 0,
      maxPlayersPerTeam: json['maxPlayersPerTeam'] != null
          ? (json['maxPlayersPerTeam'] as num).toInt()
          : 0,
      minutesPerRound: json['minutesPerRound'] != null
          ? (json['minutesPerRound'] as num).toInt()
          : 0,
      minutesPerPause: json['minutesPerPause'] != null
          ? (json['minutesPerPause'] as num).toInt()
          : 0,
      numRefereesPerMatch: json['numRefereesPerMatch'] != null
          ? (json['numRefereesPerMatch'] as num).toInt()
          : 0,
    );
  }
}
