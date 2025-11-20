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
      tournamentId: '7',
      teamId: '2',
    ),
    TournamentPartecipation(
      tournamentId: '7',
      teamId: '3',
    ),
  ];

  @override
  List<TournamentPartecipation> get mockData => _mockdata;

  Future<List<TournamentPartecipation>> getByTournamentId(String tournamentId) {
    if(AppConfig.isDebug){
      return Future.value(_mockdata.where((partecipation) => partecipation.tournamentId == tournamentId).toList());
    }
    else{
      throw UnimplementedError();
    }
  }

  Future<List<TournamentPartecipation>> getByTeamId(String teamId) {
    if(AppConfig.isDebug){
      return Future.value(_mockdata.where((partecipation) => partecipation.teamId == teamId).toList());
    }
    else{
      throw UnimplementedError();
    }
  }
}