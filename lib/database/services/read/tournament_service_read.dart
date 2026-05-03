import 'package:atl_app/database/responses/all_tournaments_response.dart';
import 'package:atl_app/database/responses/apply_tournament_filters_response.dart';
import 'package:atl_app/database/responses/callups_response.dart';
import 'package:atl_app/database/responses/football_tournament_response.dart';
import 'package:atl_app/database/responses/schedule_match_response.dart';
import 'package:atl_app/database/responses/tournament_details_response.dart';
import 'package:atl_app/database/responses/tournament_parameters_response.dart';
import 'package:atl_app/database/responses/tournament_summary_response.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:dio/dio.dart';

class TournamentServiceRead {
  final String apiUrl;
  final Dio dio;

  TournamentServiceRead({required this.apiUrl, required this.dio});

  Future<AllTournamentsResponse> getAllTournamentsScreen(
    SportCategory currentSport,
  ) async {
    final response = await dio.get("$apiUrl/${currentSport.apiName}/all-tournaments");
    return AllTournamentsResponse.fromJson(response.data);
  }

  Future<TournamentDetailsResponse> getTournamentDetailsScreen(
    double tournamentId,
  ) async {
    final response = await dio.get("$apiUrl/tournament/${tournamentId.toStringAsFixed(0)}/details");
    return TournamentDetailsResponse.fromJson(response.data);
  }

  Future<List<Player>> getViewCallupsScreen(double tournamentId) async {
    final response = await dio.get(
      "$apiUrl/tournament/${tournamentId.toStringAsFixed(0)}/view-callups",
    );
    return (response.data as List<dynamic>)
        .map(
          (playerJson) => Player.fromJson(playerJson as Map<String, dynamic>),
        )
        .toList();
  }

  Future<CallupsResponse> getCallupsScreen(double tournamentId) async {
    final response = await dio.get("$apiUrl/tournament/${tournamentId.toStringAsFixed(0)}/callups");
    return CallupsResponse.fromJson(response.data);
  }

  Future<dynamic> getTournamentScreen(
    double tournamentId,
    SportCategory sportCategory,
  ) async {
    final response = await dio.get("$apiUrl/tournament/${tournamentId.toStringAsFixed(0)}");
    switch (sportCategory) {
      case SportCategory.football:
        return FootballTournamentResponse.fromJson(response.data);
    }
  }

  Future<ApplyTournamentFiltersResponse> applyTournamentFilters({
    required SportCategory sportCategory,
    double? cityId,
    int? minTeams,
    int? maxTeams,
    double? minFee,
    double? maxFee,
    double? minPrize,
    double? maxPrize,
    String? name,
  }) async {
    final response = await dio.get(
      "$apiUrl/tournaments/apply-filters",
      queryParameters: {
        "sportCategory": sportCategory.toString().split('.').last,
        "cityId": cityId,
        "minTeams": minTeams,
        "maxTeams": maxTeams,
        "minFee": minFee,
        "maxFee": maxFee,
        "minPrize": minPrize,
        "maxPrize": maxPrize,
        "name": name,
      },
    );
    return ApplyTournamentFiltersResponse.fromJson(response.data);
  }

  Future<TournamentParametersResponse> calculateTournamentParameters(
    Tournament dummyTournament,
  ) async {
    final response = await dio.post(
      "$apiUrl/calculate-tournament-parameters",
      data: dummyTournament.toJson(),
    );
    return TournamentParametersResponse.fromJson(response.data);
  }

  Future<Tournament> getTournamentById(double tournamentId) async {
    final response = await dio.get("$apiUrl/search-by-id/${tournamentId.toStringAsFixed(0)}");
    return Tournament.fromJson(response.data);
  }

  Future<ScheduleMatchResponse> getScheduleData(double tournamentId) async {
    final response = await dio.get("$apiUrl/tournament/${tournamentId.toStringAsFixed(0)}/schedule-data");
    return ScheduleMatchResponse.fromJson(response.data);
  }

  Future<TournamentSummaryResponse> getTournamentSummary(double tournamentId) async {
    final response = await dio.get("$apiUrl/tournament/${tournamentId.toStringAsFixed(0)}/summary");
    return TournamentSummaryResponse.fromJson(response.data);
  }
}
