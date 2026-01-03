import 'package:atl_app/config/app_config.dart';

import 'base_repository.dart';
import '../../models/football_match.dart';
import '../../models/match.dart';

/// Repository per la gestione delle partite di calcio

class FootballMatchRepository extends BaseRepository<FootballMatch> {
  @override
  String get endpoint => 'football_matches';

  @override
  FootballMatch fromJson(Map<String, dynamic> json) =>
      FootballMatch.fromJson(json);

  @override
  Map<String, dynamic> toJson(FootballMatch item) => item.toJson();

  List<FootballMatch> _mockdata = [
    FootballMatch(
      id: 1,
      homeTeamId: 1,
      awayTeamId: 5,
      status: MatchStatus.startHalf,
      tournamentId: 8,
      group: 'A',
      day: 1,
      scoreHome: 1,
      scoreAway: 0,
      startMatch: DateTime.now().subtract(const Duration(minutes: 23)),
      halfTime: DateTime.now().subtract(const Duration(minutes: 3)),
      startHalf: DateTime.now().subtract(const Duration(minutes: 0)),
    ),
    FootballMatch(
      id: 2,
      homeTeamId: 6,
      awayTeamId: 7,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'A',
      day: 1,
    ),
    FootballMatch(
      id: 3,
      homeTeamId: 8,
      awayTeamId: 9,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'B',
      day: 1,
    ),
    FootballMatch(
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
  List<FootballMatch> get mockData => _mockdata;

  Future<FootballMatch?> getById(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        return mockData.firstWhere((match) => match.id == matchId);
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballMatch>> getMatchesByTournament(int tournamentId) async {
    return mockData
        .where((match) => match.tournamentId == tournamentId)
        .toList();
  }

  Future<List<FootballMatch>> getMatchesByGroup(
    int tournamentId,
    String group,
  ) async {
    return mockData
        .where(
          (match) => match.tournamentId == tournamentId && match.group == group,
        )
        .toList();
  }
}
