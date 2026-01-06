import 'package:atl_app/config/app_config.dart';
import 'base_repository.dart';
import '../../models/football_match.dart';
import '../db_controller.dart';

/// Repository per la gestione delle partite di calcio

class FootballMatchRepository extends BaseRepository<FootballMatch> {
  @override
  String get endpoint => 'football_matches';

  @override
  FootballMatch fromJson(Map<String, dynamic> json) =>
      FootballMatch.fromJson(json);

  @override
  Map<String, dynamic> toJson(FootballMatch item) => item.toJson();

  List<FootballMatch> _mockData = [
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
      startHalf: DateTime.now(),
    ),
    FootballMatch(
      id: 2,
      homeTeamId: 6,
      awayTeamId: 7,
      status: MatchStatus.finished,
      tournamentId: 8,
      group: 'A',
      day: 1,
      startMatch: DateTime.now().subtract(const Duration(hours: 2)),
      halfTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 40)),
      startHalf: DateTime.now().subtract(const Duration(hours: 1, minutes: 37)),
      endMatch: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
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
    FootballMatch(
      id: 5,
      homeTeamId: 1,
      awayTeamId: 6,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'A',
      day: 2,
    ),
    FootballMatch(
      id: 6,
      homeTeamId: 5,
      awayTeamId: 7,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'A',
      day: 2,
    ),
    FootballMatch(
      id: 7,
      homeTeamId: 8,
      awayTeamId: 10,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'B',
      day: 2,
    ),
    FootballMatch(
      id: 8,
      homeTeamId: 9,
      awayTeamId: 11,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'B',
      day: 2,
    ),
    FootballMatch(
      id: 9,
      homeTeamId: 1,
      awayTeamId: 7,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'A',
      day: 3,
    ),
    FootballMatch(
      id: 10,
      homeTeamId: 5,
      awayTeamId: 6,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'A',
      day: 3,
    ),
    FootballMatch(
      id: 11,
      homeTeamId: 8,
      awayTeamId: 11,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'B',
      day: 3,
    ),
    FootballMatch(
      id: 12,
      homeTeamId: 9,
      awayTeamId: 10,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'B',
      day: 3,
    ),
    FootballMatch(
      id: 14,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'SF1',
    ),
    FootballMatch(
      id: 15,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'SF1',
    ),
    FootballMatch(
      id: 16,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'SF2',
    ),
    FootballMatch(
      id: 17,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'SF2',
    ),
    FootballMatch(
      id: 18,
      status: MatchStatus.notScheduled,
      tournamentId: 8,
      group: 'FI',
    ),
  ];

  @override
  List<FootballMatch> get mockData => _mockData;

  Future<bool> insertMatch(
    int homeTeamId,
    int awayTeamId,
    int tournamentId,
    String group,
    int day,
  ) async {
    if (AppConfig.isDebug) {
      final int newId = _mockData.length + 1;
      final FootballMatch newMatch = FootballMatch(
        id: newId,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        tournamentId: tournamentId,
        group: group,
        day: day,
      );
      _mockData.add(newMatch);
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> generateMatches(
    int tournamentId,
    List<int> teamIds,
    int numGroups,
    bool round2GroupStage,
  ) async {
    if (AppConfig.isDebug) {
      final List<int> shuffledTeams = List.from(teamIds)..shuffle();
      final int teamsPerGroup = teamIds.length ~/ numGroups;

      for (int groupIndex = 0; groupIndex < numGroups; groupIndex++) {
        final String groupName = String.fromCharCode(
          65 + groupIndex,
        ); // 'A', 'B', 'C', ...
        final List<int> groupTeams = shuffledTeams
            .skip(groupIndex * teamsPerGroup)
            .take(teamsPerGroup)
            .toList();

        int day = 1;
        for (int i = 0; i < groupTeams.length; i++) {
          for (int j = i + 1; j < groupTeams.length; j++) {
            if (await insertMatch(
                  groupTeams[i],
                  groupTeams[j],
                  tournamentId,
                  groupName,
                  day,
                ) ==
                false) {
              return false;
            }
            day++;
          }
        }

        day = teamsPerGroup;
        if (round2GroupStage) {
          for (int i = 0; i < groupTeams.length; i++) {
            for (int j = i + 1; j < groupTeams.length; j++) {
              if (await insertMatch(
                    groupTeams[j],
                    groupTeams[i],
                    tournamentId,
                    groupName,
                    day,
                  ) ==
                  false) {
                return false;
              }
              day++;
            }
          }
        }

        for (int i = 0; i < groupTeams.length; i++) {
          if (await DB.FootballStandings.insertStandings(
                tournamentId,
                groupTeams[i],
                groupName,
                0,
              ) ==
              false) {
            return false;
          }
        }
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> scheduleMatch(int matchId, DateTime scheduledStart) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        match.scheduledStart = scheduledStart;
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> cancelMatch(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        match.status = MatchStatus.canceled;
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> setMotmPlayer(int matchId, int playerId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        match.motmPlayerId = playerId;
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> homeRetire(int matchId, int teamId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        if (match.homeTeamId != teamId) {
          return false;
        }
        match.status = MatchStatus.homeRetired;
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> awayRetire(int matchId, int teamId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        if (match.homeTeamId != teamId) {
          return false;
        }
        match.status = MatchStatus.awayRetired;
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> startMatch(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        match.status = MatchStatus.started;
        match.startMatch = DateTime.now();
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> halftimeMatch(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        match.status = MatchStatus.halftime;
        match.halfTime = DateTime.now();
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> startHalfMatch(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        match.status = MatchStatus.startHalf;
        match.startHalf = DateTime.now();
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> finishMatch(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        match.status = MatchStatus.finished;
        match.endMatch = DateTime.now();
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updateScore(int matchId, {required bool isHome}) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );
        if (isHome) {
          match.scoreHome = (match.scoreHome ?? 0) + 1;
        } else {
          match.scoreAway = (match.scoreAway ?? 0) + 1;
        }
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

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
