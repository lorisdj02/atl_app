import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

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
  final String timeZone;

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
    this.timeZone = 'Europe/Rome', // Valore di default
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

    String closedDays = json['closedDays'];
    // print("Closed days: $closedDays");

    String address = json['address'];
    // print("Address: $address");

    String timeZone = json['timeZone'] ?? 'Europe/Rome';
    // print("Time zone: $timeZone");

    TimeOfDay openingTime =
      _timeFromString(json['openingTime'], timeZone: timeZone);
    // print("Opening time: $openingTime");


    TimeOfDay closingTime =
      _timeFromString(json['closingTime'], timeZone: timeZone);
    // print("Closing time: $closingTime");


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
      timeZone: timeZone,
    );
  }

  static TimeOfDay _timeFromString(
    String time, {
    String timeZone = 'Europe/Rome',
  }) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) {
        throw FormatException('Invalid time format: $time');
      }

      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      final now = DateTime.now();
      final fieldLocation = tz.getLocation(timeZone);
      final fieldDateTime = tz.TZDateTime(
        fieldLocation,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      return TimeOfDay(
        hour: fieldDateTime.toLocal().hour,
        minute: fieldDateTime.toLocal().minute,
      );
    } catch (e) {
      // Fallback: keep the original time if timezone conversion fails.
      final parts = time.split(':');
      if (parts.length == 2) {
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      return const TimeOfDay(hour: 0, minute: 0);
    }
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
      'openingTime': _timeToStringInTimeZone(openingTime, timeZone),
      'closingTime': _timeToStringInTimeZone(closingTime, timeZone),
      'closedDays': closedDays,
      'address': address,
      'timeZone': timeZone,
    };
  }

  static String _timeToStringInTimeZone(TimeOfDay time, String timeZone) {
    try {
      final now = DateTime.now();
      final localDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      final fieldLocation = tz.getLocation(timeZone);
      final fieldDateTime = tz.TZDateTime.from(localDateTime, fieldLocation);

      return '${fieldDateTime.hour.toString().padLeft(2, '0')}'
          ':${fieldDateTime.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '${time.hour.toString().padLeft(2, '0')}'
          ':${time.minute.toString().padLeft(2, '0')}';
    }
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
