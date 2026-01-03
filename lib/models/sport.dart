import 'sport_category.dart';

class Sport {
  final int id;
  final String name;
  final int minPlayersPerTeam;
  final int maxPlayersPerTeam;
  final int minutesPerRound;
  final int minutesPerPause;
  final SportCategory category;
  final int numReferee;
  final List<String> refereeRoles;

  Sport({
    required this.id,
    required this.name,
    required this.minPlayersPerTeam,
    required this.maxPlayersPerTeam,
    required this.minutesPerRound,
    required this.minutesPerPause,
    required this.category,
    required this.numReferee,
    this.refereeRoles = const ['MAIN'],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minPlayersPerTeam': minPlayersPerTeam,
      'maxPlayersPerTeam': maxPlayersPerTeam,
      'minutesPerRound': minutesPerRound,
      'minutesPerPause': minutesPerPause,
      'category': category.toJSON(),
      'numReferee': numReferee,
      'refereeRoles': refereeRoles,
    };
  }

  Sport.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      minPlayersPerTeam = json['minPlayersPerTeam'],
      maxPlayersPerTeam = json['maxPlayersPerTeam'],
      minutesPerRound = json['minutesPerRound'],
      minutesPerPause = json['minutesPerPause'],
      category = SportCategoryExtension.fromJson(json['category']),
      numReferee = json['numReferee'],
      refereeRoles = List<String>.from(json['refereeRoles']);
}
