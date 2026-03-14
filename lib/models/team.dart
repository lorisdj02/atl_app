import 'sport_category.dart';

class Team {
  final int id;
  int? cityId;
  final String name;
  final String alias;
  String? description;
  int captainId;
  int? vice1Id;
  int? vice2Id;
  final String catId;
  String? imageUrl;
  bool vip;
  int? rankPts;
  int players;
  bool visibility;
  SportCategory sportCategory;
  static final int maxPlayers = 24;

  Team({
    required this.id,
    this.cityId,
    required this.name,
    required this.alias,
    this.description,
    required this.captainId,
    this.vice1Id,
    this.vice2Id,
    required this.catId,
    this.imageUrl,
    this.vip = false,
    this.rankPts,
    required this.players,
    this.visibility = true,
    this.sportCategory = SportCategory.football,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      cityId: json['cityId'],
      name: json['name'],
      alias: json['alias'],
      description: json['description'],
      captainId: json['captainId'],
      vice1Id: json['vice1Id'],
      vice2Id: json['vice2Id'],
      catId: json['catId'],
      imageUrl: json['imageUrl'],
      vip: json['vip'] ?? false,
      rankPts: json['rankPts'],
      players: json['players'] ?? 0,
      visibility: json['visibility'] ?? true,
      sportCategory: SportCategoryExtension.fromJson(json['catId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityId': cityId,
      'name': name,
      'alias': alias,
      'description': description,
      'captainId': captainId,
      'vice1Id': vice1Id,
      'vice2Id': vice2Id,
      'catId': catId,
      'imageUrl': imageUrl,
      'vip': vip,
      'rankPts': rankPts,
      'players': players,
      'visibility': visibility,
    };
  }
}
