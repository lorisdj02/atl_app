import 'package:atl_app/models/callup.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

/// Repository per la gestione delle convocazioni
class CallUpsRepository extends BaseRepository<Callup> {
  static final CallUpsRepository _instance = CallUpsRepository._internal();
  factory CallUpsRepository() => _instance;
  CallUpsRepository._internal();

  @override
  String get endpoint => 'callups';

  @override
  Callup fromJson(Map<String, dynamic> json) => Callup.fromJson(json);

  @override
  Map<String, dynamic> toJson(Callup item) => item.toJson();

  final List<Callup> _mockData = [
    Callup(tournamentId: 8, playerId: 1, teamId: 1),
  ];

  @override
  List<Callup> get mockData => _mockData;

  /// Ottieni convocazioni per torneo
  Future<List<Callup>> getByTournament(int tournamentId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where((callup) => callup.tournamentId == tournamentId)
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isPlayerInCallup(int playerId, int tournamentId) async {
    if (AppConfig.isDebug) {
      final callups = _mockData.where(
        (callup) =>
            callup.playerId == playerId &&
            callup.tournamentId == tournamentId,
      );
      return callups.isNotEmpty;
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni convocazioni per team
  Future<List<Callup>> getByTeam(int teamId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData.where((callup) => callup.teamId == teamId).toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni convocazione specifica per torneo e team
  Future<List<Callup>> getByTournamentAndTeam(
    int tournamentId,
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where(
              (callup) =>
                  callup.tournamentId == tournamentId &&
                  callup.teamId == teamId,
            )
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<int>> getPlayersInTeamInTournament(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      final callups = _mockData.where(
        (callup) =>
            callup.tournamentId == tournamentId && callup.teamId == teamId,
      );
      return callups.map((c) => c.playerId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Callup>> getByPlayerAndTeam(int playerId, int teamId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where(
              (callup) =>
                  callup.playerId == playerId && callup.teamId == teamId,
            )
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> addCallUp(int tournamentId, int teamId, int playerId) async {
    Callup newCallUp = Callup(
      tournamentId: tournamentId,
      teamId: teamId,
      playerId: playerId,
    );

    if (AppConfig.isDebug) {
      _mockData.add(newCallUp);
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteCallUps(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere(
        (c) => c.tournamentId == tournamentId && c.teamId == teamId,
      );
      print(
        '🔧 [DEBUG] Deleted callups for Tournament $tournamentId, Team $teamId',
      );
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

  Future<bool> deleteByTournamentAndTeam(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere(
        (c) => c.tournamentId == tournamentId && c.teamId == teamId,
      );
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteByPlayerAndTeam(int playerId, int teamId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere(
        (c) => c.playerId == playerId && c.teamId == teamId,
      );
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
