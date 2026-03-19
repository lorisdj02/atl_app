import 'dart:math';
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

  List<FootballStanding> _mockData = [
    FootballStanding(
      tournamentId: 8,
      teamId: 1,
      points: 3,
      won: 1,
      drawn: 0,
      lost: 0,
      groupName: 'A',
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
      groupName: 'A',
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
      groupName: 'A',
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
      groupName: 'A',
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
      groupName: 'B',
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
      groupName: 'B',
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
      groupName: 'B',
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
      groupName: 'B',
      rank: 4,
      qualified: false,
    ),
  ];

  @override
  List<FootballStanding> get mockData => _mockData;

  Future<bool> orderRanksInTournamentByGroup(
    int tournamentId,
    String groupName,
  ) async {
    if (AppConfig.isDebug) {
      try {
        List<FootballStanding> standingsInGroup = mockData
            .where((s) => s.tournamentId == tournamentId && s.groupName == groupName)
            .toList();
        standingsInGroup.sort(_standingSort);

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
    int numberGroups, {
    bool toBeOrdered = false,
  }) async {
    if (AppConfig.isDebug) {
      try {
        if (toBeOrdered) {
          for (int i = 0; i < numberGroups; i++) {
            final String groupLetter = String.fromCharCode(
              65 + i,
            ); // 'A' = 65 in ASCII
            bool success = await orderRanksInTournamentByGroup(
              tournamentId,
              groupLetter,
            );
            if (!success) {
              return false;
            }
          }
        }

        final int qualifiedPerGroup = numberQualified ~/ numberGroups;
        List<int> qualifiedTeams = [];
        for (int groupIndex = 0; groupIndex < numberGroups; groupIndex++) {
          final String groupLetter = String.fromCharCode(
            65 + groupIndex,
          ); // 'A' = 65 in ASCII
          List<FootballStanding> standingsInGroup = mockData
              .where(
                (s) => s.tournamentId == tournamentId && s.groupName == groupLetter,
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
          // Ottieni tutti i non qualificati
          List<FootballStanding> nonQualifiedStandings = mockData
              .where(
                (s) =>
                    s.tournamentId == tournamentId &&
                    !qualifiedTeams.contains(s.teamId),
              )
              .toList();

          // Raggruppa per rank (seconde, terze, quarte, ecc.)
          Map<int, List<FootballStanding>> standingsByRank = {};
          for (var standing in nonQualifiedStandings) {
            if (!standingsByRank.containsKey(standing.rank)) {
              standingsByRank[standing.rank] = [];
            }
            standingsByRank[standing.rank]!.add(standing);
          }

          // Ordina ogni gruppo di rank
          standingsByRank.forEach((rank, standings) {
            standings.sort(_standingSort);
          });

          // Seleziona i migliori partendo dai rank più bassi
          for (int rank in standingsByRank.keys.toList()..sort()) {
            final standings = standingsByRank[rank]!;
            for (
              int i = 0;
              i < standings.length && qualifiedTeams.length < numberQualified;
              i++
            ) {
              qualifiedTeams.add(standings[i].teamId);
            }
            if (qualifiedTeams.length >= numberQualified) break;
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

  Future<List<int>> getQualifiedTeamsByTournamentAndRank(
    int tournamentId,
    int rank,
  ) async {
    if (AppConfig.isDebug) {
      try {
        return mockData
            .where(
              (s) =>
                  s.tournamentId == tournamentId &&
                  s.qualified == true &&
                  s.rank == rank,
            )
            .map((s) => s.teamId)
            .toList();
      } catch (e) {
        return [];
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> areInTheSameGroup(
    int tournamentId,
    int teamAId,
    int teamBId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        final FootballStanding standingA = mockData.firstWhere(
          (s) => s.tournamentId == tournamentId && s.teamId == teamAId,
        );
        final FootballStanding standingB = mockData.firstWhere(
          (s) => s.tournamentId == tournamentId && s.teamId == teamBId,
        );

        return standingA.groupName == standingB.groupName;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> insertStandings(
    int tournamentId,
    int teamId,
    String groupName,
    int rank,
  ) async {
    if (AppConfig.isDebug) {
      FootballStanding newStanding = FootballStanding(
        tournamentId: tournamentId,
        teamId: teamId,
        groupName: groupName,
        rank: rank,
      );
      _mockData.add(newStanding);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> rollbackByJson(List<dynamic> jsonList) async {
    if (AppConfig.isDebug) {
      try {
        for (var json in jsonList) {
          FootballStanding standing = FootballStanding.fromJson(json);
          final int index = mockData.indexWhere(
            (s) =>
                s.tournamentId == standing.tournamentId &&
                s.teamId == standing.teamId,
          );

          if (index != -1) {
            _mockData[index] = standing;
          } else {
            return false;
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

  Future<Map<String, dynamic>> updateStanding(
    int tournamentId,
    int teamId, {
    int points = 0,
    int goalScored = 0,
    int goalConceded = 0,
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
          return {};
        }

        final FootballStanding standing = mockData.firstWhere(
          (s) => s.tournamentId == tournamentId && s.teamId == teamId,
        );
        Map<String, dynamic> result = {
          'table': "FootballStandings",
          'changes': [standing.toJson()],
        };
        standing.points += points;
        standing.goalsScored += goalScored;
        standing.goalsConceded += goalConceded;
        standing.won += won;
        standing.drawn += drawn;
        standing.lost += lost;
        _mockData[index] = standing;
        await orderRanksInTournamentByGroup(tournamentId, standing.groupName);
        return result;
      } catch (e) {
        return {};
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
    String groupName,
  ) async {
    if (AppConfig.isDebug) {
      return mockData
          .where(
            (standing) =>
                standing.tournamentId == tournamentId &&
                standing.groupName == groupName,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  int _standingSort(FootballStanding a, FootballStanding b) {
    // Ordina per punti
    if (b.points != a.points) {
      return b.points.compareTo(a.points);
    }

    // Ordina per differenza reti
    final int goalDifferenceA = a.goalsScored - a.goalsConceded;
    final int goalDifferenceB = b.goalsScored - b.goalsConceded;
    if (goalDifferenceB != goalDifferenceA) {
      return goalDifferenceB.compareTo(goalDifferenceA);
    }

    // Ordina per gol fatti
    if (b.goalsScored != a.goalsScored) {
      return b.goalsScored.compareTo(a.goalsScored);
    }

    // Ordina per gol subiti (meno è meglio)
    if (a.goalsConceded != b.goalsConceded) {
      return a.goalsConceded.compareTo(b.goalsConceded);
    }

    return Random().nextBool() ? 1 : -1; // Caso di parità completa
  }
}
