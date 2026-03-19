import 'package:atl_app/config/app_config.dart';
import 'base_repository.dart';
import '../../models/football_match.dart';
import '../db_controller.dart';
import 'dart:math';

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
      status: FootballMatchStatus.startHalf,
      tournamentId: 8,
      groupName: 'A',
      day: 1,
      scoreHome: 1,
      scoreAway: 0,
      scheduledStart: DateTime.now().subtract(const Duration(minutes: 23)),
      startMatch: DateTime.now().subtract(const Duration(minutes: 23)),
      halfTime: DateTime.now().subtract(const Duration(minutes: 3)),
      startHalf: DateTime.now(),
    ),
    FootballMatch(
      id: 2,
      homeTeamId: 6,
      awayTeamId: 7,
      status: FootballMatchStatus.finished,
      tournamentId: 8,
      groupName: 'A',
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
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'B',
      day: 1,
    ),
    FootballMatch(
      id: 4,
      homeTeamId: 10,
      awayTeamId: 11,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'B',
      day: 1,
    ),
    FootballMatch(
      id: 5,
      homeTeamId: 1,
      awayTeamId: 6,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'A',
      day: 2,
    ),
    FootballMatch(
      id: 6,
      homeTeamId: 5,
      awayTeamId: 7,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'A',
      day: 2,
    ),
    FootballMatch(
      id: 7,
      homeTeamId: 8,
      awayTeamId: 10,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'B',
      day: 2,
    ),
    FootballMatch(
      id: 8,
      homeTeamId: 9,
      awayTeamId: 11,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'B',
      day: 2,
    ),
    FootballMatch(
      id: 9,
      homeTeamId: 1,
      awayTeamId: 7,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'A',
      day: 3,
    ),
    FootballMatch(
      id: 10,
      homeTeamId: 5,
      awayTeamId: 6,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'A',
      day: 3,
    ),
    FootballMatch(
      id: 11,
      homeTeamId: 8,
      awayTeamId: 11,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'B',
      day: 3,
    ),
    FootballMatch(
      id: 12,
      homeTeamId: 9,
      awayTeamId: 10,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'B',
      day: 3,
    ),
    FootballMatch(
      id: 14,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'SF1',
    ),
    FootballMatch(
      id: 15,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'SF1',
    ),
    FootballMatch(
      id: 16,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'SF2',
    ),
    FootballMatch(
      id: 17,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'SF2',
    ),
    FootballMatch(
      id: 18,
      status: FootballMatchStatus.notScheduled,
      tournamentId: 8,
      groupName: 'FI',
    ),
  ];

  @override
  List<FootballMatch> get mockData => _mockData;

  Future<bool> insertMatch(
    int? homeTeamId,
    int? awayTeamId,
    int tournamentId,
    String group, {
    int? day,
  }) async {
    if (AppConfig.isDebug) {
      final int newId = _mockData.isEmpty ? 1 : _mockData.last.id + 1;
      final FootballMatch newMatch = FootballMatch(
        id: newId,
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        tournamentId: tournamentId,
        groupName: group,
        day: day,
        status: FootballMatchStatus.notScheduled,
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
    int qualified,
    bool round2GroupStage,
    bool round2FinalStage,
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

        if (groupTeams.length % 2 != 0) {
          groupTeams.add(
            -1,
          ); // Aggiungi un team fittizio (chi affronterà il bye riposerà)
        }

        final int n = groupTeams.length;
        final int numDays = n - 1;
        final int matchesPerDay = n ~/ 2;

        for (int day = 0; day < numDays; day++) {
          for (int match = 0; match < matchesPerDay; match++) {
            int home = (day + match) % (n - 1);
            int away = (n - 1 - match + day) % (n - 1);

            if (match == 0) {
              away = n - 1;
            }

            final bool random = Random().nextBool();

            if (random) {
              final int temp = home;
              home = away;
              away = temp;
            }

            if (groupTeams[home] != -1 && groupTeams[away] != -1) {
              if (await DB.FootballMatches.insertMatch(
                    groupTeams[home],
                    groupTeams[away],
                    tournamentId,
                    groupName,
                    day: day + 1,
                  ) ==
                  false) {
                return false;
              }

              if (round2GroupStage) {
                if (await DB.FootballMatches.insertMatch(
                      groupTeams[away],
                      groupTeams[home],
                      tournamentId,
                      groupName,
                      day: day + 1 + numDays,
                    ) ==
                    false) {
                  return false;
                }
              }
            }
          }
        }

        for (int i = 0; i < groupTeams.length; i++) {
          if (groupTeams[i] != -1) {
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
      }

      // Definisci la struttura delle fasi eliminatorie
      final List<Map<String, dynamic>> knockoutPhases = [
        {'qualified': 16, 'prefix': 'OF', 'matches': 8},
        {'qualified': 8, 'prefix': 'QF', 'matches': 4},
        {'qualified': 4, 'prefix': 'SF', 'matches': 2},
        {'qualified': 2, 'prefix': 'FI', 'matches': 1},
      ];

      for (var phase in knockoutPhases) {
        final int phaseQualified = phase['qualified'] as int;
        final String phasePrefix = phase['prefix'] as String;
        final int phaseMatches = phase['matches'] as int;

        if (qualified >= phaseQualified) {
          for (int i = 1; i <= phaseMatches; i++) {
            String matchGroup = phaseMatches == 1
                ? phasePrefix
                : '$phasePrefix$i';

            if (await DB.FootballMatches.insertMatch(
                  null,
                  null,
                  tournamentId,
                  matchGroup,
                ) ==
                false) {
              return false;
            }

            if (round2FinalStage && phaseQualified > 2) {
              if (await DB.FootballMatches.insertMatch(
                    null,
                    null,
                    tournamentId,
                    matchGroup,
                  ) ==
                  false) {
                return false;
              }
            }
          }
        }
      }

      if (await DB.FootballStandings.updateTeamsQualified(
            tournamentId,
            qualified,
            numGroups,
            toBeOrdered: true,
          ) ==
          false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<Map<String, dynamic>> updateKnockOutMatch(
    int tournamentId,
    String groupName,
    bool round2FinalStage, {
    int? homeTeamId,
    int? awayTeamId,
  }) async {
    if (AppConfig.isDebug) {
      try {
        // Trova le partite corrispondenti
        final List<int> ids = [];

        for (final match in mockData) {
          if (match.tournamentId == tournamentId && match.groupName == groupName) {
            ids.add(match.id);
          }
        }

        if (ids.isEmpty ||
            (ids.length != 2 && round2FinalStage) ||
            (round2FinalStage == false && ids.length != 1)) {
          return {};
        }

        Map<String, dynamic> result = {};
        // Aggiorna le partite trovate
        for (final id in ids) {
          final int index = mockData.indexWhere((match) => match.id == id);
          if (index == -1) {
            return {};
          }
          result = {
            'table': "FootballMatch",
            'changes': [_mockData[index].toJson()],
          };
          _mockData[index].homeTeamId = homeTeamId;
          _mockData[index].awayTeamId = awayTeamId;
        }

        return result;
      } catch (e) {
        return {};
      }
    } else {
      throw UnimplementedError();
    }
  }

  // Controlla se, nella fase finale, esiste una seconda partita per lo stesso gruppo (round 2)
  Future<bool> isThereRound2Final(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        final bool isRound2 =
            mockData
                .where(
                  (m) =>
                      m.tournamentId == match.tournamentId &&
                      m.groupName == match.groupName,
                )
                .length ==
            2;

        return isRound2;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isSecondLegFinalStage(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        final bool isRound2 = await isThereRound2Final(matchId);

        if (!isRound2) {
          return false;
        }

        List<FootballMatch> matches = mockData
            .where(
              (m) =>
                  m.tournamentId == match.tournamentId &&
                  m.groupName == match.groupName,
            )
            .toList();

        matches.remove(match);

        return matches[0].status == FootballMatchStatus.finished;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<FootballMatch?> getOtherLegFinalPhase(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        final bool isRound2 = await isThereRound2Final(matchId);

        if (!isRound2) {
          return null;
        }

        List<FootballMatch> matches = mockData
            .where(
              (m) =>
                  m.tournamentId == match.tournamentId &&
                  m.groupName == match.groupName,
            )
            .toList();

        matches.remove(match);

        return matches[0];
      } catch (e) {
        return null;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<int> getMatchWinner(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        if (match.status != FootballMatchStatus.finished) {
          return -1;
        }

        if (match.penaltyScoreHome != null && match.penaltyScoreAway != null) {
          return match.penaltyScoreHome! > match.penaltyScoreAway!
              ? match.homeTeamId!
              : match.awayTeamId!;
        } else {
          return match.scoreHome! > match.scoreAway!
              ? match.homeTeamId!
              : match.awayTeamId!;
        }
      } catch (e) {
        return -1;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> startPenaltyShootOut(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }

        if (await canMatchFinish(matchId)) {
          return false;
        }

        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        match.status = FootballMatchStatus.penaltyShootOut;
        _mockData[index] = match;
        return true;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  bool _handlePenaltyScore(FootballMatch match) {
    final int penaltyScoredHome = match.penaltyScoreHome ?? 0;
    final int penaltyScoredAway = match.penaltyScoreAway ?? 0;
    final int penaltyMissedHome = match.missedPenaltyHome ?? 0;
    final int penaltyMissedAway = match.missedPenaltyAway ?? 0;

    // Calcola i rigori totali calciati per squadra
    final int totalPenaltiesHome = penaltyScoredHome + penaltyMissedHome;
    final int totalPenaltiesAway = penaltyScoredAway + penaltyMissedAway;

    // Calcola i rigori rimanenti per squadra
    final int remainingHome = 5 - totalPenaltiesHome;
    final int remainingAway = 5 - totalPenaltiesAway;

    // Se siamo ancora nei primi 5 rigori
    if (totalPenaltiesHome <= 5 || totalPenaltiesAway <= 5) {
      // Calcola il massimo di rigori che ogni squadra può ancora segnare
      final int maxPossibleHome = penaltyScoredHome + remainingHome;
      final int maxPossibleAway = penaltyScoredAway + remainingAway;

      // Se una squadra non può più pareggiare, il match può finire
      if (penaltyScoredHome > maxPossibleAway ||
          penaltyScoredAway > maxPossibleHome) {
        return true;
      }

      // Altrimenti può finire solo se entrambe hanno calciato 5 rigori e non è parità
      if (totalPenaltiesHome >= 5 && totalPenaltiesAway >= 5) {
        return penaltyScoredHome != penaltyScoredAway;
      }

      return false;
    } else {
      // Fase ad oltranza: può finire solo se c'è differenza e hanno calciato lo stesso numero
      return penaltyScoredHome != penaltyScoredAway &&
          totalPenaltiesHome == totalPenaltiesAway;
    }
  }

  Future<bool> canMatchFinish(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        if (match.status != FootballMatchStatus.startHalf &&
            match.status != FootballMatchStatus.penaltyShootOut) {
          return false;
        }

        if (match.groupName.length <= 2 && match.status == FootballMatchStatus.startHalf) {
          // Fase a gironi
          return true;
        }

        final bool isRound2 = await isThereRound2Final(matchId);
        final bool isSecondLeg = await isSecondLegFinalStage(matchId);

        if (!isRound2) {
          // Non è andata e ritorno, devo ritornare vero se non è in parità
          if (match.status == FootballMatchStatus.penaltyShootOut) {
            return _handlePenaltyScore(match);
          } else {
            return match.scoreHome != match.scoreAway;
          }
        } else {
          if (!isSecondLeg) {
            // Andata e ritorno, non è ancora la seconda partita
            return true;
          } else {
            // Andata e ritorno, seconda partita, controllo il risultato aggregato
            // Round 2 e seconda partita, posso finire solo se il risultato aggregato non è in parità
            if (match.status == FootballMatchStatus.penaltyShootOut) {
              return _handlePenaltyScore(match);
            }

            FootballMatch otherLeg = (await getOtherLegFinalPhase(matchId))!;

            int aggregateScoreHome = match.scoreHome ?? 0;
            int aggregateScoreAway = match.scoreAway ?? 0;
            aggregateScoreHome += (otherLeg.scoreHome ?? 0);
            aggregateScoreAway += (otherLeg.scoreAway ?? 0);

            return aggregateScoreHome != aggregateScoreAway;
          }
        }
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> isPenaltyShootOut(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        return match.status == FootballMatchStatus.penaltyShootOut;
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<Map<String, dynamic>> addMissedPenalty(int matchId, int teamId) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return {};
        }

        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        if (match.status != FootballMatchStatus.penaltyShootOut) {
          return {};
        }

        Map<String, dynamic> result = {
          'table': "FootballMatch",
          'changes': [match.toJson()],
        };

        if (match.homeTeamId == teamId) {
          match.missedPenaltyHome = (match.missedPenaltyHome ?? 0) + 1;
        } else if (match.awayTeamId == teamId) {
          match.missedPenaltyAway = (match.missedPenaltyAway ?? 0) + 1;
        }
        _mockData[index] = match;
        return result;
      } catch (e) {
        return {};
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> rollbackByJson(List<dynamic> jsonList) async {
    if (AppConfig.isDebug) {
      try {
        for (var json in jsonList) {
          final int index = mockData.indexWhere(
            (match) => match.id == json['id'],
          );
          if (index != -1) {
            _mockData[index] = FootballMatch.fromJson(json);
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

  // Gestisce il goal segnato nella fase finali e calcola il vincitore per la fase successiva
  Future<List<Map<String, dynamic>>> handleGoalInFinalStage(
    int matchId,
    bool isGoalForHome,
  ) async {
    if (AppConfig.isDebug) {
      try {
        FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        // Siamo in finale, non c'è partita successiva da aggiornare
        if (match.groupName == 'FI') {
          return [];
        }

        final bool isRound2 = await isThereRound2Final(matchId);

        // Trova la partita successiva
        String nextGroup;
        if (match.groupName.startsWith('OF')) {
          nextGroup =
              'QF${((int.parse(match.groupName.substring(2)) + 1) / 2).ceil()}';
        } else if (match.groupName.startsWith('QF')) {
          nextGroup =
              'SF${((int.parse(match.groupName.substring(2)) + 1) / 2).ceil()}';
        } else if (match.groupName.startsWith('SF')) {
          nextGroup = 'FI';
        } else {
          return [];
        }

        int aggregateScoreHome = match.scoreHome ?? 0;
        int aggregateScoreAway = match.scoreAway ?? 0;

        final bool willBeHome = (int.parse(match.groupName.substring(2))) % 2 == 1;
        List<FootballMatch> nextMatches = await getMatchesByGroup(
          match.tournamentId,
          nextGroup,
        );

        if (match.status != FootballMatchStatus.penaltyShootOut) {
          if (isRound2) {
            final FootballMatch otherLeg = (await getOtherLegFinalPhase(
              matchId,
            ))!;
            aggregateScoreHome += (otherLeg.scoreHome ?? 0);
            aggregateScoreAway += (otherLeg.scoreAway ?? 0);
          }
        } else {
          match.penaltyScoreHome =
              (match.penaltyScoreHome ?? 0) + (isGoalForHome ? 1 : 0);
          match.penaltyScoreAway =
              (match.penaltyScoreAway ?? 0) + (isGoalForHome ? 0 : 1);
        }

        List<Map<String, dynamic>> result = [
          {
            'table': "FootballMatch",
            'changes': [match.toJson()],
          },
        ];

        if ((aggregateScoreAway == aggregateScoreHome &&
                match.status == FootballMatchStatus.penaltyShootOut) ||
            (match.penaltyScoreHome == match.missedPenaltyAway &&
                match.status == FootballMatchStatus.penaltyShootOut)) {
          // Pareggio, imposto a null i match successivi
          if (willBeHome) {
            result.add(
              await updateKnockOutMatch(
                match.tournamentId,
                nextGroup,
                isRound2,
                homeTeamId: null,
                awayTeamId: nextMatches[0].awayTeamId,
              ),
            );
          } else {
            result.add(
              await updateKnockOutMatch(
                match.tournamentId,
                nextGroup,
                isRound2,
                homeTeamId: nextMatches[0].homeTeamId,
                awayTeamId: null,
              ),
            );
          }
        } else if (aggregateScoreHome > aggregateScoreAway) {
          // Passa la squadra di casa
          if (willBeHome) {
            result.add(
              await updateKnockOutMatch(
                match.tournamentId,
                nextGroup,
                isRound2,
                homeTeamId: match.homeTeamId,
                awayTeamId: nextMatches[0].awayTeamId,
              ),
            );
          } else {
            result.add(
              await updateKnockOutMatch(
                match.tournamentId,
                nextGroup,
                isRound2,
                homeTeamId: nextMatches[0].homeTeamId,
                awayTeamId: match.homeTeamId,
              ),
            );
          }
        } else if (aggregateScoreAway > aggregateScoreHome) {
          // Passa la squadra ospite
          if (willBeHome) {
            result.add(
              await updateKnockOutMatch(
                match.tournamentId,
                nextGroup,
                isRound2,
                homeTeamId: match.awayTeamId,
                awayTeamId: nextMatches[0].awayTeamId,
              ),
            );
          } else {
            result.add(
              await updateKnockOutMatch(
                match.tournamentId,
                nextGroup,
                isRound2,
                homeTeamId: nextMatches[0].homeTeamId,
                awayTeamId: match.awayTeamId,
              ),
            );
          }
        }

        return result;
      } catch (e) {
        return [];
      }
    } else {
      throw UnimplementedError();
    }
  }

  /// ✅ AGGIUNGI questo metodo helper
  Future<bool> areAllMatchesFinished(int tournamentId, String prefix) async {
    final matches = await getMatchesByTournament(tournamentId);
    final phaseMatches = matches
        .where((m) => m.groupName.startsWith(prefix))
        .toList();

    if (phaseMatches.isEmpty) {
      return false; // Nessun match trovato
    }

    for (var match in phaseMatches) {
      if (match.status != FootballMatchStatus.finished) {
        return false; // C'è ancora un match non finito
      }
    }

    return true; // Tutti i match sono finiti
  }

  Future<bool> scheduleMatch(int matchId, DateTime scheduledStart) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return false;
        }

        _mockData[index].scheduledStart = scheduledStart;
        _mockData[index].status = FootballMatchStatus.scheduled;
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
        match.status = FootballMatchStatus.canceled;
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
        match.status = FootballMatchStatus.homeRetired;
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
        match.status = FootballMatchStatus.awayRetired;
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
        match.status = FootballMatchStatus.started;
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
        match.status = FootballMatchStatus.halftime;
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
        match.status = FootballMatchStatus.startHalf;
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
        match.status = FootballMatchStatus.finished;
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

  Future<Map<String, dynamic>> updateScore(
    int matchId, {
    required bool isHome,
  }) async {
    if (AppConfig.isDebug) {
      try {
        final int index = mockData.indexWhere((match) => match.id == matchId);
        if (index == -1) {
          return {};
        }
        final FootballMatch match = mockData.firstWhere(
          (match) => match.id == matchId,
        );

        Map<String, dynamic> result = {
          'table': "FootballMatch",
          'changes': [match.toJson()],
        };

        if (isHome) {
          match.scoreHome = (match.scoreHome ?? 0) + 1;
        } else {
          match.scoreAway = (match.scoreAway ?? 0) + 1;
        }
        _mockData[index] = match;
        return result;
      } catch (e) {
        return {};
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
    if (AppConfig.isDebug) {
      return mockData
          .where((match) => match.tournamentId == tournamentId)
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballMatch>> getMatchesByGroup(
    int tournamentId,
    String group,
  ) async {
    if (AppConfig.isDebug) {
      return mockData
          .where(
            (match) =>
                match.tournamentId == tournamentId && match.groupName == group,
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<FootballMatch>> getScheduledMatchesByTournament(
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      return mockData
          .where(
            (match) =>
                match.tournamentId == tournamentId &&
                (match.status == FootballMatchStatus.scheduled),
          )
          .toList();
    } else {
      throw UnimplementedError();
    }
  }
}
