import 'db_controller.dart';
import '../config/app_config.dart';
import '../../models/sport_category.dart';
import 'dart:math';
import 'dart:convert';

class DBWrite {
  static Future<bool> createTeam(
    int? cityId,
    String name,
    String alias,
    String? description,
    int captainId,
    String catId,
    String? imageUrl,
    bool vip,
    bool visibility,
  ) async {
    if (AppConfig.isDebug == true) {
      final int id = await DB.Teams.insertTeam(
        cityId,
        name,
        alias,
        description,
        captainId,
        catId,
        imageUrl,
        vip,
        visibility,
      );
      if (id == -1) {
        return false;
      }
      if ((await DB.TeamStats.createStats(
            playerId: captainId,
            teamId: id,
            motm: 0,
            goals: 0,
          )) ==
          false) {
        return false;
      }
      if ((await DB.Players.joinTeam(captainId, id)) == false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> confirmCallUps(
    int tournamentId,
    int teamId,
    Set<int> selectedPlayerIds,
    double tournamentFee,
  ) async {
    if (AppConfig.isDebug == true) {
      await DB.CallUps.deleteCallUps(tournamentId, teamId);

      bool canContinue = false;
      for (int playerId in selectedPlayerIds) {
        if ((await DB.Teams.isCaptainOrVice(teamId, playerId)) == true) {
          canContinue = true;
          break;
        }
      }

      if (canContinue == false) {
        return false;
      }

      final int sportId = (await DB.Tournaments.getById(tournamentId))!.sportId;
      final int maxPlayers = (await DB.Sports.getById(
        sportId,
      ))!.maxPlayersPerTeam;
      final int minPlayers = (await DB.Sports.getById(
        sportId,
      ))!.minPlayersPerTeam;

      if (selectedPlayerIds.length < minPlayers ||
          selectedPlayerIds.length > maxPlayers) {
        return false;
      }

      if (await DB.Tournaments.isFull(tournamentId)) {
        return false;
      }

      if (await DB.Teams.getById(teamId) == null) {
        return false;
      }

      for (int playerId in selectedPlayerIds) {
        if ((await DB.CallUps.addCallUp(tournamentId, teamId, playerId)) ==
            false) {
          await DB.CallUps.deleteCallUps(tournamentId, teamId);
          return false;
        }
      }

      if ((await DB.TournamentParticipations.addParticipation(
            tournamentId,
            teamId,
            tournamentFee,
          )) ==
          false) {
        await DB.CallUps.deleteCallUps(tournamentId, teamId);
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deleteCallups(int tournamentId, int teamId) async {
    if (AppConfig.isDebug) {
      if (await DB.CallUps.deleteByTournamentAndTeam(tournamentId, teamId) ==
          false) {
        return false;
      }
      if (await DB.TournamentParticipations.deleteParticipation(
            tournamentId,
            teamId,
          ) ==
          false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> acceptRequestToTeam(int playerId, int teamId) async {
    if (AppConfig.isDebug == true) {
      if ((await DB.Teams.getById(teamId))?.players == 24) {
        return false;
      }

      if ((await DB.Players.joinTeam(playerId, teamId)) == false) {
        return false;
      }
      if ((await DB.TeamRequests.deleteByPlayerId(playerId)) == false) {
        return false;
      }

      if ((await DB.TeamStats.createStats(
            playerId: playerId,
            teamId: teamId,
            motm: 0,
            goals: 0,
          )) ==
          false) {
        return false;
      }

      if ((await DB.Teams.updatePlayerCount(teamId, 1)) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> createLobby(
    int fieldId,
    int ownerId,
    int maxPlayers,
    int playerToFind,
    double feePerPlayer,
    DateTime startDateTime,
    DateTime endDateTime,
  ) async {
    if (AppConfig.isDebug == true) {
      final id = await DB.LobbyBookings.addLobbyBooking(
        ownerId,
        fieldId,
        startDateTime,
        endDateTime,
        maxPlayers,
        playerToFind,
        feePerPlayer,
      );
      if (id == -1) {
        return false;
      }

      if ((await DB.LobbyBookingParticipations.addParticipation(
            id,
            ownerId,
            maxPlayers - playerToFind,
          )) ==
          false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> joinLobby(
    int lobbyBookingId,
    int playerId,
    int playersPaid,
  ) async {
    if (AppConfig.isDebug == true) {
      if ((await DB.LobbyBookingParticipations.addParticipation(
            lobbyBookingId,
            playerId,
            playersPaid,
          )) ==
          false) {
        return false;
      }

      if ((await DB.LobbyBookings.decreasePlayersToFind(
            lobbyBookingId,
            playersPaid,
          )) ==
          false) {
        await DB.LobbyBookingParticipations.removeParticipation(
          playerId,
          lobbyBookingId,
        );
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deleteLobby(
    int lobbyBookingId,
    int playerId, {
    deleteAccount = false,
  }) async {
    if (AppConfig.isDebug == true) {
      if ((await DB.LobbyBookings.getById(lobbyBookingId))?.ownerId !=
          playerId) {
        return false;
      }
      if ((await DB.LobbyBookingParticipations.removeLobbyParticipation(
            lobbyBookingId,
          )) ==
          false) {
        return false;
      }
      if ((await DB.LobbyBookings.removeLobbyBooking(lobbyBookingId)) ==
          false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> leaveLobby(
    int lobbyBookingId,
    int playerId, {
    deleteAccount = false,
  }) async {
    if (AppConfig.isDebug == true) {
      if ((await DB.LobbyBookings.getById(lobbyBookingId))?.ownerId ==
          playerId) {
        return deleteLobby(
          lobbyBookingId,
          playerId,
          deleteAccount: deleteAccount,
        );
      }
      int? playersPaid =
          (await DB.LobbyBookingParticipations.getByPlayerAndLobbyBookingId(
            playerId,
            lobbyBookingId,
          ))?.playersPaid;
      if (playersPaid == null) {
        return false;
      }
      if ((await DB.LobbyBookingParticipations.removeParticipation(
            playerId,
            lobbyBookingId,
          )) ==
          false) {
        return false;
      }

      if ((await DB.LobbyBookings.increasePlayersToFind(
            lobbyBookingId,
            playersPaid,
          )) ==
          false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> leaveTeam(
    int teamId,
    int playerId, {
    deleteAccount = false,
  }) async {
    if (AppConfig.isDebug == true) {
      if ((await DB.Teams.isTeamLeftable(teamId, playerId)) == false) {
        return false;
      }

      List<int> activeTournamentsId = (await DB.Tournaments.getActive())
          .map((t) => t.id)
          .toList();

      for (final tournamentId in activeTournamentsId) {
        if (await DB.CallUps.getPlayersInTeamInTournament(
              tournamentId,
              teamId,
            ).then((players) => players.contains(playerId)) ==
            true) {
          return false;
        }
      }

      if ((await DB.Teams.isCaptain(teamId, playerId) == true)) {
        if (await DB.Teams.assignCaptain(teamId) == false) {
          return false;
        }
      } else if ((await DB.Teams.isVice1(teamId, playerId) == true)) {
        if ((await DB.Teams.updateVice1(teamId)) == false) {
          return false;
        }
      }

      if ((await DB.PlaysAt.removePlaysAt(teamId, playerId)) == false ||
          (await DB.TeamStats.deleteByPlayerIdInTeam(playerId, teamId)) ==
              false ||
          (await DB.CallUps.deleteByPlayerAndTeam(playerId, teamId)) == false ||
          (await DB.Teams.updatePlayerCount(teamId, -1) == false)) {
        return false;
      }

      if ((await DB.Teams.getById(teamId))?.players == 0) {
        if ((await DB.Teams.disableTeam(teamId)) == false) {
          return false;
        }
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deleteAccount(int id, String passwordMD5) async {
    if (AppConfig.isDebug) {
      if ((await DB.Users.getByUserId(id))?.passwordMD5 != passwordMD5) {
        return false;
      }

      if ((await DB.Users.getByUserId(id))!.isPlayer) {
        final playerId = (await DB.Players.getByUserId(id))!.playerId;
        final List<int> teamIds = await DB.PlaysAt.getByPlayerId(
          playerId,
        ).then((playsAtList) => playsAtList!.map((pa) => pa.teamId).toList());

        for (final teamId in teamIds) {
          if ((await leaveTeam(teamId, playerId, deleteAccount: true)) ==
              false) {
            return false;
          }
        }

        final List<int> lobbyIds =
            await DB.LobbyBookingParticipations.getByPlayerId(playerId).then(
              (participations) =>
                  participations.map((p) => p.lobbyBookingId).toList(),
            );

        for (final lobbyId in lobbyIds) {
          if ((await leaveLobby(lobbyId, playerId, deleteAccount: true)) ==
              false) {
            return false;
          }
        }
      }

      if (await DB.Users.deleteAccount(id, passwordMD5) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> updatePayment(
    int tournamentId,
    int teamId,
    double amount,
  ) async {
    if (AppConfig.isDebug) {
      double newToPay =
          ((await DB.TournamentParticipations.getByTournamentAndTeam(
            tournamentId,
            teamId,
          ))?.toPay ??
          0);

      newToPay -= amount;

      if (newToPay < 0) {
        return false;
      }

      if (await DB.TournamentParticipations.updatePayment(
            tournamentId,
            teamId,
            newToPay,
          ) ==
          false) {
        return false;
      }
      if (newToPay == 0 &&
          (await DB.Tournaments.incrementPaidTeams(tournamentId)) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> homeRetire(
    int matchId,
    int teamId,
    int playerRequestingId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        final tournamentId = (await DB.FootballMatches.getById(
          matchId,
        ))!.tournamentId;
        if ((await DB.Teams.isCaptainOrVice(teamId, playerRequestingId)) ==
                false ||
            (await DB.CallUps.isPlayerInCallup(
              playerRequestingId,
              tournamentId,
            ))) {
          return false;
        }
        return DB.FootballMatches.homeRetire(matchId, teamId);
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> awayRetire(
    int matchId,
    int teamId,
    int playerRequestingId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        final tournamentId = (await DB.FootballMatches.getById(
          matchId,
        ))!.tournamentId;
        if ((await DB.Teams.isCaptainOrVice(teamId, playerRequestingId)) ==
                false ||
            (await DB.CallUps.isPlayerInCallup(
                  playerRequestingId,
                  tournamentId,
                )) ==
                false) {
          return false;
        }
        return DB.FootballMatches.awayRetire(matchId, teamId);
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> scheduleMatch(
    int matchId,
    DateTime scheduledStart,
    int coordinatorId,
  ) async {
    if (AppConfig.isDebug) {
      if (scheduledStart.isBefore(DateTime.now().add(Duration(hours: 1)))) {
        return false; // Non si può schedulare una partita con meno di 1 ora di anticipo
      }
      try {
        final int tournamentId = (await DB.FootballMatches.getById(
          matchId,
        ))!.tournamentId;
        final int fieldId = (await DB.Tournaments.getById(
          tournamentId,
        ))!.fieldId;

        final int sportId = await DB.Tournaments.getById(
          tournamentId,
        ).then((t) => t!.sportId);

        final int minutesPerRound = (await DB.Sports.getById(
          sportId,
        ))!.minutesPerRound;

        final int minutesPerPause = (await DB.Sports.getById(
          sportId,
        ))!.minutesPerPause;

        final String sportCategory = (await DB.Sports.getById(
          sportId,
        ))!.category.toString().split('.').last;

        final DateTime startTime = scheduledStart.subtract(
          Duration(minutes: 15), // buffer di 15 minuti prima
        );

        final DateTime finishTime = scheduledStart.add(
          Duration(
            minutes: (minutesPerRound * 2) + minutesPerPause + 15,
          ), // buffer di 30 minuti
        );

        if (await DB.Bookings.isFieldFree(fieldId, startTime, finishTime) ==
            false) {
          return false; // Il campo non è libero in quel lasso di tempo
        }

        if (coordinatorId !=
            (await DB.Tournaments.getById(tournamentId))!.coordinatorId) {
          return false;
        }

        String status = (await DB.FootballMatches.getById(
          matchId,
        ))!.status.toString().split('.').last;

        if (status == 'scheduled') {
          final DateTime oldStartTime = (await DB.MatchBookings.getByMatchId(
            matchId,
          ))!.startTime;

          if (oldStartTime == startTime) {
            return true; // Nessuna modifica necessaria
          } else if (oldStartTime.difference(DateTime.now()).inHours < 24) {
            return false; // Non si può modificare con meno di 24 ore di anticipo
          }

          await DB.MatchBookings.deleteByMatchId(matchId);
          status = 'notScheduled';
        }

        if (status != 'notScheduled') {
          return false;
        }

        if (await DB.MatchBookings.addMatchBooking(
              coordinatorId,
              matchId,
              fieldId,
              startTime,
              finishTime,
            ) ==
            false) {
          return false;
        }

        if (sportCategory == 'football' || sportCategory == 'FOOTBALL') {
          return await DB.FootballMatches.scheduleMatch(
            matchId,
            scheduledStart,
          );
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> insertEventMatch(
    int matchId,
    String type, {
    int? playerId,
    int teamId = 0,
  }) async {
    if (AppConfig.isDebug) {
      try {
        final int tournamentId = (await DB.FootballMatches.getById(
          matchId,
        ))!.tournamentId;

        final int sportId = (await DB.Tournaments.getById(
          tournamentId,
        ))!.sportId;

        final int numReferees =
            await DB.RefereeAssignments.countRefereesPerMatch(matchId);

        if (numReferees != 1 &&
            (sportId == 1 || sportId == 2 || sportId == 3)) {
          // 1 arbitro per football 5, 7, 8
          return false;
        } else if (numReferees != 3 && sportId == 4) {
          // 3 arbitri per football 11
          return false;
        } else if (sportId > 4) {
          // Aggiungi altre condizioni per altri sport se necessario
          return false;
        }

        final int minutesPerRound = (await DB.Sports.getById(
          sportId,
        ))!.minutesPerRound;

        final bool isGroupStage = (await DB.Tournaments.getById(
          tournamentId,
        ))!.isGroupStage;

        final SportCategory sportCategory = (await DB.Sports.getById(
          sportId,
        ))!.category;

        if (sportCategory == SportCategory.football) {
          return await _handleFootballEvent(
            matchId,
            type,
            minutesPerRound,
            isGroupStage,
            tournamentId,
            playerId: playerId,
            teamId: teamId,
          );
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> _handleFootballEvent(
    int matchId,
    String type,
    int minutesPerRound,
    bool isGroupStage,
    int tournamentId, {
    int? playerId,
    int teamId = 0,
  }) async {
    if (AppConfig.isDebug == true) {
      /* EVENT TYPES:
        redCard,
        yellowCard,
        redYellowCard,
        -------------
        goal,
        penalty,
        ownGoal,
        missedPenalty,
        -------------
        start,
        halftime,
        startHalf,
        finish,
  */

      final bool isStart = type == 'start';
      final bool isStartHalf = type == 'startHalf';
      final DateTime eventTime = DateTime.now();

      if (await DB.FootballMatches.isPenaltyShootOut(matchId) &&
          ((await DB.FootballMatches.canMatchFinish(matchId) &&
                  type != 'finish') ||
              (type != 'penalty' && type != 'missedPenalty'))) {
        return false;
      }

      DateTime? startTime;
      final bool matchStarted = await DB.FootballMatchEvents.isMatchStarted(
        matchId,
      );
      final bool matchHalfStarted =
          await DB.FootballMatchEvents.isMatchHalfStarted(matchId);

      if (matchHalfStarted) {
        startTime = await DB.FootballMatchEvents.getMatchStartHalf(matchId);
      } else if (matchStarted) {
        startTime = await DB.FootballMatchEvents.getMatchStartTime(matchId);
      }

      int minute = 0;
      int additionalMinute = 0;
      if (isStart) {
        minute = 0;
      } else if (isStartHalf) {
        minute = minutesPerRound;
      } else if (startTime != null) {
        minute = eventTime.difference(startTime).inMinutes;
        additionalMinute = max(0, minute - minutesPerRound);
        if (matchHalfStarted) {
          minute += minutesPerRound;
        }
      } else {
        return false;
      }

      if (playerId != null &&
          await DB.FootballMatchEvents.isPlayerSentOff(matchId, playerId)) {
        return false; // Non inserire l'evento se il giocatore è già stato espulso
      }

      if (playerId != null &&
          await DB.FootballMatchEvents.isPlayerWarned(matchId, playerId)) {
        type = 'redYellowCard';
      }

      final int? eventId = await DB.FootballMatchEvents.insertEvent(
        matchId,
        type,
        minute,
        eventTime,
        additionalMinute: additionalMinute,
        playerId: playerId,
        teamId: teamId,
      );

      if (eventId == null) {
        return false;
      }

      final int? numberGroups = isGroupStage
          ? (await DB.Tournaments.getById(tournamentId))!.numGroups
          : null;

      final int? numberQualified = isGroupStage
          ? (await DB.Tournaments.getById(tournamentId))!.qualified
          : null;

      final int? homeTeam = (await DB.FootballMatches.getById(
        matchId,
      ))?.homeTeamId;
      final int? awayTeam = (await DB.FootballMatches.getById(
        matchId,
      ))?.awayTeamId;

      if (homeTeam == null || awayTeam == null) {
        return false;
      }

      if (type == 'start') {
        if (await DB.FootballMatches.startMatch(matchId) == false) {
          return false;
        }
        if (await DB.MatchBookings.startMatch(matchId) == false) {
          return false;
        }
        if (isGroupStage &&
            (await DB.FootballStandings.updateStanding(
                      tournamentId,
                      homeTeam,
                      points: 1,
                      drawn: 1,
                    ) ==
                    {} ||
                await DB.FootballStandings.updateStanding(
                      tournamentId,
                      awayTeam,
                      points: 1,
                      drawn: 1,
                    ) ==
                    {})) {
          return false;
        }
      } else if (type == 'halftime') {
        if (await DB.FootballMatches.halftimeMatch(matchId) == false) {
          return false;
        }
      } else if (type == 'startHalf') {
        if (await DB.FootballMatches.startHalfMatch(matchId) == false) {
          return false;
        }
      } else if (type == 'penaltyShootOut') {
        if (await DB.FootballMatches.startPenaltyShootOut(matchId) == false) {
          return false;
        }
      } else if (type == 'finish') {
        if (await DB.FootballMatches.finishMatch(matchId) == false) {
          return false;
        }
        if (await DB.MatchBookings.finishMatch(matchId) == false) {
          return false;
        }
      } else if ((type == 'goal' ||
          type == 'penalty' ||
          type == 'ownGoal' ||
          type == 'missedPenalty')) {
        if (playerId == null ||
            await _handleGoalCase(
                  playerId,
                  teamId,
                  type,
                  matchId,
                  tournamentId,
                  isGroupStage,
                  homeTeam,
                  awayTeam,
                  eventId,
                  numberGroups,
                  numberQualified,
                ) ==
                false) {
          return false;
        }
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> _handleGoalCase(
    int playerId,
    int teamId,
    String type,
    int matchId,
    int tournamentId,
    bool isGroupStage,
    int homeTeam,
    int awayTeam,
    int eventId,
    int? numberGroups,
    int? numberQualified,
  ) async {
    if (AppConfig.isDebug == true) {
      if (await DB.Players.getByPlayerId(playerId) == null) {
        return false;
      }

      final bool isPlayerInHome = teamId == homeTeam;

      final bool isGoalForHome = (type == 'ownGoal')
          ? !isPlayerInHome
          : isPlayerInHome;

      final int? currentHomeScore = (await DB.FootballMatches.getById(
        matchId,
      ))!.scoreHome;
      final int? currentAwayScore = (await DB.FootballMatches.getById(
        matchId,
      ))!.scoreAway;

      if (currentHomeScore == null || currentAwayScore == null) {
        return false;
      }

      List<Map<String, dynamic>> modifiedTables = [];
      Map<String, dynamic> result = {};

      if (await DB.FootballMatches.isPenaltyShootOut(matchId) == false &&
          type != 'missedPenalty') {
        result = await DB.FootballMatches.updateScore(
          matchId,
          isHome: isGoalForHome,
        );
        if (result == {}) {
          return false;
        } else {
          modifiedTables.add(result);
        }
      }

      if (isGroupStage) {
        if (type != 'missedPenalty') {
          final List<Map<String, dynamic>> resultList =
              await _handleFootballGroupStageGoal(
                isGoalForHome,
                currentHomeScore,
                currentAwayScore,
                tournamentId,
                homeTeam,
                awayTeam,
                numberGroups!,
                numberQualified!,
              );
          if (resultList == []) {
            return false;
          }
          modifiedTables.addAll(resultList);
        }
      } else {
        if (type == 'missedPenalty' &&
            await DB.FootballMatches.isPenaltyShootOut(matchId)) {
          result = await DB.FootballMatches.addMissedPenalty(matchId, teamId);
          if (result == {}) {
            return false;
          }
          modifiedTables.add(result);
        } else {
          final resultList = await DB.FootballMatches.handleGoalInFinalStage(
            matchId,
            isGoalForHome,
          );
          if (result == {}) {
            return false;
          }
          modifiedTables.addAll(resultList);
        }
      }
      if (type != 'ownGoal' &&
          type != 'missedPenalty' &&
          await DB.FootballMatches.isPenaltyShootOut(matchId) == false) {
        result = await DB.TeamStats.incrementStats(
          playerId,
          teamId,
          goalsIncrement: 1,
        );
        if (result == {}) {
          return false;
        } else {
          modifiedTables.add(result);
        }

        result = await DB.FootballTournamentStats.incrementStatsInTournament(
          playerId,
          teamId,
          tournamentId,
          goalsIncrement: 1,
        );
        if (result == {}) {
          return false;
        } else {
          modifiedTables.add(result);
        }

        result = await DB.PersonalStats.incrementStats(
          playerId,
          goalsIncrement: 1,
        );
        if (result == {}) {
          return false;
        } else {
          modifiedTables.add(result);
        }
      }

      // Unifica le entry per tabella
      Map<String, List<Map<String, dynamic>>> groupedTables = {};

      for (var entry in modifiedTables) {
        final String table = entry['table'];
        final List<dynamic> changes = entry['changes'];

        if (!groupedTables.containsKey(table)) {
          groupedTables[table] = [];
        }

        // Aggiungi i changes di questa entry
        groupedTables[table]!.addAll(changes.cast<Map<String, dynamic>>());
      }

      // Ricostruisci modifiedTables unificato
      List<Map<String, dynamic>> unifiedTables = [];
      groupedTables.forEach((table, changes) {
        unifiedTables.add({'table': table, 'changes': changes});
      });

      // Usa unifiedTables invece di modifiedTables
      final String jsonString = jsonEncode({"changes": unifiedTables});
      /*
      // Stampa la stringa in chunk di 800 caratteri
      final int chunkSize = 800;
      for (int i = 0; i < jsonString.length; i += chunkSize) {
        final int end = (i + chunkSize < jsonString.length)
            ? i + chunkSize
            : jsonString.length;
        print(
          'Modified tables part ${i ~/ chunkSize + 1}: ${jsonString.substring(i, end)}',
        );
      }
      */

      if (await DB.FootballMatchEvents.updateModifiedTables(
            eventId,
            jsonString,
          ) ==
          false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<List<Map<String, dynamic>>> _handleFootballGroupStageGoal(
    bool isGoalForHome,
    int currentHomeScore,
    int currentAwayScore,
    int tournamentId,
    int homeTeam,
    int awayTeam,
    int numberGroups,
    int numberQualified,
  ) async {
    List<Map<String, dynamic>> cumulativeResult = [];
    Map<String, dynamic> result = {};
    if (isGoalForHome && currentHomeScore > currentAwayScore) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalConceded: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    } else if (!isGoalForHome && currentAwayScore > currentHomeScore) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalConceded: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    } else if (isGoalForHome && currentHomeScore == currentAwayScore) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalScored: 1,
        points: 2,
        drawn: -1,
        won: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalConceded: 1,
        points: -1,
        lost: 1,
        drawn: -1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    } else if (!isGoalForHome && currentAwayScore == currentHomeScore) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalScored: 1,
        points: 2,
        drawn: -1,
        won: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalConceded: 1,
        points: -1,
        lost: 1,
        drawn: -1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    } else if (isGoalForHome && currentHomeScore == currentAwayScore - 1) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalScored: 1,
        points: 1,
        lost: -1,
        drawn: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalConceded: 1,
        points: -2,
        won: -1,
        drawn: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    } else if (!isGoalForHome && currentAwayScore == currentHomeScore - 1) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalScored: 1,
        points: 1,
        lost: -1,
        drawn: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalConceded: 1,
        points: -2,
        won: -1,
        drawn: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    } else if (isGoalForHome && currentHomeScore < currentAwayScore - 1) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalConceded: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    } else if (!isGoalForHome && currentAwayScore < currentHomeScore - 1) {
      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await DB.FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalConceded: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }
    }
    if (await DB.FootballStandings.updateTeamsQualified(
          tournamentId,
          numberQualified,
          numberGroups,
        ) ==
        false) {
      return [];
    }
    return cumulativeResult;
  }

  static Future<bool> addFootballMotm(
    int matchId,
    int playerId,
    int teamId,
    int tournamentId,
    int coordinatorId,
  ) async {
    if (AppConfig.isDebug) {
      if (await DB.FootballMatches.getById(matchId) == null) {
        return false;
      }

      final int? tourCoordinatorId = (await DB.Tournaments.getById(
        tournamentId,
      ))?.coordinatorId;

      if (tourCoordinatorId == null || tourCoordinatorId != coordinatorId) {
        return false;
      }

      if (await DB.FootballTournamentStats.incrementStatsInTournament(
            playerId,
            teamId,
            tournamentId,
            motmIncrement: 1,
          ) ==
          {}) {
        return false;
      }
      if (await DB.PersonalStats.incrementStats(playerId, motmIncrement: 1) ==
          {}) {
        return false;
      }
      if (await DB.TeamStats.incrementStats(
            playerId,
            teamId,
            motmIncrement: 1,
          ) ==
          {}) {
        return false;
      }

      if (await DB.FootballMatches.setMotmPlayer(matchId, playerId) == false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> startTournament(
    int tournamentId,
    int coordinatorId,
  ) async {
    if (AppConfig.isDebug) {
      if (await DB.Tournaments.getById(tournamentId) == null) {
        return false;
      }

      final int? tourCoordinatorId = (await DB.Tournaments.getById(
        tournamentId,
      ))?.coordinatorId;

      if (tourCoordinatorId == null || tourCoordinatorId != coordinatorId) {
        return false;
      }

      Map<int, double> refundPerTeams = await DB
          .TournamentParticipations.getRefundPerTeamsInTournament(tournamentId);

      //TODO: implementare il rimborso (i pagamenti in generale)

      if (await DB.TournamentParticipations.removeRefundedTeams(tournamentId) ==
          false) {
        return false;
      }

      if (await DB.Tournaments.startTournament(tournamentId) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> insertAssignment(
    int matchId,
    int refereeId,
    String role,
  ) async {
    if (AppConfig.isDebug) {
      final int sportId = (await DB.Tournaments.getById(
        (await DB.FootballMatches.getById(matchId))!.tournamentId,
      ))!.sportId;

      final int numReferees = await DB.RefereeAssignments.countRefereesPerMatch(
        matchId,
      );

      if (numReferees == 1 && (sportId == 1 || sportId == 2 || sportId == 3)) {
        // 1 arbitro per football 5, 7, 8
        return false;
      } else if (numReferees == 3 && sportId == 4) {
        // 3 arbitri per football 11
        return false;
      } else if (sportId > 4) {
        // Aggiungi altre condizioni per altri sport se necessario
        return false;
      }

      if (await DB.RefereeRoles.checkRoleExists(sportId, role) == false) {
        return false;
      }

      if (await DB.RefereeAssignments.insertAssignment(
            matchId,
            refereeId,
            role,
          ) ==
          false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deleteMatchEvent(int matchId, int eventId) async {
    if (AppConfig.isDebug) {
      if (await DB.FootballMatches.getById(matchId) == null) {
        return false;
      }

      int? tournamentId = (await DB.FootballMatches.getById(
        matchId,
      ))?.tournamentId;

      if (tournamentId == null) {
        return false;
      }

      int? sportId = (await DB.Tournaments.getById(tournamentId))?.sportId;

      if (sportId == null) {
        return false;
      }

      SportCategory sportCategory = (await DB.Sports.getById(
        sportId,
      ))!.category;

      if (sportCategory == SportCategory.football) {
        return await deleteFootballMatchEvents(matchId, tournamentId, eventId);
      }

      return false;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deleteFootballMatchEvents(
    int matchId,
    int tournamentId,
    int eventId,
  ) async {
    if (AppConfig.isDebug) {
      if (await DB.FootballMatchEvents.canBeDeleted(eventId) == false) {
        return false;
      }

      final String modifiedTablesJson =
          await DB.FootballMatchEvents.getModifiedTables(eventId);

      if (modifiedTablesJson.isEmpty) {
        return await DB.FootballMatchEvents.deleteEvent(eventId);
      }

      try {
        final Map<String, dynamic> data = jsonDecode(modifiedTablesJson);
        final List<dynamic> changes = data['changes'] ?? [];

        // Itera su ogni tabella modificata
        for (var tableChange in changes) {
          final String tableName = tableChange['table'];
          final List<dynamic> tableChanges = tableChange['changes'];

          // Chiama la funzione di rollback appropriata per ogni tabella
          bool success = false;
          switch (tableName) {
            case 'FootballMatch':
              success = await DB.FootballMatches.rollbackByJson(tableChanges);
              break;
            case 'FootballStandings':
              success = await DB.FootballStandings.rollbackByJson(tableChanges);
              break;
            case 'TeamStats':
              success = await DB.TeamStats.rollbackByJson(tableChanges);
              break;
            case 'FootballTournamentStats':
              success = await DB.FootballTournamentStats.rollbackByJson(
                tableChanges,
              );
              break;
            case 'PersonalStats':
              success = await DB.PersonalStats.rollbackByJson(tableChanges);
              break;
            default:
              return false; // Tabella non riconosciuta
          }

          if (!success) {
            return false; // Se una tabella fallisce, interrompi
          }
        }

        final bool isGroupStage = (await DB.Tournaments.getById(
          tournamentId,
        ))!.isGroupStage;

        if (isGroupStage) {
          await DB.FootballStandings.updateTeamsQualified(
            tournamentId,
            (await DB.Tournaments.getById(tournamentId))!.qualified,
            (await DB.Tournaments.getById(tournamentId))!.numGroups,
          );
        }
        // Dopo aver fatto il rollback di tutte le tabelle, elimina l'evento
        return await DB.FootballMatchEvents.deleteEvent(eventId);
      } catch (e) {
        print('Error parsing modifiedTables JSON: $e');
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }
}
