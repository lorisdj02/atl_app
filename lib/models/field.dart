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

  //TODO: separa sportCategory -> ogni campo può ospitare più sport? In questo caso serve una tabella di join campo-sport

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
      organizationId: json['organizationId'],
      name: json['name'],
      locationLat: double.parse(json['locationLat'].toString()),
      locationLng: double.parse(json['locationLng'].toString()),
      costTournament: double.parse(json['costTournament'].toString()),
      hourlyCostPrivate: double.parse(json['hourlyCostPrivate'].toString()),
      cityId: json['cityId'] ?? 0,
      maxPlayers: json['maxPlayers'] ?? 0,
      sportCategory: json['sportCategory'] != null
          ? SportCategory.values.firstWhere(
              (e) => e.toJSON() == json['sportCategory'],
            )
          : null,
      openingTime: json['openingTime'] != null
          ? _timeFromString(json['openingTime'])
          : const TimeOfDay(hour: 8, minute: 0),
      closingTime: json['closingTime'] != null
          ? _timeFromString(json['closingTime'])
          : const TimeOfDay(hour: 23, minute: 0),
      closedWeekdays: json['closedWeekdays'] != null
          ? List<int>.from(json['closedWeekdays'])
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
      'organizationId': organizationId,
      'name': name,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'costTournament': costTournament,
      'hourlyCostPrivate': hourlyCostPrivate,
      'cityId': cityId,
      'sportCategory': sportCategory?.toJSON(),
      'maxPlayers': maxPlayers,
      'openingTime':
          '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}',
      'closingTime':
          '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}',
      'closedWeekdays': closedWeekdays,
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
