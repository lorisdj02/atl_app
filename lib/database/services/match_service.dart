import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/responses/available_matches_response.dart';
import 'package:atl_app/database/responses/past_assigned_matches_response.dart';
import 'package:atl_app/database/services/read/match_service_read.dart';
import 'package:atl_app/database/services/write/match_service_write.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:atl_app/models/football_match_event.dart';
import 'package:dio/dio.dart';

class MatchService {
  static final String apiUrl = "/matches";
  static final Dio dio = ApiClient.instance;

  static final MatchServiceRead _read = MatchServiceRead(apiUrl, dio);
  static final MatchServiceWrite _write = MatchServiceWrite(apiUrl, dio);

  static Future<AvailableMatchesResponse> getAvailableMatchesScreen(
    SportCategory sportCategory, {
    double? cityId,
    double? sportId,
  }) async => await _read.getAvailableMatchesScreen(
    sportCategory,
    cityId: cityId,
    sportId: sportId,
  );

  static Future<PastAssignedMatchesResponse> getPastAssignedMatchesScreen(
    SportCategory sportCategory,
  ) async => await _read.getPastAssignedMatchesScreen(sportCategory);

  static Future<dynamic> getMatchScreen(
    double matchId,
    SportCategory sportCategory,
  ) async => await _read.getMatchScreen(matchId, sportCategory);

  static Future<dynamic> getMatchEvents(
    double matchId,
    SportCategory sportCategory,
  ) async => await _read.getMatchEvents(matchId, sportCategory);

  static Future<double> retireFromMatch(double matchId) async =>
      await _write.retireFromMatch(matchId);

  static Future<double> addMotmToMatch(double matchId, double playerId) async =>
      await _write.addMotmToMatch(matchId, playerId);

  static Future<double> insertRefereeAssignment(
    double matchId,
    String refereeRoleName,
  ) async => await _write.insertRefereeAssignment(matchId, refereeRoleName);

  static Future<FootballMatchEvent> insertFootballMatchEvent(
    double matchId,
    FootballMatchEvent event,
  ) async => await _write.insertFootballMatchEvent(matchId, event);

  static Future<void> deleteFootballMatchEvent(
    double matchId,
    double eventId,
  ) async => await _write.deleteFootballMatchEvent(matchId, eventId);
}
