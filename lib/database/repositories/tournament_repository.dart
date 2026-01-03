import 'package:atl_app/config/app_config.dart';
import 'package:atl_app/models/sport_category.dart';

import '../db_controller.dart';
import '../../models/tournament.dart';
import 'base_repository.dart';
import '../../models/field.dart';
import '../../models/coordinator.dart';
import '../../models/favorite_tournaments.dart';

class TournamentRepository extends BaseRepository<Tournament> {
  @override
  String get endpoint => 'tournaments';

  @override
  Tournament fromJson(Map<String, dynamic> json) => Tournament.fromJson(json);

  @override
  Map<String, dynamic> toJson(Tournament item) => item.toJson();

  @override
  List<Tournament> get mockData => _mockData;

  List<Tournament> _mockData = [
    // Tornei terminati (per palmares)
    Tournament(
      id: 1,
      name: 'Tournament ATL',
      description: 'First edition of ATL Tournament',
      coordinatorId: 1,
      fieldId: 1,
      cityId: 1,
      sportId: 1,
      startDate: DateTime(2024, 1, 15),
      numTeams: 16,
      paidTeams: 16,
      numGroups: 4,
      qualified: 8,
      payCoordinator: 100,
      status: TournamentStatus.finished,
      fee: 50.0,
      prize1: 1000.0,
      prize2: 500.0,
      isATL: true,
    ),
    Tournament(
      id: 2,
      name: 'Tournament 1',
      description: 'Summer championship',
      coordinatorId: 1,
      fieldId: 2,
      cityId: 2,
      sportId: 1,
      startDate: DateTime(2024, 3, 1),
      numTeams: 16,
      paidTeams: 16,
      numGroups: 4,
      qualified: 8,
      payCoordinator: 100,
      status: TournamentStatus.finished,
      fee: 50.0,
      prize1: 1000.0,
      prize2: 500.0,
    ),
    Tournament(
      id: 3,
      name: 'Tournament 1',
      description: 'Winter championship',
      coordinatorId: 1,
      fieldId: 1,
      cityId: 1,
      sportId: 1,
      startDate: DateTime(2024, 6, 1),
      numTeams: 32,
      paidTeams: 32,
      numGroups: 8,
      qualified: 16,
      payCoordinator: 150,
      status: TournamentStatus.finished,
      fee: 60.0,
      prize1: 2000.0,
      prize2: 1000.0,
    ),
    // Torneo attivo esistente
    Tournament(
      id: 4,
      name: 'Active Summer League',
      description: 'Current ongoing tournament',
      coordinatorId: 1,
      fieldId: 1,
      cityId: 1,
      sportId: 1,
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      numTeams: 16,
      paidTeams: 12,
      numGroups: 4,
      qualified: 8,
      payCoordinator: 100,
      status: TournamentStatus.finished,
      fee: 55.0,
      prize1: 1500.0,
      prize2: 750.0,
      phase: TournamentPhase.group,
    ),
    Tournament(
      id: 5,
      name: 'Upcoming Autumn Cup',
      description: 'Register now for the Autumn Cup',
      coordinatorId: 1,
      fieldId: 2,
      cityId: 2,
      sportId: 1,
      startDate: DateTime.now().add(const Duration(days: 20)),
      numTeams: 24,
      paidTeams: 24,
      numGroups: 6,
      qualified: 12,
      payCoordinator: 120,
      status: TournamentStatus.finished,
      fee: 65.0,
      prize1: 2500.0,
      prize2: 1200.0,
      round2FinalStage: true,
    ),
    Tournament(
      id: 6,
      name: 'Spring Championship',
      description: 'Join the Spring Championship now!',
      coordinatorId: 2,
      fieldId: 1,
      cityId: 1,
      sportId: 1,
      startDate: DateTime.now().add(const Duration(days: 30)),
      numTeams: 20,
      paidTeams: 15,
      numGroups: 5,
      qualified: 10,
      payCoordinator: 110,
      status: TournamentStatus.created,
      fee: 70.0,
      prize1: 1800.0,
      prize2: 900.0,
      round2GroupStage: true,
      isATL: true,
    ),
    Tournament(
      id: 7,
      name: 'City Cup',
      description: 'Compete in the City Cup tournament',
      coordinatorId: 1,
      fieldId: 2,
      cityId: 2,
      sportId: 1,
      startDate: DateTime.now().add(const Duration(days: 15)),
      numTeams: 16,
      paidTeams: 2,
      numGroups: 3,
      qualified: 6,
      payCoordinator: 90,
      status: TournamentStatus.created,
      fee: 60.0,
      prize1: 1300.0,
      prize2: 600.0,
      round2GroupStage: true,
      round2FinalStage: false,
    ),
    Tournament(
      id: 8,
      name: 'Torneo in corso',
      description: 'Prova del torneo in corso',
      coordinatorId: 1,
      fieldId: 1,
      cityId: 1,
      sportId: 1,
      startDate: DateTime.now().add(const Duration(days: 40)),
      numTeams: 8,
      paidTeams: 8,
      numGroups: 2,
      qualified: 4,
      payCoordinator: 130,
      status: TournamentStatus.scheduled,
      fee: 75.0,
      prize1: 2200.0,
      prize2: 1100.0,
      round2GroupStage: true,
      round2FinalStage: false,
    ),
  ];

