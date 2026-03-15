import 'package:atl_app/models/callup.dart';
import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/plays_at.dart';
import 'package:atl_app/models/referee.dart';
import 'package:atl_app/models/review.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:atl_app/models/user.dart';
import '../../config/api_json_keys.dart';
import 'db_controller.dart';
import '../config/app_config.dart';
import '../../models/sport_category.dart';
import '../../models/team.dart';
import 'dart:math';
import 'dart:convert';

class DBWrite {
  static Future<Map<String, dynamic>> updateUserInfo({
    required int id,
    String? username,
    String? phone,
    String? oldPasswordMD5,
    String? newPasswordMD5,
    DateTime? birthdate,
    String? imgUrl,
    int? preferredCityId,
  }) async {
    if (AppConfig.isDebug) {
      final bool success = await DB.Users.updateUserInfo(
        id: id,
        username: username,
        phone: phone,
        oldPasswordMD5: oldPasswordMD5,
        newPasswordMD5: newPasswordMD5,
        birthdate: birthdate,
        imgUrl: imgUrl,
        preferredCityId: preferredCityId,
      );

      if (!success) {
        return {ApiJsonKeys.updatedUser: null};
      }

      final User? updatedUser = await DB.Users.getByUserId(id);
      if (updatedUser == null) {
        return {ApiJsonKeys.updatedUser: null};
      }
      return {ApiJsonKeys.updatedUser: updatedUser};
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> createTournament({
    required String name,
    required int coordinatorId,
    required int fieldId,
    required int cityId,
    DateTime? startDate,
    required int sportId,
    required int numTeams,
    required int numGroups,
    required bool round2GroupStage,
    required bool round2FinalStage,
    required int qualified,
    required String description,
    required bool payCoordinator,
    required bool prize1,
    required bool prize2,
    required bool isPublic,
  }) async {
    if (AppConfig.isDebug == true) {
      return await DB.Tournaments.insertTournament(
        name: name,
        coordinatorId: coordinatorId,
        fieldId: fieldId,
        cityId: cityId,
        startDate: startDate,
        sportId: sportId,
        numTeams: numTeams,
        numGroups: numGroups,
        round2GroupStage: round2GroupStage,
        round2FinalStage: round2FinalStage,
        qualified: qualified,
        description: description,
        payCoordinator: payCoordinator,
        prize1: prize1,
        prize2: prize2,
        isPublic: isPublic,
      );
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> createPrivateBooking({
    required int playerId,
    required int fieldId,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    if (AppConfig.isDebug == true) {
      return await DB.PrivateBookings.addPrivateBooking(
        playerId,
        fieldId,
        startDateTime,
        endDateTime,
      );
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> promoteOrDemoteInTeam(
    int teamId,
    int playerId, {
    bool promote = true,
  }) async {
    if (AppConfig.isDebug) {
      if (promote) {
        return await DB.Teams.promoteToVice(teamId, playerId);
      } else {
        return await DB.Teams.demoteVice(teamId, playerId);
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<int> createTeam(
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
        return -1;
      }
      if ((await DB.FootballTeamStats.createStats(
            playerId: captainId,
            teamId: id,
            motm: 0,
            goals: 0,
          )) ==
          false) {
        return -1;
      }
      if ((await DB.Players.joinTeam(captainId, id)) == false) {
        return -1;
      }
      return id;
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

  static Future<bool> acceptTeamRequest(
    int teamId, {
    int? playerId,
    bool allRequests = false,
  }) async {
    if (AppConfig.isDebug == true) {
      if (allRequests == true) {
        if (await DB.Teams.getById(teamId) == null) {
          return false;
        }

        final List<TeamRequest> requests = await DB.TeamRequests.getByTeamId(
          teamId,
        );

        if (requests.isEmpty) {
          return false;
        }

        if ((await DB.Teams.getById(teamId))!.players + requests.length >
            Team.maxPlayers) {
          return false;
        }

        for (final request in requests) {
          if ((await DB.Players.joinTeam(request.playerId, teamId)) == false ||
              (await DB.FootballTeamStats.createStats(
                    playerId: request.playerId,
                    teamId: teamId,
                    motm: 0,
                    goals: 0,
                  )) ==
                  false) {
            return false;
          }
        }
        if ((await DB.TeamRequests.deleteByTeam(teamId)) == false) {
          return false;
        }
        if ((await DB.Teams.updatePlayerCount(teamId, requests.length)) ==
            false) {
          return false;
        }
        return true;
      } else if (playerId != null) {
        if ((await DB.Teams.getById(teamId))?.players == Team.maxPlayers) {
          return false;
        }

        if ((await DB.Players.joinTeam(playerId, teamId)) == false) {
          return false;
        }
        if ((await DB.TeamRequests.deleteByPlayerId(playerId)) == false) {
          return false;
        }

        if ((await DB.FootballTeamStats.createStats(
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
        throw ArgumentError(
          'Invalid arguments: either playerId must be provided or allRequests must be true',
        );
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> rejectTeamRequest(
    int teamId, {
    int? playerId,
    bool allRequests = false,
  }) async {
    if (AppConfig.isDebug) {
      if (playerId == null && allRequests == true) {
        return await DB.TeamRequests.deleteByTeam(teamId);
      } else if (playerId != null) {
        return await DB.TeamRequests.deleteRequest(teamId, playerId);
      } else {
        throw ArgumentError(
          'Invalid arguments: either playerId must be provided or allRequests must be true',
        );
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> createTeamRequest(int teamId, int playerId) async {
    if (AppConfig.isDebug) {
      return DB.TeamRequests.addRequest(teamId, playerId);
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deleteTeamRequest(int teamId, int playerId) async {
    if (AppConfig.isDebug) {
      return DB.TeamRequests.deleteRequest(teamId, playerId);
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> createLobby({
    required int fieldId,
    required int ownerPlayerId,
    required int maxPlayers,
    required int playersToFind,
    required double feePerPlayer,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    if (AppConfig.isDebug == true) {
      final id = await DB.LobbyBookings.addLobbyBooking(
        ownerPlayerId,
        fieldId,
        startDateTime,
        endDateTime,
        maxPlayers,
        playersToFind,
        feePerPlayer,
      );
      if (id == -1) {
        return false;
      }

      if ((await DB.LobbyBookingParticipations.addParticipation(
            id,
            ownerPlayerId,
            maxPlayers - playersToFind,
          )) ==
          false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> joinLobby({
    required int lobbyId,
    required int playerId,
    required int playersPaid,
  }) async {
    if (AppConfig.isDebug == true) {
      if ((await DB.LobbyBookingParticipations.addParticipation(
            lobbyId,
            playerId,
            playersPaid,
          )) ==
          false) {
        return false;
      }

      if ((await DB.LobbyBookings.decreasePlayersToFind(
            lobbyId,
            playersPaid,
          )) ==
          false) {
        await DB.LobbyBookingParticipations.removeParticipation(
          playerId,
          lobbyId,
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
      if ((await DB.LobbyBookings.getById(lobbyBookingId))?.ownerPlayerId !=
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
      if ((await DB.LobbyBookings.getById(lobbyBookingId))?.ownerPlayerId ==
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

  static Future<bool> updateTournamentParticipationPayment(
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
      } else if (type == 'yellowCard') {
        if (playerId == null) {
          return false;
        }
        if (await DB.FootballTeamStats.incrementStats(
              playerId,
              teamId,
              yellowCardsIncrement: 1,
            ) ==
            {}) {
          return false;
        }
        if (await DB.FootballTournamentStats.incrementStatsInTournament(
              playerId,
              teamId,
              tournamentId,
              yellowCardsIncrement: 1,
            ) ==
            {}) {
          return false;
        }
      } else if (type == 'redCard' || type == 'redYellowCard') {
        if (playerId == null) {
          return false;
        }
        if (await DB.FootballTeamStats.incrementStats(
              playerId,
              teamId,
              redCardsIncrement: 1,
            ) ==
            {}) {
          return false;
        }
        if (await DB.FootballTournamentStats.incrementStatsInTournament(
              playerId,
              teamId,
              tournamentId,
              redCardsIncrement: 1,
            ) ==
            {}) {
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
        result = await DB.FootballTeamStats.incrementStats(
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
      if (await DB.FootballTeamStats.incrementStats(
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

  static Future<bool> startTournament(int tournamentId) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await DB.Tournaments.getById(tournamentId);
      if (tournament == null) {
        return false;
      }

      final int tourCoordinatorId = tournament.coordinatorId;

      final Coordinator? coordinator =
          (await DB.Coordinators.getByCoordinatorId(tourCoordinatorId));

      if (coordinator == null) {
        return false;
      }

      /*
      Map<int, double> refundPerTeams = await DB
          .TournamentParticipations.getRefundPerTeamsInTournament(tournamentId);

      //TODO: implementare il rimborso (i pagamenti in generale)

      if (await DB.TournamentParticipations.removeRefundedTeams(tournamentId) ==
          false) {
        return false;
      }
      */
      if (await DB.Tournaments.startTournament(tournamentId) == false) {
        return false;
      }

      final List<TournamentParticipation> participations =
          await DB.TournamentParticipations.getByTournamentId(tournamentId);

      for (final participation in participations) {
        final Team? team = await DB.Teams.getById(participation.teamId);
        if (team == null) {
          return false;
        }
        final List<PlaysAt> playersInTeam = await DB.PlaysAt.getByTeamId(
          team.id,
        );
        for (final playsAt in playersInTeam) {
          final Player? player = await DB.Players.getByPlayerId(
            playsAt.playerId,
          );
          if (player == null) {
            //return false;
            continue; // Se il giocatore non esiste, salta al prossimo invece di fallire l'intera operazione
          }

          if (await DB.Reviews.addReview(
                reviewerUserId: player.id,
                revieweeUserId: coordinator.id,
                tournamentId: tournamentId,
                reviewType: ReviewType.playerToCoordinator,
                weight: team.captainId == player.id
                    ? 1
                    : team.vice1Id == player.id
                    ? 0.75
                    : team.vice2Id == player.id
                    ? 0.75
                    : 0.5,
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

  static Future<bool> insertAssignment(
    int matchId,
    int refereeId,
    String role,
  ) async {
    if (AppConfig.isDebug) {
      final Referee? referee = await DB.Referees.getByRefereeId(refereeId);
      if (referee == null) {
        return false;
      }

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

      final double pay = await DB.RefereeRoles.getPayPerMatch(
        sportId,
        role,
        referee.level,
      );

      if (await DB.RefereeAssignments.insertAssignment(
            matchId,
            refereeId,
            role,
            pay,
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
            case 'FootballTeamStats':
              success = await DB.FootballTeamStats.rollbackByJson(tableChanges);
              break;
            case 'FootballTournamentStats':
              success = await DB.FootballTournamentStats.rollbackByJson(
                tableChanges,
              );
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

  static Future<bool> startFootballPenaltyShootOut(int matchId) async {
    if (AppConfig.isDebug) {
      return await DB.FootballMatches.startPenaltyShootOut(matchId);
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deletePrivateBooking(int bookingId) async {
    if (AppConfig.isDebug) {
      return await await DB.PrivateBookings.deletePrivateBooking(bookingId);
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> toggleTournamentFavoriteStatus(
    int tournamentId,
    int userId,
  ) async {
    if (AppConfig.isDebug) {
      return await DB.Tournaments.toggleFavoriteStatus(tournamentId, userId);
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> insertRefereeLicense(
    int sportId,
    int refereeId,
    String id,
    DateTime issuedAt,
  ) async {
    if (AppConfig.isDebug) {
      return await DB.RefereeLicenses.addLicense(
        sportId,
        refereeId,
        id,
        issuedAt,
      );
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> deleteRefereeLicense(int refereeId, int sportId) async {
    if (AppConfig.isDebug) {
      return await DB.RefereeLicenses.removeLicense(refereeId, sportId);
    } else {
      throw UnimplementedError();
    }
  }

  static Future<int> createCheckoutSession({
    required int userId,
    required Map<String, dynamic> payload,
    required double amount,
    required CheckoutType type,
  }) async {
    if (AppConfig.isDebug) {
      return await DB.CheckoutSessions.createCheckoutSession(
        userId: userId,
        payload: jsonEncode(payload),
        amount: amount,
        type: type,
      );
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> payCheckoutSession(
    int sessionId, {
    bool useWallet = false,
  }) async {
    if (AppConfig.isDebug) {
      final CheckoutSession? session = await DB.CheckoutSessions.getById(
        sessionId,
      );
      if (session == null) {
        return false;
      }

      if (session.status != CheckoutSessionStatus.pending) {
        return false; // La sessione deve essere in stato "pending" per essere pagata
      }

      switch (session.type) {
        case CheckoutType.tournamentFee:
          final Map<String, dynamic> payload = jsonDecode(session.payload);
          final int? tournamentId = payload['tournamentId'];
          final int? teamId = payload['teamId'];
          if (tournamentId == null || teamId == null) {
            return false;
          }

          // TODO: implementa il pagamento
          print(
            'Pagato importo ${session.amount} per la partecipazione al torneo $tournamentId della squadra $teamId',
          );

          if (await DBWrite.updateTournamentParticipationPayment(
                tournamentId,
                teamId,
                session.amount,
              ) ==
              false) {
            return false;
          }

          if (await DB.CheckoutSessions.updateStatus(
                session.id,
                CheckoutSessionStatus.completed,
              ) ==
              false) {
            return false;
          }

          break;
        case CheckoutType.privateBooking:
          final Map<String, dynamic> payload = jsonDecode(session.payload);
          final int? fieldId = payload['fieldId'];
          final String? startDateTimeStr = payload['startDateTime'];
          final String? endDateTimeStr = payload['endDateTime'];

          final int? playerId = payload['playerId'];
          if (fieldId == null ||
              startDateTimeStr == null ||
              endDateTimeStr == null ||
              playerId == null) {
            return false;
          }

          final DateTime startDateTime = DateTime.parse(startDateTimeStr);
          final DateTime endDateTime = DateTime.parse(endDateTimeStr);

          // TODO: implementa il pagamento
          print(
            'Pagato importo ${session.amount} per la prenotazione del campo $fieldId da parte del giocatore $playerId',
          );

          if (await DBWrite.createPrivateBooking(
                playerId: playerId,
                fieldId: fieldId,
                startDateTime: startDateTime,
                endDateTime: endDateTime,
              ) ==
              false) {
            return false;
          }
          break;
        case CheckoutType.lobbyBookingCreate:
          final Map<String, dynamic> payload = jsonDecode(session.payload);
          final int? fieldId = payload['fieldId'];
          final int? ownerPlayerId = payload['ownerPlayerId'];
          final int? maxPlayers = payload['maxPlayers'];
          final int? playersToFind = payload['playersToFind'];
          final double? feePerPlayer = payload['feePerPlayer'];
          final String? startDateTimeStr = payload['startDateTime'];
          final String? endDateTimeStr = payload['endDateTime'];
          if (fieldId == null ||
              ownerPlayerId == null ||
              maxPlayers == null ||
              playersToFind == null ||
              feePerPlayer == null ||
              startDateTimeStr == null ||
              endDateTimeStr == null) {
            return false;
          }
          final DateTime startDateTime = DateTime.parse(startDateTimeStr);
          final DateTime endDateTime = DateTime.parse(endDateTimeStr);

          //TODO: implementa il pagamento
          print(
            'Pagato importo ${session.amount} per la creazione della lobby sul campo $fieldId da parte del giocatore $ownerPlayerId',
          );

          if (await DBWrite.createLobby(
                fieldId: fieldId,
                ownerPlayerId: ownerPlayerId,
                maxPlayers: maxPlayers,
                playersToFind: playersToFind,
                feePerPlayer: feePerPlayer,
                startDateTime: startDateTime,
                endDateTime: endDateTime,
              ) ==
              false) {
            return false;
          }
          break;
        case CheckoutType.lobbyBookingParticipate:
          final Map<String, dynamic> payload = jsonDecode(session.payload);
          final int? lobbyId = payload['lobbyId'];
          final int? playerId = payload['playerId'];
          final int? playersPaid = payload['playersPaid'];
          if (lobbyId == null || playerId == null || playersPaid == null) {
            return false;
          }

          if (await DBWrite.joinLobby(
                lobbyId: lobbyId,
                playerId: playerId,
                playersPaid: playersPaid,
              ) ==
              false) {
            return false;
          }
          break;
      }

      return await DB.CheckoutSessions.updateStatus(
            session.id,
            CheckoutSessionStatus.completed,
          ) ==
          true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> commitReview(
    int reviewId, {
    required double rating,
    String? comment,
    required int tournamentId,
    int? matchId,
  }) async {
    if (AppConfig.isDebug) {
      if (rating < 0.5 || rating > 5) {
        return false; // La valutazione deve essere compresa tra 0.5 e 5
      }
      final Review? review = await DB.Reviews.getById(reviewId);
      if (review == null) {
        return false;
      }

      final User? user = await DB.Users.getByUserId(review.reviewerUserId);
      if (user == null) {
        return false;
      }

      switch (user.role) {
        case UserRole.player:
          final Player? player = await DB.Players.getByUserId(
            review.reviewerUserId,
          );
          if (player == null) {
            return false;
          }

          if (await DB.Reviews.commitReview(
                reviewId,
                rating: rating,
                comment: comment,
              ) ==
              false) {
            return false;
          }

          final Callup? callup = await DB.CallUps.getByPlayerAndTournament(
            review.reviewerUserId,
            tournamentId,
          );

          if (callup == null) {
            return false;
          }

          if (await DB.CallUps.redeemPrize(callup.playerId, tournamentId) ==
              false) {
            return false;
          }

        //TODO: implementare il premio per i giocatori
        case UserRole.coordinator:
          final Coordinator? coordinator = await DB.Coordinators.getByUserId(
            review.reviewerUserId,
          );
          if (coordinator == null) {
            return false;
          }

          if (await DB.Reviews.commitReview(
                reviewId,
                rating: rating,
                comment: comment,
              ) ==
              false) {
            return false;
          }

        //TODO: implementare il premio per i coordinatori
        case UserRole.referee:
          final Referee? referee = await DB.Referees.getByUserId(
            review.reviewerUserId,
          );
          if (referee == null) {
            return false;
          }

          if (await DB.Reviews.commitReview(
                reviewId,
                rating: rating,
                comment: comment,
              ) ==
              false) {
            return false;
          }

        //TODO: implementare il premio per gli arbitri
        default:
          return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> registerUser({
    required String email,
    required String username,
    required String password,
    required String name,
    required String surname,
    required UserRole role,
    required String phone,
    required DateTime birthdate,
    String? inviteCode,
    String? profilePictureUrl,
  }) async {
    if (AppConfig.isDebug) {
      final int newId = await DB.Users.registerUser(
        email: email,
        username: username,
        password: password,
        name: name,
        surname: surname,
        role: role,
        phone: phone,
        birthdate: birthdate,
        profilePictureUrl: profilePictureUrl,
      );

      bool hasBeenInvited = false;
      // Per ora, inviteCode = Username
      if (inviteCode == null) {
        return true;
      }
      final User? inviterUser = await DB.Users.getByUsername(inviteCode);
      if (inviterUser != null) {
        if (await DB.FriendInvites.addInvite(
              inviterUserId: inviterUser.id,
              invitedUserId: newId,
            ) ==
            false) {
          return false;
        }

        hasBeenInvited = true;
      }

      if (await DB.Wallets.addWallet(
            userId: newId,
            hasBeenInvited: hasBeenInvited,
          ) ==
          false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }
}
