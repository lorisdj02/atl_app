import 'dart:math';
import 'package:atl_app/models/sport_category.dart';
import 'dart:convert';
import '../config/app_config.dart';
import 'repositories/user_repository.dart';
import 'repositories/tournament_repository.dart';
import 'repositories/player_repository.dart';
import 'repositories/coordinator_repository.dart';
import 'repositories/field_repository.dart';
import 'repositories/team_repository.dart';
import 'repositories/palmares_repository.dart';
import 'repositories/team_request_repository.dart';
import 'repositories/team_stats_repository.dart';
import 'repositories/plays_at_repository.dart';
import 'repositories/tournament_participation_repository.dart';
import 'repositories/callups_repository.dart';
import 'repositories/favorite_tournaments_repository.dart';
import 'repositories/football_match_repository.dart';
import 'repositories/football_standings_repository.dart';
import 'repositories/private_bookings_repository.dart';
import 'repositories/lobby_bookings_repository.dart';
import 'repositories/lobby_booking_participation_repository.dart';
import 'repositories/football_match_event_repository.dart';
import 'repositories/sport_repository.dart';
import 'repositories/city_repository.dart';
import 'repositories/football_tournament_stats_repository.dart';
import 'repositories/personal_stats_repository.dart';
import 'repositories/match_bookings_repository.dart';
import 'repositories/bookings_repository.dart';
import 'repositories/referee_assignment_repository.dart';
import 'repositories/referee_repository.dart';
import 'repositories/match_repository.dart';
import 'repositories/organization_repository.dart';
import 'repositories/wallet_repository.dart';
import 'repositories/reviews_repository.dart';
import 'repositories/referee_roles_repository.dart';
import 'repositories/orders_repository.dart';
// TODO: Aggiungi altri repository quando necessario

/// Singleton per gestire l'accesso al database
/// Uso: DB.Users.getUser(id) oppure DB.Tournaments.getTournaments()
class DB {
  // Singleton instance
  static final DB _instance = DB._internal();

  factory DB() => _instance;

  DB._internal() {
    _initializeRepositories();
  }

  // Repository instances
  static late final UserRepository Users;
  static late final TournamentRepository Tournaments;
  static late final PlayerRepository Players;
  static late final CoordinatorRepository Coordinators;
  static late final FieldRepository Fields;
  static late final TeamRepository Teams;
  static late final PalmaresRepository Palmares;
  static late final TeamRequestRepository TeamRequests;
  static late final TeamStatsRepository TeamStats;
  static late final PlaysAtRepository PlaysAt;
  static late final TournamentParticipationRepository TournamentParticipations;
  static late final CallUpsRepository CallUps;
  static late final FavoriteTournamentsRepository FavoriteTournaments;
  static late final FootballMatchRepository FootballMatches;
  static late final FootballStandingsRepository FootballStandings;
  static late final PrivateBookingsRepository PrivateBookings;
  static late final LobbyBookingsRepository LobbyBookings;
  static late final LobbyBookingParticipationRepository
  LobbyBookingParticipations;
  static late final FootballMatchEventRepository FootballMatchEvents;
  static late final SportRepository Sports;
  static late final CityRepository Cities;
  static late final FootballTournamentStatsRepository FootballTournamentStats;
  static late final PersonalStatsRepository PersonalStats;
  static late final MatchBookingsRepository MatchBookings;
  static late final BookingsRepository Bookings;
  static late final RefereeRepository Referees;
  static late final RefereeAssignmentRepository RefereeAssignments;
  static late final MatchRepository Matches;
  static late final OrganizationRepository Organizations;
  static late final WalletRepository Wallets;
  static late final ReviewsRepository Reviews;
  static late final RefereeRolesRepository RefereeRoles;
  static late final OrdersRepository Orders;
  // TODO: Aggiungi altri repository

