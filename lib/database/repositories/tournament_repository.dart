import 'package:atl_app/config/app_config.dart';

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
      city: 'Milano',
      sportName: 'FOOTBALL',
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
      round2: 1,
      minPlayers: 5,
      maxPlayers: 10,
    ),
    Tournament(
      id: 2,
      name: 'Tournament 1',
      description: 'Summer championship',
      coordinatorId: 1,
      fieldId: 2,
      city: 'Roma',
      sportName: 'FOOTBALL',
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
      round2: 1,
      minPlayers: 5,
      maxPlayers: 10,
    ),
    Tournament(
      id: 3,
      name: 'Tournament 1',
      description: 'Winter championship',
      coordinatorId: 1,
      fieldId: 1,
      city: 'Milano',
      sportName: 'FOOTBALL',
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
      round2: 1,
      minPlayers: 7,
      maxPlayers: 14,
    ),
    // Torneo attivo esistente
    Tournament(
      id: 4,
      name: 'Active Summer League',
      description: 'Current ongoing tournament',
      coordinatorId: 1,
      fieldId: 1,
      city: 'Milano',
      sportName: 'FOOTBALL',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      numTeams: 16,
      paidTeams: 12,
      numGroups: 4,
      qualified: 8,
      payCoordinator: 100,
      status: TournamentStatus.scheduled,
      fee: 55.0,
      prize1: 1500.0,
      prize2: 750.0,
      phase: TournamentPhase.group,
      round2: 0,
      minPlayers: 6,
      maxPlayers: 12,
    ),
    Tournament(
      id: 5,
      name: 'Upcoming Autumn Cup',
      description: 'Register now for the Autumn Cup',
      coordinatorId: 1,
      fieldId: 2,
      city: 'Roma',
      sportName: 'FOOTBALL',
      startDate: DateTime.now().add(const Duration(days: 20)),
      numTeams: 24,
      paidTeams: 24,
      numGroups: 6,
      qualified: 12,
      payCoordinator: 120,
      status: TournamentStatus.created,
      fee: 65.0,
      prize1: 2500.0,
      prize2: 1200.0,
      round2: 1,
      minPlayers: 8,
      maxPlayers: 16,
    ),
    Tournament(
      id: 6,
      name: 'Spring Championship',
      description: 'Join the Spring Championship now!',
      coordinatorId: 2,
      fieldId: 1,
      city: 'Milano',
      sportName: 'FOOTBALL',
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
      round2: 1,
      isATL: true,
      minPlayers: 5,
      maxPlayers: 5,
    ),
    Tournament(
      id: 7,
      name: 'City Cup',
      description: 'Compete in the City Cup tournament',
      coordinatorId: 1,
      fieldId: 2,
      city: 'Roma',
      sportName: 'FOOTBALL',
      startDate: DateTime.now().add(const Duration(days: 15)),
      numTeams: 16,
      paidTeams: 3,
      numGroups: 3,
      qualified: 6,
      payCoordinator: 90,
      status: TournamentStatus.created,
      fee: 60.0,
      prize1: 1300.0,
      prize2: 600.0,
      round2: 1,
      minPlayers: 6,
      maxPlayers: 12,
    ),
  ];

  /// Metodo custom: ottieni tornei per coordinatore
  Future<List<Tournament>> getByCoordinator(int coordinatorId) async {
    final tournaments = await getAll();
    return tournaments.where((t) => t.coordinatorId == coordinatorId).toList();
  }

  /// Metodo custom: ottieni tornei attivi
  Future<List<Tournament>> getActive() async {
    final tournaments = await getAll();
    return tournaments.where((t) => 
      t.status == TournamentStatus.scheduled || 
      t.status == TournamentStatus.created
    ).toList();
  }

  /// Metodo custom: ottieni tornei per sport
  Future<List<Tournament>> getBySport(String sportName) async {
    final tournaments = await getAll();
    return tournaments.where((t) => t.sportName == sportName).toList();
  }

  @override
  Future<Tournament> create(Tournament item) async {
    if (AppConfig.isDebug) {
      _mockData.add(item);
      print('🔧 [DEBUG] Created tournament: ${item.name}');
      return item;
    } else {
      return super.create(item);
    }
  }

  Future<List<Tournament>> getParticipatingTournamentByPlayerAndTeam(int playerId, int teamId) async {
    if (AppConfig.isDebug) {
      // In modalità debug, restituisci tutti i tornei come preferiti
      //TODO: implementare logica per la partecipazione effettiva del giocatore
      List<int> callupsTournamentsIds = (await DB.CallUps.getByPlayerAndTeam(playerId, teamId))
          .map((c) => c.tournamentId).toList();
      List<Tournament> participatingTournaments = _mockData.where((t) => callupsTournamentsIds.contains(t.id)).map((t) => t.copyWith(isParticipating: true)).toList();
      return participatingTournaments;
      //return (await getActive()).where((t) => t.isFavorite == true || t.isParticipating == true).toList();
    } else {
      return super.getAll();
    }
  }

  Future<List<Tournament>> getFavoriteTournamentByUser(int userId) async {
    if (AppConfig.isDebug) {
      List<int> favoriteTournamentsIds = (await DB.FavoriteTournaments.getByUserId(userId))
          .map((f) => f.tournamentId).toList();
      List<Tournament> favoriteTournaments = _mockData.where((t) => favoriteTournamentsIds.contains(t.id)).map((t) => t.copyWith(isFavorite: true)).toList();
      return favoriteTournaments;
    }
    else{
      return super.getAll();
    }
  }

  Future<void> toggleFavoriteStatus(int tournamentId, int userId) async {
    if (AppConfig.isDebug) {
        if(await DB.FavoriteTournaments.isFavorite(userId, tournamentId)){
          await DB.FavoriteTournaments.removeFavorite(userId, tournamentId);
        }
        else{
          await DB.FavoriteTournaments.addFavorite(userId, tournamentId);
        }
        return Future.value();
      }
    else {
      throw UnimplementedError();
    }
  }

  Future<List<Tournament>> filterByNameOrId(String query) async {
    if (AppConfig.isDebug) {
      final results = _mockData.where((t) => 
        t.name.toLowerCase().contains(query.toLowerCase()) || t.id.toString() == query
      ).toList();
      print('🔧 [DEBUG] Search results for "$query": ${results.map((t) => t.name).join(', ')}');
      return results;
    } else {
      return List<Tournament>.empty();
      // Implementa la logica di ricerca nel database reale
    }
  }

  Future<double> getTournamentFee(int tournamentId) async {
    if (AppConfig.isDebug) {
      final tournament = _mockData.firstWhere((t) => t.id == tournamentId, orElse: () => throw Exception('Tournament not found'));
      return tournament.fee;
    } else {
      throw UnimplementedError();
    }
  }
}
