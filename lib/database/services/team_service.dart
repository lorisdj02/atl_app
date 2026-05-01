import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/abstract_team_response.dart';
import 'package:atl_app/database/responses/pay_participation_response.dart';
import 'package:atl_app/database/responses/player_requests_response.dart';
import 'package:atl_app/database/responses/players_in_team_response.dart';
import 'package:atl_app/database/responses/team_details_response.dart';
import 'package:atl_app/database/responses/teams_response.dart';
import 'package:atl_app/database/services/read/team_service_read.dart';
import 'package:atl_app/database/services/write/team_service_write.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:dio/dio.dart';

class TeamService {
  static final String apiUrl = "/teams";
  static final Dio dio = ApiClient.instance;

  static final TeamServiceRead _read = TeamServiceRead(apiUrl: apiUrl, dio: dio);
  static final TeamServiceWrite _write = TeamServiceWrite(apiUrl: apiUrl, dio: dio);

  static Future<TeamsResponse> getTeamsScreen(SportCategory sportCategory) async =>
      await _read.getTeamsScreen(sportCategory);

  static Future<PlayersInTeamResponse> getPlayersInTeam(double teamId) async =>
      await _read.getPlayersInTeam(teamId);

  static Future<AbstractTeamResponse> getAbstractTeamScreen(double teamId) async =>
      await _read.getAbstractTeamScreen(teamId);

  static Future<PayParticipationResponse> getPayParticipationScreen(
    double teamId,
  ) async => await _read.getPayParticipationScreen(teamId);

  static Future<PlayerRequestsResponse> getTeamRequestsScreen(double teamId) async =>
      await _read.getTeamRequestsScreen(teamId);

  static Future<TeamDetailsResponse> getTeamDetailsScreen(double teamId) async =>
      await _read.getTeamDetailsScreen(teamId);

  static Future<bool> checkTeamNameInCategoryExists(
    SportCategory sportCategory,
    String teamName,
  ) async => await _read.checkTeamNameInCategoryExists(sportCategory, teamName);

  static Future<List<TournamentParticipation>> getNotPaidTeamParticipations(
    double teamId,
  ) async => await _read.getNotPaidTeamParticipations(teamId);

  static Future<Team> getTeamById(double teamId) async =>
      await _read.getTeamById(teamId);

  static Future<Team> promoteOrDemotePlayer(double teamId, double playerId) async =>
      await _write.promoteOrDemotePlayer(teamId, playerId);

  static Future<Team> createTeam(Team team) async => await _write.createTeam(team);

  static Future<void> acceptTeamRequest({
    required double teamId,
    double? playerId,
    bool? acceptAll,
  }) async => await _write.acceptTeamRequest(
    teamId: teamId,
    playerId: playerId,
    acceptAll: acceptAll,
  );

  static Future<void> rejectTeamRequest({
    required double teamId,
    double? playerId,
    bool? rejectAll,
  }) async => await _write.rejectTeamRequest(
    teamId: teamId,
    playerId: playerId,
    rejectAll: rejectAll,
  );

  static Future<TeamRequest> sendTeamRequest(double teamId) async =>
      await _write.sendTeamRequest(teamId);

  static Future<void> cancelTeamRequest(double teamId) async =>
      await _write.cancelTeamRequest(teamId);

  static Future<void> leaveTeam(double teamId) async => await _write.leaveTeam(teamId);

  static Future<void> expelPlayer(double teamId, double playerId) async =>
      await _write.expelPlayer(teamId, playerId);

  static Future<void> deleteTeam(double teamId) async =>
      await _write.deleteTeam(teamId);
}
