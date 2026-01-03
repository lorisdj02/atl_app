import 'package:atl_app/models/sport_category.dart';
import 'package:flutter/material.dart';

/// Modello Field dal database
class Field {
  final int id;
  final int organizationId;
  final String name;
  final double locationLat;
  final double locationLng;
  final double costTournament;
  final double hourlyCostPrivate;
  final int cityId;
  final SportCategory? sportCategory;
  final int maxPlayers;

  // Nuovi campi
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final List<int> closedWeekdays; // 1=Lunedì, 7=Domenica
  final String address;

  Field({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.locationLat,
    required this.locationLng,
    required this.costTournament,
    required this.hourlyCostPrivate,
    required this.cityId,
    required this.sportCategory,
    required this.maxPlayers,
    this.openingTime = const TimeOfDay(hour: 8, minute: 0), // Default 08:00
    this.closingTime = const TimeOfDay(hour: 23, minute: 0), // Default 23:00
    this.closedWeekdays = const [], // Default sempre aperto
    this.address = 'Via Roma 1',
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      id: json['id'],
      organizationId: json['organization_id'],
      name: json['name'],
      locationLat: double.parse(json['location_lat'].toString()),
      locationLng: double.parse(json['location_lng'].toString()),
      costTournament: double.parse(json['cost_tournament'].toString()),
      hourlyCostPrivate: double.parse(json['hourly_cost_private'].toString()),
      cityId: json['city_id'] ?? 0,
      maxPlayers: json['max_players'] ?? 0,
      sportCategory: json['sport_category'] != null
          ? SportCategory.values.firstWhere(
              (e) => e.toJSON() == json['sport_category'],
            )
          : null,
      openingTime: json['opening_time'] != null
          ? _timeFromString(json['opening_time'])
          : const TimeOfDay(hour: 8, minute: 0),
      closingTime: json['closing_time'] != null
          ? _timeFromString(json['closing_time'])
          : const TimeOfDay(hour: 23, minute: 0),
      closedWeekdays: json['closed_weekdays'] != null
          ? List<int>.from(json['closed_weekdays'])
          : [],
    );
  }

  static TimeOfDay _timeFromString(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organization_id': organizationId,
      'name': name,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'cost_tournament': costTournament,
      'hourly_cost_private': hourlyCostPrivate,
      'city_id': cityId,
      'sport_category': sportCategory?.toJSON(),
      'max_players': maxPlayers,
      'opening_time':
          '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}',
      'closing_time':
          '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}',
      'closed_weekdays': closedWeekdays,
    };
  }

  /// Formatta il costo torneo come stringa con valuta
  String get formattedCostTournament => '€${costTournament.toStringAsFixed(2)}';

  /// Formatta il costo privato come stringa con valuta
  String get formattedHourlyCostPrivate =>
      '€${hourlyCostPrivate.toStringAsFixed(2)}';

  /// Verifica se il campo è aperto in un determinato giorno/orario
  bool isOpenAt(DateTime dateTime) {
    // Controlla giorno chiusura (1=Lunedì, 7=Domenica)
    if (closedWeekdays.contains(dateTime.weekday)) {
      return false;
    }

    // Controlla orario
    final timeInMinutes = dateTime.hour * 60 + dateTime.minute;
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;

    return timeInMinutes >= openingMinutes && timeInMinutes <= closingMinutes;
  }
}
