import 'base_repository.dart';
import '../../models/match.dart';
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