  Future<Tournament?> getById(int tournamentId) async {
    if (AppConfig.isDebug) {
      try {
        return _mockData.firstWhere((t) => t.id == tournamentId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  /// Metodo custom: ottieni tornei per coordinatore
  Future<List<Tournament>> getByCoordinator(int coordinatorId) async {
    if (AppConfig.isDebug) {
      final tournaments = _mockData
          .where((t) => t.coordinatorId == coordinatorId)
          .toList();
      return tournaments;
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Tournament>> getByField(int fieldId) async {
    if (AppConfig.isDebug) {
      final tournaments = _mockData.where((t) => t.fieldId == fieldId).toList();
      return tournaments;
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Tournament>> getActiveOwnedByCoordinatorId(
    int coordinatorId,
  ) async {
    if (AppConfig.isDebug) {
      List<Tournament> tournaments = await getActive();
      tournaments.retainWhere((t) => t.coordinatorId == coordinatorId);

      tournaments = tournaments
          .map((t) => t.copyWith(isParticipating: true))
          .toList();
      return tournaments;
    } else {
      throw UnimplementedError();
    }
  }

  /// Metodo custom: ottieni tornei attivi
  Future<List<Tournament>> getActive() async {
    if (AppConfig.isDebug) {
      return _mockData
          .where(
            (t) =>
                t.status == TournamentStatus.scheduled ||
                t.status == TournamentStatus.created,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  /// Metodo custom: ottieni tornei per sport
  Future<List<Tournament>> getBySportCategory(SportCategory category) async {
    if (AppConfig.isDebug) {
      final sportIds = (await DB.Sports.getByCategory(
        category,
      )).map((s) => s.id).toList();
      return mockData.where((t) => sportIds.contains(t.sportId)).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Tournament>> getActiveParticipatingTournamentByPlayerAndTeam(
    int playerId,
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      // In modalità debug, restituisci tutti i tornei come preferiti
      List<int> activeTournamentsId = (await getActive())
          .map((t) => t.id)
          .toList();
      List<int> callupsTournamentsIds = (await DB.CallUps.getByPlayerAndTeam(
        playerId,
        teamId,
      )).map((c) => c.tournamentId).toList();
      List<Tournament> participatingTournaments = _mockData
          .where((t) => callupsTournamentsIds.contains(t.id))
          .map((t) => t.copyWith(isParticipating: true))
          .toList();
      participatingTournaments = participatingTournaments
          .where((t) => activeTournamentsId.contains(t.id))
          .toList();
      return participatingTournaments;
      //return (await getActive()).where((t) => t.isFavorite == true || t.isParticipating == true).toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Tournament>> getFavoriteTournamentByUser(int userId) async {
    if (AppConfig.isDebug) {
      List<int> favoriteTournamentsIds =
          (await DB.FavoriteTournaments.getByUserId(
            userId,
          )).map((f) => f.tournamentId).toList();
      List<Tournament> favoriteTournaments = _mockData
          .where((t) => favoriteTournamentsIds.contains(t.id))
          .map((t) => t.copyWith(isFavorite: true))
          .toList();
      return favoriteTournaments;
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> toggleFavoriteStatus(int tournamentId, int userId) async {
    if (AppConfig.isDebug) {
      if (await DB.FavoriteTournaments.isFavorite(userId, tournamentId)) {
        await DB.FavoriteTournaments.removeFavorite(userId, tournamentId);
      } else {
        await DB.FavoriteTournaments.addFavorite(userId, tournamentId);
      }
      return Future.value();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Tournament>> filterByNameOrId(String query) async {
    if (AppConfig.isDebug) {
      final results = _mockData
          .where(
            (t) =>
                t.name.toLowerCase().contains(query.toLowerCase()) ||
                t.id.toString() == query,
          )
          .toList();
      print(
        '🔧 [DEBUG] Search results for "$query": ${results.map((t) => t.name).join(', ')}',
      );
      return results;
    } else {
      return List<Tournament>.empty();
      // Implementa la logica di ricerca nel database reale
    }
  }

  Future<double> getTournamentFee(int tournamentId) async {
    if (AppConfig.isDebug) {
      final tournament = _mockData.firstWhere(
        (t) => t.id == tournamentId,
        orElse: () => throw Exception('Tournament not found'),
      );
      return tournament.fee;
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getPaidTeamsCount(int tournamentId) async {
    if (AppConfig.isDebug) {
      final tournament = _mockData.firstWhere(
        (t) => t.id == tournamentId,
        orElse: () => throw Exception('Tournament not found'),
      );
      return tournament.paidTeams;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> incrementPaidTeams(int tournamentId) async {
    if (AppConfig.isDebug) {
      final index = _mockData.indexWhere((t) => t.id == tournamentId);
      if (index == -1) {
        return false;
      }
      Tournament tournament = _mockData[index];
      if (tournament.paidTeams < tournament.numTeams) {
        tournament.paidTeams += 1;
        _mockData[index] = tournament;
        print(
          '🔧 [DEBUG] Incremented paid teams for tournament ${tournament.name}. New count: ${tournament.paidTeams}',
        );
        return true;
      } else {
        print(
          '🔧 [DEBUG] Cannot increment paid teams for tournament ${tournament.name}. Already at max: ${tournament.numTeams}',
        );
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getMinutesPerRoundById(int tournamentId) async {
    if (AppConfig.isDebug) {
      final Tournament tournament = mockData.firstWhere(
        (t) => t.id == tournamentId,
      );
      return (await DB.Sports.getMinutesPerRoundById(tournament.sportId))!;
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getMinutesPerPauseById(int tournamentId) async {
    if (AppConfig.isDebug) {
      final Tournament tournament = mockData.firstWhere(
        (t) => t.id == tournamentId,
      );
      return (await DB.Sports.getMinutesPerPauseById(tournament.sportId))!;
    } else {
      throw UnimplementedError();
    }
  }

  Future<double> calculatePrize1(Tournament tournament) async {
    if (AppConfig.isDebug) {
      // Logica di calcolo fittizia per debug
      double basePrize = 1000.0;
      double fieldMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità del campo
      double sportMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità dello sport
      double teamMultiplier =
          tournament.numTeams / 8.0; // Più squadre, più alto il premio

      double prize1 =
          basePrize * fieldMultiplier * sportMultiplier * teamMultiplier;
      return prize1;
    } else {
      throw UnimplementedError();
    }
  }

  Future<double> calculatePrize2(Tournament tournament) async {
    if (AppConfig.isDebug) {
      // Logica di calcolo fittizia per debug
      double basePrize = 500.0;
      double fieldMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità del campo
      double sportMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità dello sport
      double teamMultiplier =
          tournament.numTeams / 8.0; // Più squadre, più alto il premio

      double prize2 =
          basePrize * fieldMultiplier * sportMultiplier * teamMultiplier;
      return prize2;
    } else {
      throw UnimplementedError();
    }
  }

  Future<double> calculateTournamentFee(Tournament tournament) async {
    if (AppConfig.isDebug) {
      // Logica di calcolo fittizia per debug
      double baseFee = 50.0;
      double fieldMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità del campo
      double sportMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità dello sport
      double teamMultiplier =
          tournament.numTeams / 8.0; // Più squadre, più alta la quota

      double fee = baseFee * fieldMultiplier * sportMultiplier * teamMultiplier;
      return fee + 1;
    } else {
      throw UnimplementedError();
    }
  }

  Future<double> calculatePayCoordinator(Tournament tournament) async {
    if (AppConfig.isDebug) {
      // Logica di calcolo fittizia per debug
      double basePay = 100.0;
      double fieldMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità del campo
      double sportMultiplier =
          1.0; // Potrebbe essere basato sulla popolarità dello sport
      double teamMultiplier =
          tournament.numTeams / 8.0; // Più squadre, più alto il compenso

      double payCoordinator =
          basePay * fieldMultiplier * sportMultiplier * teamMultiplier;
      return payCoordinator;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> newTournament({
    required String name,
    required int coordinatorId,
    required int fieldId,
    required int cityId,
    DateTime? startDate,
    required int sportId,
    required int numTeams,
    required int numGroups,
    required bool round2GroupStage,
    required bool round2FinalStage,
    required int qualified,
    required String description,
    required bool payCoordinator,
    required bool prize1,
    required bool prize2,
    required bool isPublic,
  }) async {
    if (AppConfig.isDebug) {
      final Tournament mockTournament = Tournament(
        id: _mockData.length + 1,
        name: name,
        coordinatorId: coordinatorId,
        fieldId: fieldId,
        cityId: cityId,
        startDate: startDate,
        sportId: sportId,
        numTeams: numTeams,
        paidTeams: 0,
        numGroups: numGroups,
        round2GroupStage: round2GroupStage,
        round2FinalStage: round2FinalStage,
        qualified: qualified,
        description: description,
        payCoordinator: 0,
        status: TournamentStatus.created,
        fee: 0,
        prize1: 0,
        prize2: 0,
        isPublic: isPublic,
        isATL: false,
      );

      if (prize1 != payCoordinator) {
        return false;
      }

      final double calculatedFee = await calculateTournamentFee(mockTournament);
      final double calculatedPrize1 = prize1
          ? await calculatePrize1(mockTournament)
          : 0.0;
      final double calculatedPrize2 = prize2
          ? await calculatePrize2(mockTournament)
          : 0.0;
      final double calculatedPayCoordinator = payCoordinator
          ? await calculatePayCoordinator(mockTournament)
          : 0.0;

      if (calculatedFee == 0) {
        return false;
      }

      final Tournament newTournament = Tournament(
        id: _mockData.length + 1,
        name: name,
        coordinatorId: coordinatorId,
        fieldId: fieldId,
        cityId: cityId,
        startDate: startDate,
        sportId: sportId,
        numTeams: numTeams,
        paidTeams: 0,
        numGroups: numGroups,
        round2GroupStage: round2GroupStage,
        round2FinalStage: round2FinalStage,
        qualified: qualified,
        description: description,
        payCoordinator: calculatedPayCoordinator,
        status: TournamentStatus.created,
        fee: calculatedFee,
        prize1: calculatedPrize1,
        prize2: calculatedPrize2,
        isPublic: isPublic,
        isATL: false,
      );
      _mockData.add(newTournament);
      print(
        '🔧 [DEBUG] Created new tournament: ${newTournament.name} with fee: ${newTournament.fee}, prize1: ${newTournament.prize1}, prize2: ${newTournament.prize2}, payCoordinator: ${newTournament.payCoordinator}',
      );
      print('🔧 [DEBUG] Sport ID: ${newTournament.sportId}');
      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
