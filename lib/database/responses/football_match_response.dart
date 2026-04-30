
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
    return FootballMatchResponse(
      match: FootballMatch.fromJson(json[ApiJsonKeys.match]),
      homeTeam: json[ApiJsonKeys.homeTeam] != null
          ? Team.fromJson(json[ApiJsonKeys.homeTeam])
          : null,
      awayTeam: json[ApiJsonKeys.awayTeam] != null
          ? Team.fromJson(json[ApiJsonKeys.awayTeam])
          : null,
      events: (json[ApiJsonKeys.events] as List)
          .map((e) => FootballMatchEvent.fromJson(e))
          .toList(),
      minutesPerRound: json[ApiJsonKeys.minutesPerRound],
      minutesPerPause: json[ApiJsonKeys.minutesPerPause],
      availableRefereeRoles:
          List<String>.from(json[ApiJsonKeys.availableRefereeRoles] as List),
      playersPerTeam: (json[ApiJsonKeys.playersPerTeam] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
              double.parse(key),
              (value as List)
                  .map((e) => Player.fromJson(e))
                  .toList())),
      assignmentPerRefereeNameSurname:
          Map<String, String>.from(json[ApiJsonKeys.assignmentPerRefereeNameSurname]),
      field: Field.fromJson(json[ApiJsonKeys.field]),
      cityName: json[ApiJsonKeys.cityName],
      coordinatorId: json[ApiJsonKeys.coordinatorId],
      refereeCheck: json[ApiJsonKeys.refereeCheck],
      canMatchFinish: json[ApiJsonKeys.canMatchFinish],
      hasRefereeLicense: json[ApiJsonKeys.hasRefereeLicense],
      payPerRole: Map<String, double>.from(json[ApiJsonKeys.payPerRole]),
    );
  }


}