import '../../models/football_standing.dart';
import 'base_repository.dart';
import '../../config/app_config.dart';
/// Repository per la gestione delle classifiche di calcio

class FootballStandingsRepository extends BaseRepository<FootballStanding> {
  @override
  String get endpoint => 'football_standings';

  @override
  FootballStanding fromJson(Map<String, dynamic> json) =>
      FootballStanding.fromJson(json);

  @override
  Map<String, dynamic> toJson(FootballStanding item) => item.toJson();

  @override
  List<FootballStanding> _mockData = [
    FootballStanding(
      tournamentId: 8,
      teamId: 1,
      points: 3,
      won: 1,
      drawn: 0,
      lost: 0,
      group: 'A',
      rank: 1,
      qualified: true,
      goalsScored: 1,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 5,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 1,
      group: 'A',
      rank: 4,
      qualified: false,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 6,
      points: 0,
      won: 0,
      drawn: 1,
      lost: 0,
      group: 'A',
      rank: 2,
      qualified: true,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 7,
      points: 0,
      won: 0,
      drawn: 1,
      lost: 0,
      group: 'A',
      rank: 3,
      qualified: false,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 8,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
      rank: 1,
      qualified: true,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 9,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
      rank: 2,
      qualified: true,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 10,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
      rank: 3,
      qualified: false,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 11,
      points: 0,
      won: 0,
      drawn: 0,
      lost: 0,
      group: 'B',
      rank: 4,
      qualified: false,
    ),
  ];

  List<FootballStanding> get mockData => _mockData;

  Future<List<FootballStanding>> getStandingsByTournament(
    int tournamentId,
  ) async {
    if(AppConfig.isDebug){
    try{
    return mockData
        .where((standing) => standing.tournamentId == tournamentId)
        .toList();
    } catch (e) {
      return [];
    }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballStanding>> getStandingsByGroup(
    int tournamentId,
    String group,
  ) async {
    if (AppConfig.isDebug) {
      return mockData
          .where(
            (standing) =>
                standing.tournamentId == tournamentId &&
                standing.group == group,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

}
