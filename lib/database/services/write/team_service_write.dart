import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:dio/dio.dart';

class TeamServiceWrite {
  final String apiUrl;
  final Dio dio;

  TeamServiceWrite({required this.apiUrl, required this.dio});

  Future<Team> promoteOrDemotePlayer(double teamId, double playerId) async {
    final response = await dio.patch(
      "$apiUrl/team/${teamId.toStringAsFixed(0)}/promote-or-demote/${playerId.toStringAsFixed(0)}",
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
      "$apiUrl/team/${teamId.toStringAsFixed(0)}/manage/requests/accept",
      queryParameters: {"playerId": playerId, "acceptAll": acceptAll},
    );
  }

  Future<void> rejectTeamRequest({
    required double teamId,
    double? playerId,
    bool? rejectAll,
  }) async {
    await dio.patch(
      "$apiUrl/team/${teamId.toStringAsFixed(0)}/manage/requests/reject",
      queryParameters: {"playerId": playerId, "rejectAll": rejectAll},
    );
  }

  Future<TeamRequest> sendTeamRequest(double teamId) async {
    final response = await dio.post("$apiUrl/team/${teamId.toStringAsFixed(0)}/requests/send");
    return TeamRequest.fromJson(response.data);
  }

  Future<void> cancelTeamRequest(double teamId) async {
    await dio.delete("$apiUrl/team/${teamId.toStringAsFixed(0)}/requests/cancel");
  }

  Future<void> leaveTeam(double teamId) async {
    await dio.delete("$apiUrl/team/${teamId.toStringAsFixed(0)}/leave");
  }

  Future<void> expelPlayer(double teamId, double playerId) async {
    await dio.delete("$apiUrl/team/${teamId.toStringAsFixed(0)}/expel/${playerId.toStringAsFixed(0)}");
  }

  //viene fatto con leaveTeam se il capitano lascia la squadra VUOTA
  Future<void> deleteTeam(double teamId) async {
    await dio.delete("$apiUrl/team/${teamId.toStringAsFixed(0)}/delete");
  }
}
