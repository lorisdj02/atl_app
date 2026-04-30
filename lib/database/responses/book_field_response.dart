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
    final cities = List<City>.from(
      json[ApiJsonKeys.cities].map((x) => City.fromJson(x)),
    );
    final minOpeningTimePerCity = Map<double, TimeOfDay>.from(
      json[ApiJsonKeys.minOpeningTimePerCity].map(
        (key, value) => MapEntry(double.parse(key), timeOfDayFromJson(value)),
      ),
    );
    final maxClosingTimePerCity = Map<double, TimeOfDay>.from(
      json[ApiJsonKeys.maxClosingTimePerCity].map(
        (key, value) => MapEntry(double.parse(key), timeOfDayFromJson(value)),
      ),
    );
    return BookFieldResponse(
      cities: cities,
      minOpeningTimePerCity: minOpeningTimePerCity,
      maxClosingTimePerCity: maxClosingTimePerCity,
    );
  }
}
