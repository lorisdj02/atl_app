import 'package:atl_app/database/responses/abstract_team_response.dart';
import 'package:atl_app/database/responses/pay_participation_response.dart';
import 'package:atl_app/database/responses/player_requests_response.dart';
import 'package:atl_app/database/responses/players_in_team_response.dart';
import 'package:atl_app/database/responses/team_details_response.dart';
import 'package:atl_app/database/responses/teams_response.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:dio/dio.dart';

class TeamServiceRead {
  final String apiUrl;
  final Dio dio;

  TeamServiceRead({required this.apiUrl, required this.dio});

  Future<TeamsResponse> getTeamsScreen(SportCategory sportCategory) async {
    final response = await dio.get(
      "$apiUrl/${sportCategory.apiName}",
    );
    return TeamsResponse.fromJson(response.data);
  }

  Future<PlayersInTeamResponse> getPlayersInTeam(double teamId) async {
    final response = await dio.get("$apiUrl/team/${teamId.toStringAsFixed(0)}/players");
    return PlayersInTeamResponse.fromJson(response.data);
  }

  Future<AbstractTeamResponse> getAbstractTeamScreen(double teamId) async {
    final response = await dio.get("$apiUrl/team/${teamId.toStringAsFixed(0)}/abstract");
    return AbstractTeamResponse.fromJson(response.data);
  }

  Future<PayParticipationResponse> getPayParticipationScreen(
    double teamId,
  ) async {
    final response = await dio.get("$apiUrl/team/${teamId.toStringAsFixed(0)}/pay-participation");
    return PayParticipationResponse.fromJson(response.data);
  }

  Future<PlayerRequestsResponse> getTeamRequestsScreen(double teamId) async {
    final response = await dio.get(
      "$apiUrl/team/${teamId.toStringAsFixed(0)}/manage/view-player-requests",
    );
    return PlayerRequestsResponse.fromJson(response.data);
  }

  Future<TeamDetailsResponse> getTeamDetailsScreen(double teamId) async {
    final response = await dio.get("$apiUrl/team/${teamId.toStringAsFixed(0)}/details");
    return TeamDetailsResponse.fromJson(response.data);
  }

  Future<bool> checkTeamNameInCategoryExists(
    SportCategory sportCategory,
    String teamName,
  ) async {
    final response = await dio.get(
      "$apiUrl/create/${sportCategory.apiName}/check-name/${teamName}",
    );
    return response.data;
  }

  Future<List<TournamentParticipation>> getNotPaidTeamParticipations(
    double teamId,
  ) async {
    final response = await dio.get(
      "$apiUrl/team/${teamId.toStringAsFixed(0)}/not-paid-participations",
    );
    return (response.data as List<dynamic>)
        .map((e) => TournamentParticipation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Team> getTeamById(double teamId) async {
    final response = await dio.get("$apiUrl/search-by-id/${teamId.toStringAsFixed(0)}");
    return Team.fromJson(response.data);
  }
}