  void _initializeRepositories() {
    Users = UserRepository();
    Tournaments = TournamentRepository();
    Players = PlayerRepository();
    Coordinators = CoordinatorRepository();
    Fields = FieldRepository();
    Teams = TeamRepository();
    Palmares = PalmaresRepository();
    TeamRequests = TeamRequestRepository();
    TeamStats = TeamStatsRepository();
    PlaysAt = PlaysAtRepository();
    TournamentParticipations = TournamentParticipationRepository();
    CallUps = CallUpsRepository();
    FavoriteTournaments = FavoriteTournamentsRepository();
    FootballMatches = FootballMatchRepository();
    FootballStandings = FootballStandingsRepository();
    PrivateBookings = PrivateBookingsRepository();
    LobbyBookings = LobbyBookingsRepository();
    LobbyBookingParticipations = LobbyBookingParticipationRepository();
    FootballMatchEvents = FootballMatchEventRepository();
    Sports = SportRepository();
    Cities = CityRepository();
    FootballTournamentStats = FootballTournamentStatsRepository();
    PersonalStats = PersonalStatsRepository();
    MatchBookings = MatchBookingsRepository();
    Bookings = BookingsRepository();
    Referees = RefereeRepository();
    RefereeAssignments = RefereeAssignmentRepository();
    Matches = MatchRepository();
    Organizations = OrganizationRepository();
    Wallets = WalletRepository();
    Reviews = ReviewsRepository();
    RefereeRoles = RefereeRolesRepository();
    Orders = OrdersRepository();
    // TODO: Inizializza altri repository
  }

  /// Inizializza il DB (chiamare all'avvio dell'app)
  static Future<void> initialize() async {
    // Inizializza il singleton
    DB();

    if (AppConfig.isDebug) {
      print('🔧 DB in DEBUG mode - usando mock data');
    } else {
      print('🚀 DB in PRODUCTION mode - usando API');
    }
  }

