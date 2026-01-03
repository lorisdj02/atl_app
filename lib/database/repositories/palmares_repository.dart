import '../../models/palmares.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';

class PalmaresRepository extends BaseRepository<Palmares> {
  @override
  String get endpoint => 'palmares';

  @override
  Palmares fromJson(Map<String, dynamic> json) => Palmares.fromJson(json);

  @override
  Map<String, dynamic> toJson(Palmares item) => item.toJson();

  List<Palmares> _mockData = [
    // Team A (id: 1) palmares
    Palmares(tournamentId: 1, teamId: 1, position: PalmaresPosition.WINNER),
    Palmares(tournamentId: 2, teamId: 1, position: PalmaresPosition.FINALIST),
    Palmares(tournamentId: 3, teamId: 1, position: PalmaresPosition.SEMI),

    // Team B (id: 2) palmares
    Palmares(tournamentId: 1, teamId: 2, position: PalmaresPosition.SEMI),
    Palmares(tournamentId: 2, teamId: 2, position: PalmaresPosition.ROUND8),

    // Team C (id: 3) palmares
    Palmares(tournamentId: 1, teamId: 3, position: PalmaresPosition.FINALIST),
    Palmares(tournamentId: 3, teamId: 3, position: PalmaresPosition.WINNER),

    // Team D (id: 4) palmares
    Palmares(tournamentId: 2, teamId: 4, position: PalmaresPosition.WINNER),
    Palmares(tournamentId: 3, teamId: 4, position: PalmaresPosition.FINALIST),

    // Team E (id: 5) palmares
    Palmares(tournamentId: 1, teamId: 5, position: PalmaresPosition.ROUND16),
    Palmares(tournamentId: 2, teamId: 5, position: PalmaresPosition.SEMI),
  ];

  @override
  List<Palmares> get mockData => _mockData;

  /// Ottieni palmares per team
  Future<List<Palmares>> getByTeam(int teamId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((p) => p.teamId == teamId).toList();
    } else {
      throw UnimplementedError();
    }
  }

  /// Ottieni palmares per torneo
  Future<List<Palmares>> getByTournament(int tournamentId) async {
    if (AppConfig.isDebug) {
      return _mockData.where((p) => p.tournamentId == tournamentId).toList();
    } else {
      throw UnimplementedError();
    }
  }
}
