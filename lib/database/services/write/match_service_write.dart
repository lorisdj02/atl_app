import 'package:atl_app/models/football_match_event.dart';
import 'package:dio/dio.dart';

class MatchServiceWrite {
  final String apiUrl;
  final Dio dio;

  MatchServiceWrite(this.apiUrl, this.dio);

  Future<double> retireFromMatch(double matchId) async {
    final response = await dio.patch("$apiUrl/match/$matchId/retire");
    return response.data;
  }

  Future<double> addMotmToMatch(double matchId, double playerId) async {
    final response = await dio.patch(
      "$apiUrl/match/$matchId/add-motm/$playerId",
    );
    return response.data;
  }

  Future<double> insertRefereeAssignment(
    double matchId,
    String refereeRoleName,
  ) async {
    final response = await dio.post(
      "$apiUrl/match/$matchId/insert-referee-assignment/$refereeRoleName",
    );
    return response.data;
  }

  Future<FootballMatchEvent> insertFootballMatchEvent(
    double matchId,
    FootballMatchEvent event,
  ) async {
    final response = await dio.post(
      "$apiUrl/match/$matchId/football-event/insert",
      data: event.toJson(),
    );
    return FootballMatchEvent.fromJson(response.data);
  }

  Future<void> deleteFootballMatchEvent(double matchId, double eventId) async {
    await dio.delete("$apiUrl/match/$matchId/football-event/$eventId/delete");
  }
}
