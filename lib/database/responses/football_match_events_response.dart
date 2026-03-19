
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
    return FootballMatchEventsResponse(
      events: List<FootballMatchEvent>.from(
        (json[ApiJsonKeys.events] as List).map(
          (eventJson) => FootballMatchEvent.fromJson(eventJson),
        ),
      ),
      canMatchFinish: json[ApiJsonKeys.canMatchFinish] as bool,
    );
  }
}
