import 'package:atl_app/models/callups.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

/// Repository per la gestione delle convocazioni
class CallUpsRepository extends BaseRepository<CallUps> {
  static final CallUpsRepository _instance = CallUpsRepository._internal();
  factory CallUpsRepository() => _instance;
  CallUpsRepository._internal();

  @override
  String get endpoint => 'callups';

  @override
  CallUps fromJson(Map<String, dynamic> json) => CallUps.fromJson(json);

  @override
  Map<String, dynamic> toJson(CallUps item) => item.toJson();

  final List<CallUps> _mockData = [
    CallUps(tournamentId: 7, playerId: 1, teamId: 1),
  ];

  @override
  List<CallUps> get mockData => _mockData;

  /// Ottieni convocazioni per torneo
  Future<List<CallUps>> getByTournament(int tournamentId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData.where((callup) => callup.tournamentId == tournamentId).toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni convocazioni per team
  Future<List<CallUps>> getByTeam(int teamId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData.where((callup) => callup.teamId == teamId).toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni convocazione specifica per torneo e team
  Future<List<CallUps>> getByTournamentAndTeam(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData.where((callup) =>
            callup.tournamentId == tournamentId && callup.teamId == teamId).toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<CallUps>> getByPlayerAndTeam(int playerId, int teamId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData.where((callup) =>
            callup.playerId == playerId && callup.teamId == teamId).toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> addCallUp(CallUps callUp) async {
    if (AppConfig.isDebug) {
      _mockData.add(callUp);
      print('🔧 [DEBUG] Added callup: Tournament ${callUp.tournamentId}, Team ${callUp.teamId}, Player ${callUp.playerId}');
      return Future.value();
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteCallUp(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere((c) =>
          c.tournamentId == tournamentId && c.teamId == teamId);
      print('🔧 [DEBUG] Deleted callups for Tournament $tournamentId, Team $teamId');
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  /// Verifica se esistono convocazioni per un torneo e team
  Future<bool> hasCallUps(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      final callups = await getByTournamentAndTeam(tournamentId, teamId);
      return callups.isNotEmpty;
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> deleteByTournamentAndTeam(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere((c) =>
          c.tournamentId == tournamentId && c.teamId == teamId);
      print('🔧 [DEBUG] Deleted callups for Tournament $tournamentId, Team $teamId');
      return Future.value();
    } else {
      throw UnimplementedError();
    }
  }
}
