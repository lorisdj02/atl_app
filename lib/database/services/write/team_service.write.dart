import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:dio/dio.dart';

class TeamServiceWrite {
  final String apiUrl = "/teams";
  final Dio dio = ApiClient.instance;

  Future<Team> promoteOrDemotePlayer(double teamId, double playerId) async {
    final response = await dio.patch(
      "$apiUrl/team/$teamId/promote-or-demote/$playerId",
    );
    return Team.fromJson(response.data);
  }

  Future<Team> createTeam(Team team) async {
    final response = await dio.post(apiUrl, data: team.toJson());
    return Team.fromJson(response.data);
  }

  Future<void> acceptTeamRequest({
    required double teamId,
    double? playerId,
    bool? acceptAll,
  }) async {
    await dio.patch(
      "$apiUrl/team/$teamId/manage/requests/accept",
      queryParameters: {"playerId": playerId, "acceptAll": acceptAll},
    );
  }

  Future<void> rejectTeamRequest({
    required double teamId,
    double? playerId,
    bool? rejectAll,
  }) async {
    await dio.patch(
      "$apiUrl/team/$teamId/manage/requests/reject",
      queryParameters: {"playerId": playerId, "rejectAll": rejectAll},
    );
  }

  Future<TeamRequest> sendTeamRequest(double teamId) async {
    final response = await dio.post("$apiUrl/team/$teamId/requests/send");
    return TeamRequest.fromJson(response.data);
  }

  Future<void> cancelTeamRequest(double teamId) async {
    await dio.delete("$apiUrl/team/$teamId/requests/cancel");
  }

  Future<void> leaveTeam(double teamId) async {
    await dio.delete("$apiUrl/team/$teamId/leave");
  }

  Future<void> expelPlayer(double teamId, double playerId) async {
    await dio.delete("$apiUrl/team/$teamId/expel/$playerId");
  }

  //viene fatto con leaveTeam se il capitano lascia la squadra VUOTA
  Future<void> deleteTeam(double teamId) async {
    await dio.delete("$apiUrl/team/$teamId/delete");
  }
}
