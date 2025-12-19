import 'package:atl_app/config/app_config.dart';

import 'base_repository.dart';
import '../../models/tournament_partecipation.dart';
import '../api_client.dart';
import 'package:dio/dio.dart';

class TournamentPartecipationRepository extends BaseRepository<TournamentPartecipation> {
  final Dio _dio = ApiClient.instance;

  @override
  String get endpoint => 'tournament_partecipations';

  @override
  TournamentPartecipation fromJson(Map<String, dynamic> json) => TournamentPartecipation.fromJson(json);

  @override
  Map<String, dynamic> toJson(TournamentPartecipation item) => item.toJson();

  List<TournamentPartecipation> _mockdata = [
    TournamentPartecipation(
      tournamentId: 7,
      teamId: 2,
      toPay: 200.0,
    ),
    TournamentPartecipation(
      tournamentId: 7,
      teamId: 3,
      toPay: 150.0,
    ),
    TournamentPartecipation(
      tournamentId: 8,
      teamId: 1,
      toPay: 0,
    ),
    TournamentPartecipation(
      tournamentId: 8,
      teamId: 5,
      toPay: 0,
    ),
    TournamentPartecipation(
      tournamentId: 8,
      teamId: 6,
      toPay: 0,
    ),
    TournamentPartecipation(
      tournamentId: 8,
      teamId: 7,
      toPay: 0,
    ),
     TournamentPartecipation(
      tournamentId: 8,
      teamId: 8,
      toPay: 0,
    ),
     TournamentPartecipation(
      tournamentId: 8,
      teamId: 9,
      toPay: 0,
    ),
     TournamentPartecipation(
      tournamentId: 8,
      teamId: 10,
      toPay: 0,
    ),
     TournamentPartecipation(
      tournamentId: 8,
      teamId: 11,
      toPay: 0,
    ),
  ];

  @override
  List<TournamentPartecipation> get mockData => _mockdata;

  Future<List<TournamentPartecipation>> getByTournamentId(int tournamentId) {
    if(AppConfig.isDebug){
      return Future.value(_mockdata.where((partecipation) => partecipation.tournamentId == tournamentId).toList());
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<List<TournamentPartecipation>> getByTeamId(int teamId) {
    if(AppConfig.isDebug){
      return Future.value(_mockdata.where((partecipation) => partecipation.teamId == teamId).toList());
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<TournamentPartecipation?> getByTournamentAndTeam(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      try {
        final partecipation = _mockdata.firstWhere(
          (partecipation) =>
              partecipation.tournamentId == tournamentId &&
              partecipation.teamId == teamId,
        );
        return Future.value(partecipation);
      } catch (e) {
        return Future.value(null);
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addPartecipation(int tournamentId, int teamId, double toPay) async {
    TournamentPartecipation newPartecipation = TournamentPartecipation(
      tournamentId: tournamentId,
      teamId: teamId,
      toPay: toPay,
    );
    if(AppConfig.isDebug){
      _mockdata.add(newPartecipation);
      return Future.value(true);
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<void> deletePartecipation(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      _mockdata.removeWhere((partecipation) =>
          partecipation.tournamentId == tournamentId &&
          partecipation.teamId == teamId);
      return Future.value();
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> updatePayment(int tournamentId, int teamId, double toPay) async {
    if (AppConfig.isDebug) {
      for (var partecipation in _mockdata) {
        if (partecipation.tournamentId == tournamentId &&
            partecipation.teamId == teamId) {
          partecipation.toPay = toPay;
          break;
        }
      }
      return Future.value();
    } else {
      throw UnimplementedError();
    }
  }
}