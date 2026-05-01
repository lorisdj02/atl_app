import 'package:atl_app/database/responses/available_matches_response.dart';
import 'package:atl_app/database/responses/football_match_events_response.dart';
import 'package:atl_app/database/responses/football_match_response.dart';
import 'package:atl_app/database/responses/past_assigned_matches_response.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:dio/dio.dart';

class MatchServiceRead {
  final String apiUrl;
  final Dio dio;

  MatchServiceRead(this.apiUrl, this.dio);

  Future<AvailableMatchesResponse> getAvailableMatchesScreen(
    SportCategory sportCategory,
    {
      double? cityId,
      double? sportId,
    }
  ) async {
    //TODO: Aggiungere parametri per filtrare per città e sport
    final response = await dio.get(
      "$apiUrl/${sportCategory.apiName}/referee/available-matches",
      queryParameters: {
        if (cityId != null) 'cityId': cityId,
        if (sportId != null) 'sportId': sportId,
      },
    );
    return AvailableMatchesResponse.fromJson(response.data);
  }

  Future<PastAssignedMatchesResponse> getPastAssignedMatchesScreen(
    SportCategory sportCategory,
  ) async {
    final response = await dio.get(
      "$apiUrl/${sportCategory.apiName}/referee/past-assigned-matches",
    );
    return PastAssignedMatchesResponse.fromJson(response.data);
  }

  Future<dynamic> getMatchScreen(
    double matchId,
    SportCategory sportCategory,
  ) async {
    final Response response = await dio.get("$apiUrl/match/${matchId.toStringAsFixed(0)}");
    switch (sportCategory) {
      case SportCategory.football:
        return FootballMatchResponse.fromJson(response.data);
      //TODO: Aggiungere case per altri sport
    }
  }

  Future<dynamic> getMatchEvents(
    double matchId,
    SportCategory sportCategory,
  ) async {
    final Response response = await dio.get("$apiUrl/match/${matchId.toStringAsFixed(0)}/events");
    switch (sportCategory) {
      case SportCategory.football:
        return FootballMatchEventsResponse.fromJson(response.data);
      //TODO: Aggiungere case per altri sport
    }
  }
}
