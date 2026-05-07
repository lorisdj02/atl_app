import 'package:atl_app/database/api_client.dart';
import 'package:atl_app/database/requests/assign_tournament_prizes_request.dart';
import 'package:atl_app/database/requests/confirm_callups_request.dart';
import 'package:atl_app/database/responses/all_tournaments_response.dart';
import 'package:atl_app/database/responses/apply_tournament_filters_response.dart';
import 'package:atl_app/database/responses/assign_football_prizes_response.dart';
import 'package:atl_app/database/responses/callups_response.dart';
import 'package:atl_app/database/responses/schedule_match_response.dart';
import 'package:atl_app/database/responses/tournament_details_response.dart';
import 'package:atl_app/database/responses/tournament_parameters_response.dart';
import 'package:atl_app/database/responses/tournament_summary_response.dart';
import 'package:atl_app/database/services/read/tournament_service_read.dart';
import 'package:atl_app/database/services/write/tournament_service_write.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:dio/dio.dart';

class TournamentService {
  static final String apiUrl = "/tournaments";
  static final Dio dio = ApiClient.instance;

  static final TournamentServiceRead _read = TournamentServiceRead(
    apiUrl: apiUrl,
    dio: dio,
  );
  static final TournamentServiceWrite _write = TournamentServiceWrite(
    apiUrl: apiUrl,
    dio: dio,
  );

  static Future<AllTournamentsResponse> getAllTournamentsScreen(
    SportCategory currentSport,
  ) async => await _read.getAllTournamentsScreen(currentSport);

  static Future<TournamentDetailsResponse> getTournamentDetailsScreen(
    double tournamentId,
  ) async => await _read.getTournamentDetailsScreen(tournamentId);

  static Future<List<Player>> getViewCallupsScreen(double tournamentId) async =>
      await _read.getViewCallupsScreen(tournamentId);

  static Future<CallupsResponse> getCallupsScreen(double tournamentId) async =>
      await _read.getCallupsScreen(tournamentId);

  static Future<dynamic> getTournamentScreen(
    double tournamentId,
    SportCategory sportCategory,
  ) async => await _read.getTournamentScreen(tournamentId, sportCategory);

  static Future<ApplyTournamentFiltersResponse> applyTournamentFilters({
    required SportCategory sportCategory,
    double? cityId,
    int? minTeams,
    int? maxTeams,
    double? minFee,
    double? maxFee,
    double? minPrize,
    double? maxPrize,
    String? name,
  }) async => await _read.applyTournamentFilters(
    sportCategory: sportCategory,
    cityId: cityId,
    minTeams: minTeams,
    maxTeams: maxTeams,
    minFee: minFee,
    maxFee: maxFee,
    minPrize: minPrize,
    maxPrize: maxPrize,
    name: name,
  );

  static Future<TournamentParametersResponse> calculateTournamentParameters(
    Tournament dummyTournament,
  ) async => await _read.calculateTournamentParameters(dummyTournament);

  static Future<Tournament> getTournamentById(double tournamentId) async =>
      await _read.getTournamentById(tournamentId);

  static Future<ScheduleMatchResponse> getScheduleData(
    double tournamentId,
  ) async => await _read.getScheduleData(tournamentId);

  static Future<TournamentSummaryResponse> getTournamentSummary(
    double tournamentId,
  ) async => await _read.getTournamentSummary(tournamentId);

  static Future<AssignFootballPrizesResponse> getAssignFootballPrizesScreen(
    double tournamentId,
  ) async => await _read.getAssignFootballPrizesScreen(tournamentId);

  static Future<Tournament> createTournament(Tournament tournament) async =>
      await _write.createTournament(tournament);

  static Future<TournamentParticipation> confirmCallups(
    double tournamentId,
    ConfirmCallupsRequest request,
  ) async => await _write.confirmCallups(tournamentId, request);

  static Future<void> deleteCallups(double tournamentId, double teamId) async =>
      await _write.deleteCallups(tournamentId, teamId);

  static Future<void> goToCoordinatorNextPhase(double tournamentId) async =>
      await _write.goToCoordinatorNextPhase(tournamentId);

  static Future<void> startTournament(double tournamentId) async =>
      await _write.startTournament(tournamentId);

  static Future<void> toggleFavoriteStatus(double tournamentId) async =>
      await _write.toggleFavoriteStatus(tournamentId);

  static Future<void> assignTournamentPrizes(
    double tournamentId,
    AssignTournamentPrizesRequest request,
  ) async => await _write.assignTournamentPrizes(tournamentId, request);
}
