import '../../../models/city.dart';
import 'package:flutter/material.dart';
import '../../config/api_json_keys.dart';
import '../../utils/time_of_day_parser.dart';

class BookFieldResponse {
  final List<City> cities;
  final Map<double, TimeOfDay> minOpeningTimePerCity;
  final Map<double, TimeOfDay> maxClosingTimePerCity;

  BookFieldResponse({
    required this.cities,
    required this.minOpeningTimePerCity,
    required this.maxClosingTimePerCity,
  });

  factory BookFieldResponse.fromJson(Map<String, dynamic> json) {
    final cities = (json[ApiJsonKeys.cities] as List<dynamic>)
        .map((cityJson) => City.fromJson(cityJson))
        .toList();
    print("Cities parsed: ${cities.length}");

    final minOpeningTimePerCity =
        (json[ApiJsonKeys.minOpeningTimePerCity] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), timeOfDayFromJson(value)),
        );
    print(
      "Min opening time per city parsed: ${minOpeningTimePerCity.values.length}",
    );

    final maxClosingTimePerCity =
        (json[ApiJsonKeys.maxClosingTimePerCity] as Map<String, dynamic>).map(
          (key, value) => MapEntry(double.parse(key), timeOfDayFromJson(value)),
        );
    print(
      "Max closing time per city parsed: ${maxClosingTimePerCity.values.length}",
    );

    return BookFieldResponse(
      cities: cities,
      minOpeningTimePerCity: minOpeningTimePerCity,
      maxClosingTimePerCity: maxClosingTimePerCity,
    );
  }
}
