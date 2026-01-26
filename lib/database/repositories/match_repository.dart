import 'base_repository.dart';
import '../../models/football_match.dart';
import '../../models/match.dart';
import '../../config/app_config.dart';
import '../../models/sport_category.dart';
import '../db_controller.dart';

class MatchRepository extends BaseRepository<Match> {
  @override
  String get endpoint => 'matches';

  @override
  Match fromJson(Map<String, dynamic> json) => Match.fromJson(json);

  @override
  Map<String, dynamic> toJson(Match item) => item.toJson();

  @override
  List<Match> get mockData => [
    ...DB.FootballMatches.mockData
  ];

}
