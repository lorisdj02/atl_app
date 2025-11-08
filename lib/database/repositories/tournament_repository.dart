import '../../models/tournament.dart';
import 'base_repository.dart';

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
      id: 1,
      coordinatorId: 1,
      fieldId: 1,
      cityId: 1,
      cityName: 'Taranto',
      startDate: DateTime.now().add(const Duration(days: 7)),
      sportId: 'football',
      numTeams: 12,
      paidTeams: 11,
      numGroups: 3,
      description: 'Summer Championship 2024',
      payCoordinator: 50,
      payField: 100,
      fee: 25.00,
      prize1: 500.00,
      prize2: 200.00,
      atlEvent: true,
      status: TournamentStatus.scheduled,
    ),
    // Torneo pieno/schedulato (grigio)
    Tournament(
      id: 2,
      coordinatorId: 1,
      fieldId: 2,
      cityId: 2,
      cityName: 'Milano',
      startDate: DateTime.now().add(const Duration(days: 14)),
      sportId: 'football',
      numTeams: 8,
      paidTeams: 8,
      numGroups: 2,
      description: 'City Cup Milano',
      payCoordinator: 75,
      payField: 150,
      fee: 30.00,
      prize1: 1000.00,
      prize2: 400.00,
      status: TournamentStatus.scheduled,
    ),
    // Tornei bianchi
    Tournament(
      id: 3,
      coordinatorId: 2,
      fieldId: 3,
      cityId: 3,
      cityName: 'Torino',
      startDate: DateTime.now().add(const Duration(days: 21)),
      sportId: 'football',
      numTeams: 16,
      paidTeams: 5,
      numGroups: 4,
      description: 'Torino Spring Tournament',
      payCoordinator: 60,
      payField: 120,
      fee: 20.00,
      prize1: 800.00,
      prize2: 300.00,
      status: TournamentStatus.created,
    ),
    Tournament(
      id: 4,
      coordinatorId: 1,
      fieldId: 4,
      cityId: 4,
      cityName: 'Roma',
      startDate: DateTime.now().add(const Duration(days: 10)),
      sportId: 'football',
      numTeams: 8,
      paidTeams: 3,
      numGroups: 2,
      description: 'Roma Open League',
      payCoordinator: 40,
      payField: 80,
      fee: 15.00,
      prize1: 400.00,
      prize2: 150.00,
      status: TournamentStatus.created,
    ),
    Tournament(
      id: 5,
      coordinatorId: 3,
      fieldId: 1,
      cityId: 1,
      cityName: 'Taranto',
      startDate: DateTime.now().add(const Duration(days: 28)),
      sportId: 'football',
      numTeams: 12,
      paidTeams: 7,
      numGroups: 3,
      description: 'Taranto Champions Cup',
      payCoordinator: 55,
      payField: 110,
      fee: 22.00,
      prize1: 600.00,
      prize2: 250.00,
      status: TournamentStatus.created,
    ),
    Tournament(
      id: 6,
      coordinatorId: 2,
      fieldId: 2,
      cityId: 2,
      cityName: 'Milano',
      startDate: DateTime.now().add(const Duration(days: 35)),
      sportId: 'football',
      numTeams: 16,
      paidTeams: 4,
      numGroups: 4,
      description: 'Milano Elite Tournament',
      payCoordinator: 80,
      payField: 160,
      fee: 35.00,
      prize1: 1200.00,
      prize2: 500.00,
      status: TournamentStatus.created,
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
  Future<List<Tournament>> getBySport(String sportId) async {
    final tournaments = await getAll();
    return tournaments.where((t) => t.sportId == sportId).toList();
  }
}
