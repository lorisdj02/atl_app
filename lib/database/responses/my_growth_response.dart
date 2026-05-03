import 'package:atl_app/models/growth_step.dart';
import 'package:atl_app/models/enums/sport_category.dart';
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
    final growthSteps = (json[ApiJsonKeys.growthSteps] as List)
        .map((e) => GrowthStep.fromJson(e))
        .toList();
    print("Growth steps parsed: ${growthSteps.length}");

    final level = json[ApiJsonKeys.level] as int;
    print("Level parsed: $level");

    final minRefereePayPerCategoryPerLevel =
        (json[ApiJsonKeys.minRefereePayPerCategoryPerLevel]
                as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                int.parse(key),
                (value as Map<String, dynamic>).map(
                  (catKey, catValue) => MapEntry(
                    SportCategory.values.firstWhere((e) => e.apiName == catKey),
                    (catValue as num).toDouble(),
                  ),
                ),
              ),
            );
    print(
      "Min referee pay per category per level parsed: ${minRefereePayPerCategoryPerLevel.length}",
    );

    final maxRefereePayPerCategoryPerLevel =
        (json[ApiJsonKeys.maxRefereePayPerCategoryPerLevel]
                as Map<String, dynamic>)
            .map(
              (key, value) => MapEntry(
                int.parse(key),
                (value as Map<String, dynamic>).map(
                  (catKey, catValue) => MapEntry(
                    SportCategory.values.firstWhere((e) => e.apiName == catKey),
                    (catValue as num).toDouble(),
                  ),
                ),
              ),
            );
    print(
      "Max referee pay per category per level parsed: ${maxRefereePayPerCategoryPerLevel.length}",
    );

    return MyGrowthResponse(
      growthSteps: growthSteps,
      level: level,
      minRefereePayPerCategoryPerLevel: minRefereePayPerCategoryPerLevel,
      maxRefereePayPerCategoryPerLevel: maxRefereePayPerCategoryPerLevel,
    );
  }
}
