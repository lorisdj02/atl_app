import 'base_repository.dart';
import '../../models/soccer_match.dart';

/// Repository per la gestione delle partite di calcio

class SoccerMatchRepository extends BaseRepository<SoccerMatch> {
  @override
  String get endpoint => 'soccer_matches';

  @override
  SoccerMatch fromJson(Map<String, dynamic> json) => SoccerMatch.fromJson(json);

  @override
  Map<String, dynamic> toJson(SoccerMatch item) => item.toJson();


  List<SoccerMatch> _mockdata = [
    SoccerMatch(
      id: 1,
      homeTeamId: 1,
      awayTeamId: 5,
      status: MatchStatus.started,
      tournamentId: 8,
      group: 'A',
      day: 1,
      scoreHome: 1,
      scoreAway: 0,
      startMatch: DateTime.now().subtract(const Duration(minutes: 23)),
    ),
    SoccerMatch(
      id: 2,
      homeTeamId: 6,
      awayTeamId: 7,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'A',
      day: 1,
    ),
    SoccerMatch(
      id: 3,
      homeTeamId: 8,
      awayTeamId: 9,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'B',
      day: 1,
    ),
    SoccerMatch(
      id: 4,
      homeTeamId: 10,
      awayTeamId: 11,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'B',
      day: 1,
    ),
  ];

  @override
  List<SoccerMatch> get mockData => _mockdata;

  Future<List<SoccerMatch>> getMatchesByTournament(int tournamentId) async {
    return mockData.where((match) => match.tournamentId == tournamentId).toList();
  }

  Future<List<SoccerMatch>> getMatchesByGroup(int tournamentId, String group) async {
    return mockData.where((match) =>
      match.tournamentId == tournamentId && match.group == group).toList();
  }
}