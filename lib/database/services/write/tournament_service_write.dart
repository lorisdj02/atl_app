import 'package:atl_app/database/requests/confirm_callups_request.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:dio/dio.dart';

class TournamentServiceWrite {
  final String apiUrl;
  final Dio dio;

  TournamentServiceWrite({required this.apiUrl, required this.dio});

  Future<Tournament> createTournament(Tournament tournament) async {
    final response = await dio.post(
      "$apiUrl/create",
      data: tournament.toJson(),
    );
    return Tournament.fromJson(response.data);
  }

  Future<TournamentParticipation> confirmCallups(
    double tournamentId,
    ConfirmCallupsRequest request,
  ) async {
    final response = await dio.post(
      "$apiUrl/tournament/$tournamentId/confirm-callups",
      data: request.toJson(),
    );
    return TournamentParticipation.fromJson(response.data);
  }

  Future<void> deleteCallups(double tournamentId, double teamId) async {
    await dio.delete("$apiUrl/tournament/$tournamentId/team/$teamId/delete-callups");
  }

  Future<void> goToCoordinatorNextPhase(double tournamentId) async {
    await dio.patch("$apiUrl/tournament/$tournamentId/go-next-phase");
  }

  Future<void> startTournament(double tournamentId) async {
    await dio.patch("$apiUrl/tournament/$tournamentId/start");
  }

  Future<void> toggleFavoriteStatus(double tournamentId) async {
    await dio.patch("$apiUrl/tournament/$tournamentId/toggle-favorite-status");
  }
}
