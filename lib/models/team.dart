import 'package:atl_app/models/player.dart';

class Team {
  final int id;
  final String? cityId;
  final String name;
  final String? alias;
  final String? description;
  final Player captain;
  final Player? vice1;
  final Player? vice2;
  final String catId;
  final String? imageUrl;
  final bool vip;
  final int? rankPts;
  final int? standingPts;
  final int players;

  Team({
    required this.id,
    this.cityId,
    required this.name,
    this.alias,
    this.description,
    required this.captain,
    this.vice1,
    this.vice2,
    required this.catId,
    this.imageUrl,
    this.vip = false,
    this.rankPts,
    this.standingPts,
    required this.players,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
      alias: json['alias'],
      description: json['description'],
      captain: Player.fromJson(json['captain']),
      vice1: json['vice1'] != null ? Player.fromJson(json['vice1']) : null,
      vice2: json['vice2'] != null ? Player.fromJson(json['vice2']) : null,
      catId: json['cat_id'],
      imageUrl: json['image_url'],
      vip: json['vip'] ?? false,
      rankPts: json['rank_pts'],
      standingPts: json['standing_pts'],
      players: json['players'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'alias': alias,
      'description': description,
      'captain': captain,
      'vice1': vice1,
      'vice2': vice2,
      'cat_id': catId,
      'image_url': imageUrl,
      'vip': vip,
    };
  }
}