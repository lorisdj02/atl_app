import 'package:atl_app/models/growth_step.dart';
import 'package:atl_app/models/sport_category.dart';
import '../../config/api_json_keys.dart';

class MyGrowthResponse {
  final List<GrowthStep> growthSteps;
  final int level;
  final Map<int, Map<SportCategory, double>> minRefereePayPerCategoryPerLevel;
  final Map<int, Map<SportCategory, double>> maxRefereePayPerCategoryPerLevel;

  MyGrowthResponse({
    required this.growthSteps,
    required this.level,
    required this.minRefereePayPerCategoryPerLevel,
    required this.maxRefereePayPerCategoryPerLevel,
  });

  factory MyGrowthResponse.fromJson(Map<String, dynamic> json) {
    final growthSteps = List<GrowthStep>.from(
      json[ApiJsonKeys.growthSteps].map((x) => GrowthStep.fromJson(x)),
    );
    final level = json[ApiJsonKeys.level] as int;
    final minRefereePayPerCategoryPerLevel =
        Map<int, Map<SportCategory, double>>.from(
          json[ApiJsonKeys.minRefereePayPerCategoryPerLevel].map(
            (key, value) => MapEntry(
              int.parse(key),
              Map<SportCategory, double>.from(
                value.map(
                  (catKey, catValue) => MapEntry(
                    SportCategory.values.firstWhere((e) => e.apiName == catKey),
                    catValue,
                  ),
                ),
              ),
            ),
          ),
        );
    final maxRefereePayPerCategoryPerLevel =
        Map<int, Map<SportCategory, double>>.from(
          json[ApiJsonKeys.maxRefereePayPerCategoryPerLevel].map(
            (key, value) => MapEntry(
              int.parse(key),
              Map<SportCategory, double>.from(
                value.map(
                  (catKey, catValue) => MapEntry(
                    SportCategory.values.firstWhere((e) => e.apiName == catKey),
                    catValue,
                  ),
                ),
              ),
            ),
          ),
        );
    return MyGrowthResponse(
      growthSteps: growthSteps,
      level: level,
      minRefereePayPerCategoryPerLevel: minRefereePayPerCategoryPerLevel,
      maxRefereePayPerCategoryPerLevel: maxRefereePayPerCategoryPerLevel,
    );
  }
}
