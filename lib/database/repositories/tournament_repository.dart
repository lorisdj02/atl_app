import '../db_controller.dart';
import '../../models/tournament.dart';
import 'base_repository.dart';
import '../../models/field.dart';
class TournamentRepository extends BaseRepository<Tournament> {
  @override
  String get endpoint => 'tournaments';

  @override
  Tournament fromJson(Map<String, dynamic> json) => Tournament.fromJson(json);

  @override
  Map<String, dynamic> toJson(Tournament item) => item.toJson();

  @override
  List<Tournament> get mockData => [
    // Torneo ATL
    Tournament(
      name: 'ATL Summer Championship',
      field: DB.Fields.mockData[0],
      coordinator: DB.Coordinators.mockData[0],
      id: 1,
      city: 'Taranto',
      startDate: DateTime.now().add(const Duration(days: 7)),
      sportName: 'football',
      numTeams: 12,
      paidTeams: 11,
      numGroups: 3,
      description: 'Summer Championship 2024',
      payCoordinator: 50,
      fee: 25.00,
      prize1: 500.00,
      prize2: 200.00,
      atlEvent: true,
      status: TournamentStatus.scheduled,
    ),
    // Torneo pieno/schedulato (grigio)
    
    Tournament(
      name: 'City Cup Milano',
      field: DB.Fields.mockData[1],
      coordinator: DB.Coordinators.mockData[1],
      id: 2,
      city: 'Milano',
      startDate: DateTime.now().add(const Duration(days: 14)),
      sportName: 'football',
      numTeams: 8,
      paidTeams: 8,
      numGroups: 2,
      description: 'City Cup Milano',
      payCoordinator: 75,
      fee: 30.00,
      prize1: 1000.00,
      prize2: 400.00,
      status: TournamentStatus.scheduled,
    ),
    // Tornei bianchi
    Tournament(
      name: 'Torino Spring Tournament',
      field: DB.Fields.mockData[2],
      coordinator: DB.Coordinators.mockData[0],
      id: 3,
      city: 'Torino',
      startDate: DateTime.now().add(const Duration(days: 21)),
      sportName: 'football',
      numTeams: 16,
      paidTeams: 5,
      numGroups: 4,
      description: 'Torino Spring Tournament',
      payCoordinator: 60,
      fee: 20.00,
      prize1: 800.00,
      prize2: 300.00,
      status: TournamentStatus.created,
    ),
    Tournament(
      field: DB.Fields.mockData[0],
      name: 'Roma Open League',
      coordinator: DB.Coordinators.mockData[2],
      id: 4,
      city: 'Roma',
      startDate: DateTime.now().add(const Duration(days: 10)),
      sportName: 'football',
      numTeams: 8,
      paidTeams: 3,
      numGroups: 2,
      description: 'Roma Open League',
      payCoordinator: 40,
      fee: 15.00,
      prize1: 400.00,
      prize2: 150.00,
      status: TournamentStatus.created,
    ),
    Tournament(
      name: 'Taranto Champions Cup',
      field: DB.Fields.mockData[3],
      coordinator: DB.Coordinators.mockData[1],
      id: 5,
      city: 'Taranto',
      startDate: DateTime.now().add(const Duration(days: 28)),
      sportName: 'football',
      numTeams: 12,
      paidTeams: 7,
      numGroups: 3,
      description: 'Taranto Champions Cup',
      payCoordinator: 55,
      fee: 22.00,
      prize1: 600.00,
      prize2: 250.00,
      status: TournamentStatus.created,
    ),
    Tournament(
      name: 'Milano Elite Tournament',
      field: DB.Fields.mockData[1],
      coordinator: DB.Coordinators.mockData[0],
      id: 6,
      city: 'Milano',
      startDate: DateTime.now().add(const Duration(days: 35)),
      sportName: 'football',
      numTeams: 16,
      paidTeams: 4,
      numGroups: 4,
      description: 'Milano Elite Tournament',
      payCoordinator: 80,
      fee: 35.00,
      prize1: 1200.00,
      prize2: 500.00,
      status: TournamentStatus.created,
    ),
    
  ];

  /// Metodo custom: ottieni tornei per coordinatore
  Future<List<Tournament>> getByCoordinator(int coordinatorId) async {
    final tournaments = await getAll();
    return tournaments.where((t) => t.coordinator.id == coordinatorId).toList();
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
}
