import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_match_event.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/team.dart';

class FootballMatchResponse {
  final FootballMatch match;
  final Team? homeTeam;
  final Team? awayTeam;
  final List<FootballMatchEvent> events;
  final int minutesPerRound;
  final int minutesPerPause;
  final List<String> availableRefereeRoles;
  final Map<double, List<Player>> playersPerTeam;
  final Map<String, String> assignmentPerRefereeNameSurname;
  final Field field;
  final String cityName;
  final double coordinatorId;
  final bool refereeCheck;
  final bool canMatchFinish;
  final bool hasRefereeLicense;
  final Map<String, double> payPerRole;

  FootballMatchResponse({
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.events,
    required this.minutesPerRound,
    required this.minutesPerPause,
    required this.availableRefereeRoles,
    required this.playersPerTeam,
    required this.assignmentPerRefereeNameSurname,
    required this.field,
    required this.cityName,
    required this.coordinatorId,
    required this.refereeCheck,
    required this.canMatchFinish,
    required this.hasRefereeLicense,
    required this.payPerRole,
  });

  factory FootballMatchResponse.fromJson(Map<String, dynamic> json) {
    final FootballMatch match = FootballMatch.fromJson(json[ApiJsonKeys.match]);
    print("Match parsed: ${match.id}");
    
    final Team? homeTeam = json[ApiJsonKeys.homeTeam] != null
        ? Team.fromJson(json[ApiJsonKeys.homeTeam])
        : null;
    print("Home team parsed: ${homeTeam?.name}");

    final Team? awayTeam = json[ApiJsonKeys.awayTeam] != null
        ? Team.fromJson(json[ApiJsonKeys.awayTeam])
        : null;
    print("Away team parsed: ${awayTeam?.name}");

    final List<FootballMatchEvent> events = (json[ApiJsonKeys.events] as List)
        .map((e) => FootballMatchEvent.fromJson(e))
        .toList();
    print("Events parsed: ${events.length}");

    final int minutesPerRound = (json[ApiJsonKeys.minutesPerRound] as num)
        .toInt();
    print("Minutes per round parsed: $minutesPerRound");

    final int minutesPerPause = (json[ApiJsonKeys.minutesPerPause] as num)
        .toInt();
    print("Minutes per pause parsed: $minutesPerPause");

    final List<String> availableRefereeRoles = List<String>.from(
      json[ApiJsonKeys.availableRefereeRoles] as List,
    );
    print("Available referee roles parsed: ${availableRefereeRoles.length}");

    final Map<double, List<Player>> playersPerTeam =
        (json[ApiJsonKeys.playersPerTeam] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            double.parse(key),
            (value as List).map((e) => Player.fromJson(e)).toList(),
          ),
        );
    print("Players per team parsed: ${playersPerTeam.length}");

    final Map<String, String> assignmentPerRefereeNameSurname =
        Map<String, String>.from(
          json[ApiJsonKeys.assignmentPerRefereeNameSurname],
        );
    print(
      "Assignment per referee parsed: ${assignmentPerRefereeNameSurname.length}",
    );

    final Field field = Field.fromJson(json[ApiJsonKeys.field]);
    print("Field parsed: ${field.name}");

    final String cityName = json[ApiJsonKeys.cityName];
    print("City name parsed: $cityName");

    final double coordinatorId = (json[ApiJsonKeys.coordinatorId] as num).toDouble();
    print("Coordinator ID parsed: $coordinatorId");

    final bool refereeCheck = json[ApiJsonKeys.refereeCheck];
    print("Referee check parsed: $refereeCheck");

    final bool canMatchFinish = json[ApiJsonKeys.canMatchFinish];
    print("Can match finish parsed: $canMatchFinish");

    final bool hasRefereeLicense = json[ApiJsonKeys.hasRefereeLicense];
    print("Has referee license parsed: $hasRefereeLicense");

    final Map<String, double> payPerRole = Map<String, double>.from(
      json[ApiJsonKeys.payPerRole],
    );
    print("Pay per role parsed: ${payPerRole.length}");

    return FootballMatchResponse(
      match: match,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      events: events,
      minutesPerRound: minutesPerRound,
      minutesPerPause: minutesPerPause,
      availableRefereeRoles: availableRefereeRoles,
      assignmentPerRefereeNameSurname: assignmentPerRefereeNameSurname,
      field: field,
      cityName: cityName,
      coordinatorId: coordinatorId,
      refereeCheck: refereeCheck,
      canMatchFinish: canMatchFinish,
      hasRefereeLicense: hasRefereeLicense,
      payPerRole: payPerRole,
      playersPerTeam: playersPerTeam,
    );
  }
}
