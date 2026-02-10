import 'package:atl_app/config/app_config.dart';
import 'base_repository.dart';
import '../../models/tournament_participation.dart';

class TournamentParticipationRepository
    extends BaseRepository<TournamentParticipation> {

  @override
  String get endpoint => 'tournament_participations';

  @override
  TournamentParticipation fromJson(Map<String, dynamic> json) =>
      TournamentParticipation.fromJson(json);
  @override
  Map<String, dynamic> toJson(TournamentParticipation item) => item.toJson();

  List<TournamentParticipation> _mockData = [
    TournamentParticipation(tournamentId: 7, teamId: 2, toPay: 0.0),
    TournamentParticipation(tournamentId: 7, teamId: 3, toPay: 0.0),
    TournamentParticipation(tournamentId: 8, teamId: 1, toPay: 0),
    TournamentParticipation(tournamentId: 8, teamId: 5, toPay: 0),
    TournamentParticipation(tournamentId: 8, teamId: 6, toPay: 0),
    TournamentParticipation(tournamentId: 8, teamId: 7, toPay: 0),
    TournamentParticipation(tournamentId: 8, teamId: 8, toPay: 0),
    TournamentParticipation(tournamentId: 8, teamId: 9, toPay: 0),
    TournamentParticipation(tournamentId: 8, teamId: 10, toPay: 0),
    TournamentParticipation(tournamentId: 8, teamId: 11, toPay: 0),
    
    TournamentParticipation(tournamentId: 9, teamId: 5, toPay: 0),
    TournamentParticipation(tournamentId: 9, teamId: 6, toPay: 0),
    TournamentParticipation(tournamentId: 9, teamId: 7, toPay: 0),
    TournamentParticipation(tournamentId: 9, teamId: 8, toPay: 0),
    TournamentParticipation(tournamentId: 9, teamId: 9, toPay: 0),
    TournamentParticipation(tournamentId: 9, teamId: 10, toPay: 0),
    TournamentParticipation(tournamentId: 9, teamId: 11, toPay: 0),
  ];

  @override
  List<TournamentParticipation> get mockData => _mockData;
  Future<Map<int, double>> getRefundPerTeamsInTournament(
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      return Map.fromEntries(
        _mockData
            .where(
              (participation) =>
                  participation.tournamentId == tournamentId &&
                  (participation.toPay ?? 0) > 0,
            )
            .map((participation) => MapEntry(participation.teamId, participation.toPay!)),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> removeRefundedTeams(int tournamentId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere(
        (participation) =>
            participation.tournamentId == tournamentId &&
            (participation.toPay ?? 0) > 0,
      );
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<int>> getTeamIdsByTournamentId(int tournamentId) async {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where(
              (participation) => participation.tournamentId == tournamentId,
            )
            .map((participation) => participation.teamId)
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<TournamentParticipation>> getByTournamentId(int tournamentId) {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where(
              (participation) => participation.tournamentId == tournamentId,
            )
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<TournamentParticipation>> getByTeamId(int teamId) {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where((participation) => participation.teamId == teamId)
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<TournamentParticipation>> getPaidByTournamentId(
    int tournamentId,
  ) {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where(
              (partecipation) =>
                  partecipation.tournamentId == tournamentId &&
                  (partecipation.toPay ?? 0) <= 0,
            )
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<TournamentParticipation>> getPaidByTeamId(int teamId) {
    if (AppConfig.isDebug) {
      return Future.value(
        _mockData
            .where(
              (participation) =>
                  participation.teamId == teamId &&
                  (participation.toPay ?? 0) <= 0,
            )
            .toList(),
      );
    } else {
      throw UnimplementedError();
    }
  }

  Future<TournamentParticipation?> getByTournamentAndTeam(
    int tournamentId,
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        final partecipation = _mockData.firstWhere(
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

  Future<bool> addParticipation(
    int tournamentId,
    int teamId,
    double toPay,
  ) async {
    TournamentParticipation newParticipation = TournamentParticipation(
      tournamentId: tournamentId,
      teamId: teamId,
      toPay: toPay,
    );
    if (AppConfig.isDebug) {
      _mockData.add(newParticipation);
      return Future.value(true);
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteParticipation(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      _mockData.removeWhere(
        (participation) =>
            participation.tournamentId == tournamentId &&
            participation.teamId == teamId,
      );
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updatePayment(int tournamentId, int teamId, double toPay) async {
    if (AppConfig.isDebug) {
      for (var partecipation in _mockData) {
        if (partecipation.tournamentId == tournamentId &&
            partecipation.teamId == teamId) {
          partecipation.toPay = toPay;
          break;
        }
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
