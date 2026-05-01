import 'enums/sport_category.dart';

// OK
class Team {
  final double id;
  final double? cityId;
  final double? captainPlayerId;
  final double? vice1PlayerId;
  final double? vice2PlayerId;
  final String? logoUrl;
  final int rankPts;
  final String name;
  final String alias;
  final String? description;
  final bool vip;
  final int maxPlayers;
  final int numPlayers;
  final SportCategory sportCategory;
  final bool visible;

  Team({
    required this.id,
    required this.name,
    required this.alias,
    required this.sportCategory,
    required this.visible,
    required this.cityId,
    required this.captainPlayerId,
    required this.vice1PlayerId,
    required this.vice2PlayerId,
    required this.logoUrl,
    required this.rankPts,
    required this.description,
    required this.vip,
    required this.maxPlayers,
    required this.numPlayers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityId': cityId,
      'captainPlayerId': captainPlayerId,
      'vice1PlayerId': vice1PlayerId,
      'vice2PlayerId': vice2PlayerId,
      'logoUrl': logoUrl,
      'rankPts': rankPts,
      'name': name,
      'alias': alias,
      'description': description,
      'vip': vip,
      'maxPlayers': maxPlayers,
      'numPlayers': numPlayers,
      'sportCategory': sportCategory.apiName,
      'visible': visible,
    };
  }

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] != null ? (json['id'] as num).toDouble() : 0.0,
      cityId: json['cityId'] != null ? (json['cityId'] as num).toDouble() : 0.0,
      captainPlayerId: json['captainPlayerId'] != null
          ? (json['captainPlayerId'] as num).toDouble()
          : 0.0,
      vice1PlayerId: json['vice1PlayerId'] != null
          ? (json['vice1PlayerId'] as num).toDouble()
          : 0.0,
      vice2PlayerId: json['vice2PlayerId'] != null
          ? (json['vice2PlayerId'] as num).toDouble()
          : 0.0,
      logoUrl: json['logoUrl'],
      rankPts: json['rankPts'] != null ? (json['rankPts'] as num).toInt() : 0,
      name: json['name'],
      alias: json['alias'],
      description: json['description'],
      vip: json['vip'] != null ? json['vip'] as bool : false,
      maxPlayers: json['maxPlayers'] != null
          ? (json['maxPlayers'] as num).toInt()
          : 0,
      numPlayers: json['numPlayers'] != null
          ? (json['numPlayers'] as num).toInt()
          : 0,
      sportCategory: json['sportCategory'] != null
          ? SportCategoryExtension.fromJson(json['sportCategory'])
          : SportCategory.football,
      visible: json['visible'] != null ? json['visible'] as bool : false,
    );
  }
}
