import '../../models/soccer_standing.dart';
import 'base_repository.dart';

/// Repository per la gestione delle classifiche di calcio

class SoccerStandingsRepository extends BaseRepository<SoccerStanding> {
  @override
  String get endpoint => 'soccer_standings';

  @override
  SoccerStanding fromJson(Map<String, dynamic> json) => SoccerStanding.fromJson(json);

  @override
  Map<String, dynamic> toJson(SoccerStanding item) => item.toJson();

  @override
  List<SoccerStanding> _mockData = [
    SoccerStanding(
      tournamentId: 8,
      teamId: 1,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    SoccerStanding(
      tournamentId: 8,
      teamId: 5,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    SoccerStanding(
      tournamentId: 8,
      teamId: 6,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    SoccerStanding(
      tournamentId: 8,
      teamId: 7,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'A',
    ),
    SoccerStanding(
      tournamentId: 8,
      teamId: 8,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
    SoccerStanding(
      tournamentId: 8,
      teamId: 9,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
    SoccerStanding(
      tournamentId: 8,
      teamId: 10,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
    SoccerStanding(
      tournamentId: 8,
      teamId: 11,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
    ),
  ];
  
  List<SoccerStanding> get mockData => _mockData;

  Future<List<SoccerStanding>> getStandingsByTournament(int tournamentId) async{
    return mockData.where((standing) => standing.tournamentId == tournamentId).toList();
  }

  Future<List<SoccerStanding>> getStandingsByGroup(int tournamentId, String group) async {
    return mockData.where((standing) =>
      standing.tournamentId == tournamentId && standing.group == group).toList();
  }
}