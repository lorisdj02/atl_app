import 'package:atl_app/models/sport.dart';

import 'base_repository.dart';
import '../../models/field_category.dart';
import '../../config/app_config.dart';
import '../../models/sport_category.dart';

class FieldCategoriesRepository extends BaseRepository<FieldCategory> {
  @override
  String get endpoint => 'field-categories';

  @override
  FieldCategory fromJson(Map<String, dynamic> json) =>
      FieldCategory.fromJson(json);

  @override
  Map<String, dynamic> toJson(FieldCategory item) => item.toJson();

  List<FieldCategory> _mockData = [
    FieldCategory(
      fieldId: 1,
      sportCategory: SportCategory.football,
      maxPlayers: 22,
    ),
    FieldCategory(
      fieldId: 2,
      sportCategory: SportCategory.football,
      maxPlayers: 14,
    ),
    FieldCategory(
      fieldId: 3,
      sportCategory: SportCategory.football,
      maxPlayers: 10,
    ),
    FieldCategory(
      fieldId: 4,
      sportCategory: SportCategory.football,
      maxPlayers: 16,
    ),
  ];

  @override
  List<FieldCategory> get mockData => _mockData;

  Future<List<int>> getFieldIdsBySportCategory(
    SportCategory sportCategory,
  ) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where((fc) => fc.sportCategory == sportCategory)
          .map((fc) => fc.fieldId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FieldCategory>> getByFieldId(int fieldId) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.where((fc) => fc.fieldId == fieldId).toList();
      } catch (e) {
        return [];
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<int>> getFieldIdsBySportCategoryAndMaxPlayers(
    SportCategory sportCategory,
    int maxPlayers,
  ) async {
    if (AppConfig.isDebug) {
      return _mockData
          .where(
            (fc) =>
                fc.sportCategory == sportCategory &&
                fc.maxPlayers >= maxPlayers,
          )
          .map((fc) => fc.fieldId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<FieldCategory?> getByFieldIdAndSportCategory(
    int fieldId,
    SportCategory sportCategory,
  ) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere(
          (fc) => fc.fieldId == fieldId && fc.sportCategory == sportCategory,
        );
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }
}
