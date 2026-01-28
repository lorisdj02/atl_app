import 'package:atl_app/config/app_config.dart';

import '../../models/sport.dart';
import '../../models/sport_category.dart';
import 'base_repository.dart';
import '../db_controller.dart';

class SportRepository extends BaseRepository<Sport> {
  @override
  String get endpoint => 'sports';

  @override
  Sport fromJson(Map<String, dynamic> json) => Sport.fromJson(json);

  @override
  Map<String, dynamic> toJson(Sport item) => item.toJson();

  @override
  List<Sport> get mockData => [
    Sport(
      id: 1,
      name: 'Football 5v5',
      minPlayersPerTeam: 5,
      maxPlayersPerTeam: 10,
      minutesPerRound: 20,
      minutesPerPause: 5,
      category: SportCategory.football,
      numReferee: 1,
    ),
    Sport(
      id: 2,
      name: 'Football 7v7',
      minPlayersPerTeam: 7,
      maxPlayersPerTeam: 14,
      minutesPerRound: 25,
      minutesPerPause: 10,
      category: SportCategory.football,
      numReferee: 1,
    ),
    Sport(
      id: 3,
      name: 'Football 8v8',
      minPlayersPerTeam: 8,
      maxPlayersPerTeam: 16,
      minutesPerRound: 30,
      minutesPerPause: 10,
      category: SportCategory.football,
      numReferee: 1,
    ),
    Sport(
      id: 4,
      name: 'Football 11v11',
      minPlayersPerTeam: 11,
      maxPlayersPerTeam: 22,
      minutesPerRound: 40,
      minutesPerPause: 10,
      category: SportCategory.football,
      numReferee: 3,
    ),
  ];

  Future<Sport?> getById(int id) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((sport) => sport.id == id);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Sport>> getByCategory(SportCategory category) async {
    if (AppConfig.isDebug) {
      return mockData.where((sport) => sport.category == category).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<int?> getMinutesPerRoundById(int sportId) async {
    if (AppConfig.isDebug) {
      try {
        final sport = mockData.firstWhere((sport) => sport.id == sportId);
        return sport.minutesPerRound;
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<int?> getMinutesPerPauseById(int sportId) async {
    if (AppConfig.isDebug) {
      final sport = mockData.firstWhere(
        (sport) => sport.id == sportId,
        orElse: () => throw Exception('Sport not found'),
      );
      return sport.minutesPerPause;
    } else {
      throw UnimplementedError();
    }
  }

}
