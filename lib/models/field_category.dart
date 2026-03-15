import 'sport_category.dart';

class FieldCategory {
  final int fieldId;
  final SportCategory sportCategory;
  final int maxPlayers; // Se calcio a 5, maxPlayers=10; Se calcio a 11, maxPlayers=22

  FieldCategory({
    required this.fieldId,
    required this.sportCategory,
    required this.maxPlayers,
  });

  factory FieldCategory.fromJson(Map<String, dynamic> json) {
    return FieldCategory(
      fieldId: json['fieldId'],
      sportCategory: SportCategory.values.firstWhere(
        (e) => e.toJSON() == json['sportCategory'],
      ),
      maxPlayers: json['maxPlayers'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fieldId': fieldId,
      'sportCategory': sportCategory.toJSON(),
      'maxPlayers': maxPlayers,
    };
  }
}