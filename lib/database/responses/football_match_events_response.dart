import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match_event.dart';

class FootballMatchEventsResponse {
  final List<FootballMatchEvent> events;
  final bool canMatchFinish;

  FootballMatchEventsResponse({
    required this.events,
    required this.canMatchFinish,
  });

  factory FootballMatchEventsResponse.fromJson(Map<String, dynamic> json) {
      final List<FootballMatchEvent> events = (json[ApiJsonKeys.events] as List)
          .map((e) => FootballMatchEvent.fromJson(e))
          .toList();
      print("Events parsed: ${events.length}");

  final bool canMatchFinish = json[ApiJsonKeys.canMatchFinish] as bool;
  print("Can match finish parsed: $canMatchFinish");

    return FootballMatchEventsResponse(
      events: events,
      canMatchFinish: canMatchFinish,
    );
  }
}
