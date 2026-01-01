import '../../models/football_standing.dart';
import 'base_repository.dart';

/// Repository per la gestione delle classifiche di calcio

class FootballStandingsRepository extends BaseRepository<FootballStanding> {
  @override
  String get endpoint => 'football_standings';

  @override
  FootballStanding fromJson(Map<String, dynamic> json) => FootballStanding.fromJson(json);

  @override
  Map<String, dynamic> toJson(FootballStanding item) => item.toJson();

  @override
  List<FootballStanding> _mockData = [
    FootballStanding(
      tournamentId: 8,
      teamId: 1,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 5,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 6,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 7,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 8,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 9,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 10,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 11,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
  ];
  
  List<FootballStanding> get mockData => _mockData;

  Future<List<FootballStanding>> getStandingsByTournament(int tournamentId) async{
    return mockData.where((standing) => standing.tournamentId == tournamentId).toList();
  }

  Future<List<FootballStanding>> getStandingsByGroup(int tournamentId, String group) async {
    return mockData.where((standing) =>
      standing.tournamentId == tournamentId && standing.group == group).toList();
  }
}