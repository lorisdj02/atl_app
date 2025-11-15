import 'package:atl_app/config/app_config.dart';

import '../db_controller.dart';
import '../../models/tournament.dart';
import 'base_repository.dart';
import '../../models/field.dart';
import '../../models/coordinator.dart';

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
      atlEvent: true,
      round2: 1,
    ),
    Tournament(
      id: 2,
      name: 'Tournament 1',
      description: 'Summer championship',
      coordinatorId: 2,
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
      isParticipating: true,
    ),
    Tournament(
      id: 5,
      name: 'Upcoming Autumn Cup',
      description: 'Register now for the Autumn Cup',
      coordinatorId: 2,
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
      isFavorite: true,
    ),
    Tournament(
      id: 6,
      name: 'Spring Championship',
      description: 'Join the Spring Championship now!',
      coordinatorId: 1,
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
      atlEvent: true,
    )
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

  Future<List<Tournament>> getMyTournamentsByPlayerId(int playerId) async {
    if (AppConfig.isDebug) {
      // In modalità debug, restituisci tutti i tornei come preferiti
      return (await getActive()).where((t) => t.isFavorite == true || t.isParticipating == true).toList();
    } else {
      return super.getAll();
    }
  }

  Future<void> toggleFavoriteStatus(int tournamentId, bool isFavorite) async {
    if (AppConfig.isDebug) {
      final tournament = _mockData.firstWhere((t) => t.id == tournamentId);
      tournament.isFavorite = isFavorite;
      print('🔧 [DEBUG] Toggled favorite status for tournament ${tournament.name} to $isFavorite');
    } else {
      // Implementa la logica per aggiornare lo stato nel database reale
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
}
