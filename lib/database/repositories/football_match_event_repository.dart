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
      teamId: 1,
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
      additionalMinute: 2,
      eventTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    FootballMatchEvent(
      id: 7,
      matchId: 1,
      type: FootballMatchEventType.startHalf,
      minute: 20,
      eventTime: DateTime.now(),
    ),
  ];

  @override
  List<FootballMatchEvent> get mockData => _mockData;

  Future<bool> updateModifiedTables(int eventId, String modifiedTables) async {
    if (AppConfig.isDebug) {
      final eventIndex = _mockData.indexWhere((event) => event.id == eventId);
      if (eventIndex != -1) {
        _mockData[eventIndex].modifiedTables = modifiedTables;
        return true;
      } else {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteEvent(int eventId) async {
    if (AppConfig.isDebug) {
      final eventIndex = _mockData.indexWhere((event) => event.id == eventId);
      if (eventIndex != -1) {
        _mockData.removeAt(eventIndex);
        return true;
      } else {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> canBeDeleted(int eventId) async {
    if (AppConfig.isDebug) {
      FootballMatchEvent event = _mockData.firstWhere(
        (event) => event.id == eventId,
      );
      List<FootballMatchEventType> nonDeletableTypes = [
        FootballMatchEventType.start,
        FootballMatchEventType.startHalf,
        FootballMatchEventType.halftime,
        FootballMatchEventType.finish,
        FootballMatchEventType.penaltyShootOut,
      ];
      List<FootballMatchEvent> matchEvents = _mockData
          .where((e) => e.matchId == event.matchId)
          .toList();

      // Verifica se è l'ultimo evento della partita
      if (matchEvents.isNotEmpty) {
        FootballMatchEvent lastEvent = matchEvents.reduce(
          (a, b) => a.eventTime.isAfter(b.eventTime) ? a : b,
        );
        if (lastEvent.id != event.id) {
          return false;
        }
      }
      return !nonDeletableTypes.contains(event.type);
    } else {
      throw UnimplementedError();
    }
  }

  Future<String> getModifiedTables(int eventId) async {
    if (AppConfig.isDebug) {
      final event = _mockData.firstWhere(
        (event) => event.id == eventId,
        orElse: () => FootballMatchEvent(
          id: 0,
          matchId: 0,
          type: FootballMatchEventType.start,
          minute: 0,
          eventTime: DateTime.now(),
          modifiedTables: '',
        ),
      );
      return event.modifiedTables;
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballMatchEvent>> getByMatchId(int matchId) async {
    if (AppConfig.isDebug) {
      return mockData.where((event) => event.matchId == matchId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<DateTime?> getMatchStartTime(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final FootballMatchEvent startEvent = _mockData.firstWhere(
          (event) =>
              event.type == FootballMatchEventType.start &&
              event.matchId == matchId,
        );

        return startEvent.eventTime;
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<DateTime?> getMatchStartHalf(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final FootballMatchEvent startHalfEvent = mockData.firstWhere(
          (event) =>
              event.matchId == matchId &&
              event.type == FootballMatchEventType.startHalf,
        );

        return startHalfEvent.eventTime;
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isMatchHalfStarted(int matchId) async {
    if (AppConfig.isDebug) {
      final List<FootballMatchEvent> events = await getByMatchId(matchId);
      return events.any(
        (event) => event.type == FootballMatchEventType.startHalf,
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isMatchStarted(int matchId) async {
    if (AppConfig.isDebug) {
      final List<FootballMatchEvent> events = await getByMatchId(matchId);
      return events.any((event) => event.type == FootballMatchEventType.start);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isPlayerWarned(int matchId, int playerId) async {
    if (AppConfig.isDebug) {
      final List<FootballMatchEvent> events = await getByMatchId(matchId);
      return events.any(
        (event) =>
            (event.type == FootballMatchEventType.yellowCard ||
                event.type == FootballMatchEventType.redYellowCard) &&
            event.playerId == playerId,
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isPlayerSentOff(int matchId, int playerId) async {
    if (AppConfig.isDebug) {
      final List<FootballMatchEvent> events = _mockData
          .where((event) => event.matchId == matchId)
          .toList();
      return events.any(
        (event) =>
            (event.type == FootballMatchEventType.redCard ||
                event.type == FootballMatchEventType.redYellowCard) &&
            event.playerId == playerId,
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<int?> insertEvent(
    int matchId,
    String type,
    int minute,
    DateTime eventTime, {
    int additionalMinute = 0,
    int? playerId,
    int? teamId,
  }) async {
    if (AppConfig.isDebug) {
      // Aggiungi l'evento alla lista mock

      FootballMatchEventType eventType = FootballMatchEventType.values
          .firstWhere(
            (e) => e.toString() == 'FootballMatchEventType.$type',
            orElse: () => FootballMatchEventType.start,
          );

      final int? newId = _mockData.isNotEmpty
          ? _mockData.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1
          : 1;

      if(newId == null){
        return null;
      }

      final event = FootballMatchEvent(
        id: newId,
        matchId: matchId,
        type: eventType,
        minute: minute,
        additionalMinute: additionalMinute,
        playerId: playerId,
        eventTime: eventTime,
        teamId: teamId,
      );
      _mockData.add(event);
      return newId;
    } else {
      throw UnimplementedError();
    }
  }
}
