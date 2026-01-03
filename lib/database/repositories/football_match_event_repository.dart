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
      eventTime: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
    FootballMatchEvent(
      id: 2,
      matchId: 1,
      type: FootballMatchEventType.goal,
      minute: 15,
      playerId: 1,
      eventTime: DateTime.now().subtract(const Duration(minutes: 8)),
    ),
    FootballMatchEvent(
      id: 3,
      matchId: 2,
      type: FootballMatchEventType.start,
      minute: 0,
      eventTime: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    FootballMatchEvent(
      id: 4,
      matchId: 2,
      type: FootballMatchEventType.halftime,
      minute: 20,
      eventTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
    ),
    FootballMatchEvent(
      id: 5,
      matchId: 2,
      type: FootballMatchEventType.startHalf,
      minute: 20,
      eventTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 37)),
    ),
    FootballMatchEvent(
      id: 6,
      matchId: 2,
      type: FootballMatchEventType.finish,
      minute: 40,
      eventTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
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

//TODO TODO A parità di minute, ordinare per eventTime. Far gestire anche i minuti di recupero nella visualizzazione e inserimento