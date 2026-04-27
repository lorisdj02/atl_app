import 'package:atl_app/database/requests/confirm_callups_request.dart';
import 'package:atl_app/models/booking.dart';
import 'package:atl_app/models/checkout_payload.dart';
import 'package:atl_app/models/checkout_session.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/plays_at.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/review.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'db_controller.dart';
import '../config/app_config.dart';
import '../../models/sport_category.dart';
import '../../models/team.dart';
import 'dart:convert';

class DBWrite {
  // DONE
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
    Tournament request = Tournament(
      id: -1,
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
      payCoordinator: payCoordinator ? 1 : 0,
      prize1: prize1 ? 1 : 0,
      prize2: prize2 ? 1 : 0,
      isPublic: isPublic,
      paidTeams: 0,
      fee: 0,
    );
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

  // DONE
  static Future<bool> createPrivateBooking({
    required int playerId,
    required int fieldId,
    required DateTime startTime,
    required DateTime finishTime,
    required SportCategory sportCategory,
  }) async {
    PrivateBooking request = PrivateBooking(
      id: -1,
      playerId: playerId,
      fieldId: fieldId,
      startTime: startTime,
      finishTime: finishTime,
      sportCategory: sportCategory,
      cost: 0,
    );
    if (AppConfig.isDebug == true) {
      return await DB.PrivateBookings.addPrivateBooking(
        playerId,
        fieldId,
        startTime,
        finishTime,
        sportCategory,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  // TODO: Per i booking, ricordati nei pagamenti di aggiungere la fee.
  static Future<bool> createLobby({
    required int fieldId,
    required int ownerPlayerId,
    required int maxPlayers,
    required int playersToFind,
    required double feePerPlayer,
    required DateTime startTime,
    required DateTime finishTime,
    required SportCategory sportCategory,
  }) async {
    LobbyBooking request = LobbyBooking(
      id: -1,
      fieldId: fieldId,
      ownerPlayerId: ownerPlayerId,
      maxPlayers: maxPlayers,
      playersToFind: playersToFind,
      feePerPlayer: feePerPlayer,
      startTime: startTime,
      finishTime: finishTime,
      status: BookingStatus.booked,
      sportCategory: sportCategory,
    );
    if (AppConfig.isDebug == true) {
      final id = await DB.LobbyBookings.addLobbyBooking(
        ownerPlayerId,
        fieldId,
        startTime,
        finishTime,
        maxPlayers,
        playersToFind,
        feePerPlayer,
        sportCategory,
      );
      if (id == -1) {
        return false;
      }

      if ((await DB.LobbyBookingParticipations.addParticipation(
            id,
            ownerPlayerId,
            maxPlayers - playersToFind,
            feePerPlayer * (maxPlayers - playersToFind),
          )) ==
          false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, il bool non serve più
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

  // DONE
  static Future<int> createTeam(
    int? cityId,
    String name,
    String alias,
    String? description,
    int captainId,
    SportCategory sportCategory,
    String? imageUrl,
    bool vip,
    bool visibility,
  ) async {
    if (AppConfig.isDebug == true) {
      Team request = Team(
        id: -1,
        cityId: cityId,
        name: name,
        alias: alias,
        description: description,
        captainId: captainId,
        sportCategory: sportCategory,
        imageUrl: imageUrl,
        vip: vip,
        visibility: visibility,
        players: 1,
      );
      final int id = await DB.Teams.insertTeam(
        cityId,
        name,
        alias,
        description,
        captainId,
        sportCategory,
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

  // DONE, tournamentFee è inutile
  static Future<bool> confirmCallUps(
    int tournamentId,
    int teamId,
    Set<int> selectedPlayerIds,
    double tournamentFee,
  ) async {
    ConfirmCallupsRequest request = ConfirmCallupsRequest(
      tournamentId: tournamentId,
      teamId: teamId,
      selectedPlayerIds: selectedPlayerIds.toList(),
    );
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

  // DONE, forse ho implementato anche i pagamenti
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

  // DONE
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

        final Team? team = await DB.Teams.getById(teamId);
        if (team == null) {
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
        final Team? team = await DB.Teams.getById(teamId);
        if (team == null) {
          return false;
        }

        if (team.players == team.maxPlayers) {
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

  // DONE
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

  // DONE
  static Future<bool> sendTeamRequest(int teamId, int playerId) async {
    if (AppConfig.isDebug) {
      return DB.TeamRequests.addRequest(teamId, playerId);
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<bool> cancelTeamRequest(int teamId, int playerId) async {
    if (AppConfig.isDebug) {
      return DB.TeamRequests.deleteRequest(teamId, playerId);
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, sempre implementato nei pagamenti
  static Future<bool> joinLobby({
    required int lobbyId,
    required int playerId,
    required int playersPaid,
  }) async {
    if (AppConfig.isDebug == true) {
      final lobby = await DB.LobbyBookings.getById(lobbyId);
      if (lobby == null) {
        return false;
      }
      if ((await DB.LobbyBookingParticipations.addParticipation(
            lobbyId,
            playerId,
            playersPaid,
            lobby.feePerPlayer * playersPaid,
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

  // DONE
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

  // DONE
  static Future<bool> expelPlayer(int teamId, int playerId) async {
    if (AppConfig.isDebug) {
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, forse non serve più perchè viene fatto nei pagamenti
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

  // DONE
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

  // DONE
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
                reviewerAccountId: player.id,
                reviewedAccountId: coordinator.id,
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

  // DONE
  static Future<bool> startFootballPenaltyShootOut(int matchId) async {
    if (AppConfig.isDebug) {
      return await DB.FootballMatches.startPenaltyShootOut(matchId);
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, EASY
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

  // DONE, adesso è più semplice, si passa direttamente il payload con tutte le info necessarie
  static Future<int> createCheckoutSession({
    required int userId,
    required CheckoutPayload payload,
  }) async {
    if (AppConfig.isDebug) {
      return await DB.CheckoutSessions.createCheckoutSession(
        userId: userId,
        payload: payload,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<bool> payCheckoutSession(
    int sessionId, {
    bool useWallet = false,
    required SportCategory sportCategory,
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

          if (await DBWrite.createPrivateBooking(
                playerId: playerId,
                fieldId: fieldId,
                startTime: startDateTime,
                finishTime: endDateTime,
                sportCategory: sportCategory,
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

          if (await DBWrite.createLobby(
                fieldId: fieldId,
                ownerPlayerId: ownerPlayerId,
                maxPlayers: maxPlayers,
                playersToFind: playersToFind,
                feePerPlayer: feePerPlayer,
                startTime: startDateTime,
                finishTime: endDateTime,
                sportCategory: sportCategory,
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
}
