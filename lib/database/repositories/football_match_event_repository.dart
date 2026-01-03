import 'package:atl_app/config/app_config.dart';

import '../../models/football_match_event.dart';
import 'base_repository.dart';

class FootballMatchEventRepository extends BaseRepository<FootballMatchEvent> {
  @override
  String get endpoint => 'football_match_events';

  @override
  FootballMatchEvent fromJson(Map<String, dynamic> json) =>
      FootballMatchEvent.fromJson(json);

  @override
  Map<String, dynamic> toJson(FootballMatchEvent item) => item.toJson();

  final List<FootballMatchEvent> _mockData = [
    FootballMatchEvent(
      id: 1,
      matchId: 1,
      type: FootballMatchEventType.start,
      minute: 0,
    ),
    FootballMatchEvent(
      id: 2,
      matchId: 1,
      type: FootballMatchEventType.goal,
      minute: 15,
      playerId: 1,
    ),
  ];

  @override
  List<FootballMatchEvent> get mockData => _mockData;

  Future<List<FootballMatchEvent>> getByMatchId(int matchId) async {
    if (AppConfig.isDebug) {
      return mockData.where((event) => event.matchId == matchId).toList();
    } else {
      throw UnimplementedError();
    }
  }
}
