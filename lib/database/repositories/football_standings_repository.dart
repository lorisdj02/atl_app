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
      goalsConceded: 1,
      rank: 4,
      qualified: false,
    ),
    FootballStanding(
      tournamentId: 8,
      teamId: 6,
      points: 1,
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
      points: 1,
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

  @override
  List<FootballStanding> get mockData => _mockData;

  Future<bool> orderRanksInTournamentByGroup(
    int tournamentId,
    String group,
  ) async {
    if (AppConfig.isDebug) {
      try {
        List<FootballStanding> standingsInGroup = mockData
            .where((s) => s.tournamentId == tournamentId && s.group == group)
            .toList();
        standingsInGroup.sort((a, b) {
          if (b.points != a.points) {
            return b.points.compareTo(a.points);
          } else if ((b.goalsScored - b.goalsConceded) !=
              (a.goalsScored - a.goalsConceded)) {
            final int goalDifferenceA = a.goalsScored - a.goalsConceded;
            final int goalDifferenceB = b.goalsScored - b.goalsConceded;
            if (goalDifferenceB != goalDifferenceA) {
              return goalDifferenceB.compareTo(goalDifferenceA);
            } else {
              return b.goalsScored.compareTo(a.goalsScored);
            }
          } else if (b.goalsScored != a.goalsScored) {
            return b.goalsScored.compareTo(a.goalsScored);
          } else {
            return b.goalsConceded.compareTo(a.goalsConceded);
          }
        });

        // Aggiorna i rank nella lista ordinata
        for (int i = 0; i < standingsInGroup.length; i++) {
          standingsInGroup[i].rank = i + 1;
        }

        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateTeamsQualified(
    int tournamentId,
    int numberQualified,
    int numberGroups,
  ) async {
    if (AppConfig.isDebug) {
      try {
        final int qualifiedPerGroup = numberQualified ~/ numberGroups;
        List<int> qualifiedTeams = [];
        for (int groupIndex = 0; groupIndex < numberGroups; groupIndex++) {
          final String groupLetter = String.fromCharCode(
            65 + groupIndex,
          ); // 'A' = 65 in ASCII
          List<FootballStanding> standingsInGroup = mockData
              .where(
                (s) => s.tournamentId == tournamentId && s.group == groupLetter,
              )
              .toList();

          standingsInGroup.sort((a, b) {
            return a.rank.compareTo(b.rank);
          });

          for (int i = 0; i < qualifiedPerGroup; i++) {
            qualifiedTeams.add(standingsInGroup[i].teamId);
          }
        }

        final int remainingQualified = numberQualified % numberGroups;
        if (remainingQualified > 0) {
          List<FootballStanding> nonQualifiedStandings = mockData
              .where(
                (s) =>
                    s.tournamentId == tournamentId &&
                    !qualifiedTeams.contains(s.teamId),
              )
              .toList();

          nonQualifiedStandings.sort((a, b) {
            if (b.points != a.points) {
              return b.points.compareTo(a.points);
            } else if ((b.goalsScored - b.goalsConceded) !=
                (a.goalsScored - a.goalsConceded)) {
              final int goalDifferenceA = a.goalsScored - a.goalsConceded;
              final int goalDifferenceB = b.goalsScored - b.goalsConceded;
              if (goalDifferenceB != goalDifferenceA) {
                return goalDifferenceB.compareTo(goalDifferenceA);
              } else {
                return b.goalsScored.compareTo(a.goalsScored);
              }
            } else if (b.goalsScored != a.goalsScored) {
              return b.goalsScored.compareTo(a.goalsScored);
            } else {
              return b.goalsConceded.compareTo(a.goalsConceded);
            }
          });

          for (
            int i = 0;
            i < remainingQualified && i < nonQualifiedStandings.length;
            i++
          ) {
            qualifiedTeams.add(nonQualifiedStandings[i].teamId);
          }
        }

        for (int i = 0; i < _mockData.length; i++) {
          if (_mockData[i].tournamentId == tournamentId) {
            _mockData[i].qualified = qualifiedTeams.contains(
              _mockData[i].teamId,
            );
          }
        }

        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateGames(
    int tournamentId,
    int teamId, {
    int won = 0,
    int drawn = 0,
    int lost = 0,
  }) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere(
          (s) => s.tournamentId == tournamentId && s.teamId == teamId,
        );

        if (index == -1) {
          return false;
        }

        final FootballStanding standing = mockData.firstWhere(
          (s) => s.tournamentId == tournamentId && s.teamId == teamId,
        );
        standing.won += won;
        standing.drawn += drawn;
        standing.lost += lost;
        _mockData[index] = standing;

        return await orderRanksInTournamentByGroup(
          tournamentId,
          standing.group,
        );
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updatePtsGoal(
    int tournamentId,
    int teamId, {
    int points = 0,
    int goalScored = 0,
    int goalConceded = 0,
  }) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere(
          (s) => s.tournamentId == tournamentId && s.teamId == teamId,
        );

        if (index == -1) {
          return false;
        }

        final FootballStanding standing = mockData.firstWhere(
          (s) => s.tournamentId == tournamentId && s.teamId == teamId,
        );
        standing.points += points;
        standing.goalsScored += goalScored;
        standing.goalsConceded += goalConceded;
        _mockData[index] = standing;

        await orderRanksInTournamentByGroup(tournamentId, standing.group);
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballStanding>> getStandingsByTournament(
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      try {
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
