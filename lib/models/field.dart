import 'package:flutter/material.dart';

/// Modello Field dal database
/// OK
class Field {
  final double id;
  final String name;
  final String address;
  final double locationLat;
  final double locationLng;
  final double cityId;
  final double hourCostTournament;
  final double hourCostPrivate;
  final double organizationId;
  final String closedDays; // 0000001 (Lun-Dom, 1=chiuso, 0=aperto)
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;

  Field({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.locationLat,
    required this.locationLng,
    required this.hourCostTournament,
    required this.hourCostPrivate,
    required this.cityId,
    required this.openingTime,
    required this.closingTime,
    required this.closedDays,
    required this.address,
  });

  factory Field.fromJson(Map<String, dynamic> json) {
    double id = (json['id'] as num).toDouble();
    // print("Parsing Field with id: $id");

    double organizationId = (json['organizationId'] as num).toDouble();
    // print("Organization ID: $organizationId");

    String name = json['name'];
    // print("Field name: $name");

    double locationLat = (json['locationLat'] as num).toDouble();
    double locationLng = (json['locationLng'] as num).toDouble();
    // print("Location: ($locationLat, $locationLng)");

    double hourCostTournament = (json['hourCostTournament'] as num).toDouble();
    double hourCostPrivate = (json['hourCostPrivate'] as num).toDouble();
    // print(
    //   "Hour cost tournament: $hourCostTournament, private: $hourCostPrivate",
    // );

    double cityId = (json['cityId'] as num).toDouble();
    // print("City ID: $cityId");

    TimeOfDay openingTime = json['openingTime'] != null
        ? _timeFromString(json['openingTime'])
        : const TimeOfDay(hour: 8, minute: 0);

    TimeOfDay closingTime = json['closingTime'] != null
        ? _timeFromString(json['closingTime'])
        : const TimeOfDay(hour: 23, minute: 0);

    String closedDays = json['closedDays'];
    // print("Closed days: $closedDays");

    String address = json['address'];
    // print("Address: $address");

    return Field(
      id: id,
      organizationId: organizationId,
      name: name,
      locationLat: locationLat,
      locationLng: locationLng,
      hourCostTournament: hourCostTournament,
      hourCostPrivate: hourCostPrivate,
      cityId: cityId,
      openingTime: openingTime,
      closingTime: closingTime,
      closedDays: closedDays,
      address: address,
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
      'hourCostTournament': hourCostTournament,
      'hourCostPrivate': hourCostPrivate,
      'cityId': cityId,
      'openingTime':
          '${openingTime.hour.toString().padLeft(2, '0')}:${openingTime.minute.toString().padLeft(2, '0')}',
      'closingTime':
          '${closingTime.hour.toString().padLeft(2, '0')}:${closingTime.minute.toString().padLeft(2, '0')}',
      'closedDays': closedDays,
      'address': address,
    };
  }

  /// Formatta il costo torneo come stringa con valuta
  String get formattedCostTournament =>
      '€${hourCostTournament.toStringAsFixed(2)}';

  /// Formatta il costo privato come stringa con valuta
  String get formattedHourlyCostPrivate =>
      '€${hourCostPrivate.toStringAsFixed(2)}';

  /// Verifica se il campo è aperto in un determinato giorno/orario
  bool isOpenAt(DateTime dateTime) {
    // Controlla giorno chiusura (1=Lunedì, 7=Domenica)
    if (closedDays[dateTime.weekday - 1] == '1') {
      return false;
    }

    // Controlla orario
    final timeInMinutes = dateTime.hour * 60 + dateTime.minute;
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;

    return timeInMinutes >= openingMinutes && timeInMinutes <= closingMinutes;
  }
}
