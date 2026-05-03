import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';

class FootballMatchBracketResponse {
  final FootballMatch match;
  final Team? homeTeam;
  final Team? awayTeam;
  final double? winnerId;

  FootballMatchBracketResponse({
    required this.match,
    this.homeTeam,
    this.awayTeam,
    this.winnerId,
  });

  factory FootballMatchBracketResponse.fromJson(Map<String, dynamic> json) {
    final FootballMatch match = FootballMatch.fromJson(
      json[ApiJsonKeys.match] as Map<String, dynamic>,
    );
    print("Match parsed: ${match.id}");

    final Team? homeTeam = json[ApiJsonKeys.homeTeam] == null
        ? null
        : Team.fromJson(json[ApiJsonKeys.homeTeam] as Map<String, dynamic>);
    print("Home team parsed: ${homeTeam?.name}");

    final Team? awayTeam = json[ApiJsonKeys.awayTeam] == null
        ? null
        : Team.fromJson(json[ApiJsonKeys.awayTeam] as Map<String, dynamic>);
    print("Away team parsed: ${awayTeam?.name}");

    final double? winnerId = (json[ApiJsonKeys.winnerId] as num?)?.toDouble();
    print("Winner ID parsed: $winnerId");

    return FootballMatchBracketResponse(
      match: match,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      winnerId: winnerId,
    );
  }
}
