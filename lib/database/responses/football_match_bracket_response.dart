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
    return FootballMatchBracketResponse(
      match: FootballMatch.fromJson(
        json[ApiJsonKeys.match] as Map<String, dynamic>,
      ),
      homeTeam: json[ApiJsonKeys.homeTeam] == null
          ? null
          : Team.fromJson(json[ApiJsonKeys.homeTeam] as Map<String, dynamic>),
      awayTeam: json[ApiJsonKeys.awayTeam] == null
          ? null
          : Team.fromJson(json[ApiJsonKeys.awayTeam] as Map<String, dynamic>),
      winnerId: json[ApiJsonKeys.winnerId] == null
          ? null
          : json[ApiJsonKeys.winnerId] as double?,
    );
  }
}