  Future<bool> createTeam(
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
      final int id = await Teams.insertTeam(
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
      if ((await TeamStats.createStats(
            playerId: captainId,
            teamId: id,
            motm: 0,
            goals: 0,
          )) ==
          false) {
        return false;
      }
      if ((await Players.joinTeam(captainId, id)) == false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> confirmCallUps(
    int tournamentId,
    int teamId,
    Set<int> selectedPlayerIds,
    double tournamentFee,
  ) async {
    if (AppConfig.isDebug == true) {
      await CallUps.deleteCallUps(tournamentId, teamId);

      bool canContinue = false;
      for (int playerId in selectedPlayerIds) {
        if ((await Teams.isCaptainOrVice(teamId, playerId)) == true) {
          canContinue = true;
          break;
        }
      }

      if (canContinue == false) {
        return false;
      }

      final int sportId = (await Tournaments.getById(tournamentId))!.sportId;
      final int maxPlayers = (await Sports.getById(sportId))!.maxPlayersPerTeam;
      final int minPlayers = (await Sports.getById(sportId))!.minPlayersPerTeam;

      if (selectedPlayerIds.length < minPlayers ||
          selectedPlayerIds.length > maxPlayers) {
        return false;
      }

      if (await Tournaments.isFull(tournamentId)) {
        return false;
      }

      if (await Teams.getById(teamId) == null) {
        return false;
      }

      for (int playerId in selectedPlayerIds) {
        if ((await CallUps.addCallUp(tournamentId, teamId, playerId)) ==
            false) {
          await CallUps.deleteCallUps(tournamentId, teamId);
          return false;
        }
      }

      if ((await TournamentParticipations.addParticipation(
            tournamentId,
            teamId,
            tournamentFee,
          )) ==
          false) {
        await CallUps.deleteCallUps(tournamentId, teamId);
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> acceptRequestToTeam(int playerId, int teamId) async {
    if (AppConfig.isDebug == true) {
      if ((await Teams.getById(teamId))?.players == 24) {
        return false;
      }

      if ((await Players.joinTeam(playerId, teamId)) == false) {
        return false;
      }
      if ((await TeamRequests.deleteByPlayerId(playerId)) == false) {
        return false;
      }

      if ((await TeamStats.createStats(
            playerId: playerId,
            teamId: teamId,
            motm: 0,
            goals: 0,
          )) ==
          false) {
        return false;
      }

      if ((await Teams.updatePlayerCount(teamId, 1)) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> createLobby(
    int fieldId,
    int ownerId,
    int maxPlayers,
    int playerToFind,
    double feePerPlayer,
    DateTime startDateTime,
    DateTime endDateTime,
  ) async {
    if (AppConfig.isDebug == true) {
      final id = await LobbyBookings.addLobbyBooking(
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

      if ((await LobbyBookingParticipations.addParticipation(
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

  Future<bool> joinLobby(
    int lobbyBookingId,
    int playerId,
    int playersPaid,
  ) async {
    if (AppConfig.isDebug == true) {
      if ((await LobbyBookingParticipations.addParticipation(
            lobbyBookingId,
            playerId,
            playersPaid,
          )) ==
          false) {
        return false;
      }

      if ((await LobbyBookings.decreasePlayersToFind(
            lobbyBookingId,
            playersPaid,
          )) ==
          false) {
        await LobbyBookingParticipations.removeParticipation(
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

  Future<bool> leaveLobby(
    int lobbyBookingId,
    int playerId, {
    deleteAccount = false,
  }) async {
    if (AppConfig.isDebug == true) {
      if ((await LobbyBookings.getById(lobbyBookingId))?.ownerId == playerId) {
        return deleteLobby(
          lobbyBookingId,
          playerId,
          deleteAccount: deleteAccount,
        );
      }
      int? playersPaid =
          (await LobbyBookingParticipations.getByPlayerAndLobbyBookingId(
            playerId,
            lobbyBookingId,
          ))?.playersPaid;
      if (playersPaid == null) {
        return false;
      }
      if ((await LobbyBookingParticipations.removeParticipation(
            playerId,
            lobbyBookingId,
          )) ==
          false) {
        return false;
      }

      if ((await LobbyBookings.increasePlayersToFind(
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

  Future<bool> deleteLobby(
    int lobbyBookingId,
    int playerId, {
    deleteAccount = false,
  }) async {
    if (AppConfig.isDebug == true) {
      if ((await LobbyBookings.getById(lobbyBookingId))?.ownerId != playerId) {
        return false;
      }
      if ((await LobbyBookingParticipations.removeLobbyParticipation(
            lobbyBookingId,
          )) ==
          false) {
        return false;
      }
      if ((await LobbyBookings.removeLobbyBooking(lobbyBookingId)) == false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> leaveTeam(
    int teamId,
    int playerId, {
    deleteAccount = false,
  }) async {
    if (AppConfig.isDebug == true) {
      if ((await Teams.isTeamLeftable(teamId, playerId)) == false) {
        return false;
      }

      List<int> activeTournamentsId = (await Tournaments.getActive())
          .map((t) => t.id)
          .toList();

      for (final tournamentId in activeTournamentsId) {
        if (await CallUps.getPlayersInTeamInTournament(
              tournamentId,
              teamId,
            ).then((players) => players.contains(playerId)) ==
            true) {
          return false;
        }
      }

      if ((await Teams.isCaptain(teamId, playerId) == true)) {
        if (await Teams.assignCaptain(teamId) == false) {
          return false;
        }
      } else if ((await Teams.isVice1(teamId, playerId) == true)) {
        if ((await Teams.updateVice1(teamId)) == false) {
          return false;
        }
      }

      if ((await PlaysAt.removePlaysAt(teamId, playerId)) == false ||
          (await TeamStats.deleteByPlayerIdInTeam(playerId, teamId)) == false ||
          (await CallUps.deleteByPlayerAndTeam(playerId, teamId)) == false ||
          (await Teams.updatePlayerCount(teamId, -1) == false)) {
        return false;
      }

      if ((await Teams.getById(teamId))?.players == 0) {
        if ((await Teams.disableTeam(teamId)) == false) {
          return false;
        }
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteAccount(int id, String passwordMD5) async {
    if (AppConfig.isDebug) {
      if ((await Users.getByUserId(id))?.passwordMD5 != passwordMD5) {
        return false;
      }

      if ((await Users.getByUserId(id))!.isPlayer) {
        final playerId = (await Players.getByUserId(id))!.playerId;
        final List<int> teamIds = await PlaysAt.getByPlayerId(
          playerId,
        ).then((playsAtList) => playsAtList!.map((pa) => pa.teamId).toList());

        for (final teamId in teamIds) {
          if ((await leaveTeam(teamId, playerId, deleteAccount: true)) ==
              false) {
            return false;
          }
        }

        final List<int> lobbyIds =
            await LobbyBookingParticipations.getByPlayerId(playerId).then(
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

      if (await Users.deleteAccount(id, passwordMD5) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> updatePayment(
    int tournamentId,
    int teamId,
    double amount,
  ) async {
    if (AppConfig.isDebug) {
      double newToPay =
          ((await TournamentParticipations.getByTournamentAndTeam(
            tournamentId,
            teamId,
          ))?.toPay ??
          0);

      newToPay -= amount;

      if (newToPay < 0) {
        return false;
      }

      if (await TournamentParticipations.updatePayment(
            tournamentId,
            teamId,
            newToPay,
          ) ==
          false) {
        return false;
      }
      if (newToPay == 0 &&
          (await Tournaments.incrementPaidTeams(tournamentId)) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteCallups(int tournamentId, int teamId) async {
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

  Future<bool> homeRetire(
    int matchId,
    int teamId,
    int playerRequestingId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        if ((await Teams.isCaptainOrVice(teamId, playerRequestingId)) ==
            false) {
          return false;
        }
        return FootballMatches.homeRetire(matchId, teamId);
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> awayRetire(
    int matchId,
    int teamId,
    int playerRequestingId,
  ) async {
    if (AppConfig.isDebug) {
      try {
        if ((await Teams.isCaptainOrVice(teamId, playerRequestingId)) ==
            false) {
          return false;
        }
        return FootballMatches.awayRetire(matchId, teamId);
      } catch (e) {
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> scheduleMatch(
    int matchId,
    DateTime scheduledStart,
    int coordinatorId,
  ) async {
    if (AppConfig.isDebug) {
      if (scheduledStart.isBefore(DateTime.now().add(Duration(hours: 1)))) {
        return false; // Non si può schedulare una partita con meno di 1 ora di anticipo
      }
      try {
        final int tournamentId = (await FootballMatches.getById(
          matchId,
        ))!.tournamentId;
        final int fieldId = (await Tournaments.getById(tournamentId))!.fieldId;

        final int sportId = await Tournaments.getById(
          tournamentId,
        ).then((t) => t!.sportId);

        final int minutesPerRound = (await Sports.getById(
          sportId,
        ))!.minutesPerRound;

        final int minutesPerPause = (await Sports.getById(
          sportId,
        ))!.minutesPerPause;

        final String sportCategory = (await Sports.getById(
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

        if (await Bookings.isFieldFree(fieldId, startTime, finishTime) ==
            false) {
          return false; // Il campo non è libero in quel lasso di tempo
        }

        if (coordinatorId !=
            (await Tournaments.getById(tournamentId))!.coordinatorId) {
          return false;
        }

        String status = (await FootballMatches.getById(
          matchId,
        ))!.status.toString().split('.').last;

        if (status == 'scheduled') {
          final DateTime oldStartTime = (await MatchBookings.getByMatchId(
            matchId,
          ))!.startTime;

          if (oldStartTime == startTime) {
            return true; // Nessuna modifica necessaria
          } else if (oldStartTime.difference(DateTime.now()).inHours < 24) {
            return false; // Non si può modificare con meno di 24 ore di anticipo
          }

          await MatchBookings.deleteByMatchId(matchId);
          status = 'notScheduled';
        }

        if (status != 'notScheduled') {
          return false;
        }

        if (await MatchBookings.addMatchBooking(
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
          return await FootballMatches.scheduleMatch(matchId, scheduledStart);
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

  Future<bool> insertEventMatch(
    int matchId,
    String type, {
    int? playerId,
    int teamId = 0,
  }) async {
    if (AppConfig.isDebug) {
      try {
        final int tournamentId = (await FootballMatches.getById(
          matchId,
        ))!.tournamentId;

        final int sportId = (await Tournaments.getById(tournamentId))!.sportId;

        final int numReferees = await RefereeAssignments.countRefereesPerMatch(
          matchId,
        );

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

        final int minutesPerRound = (await Sports.getById(
          sportId,
        ))!.minutesPerRound;

        final bool isGroupStage = (await Tournaments.getById(
          tournamentId,
        ))!.isGroupStage;

        final SportCategory sportCategory = (await Sports.getById(
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

  Future<bool> _handleFootballEvent(
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

      if (await FootballMatches.isPenaltyShootOut(matchId) &&
          ((await FootballMatches.canMatchFinish(matchId) &&
                  type != 'finish') ||
              (type != 'penalty' && type != 'missedPenalty'))) {
        return false;
      }

      DateTime? startTime;
      final bool matchStarted = await FootballMatchEvents.isMatchStarted(
        matchId,
      );
      final bool matchHalfStarted =
          await FootballMatchEvents.isMatchHalfStarted(matchId);

      if (matchHalfStarted) {
        startTime = await FootballMatchEvents.getMatchStartHalf(matchId);
      } else if (matchStarted) {
        startTime = await FootballMatchEvents.getMatchStartTime(matchId);
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
          await FootballMatchEvents.isPlayerSentOff(matchId, playerId)) {
        return false; // Non inserire l'evento se il giocatore è già stato espulso
      }

      if (playerId != null &&
          await FootballMatchEvents.isPlayerWarned(matchId, playerId)) {
        type = 'redYellowCard';
      }

      final int? eventId = await FootballMatchEvents.insertEvent(
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
          ? (await Tournaments.getById(tournamentId))!.numGroups
          : null;

      final int? numberQualified = isGroupStage
          ? (await Tournaments.getById(tournamentId))!.qualified
          : null;

      final int? homeTeam = (await FootballMatches.getById(
        matchId,
      ))?.homeTeamId;
      final int? awayTeam = (await FootballMatches.getById(
        matchId,
      ))?.awayTeamId;

      if (homeTeam == null || awayTeam == null) {
        return false;
      }

      if (type == 'start') {
        if (await FootballMatches.startMatch(matchId) == false) {
          return false;
        }
        if (await MatchBookings.startMatch(matchId) == false) {
          return false;
        }
        if (isGroupStage &&
            (await FootballStandings.updateStanding(
                      tournamentId,
                      homeTeam,
                      points: 1,
                      drawn: 1,
                    ) ==
                    {} ||
                await FootballStandings.updateStanding(
                      tournamentId,
                      awayTeam,
                      points: 1,
                      drawn: 1,
                    ) ==
                    {})) {
          return false;
        }
      } else if (type == 'halftime') {
        if (await FootballMatches.halftimeMatch(matchId) == false) {
          return false;
        }
      } else if (type == 'startHalf') {
        if (await FootballMatches.startHalfMatch(matchId) == false) {
          return false;
        }
      } else if (type == 'penaltyShootOut') {
        if (await FootballMatches.startPenaltyShootOut(matchId) == false) {
          return false;
        }
      } else if (type == 'finish') {
        if (await FootballMatches.finishMatch(matchId) == false) {
          return false;
        }
        if (await MatchBookings.finishMatch(matchId) == false) {
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

  Future<bool> _handleGoalCase(
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
      if (await Players.getByPlayerId(playerId) == null) {
        return false;
      }

      final bool isPlayerInHome = teamId == homeTeam;

      final bool isGoalForHome = (type == 'ownGoal')
          ? !isPlayerInHome
          : isPlayerInHome;

      final int? currentHomeScore = (await FootballMatches.getById(
        matchId,
      ))!.scoreHome;
      final int? currentAwayScore = (await FootballMatches.getById(
        matchId,
      ))!.scoreAway;

      if (currentHomeScore == null || currentAwayScore == null) {
        return false;
      }

      List<Map<String, dynamic>> modifiedTables = [];
      Map<String, dynamic> result = {};

      if (await FootballMatches.isPenaltyShootOut(matchId) == false &&
          type != 'missedPenalty') {
        result = await FootballMatches.updateScore(
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
            await FootballMatches.isPenaltyShootOut(matchId)) {
          result = await FootballMatches.addMissedPenalty(matchId, teamId);
          if (result == {}) {
            return false;
          }
          modifiedTables.add(result);
        } else {
          final resultList = await FootballMatches.handleGoalInFinalStage(
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
          await FootballMatches.isPenaltyShootOut(matchId) == false) {
        result = await TeamStats.incrementStats(
          playerId,
          teamId,
          goalsIncrement: 1,
        );
        if (result == {}) {
          return false;
        } else {
          modifiedTables.add(result);
        }

        result = await FootballTournamentStats.incrementStatsInTournament(
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

        result = await PersonalStats.incrementStats(
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

      if (await FootballMatchEvents.updateModifiedTables(eventId, jsonString) ==
          false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<List<Map<String, dynamic>>> _handleFootballGroupStageGoal(
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
      result = await FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await FootballStandings.updateStanding(
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
      result = await FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await FootballStandings.updateStanding(
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
      result = await FootballStandings.updateStanding(
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

      result = await FootballStandings.updateStanding(
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
      result = await FootballStandings.updateStanding(
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

      result = await FootballStandings.updateStanding(
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
      result = await FootballStandings.updateStanding(
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

      result = await FootballStandings.updateStanding(
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
      result = await FootballStandings.updateStanding(
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

      result = await FootballStandings.updateStanding(
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
      result = await FootballStandings.updateStanding(
        tournamentId,
        homeTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await FootballStandings.updateStanding(
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
      result = await FootballStandings.updateStanding(
        tournamentId,
        awayTeam,
        goalScored: 1,
      );
      if (result == {}) {
        return [];
      } else {
        cumulativeResult.add(result);
      }

      result = await FootballStandings.updateStanding(
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
    if (await FootballStandings.updateTeamsQualified(
          tournamentId,
          numberQualified,
          numberGroups,
        ) ==
        false) {
      return [];
    }
    return cumulativeResult;
  }

  Future<bool> addFootballMotm(
    int matchId,
    int playerId,
    int teamId,
    int tournamentId,
    int coordinatorId,
  ) async {
    if (AppConfig.isDebug) {
      if (await FootballMatches.getById(matchId) == null) {
        return false;
      }

      final int? tourCoordinatorId = (await Tournaments.getById(
        tournamentId,
      ))?.coordinatorId;

      if (tourCoordinatorId == null || tourCoordinatorId != coordinatorId) {
        return false;
      }

      if (await FootballTournamentStats.incrementStatsInTournament(
            playerId,
            teamId,
            tournamentId,
            motmIncrement: 1,
          ) ==
          false) {
        return false;
      }
      if (await PersonalStats.incrementStats(playerId, motmIncrement: 1) ==
          false) {
        return false;
      }
      if (await TeamStats.incrementStats(playerId, teamId, motmIncrement: 1) ==
          false) {
        return false;
      }

      if (await FootballMatches.setMotmPlayer(matchId, playerId) == false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> startTournament(int tournamentId, int coordinatorId) async {
    if (AppConfig.isDebug) {
      if (await Tournaments.getById(tournamentId) == null) {
        return false;
      }

      final int? tourCoordinatorId = (await Tournaments.getById(
        tournamentId,
      ))?.coordinatorId;

      if (tourCoordinatorId == null || tourCoordinatorId != coordinatorId) {
        return false;
      }

      Map<int, double> refundPerTeams =
          await TournamentParticipations.getRefundPerTeamsInTournament(
            tournamentId,
          );

      //TODO: implementare il rimborso (i pagamenti in generale)

      if (await TournamentParticipations.removeRefundedTeams(tournamentId) ==
          false) {
        return false;
      }

      if (await Tournaments.startTournament(tournamentId) == false) {
        return false;
      }

      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> insertAssignment(int matchId, int refereeId, String role) async {
    if (AppConfig.isDebug) {
      final int sportId = (await Tournaments.getById(
        (await FootballMatches.getById(matchId))!.tournamentId,
      ))!.sportId;

      final int numReferees = await RefereeAssignments.countRefereesPerMatch(
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

      if (await RefereeRoles.checkRoleExists(sportId, role) == false) {
        return false;
      }

      if (await RefereeAssignments.insertAssignment(matchId, refereeId, role) ==
          false) {
        return false;
      }
      return true;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteMatchEvent(int matchId, int eventId) async {
    if (AppConfig.isDebug) {
      if (await FootballMatches.getById(matchId) == null) {
        return false;
      }

      int? tournamentId = (await FootballMatches.getById(
        matchId,
      ))?.tournamentId;

      if (tournamentId == null) {
        return false;
      }

      int? sportId = (await Tournaments.getById(tournamentId))?.sportId;

      if (sportId == null) {
        return false;
      }

      SportCategory sportCategory = (await Sports.getById(sportId))!.category;

      if (sportCategory == SportCategory.football) {
        return await deleteFootballMatchEvents(matchId, tournamentId, eventId);
      }

      return false;
    } else {
      throw UnimplementedError();
    }
  }

  Future<bool> deleteFootballMatchEvents(
    int matchId,
    int tournamentId,
    int eventId,
  ) async {
    if (AppConfig.isDebug) {
      if (await FootballMatchEvents.canBeDeleted(eventId) == false) {
        return false;
      }

      final String modifiedTablesJson =
          await FootballMatchEvents.getModifiedTables(eventId);

      if (modifiedTablesJson.isEmpty) {
        return await FootballMatchEvents.deleteEvent(eventId);
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
              success = await FootballMatches.rollbackByJson(tableChanges);
              break;
            case 'FootballStandings':
              success = await FootballStandings.rollbackByJson(tableChanges);
              break;
            case 'TeamStats':
              success = await TeamStats.rollbackByJson(tableChanges);
              break;
            case 'FootballTournamentStats':
              success = await FootballTournamentStats.rollbackByJson(
                tableChanges,
              );
              break;
            case 'PersonalStats':
              success = await PersonalStats.rollbackByJson(tableChanges);
              break;
            default:
              return false; // Tabella non riconosciuta
          }

          if (!success) {
            return false; // Se una tabella fallisce, interrompi
          }
        }

        final bool isGroupStage = (await Tournaments.getById(
          tournamentId,
        ))!.isGroupStage;

        if (isGroupStage) {
          await FootballStandings.updateTeamsQualified(
            tournamentId,
            (await Tournaments.getById(tournamentId))!.qualified,
            (await Tournaments.getById(tournamentId))!.numGroups,
          );
        }
        // Dopo aver fatto il rollback di tutte le tabelle, elimina l'evento
        return await FootballMatchEvents.deleteEvent(eventId);
      } catch (e) {
        print('Error parsing modifiedTables JSON: $e');
        return false;
      }
    } else {
      throw UnimplementedError();
    }
  }
}
