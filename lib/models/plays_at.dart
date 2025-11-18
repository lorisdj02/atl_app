import 'package:atl_app/models/sport_category.dart';

class PlaysAt {
  final int teamId;
  final int playerId;
  final DateTime joined;
  final SportCategory sportCategory;

  PlaysAt({
    required this.teamId,
    required this.playerId,
    required this.joined,
    this.sportCategory = SportCategory.football,
  });

  factory PlaysAt.fromJson(Map<String, dynamic> json) {
    return PlaysAt(
      teamId: json['team_id'] as int,
      playerId: json['player_id'] as int,
      joined: DateTime.parse(json['joined'] as String),
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.toString() == 'SportCategory.${json['sport_category']}',
        orElse: () => SportCategory.football,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'player_id': playerId,
      'joined': joined.toIso8601String(),
      'sport_category': sportCategory.toString().split('.').last,
    };
  }

  PlaysAt copyWith({
    int? teamId,
    int? playerId,
    DateTime? joined,
    SportCategory? sportCategory,
  }) {
    return PlaysAt(
      teamId: teamId ?? this.teamId,
      playerId: playerId ?? this.playerId,
      joined: joined ?? this.joined,
      sportCategory: sportCategory ?? this.sportCategory,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaysAt &&
        other.teamId == teamId &&
        other.playerId == playerId;
  }

  @override
  int get hashCode => Object.hash(teamId, playerId);
}
