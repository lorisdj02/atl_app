class Team {
  final int id;
  String? cityId;
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
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
      alias: json['alias'],
      description: json['description'],
      captainId: json['captain_id'],
      vice1Id: json['vice1_id'],
      vice2Id: json['vice2_id'],
      catId: json['cat_id'],
      imageUrl: json['image_url'],
      vip: json['vip'] ?? false,
      rankPts: json['rank_pts'],
      players: json['players'] ?? 0,
      visibility: json['visibility'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city_id': cityId,
      'name': name,
      'alias': alias,
      'description': description,
      'captain_id': captainId,
      'vice1_id': vice1Id,
      'vice2_id': vice2Id,
      'cat_id': catId,
      'image_url': imageUrl,
      'vip': vip,
      'rank_pts': rankPts,
      'players': players,
      'visibility': visibility,
    };
  }
}