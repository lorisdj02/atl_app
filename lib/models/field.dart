import 'package:atl_app/models/sport_category.dart';

/// Modello Field dal database
class Field {
  final int id;
  final int organizationId;
  final String name;
  final double locationX;
  final double locationY;
  final double costTournament;
  final double hourlyCostPrivate;
  final String city;
  final SportCategory? sportCategory;
  final int maxPlayers;

  Field({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.locationX,
    required this.locationY,
    required this.costTournament,
    required this.hourlyCostPrivate,
    required this.city,
    required this.sportCategory,
    required this.maxPlayers,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      organizationId: json['organization_id'],
      name: json['name'],
      locationX: double.parse(json['location_x'].toString()),
      locationY: double.parse(json['location_y'].toString()),
      costTournament: double.parse(json['cost_tournament'].toString()),
      hourlyCostPrivate: double.parse(json['hourly_cost_private'].toString()),
      city: json['city'] ?? '',
      maxPlayers: json['max_players'] ?? 0,
      sportCategory: json['sport_category'] != null ? SportCategory.values.firstWhere((e) => e.toJSON() == json['sport_category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'location_x': locationX,
      'location_y': locationY,
      'cost_tournament': costTournament,
      'hourly_cost_private': hourlyCostPrivate,
      'city': city,
      'sport_category': sportCategory?.toJSON(),
      'max_players': maxPlayers,
    };
  }

  /// Formatta il costo torneo come stringa con valuta
  String get formattedCostTournament => '€${costTournament.toStringAsFixed(2)}';

  /// Formatta il costo privato come stringa con valuta
  String get formattedHourlyCostPrivate => '€${hourlyCostPrivate.toStringAsFixed(2)}';
}
