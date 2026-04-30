import 'sport_category.dart';
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
      id: json['id'],
      name: json['name'],
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.apiName == json['sportCategory'],
      ),
      minPlayersPerTeam: json['minPlayersPerTeam'],
      maxPlayersPerTeam: json['maxPlayersPerTeam'],
      minutesPerRound: json['minutesPerRound'],
      minutesPerPause: json['minutesPerPause'],
      numRefereesPerMatch: json['numRefereesPerMatch'],
    );
  }
}
