import 'dart:math';

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
import 'repositories/tournament_partecipation_repository.dart';
import 'repositories/callups_repository.dart';
import 'repositories/favorite_tournaments_repository.dart';
import 'repositories/soccer_match_repository.dart';
import 'repositories/soccer_standings_repository.dart';
import 'repositories/private_bookings_repository.dart';
import 'repositories/lobby_bookings_repository.dart';
import 'repositories/lobby_booking_participation_repository.dart';
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
  static late final TournamentPartecipationRepository TournamentPartecipations;
  static late final CallUpsRepository CallUps;
  static late final FavoriteTournamentsRepository FavoriteTournaments;
  static late final SoccerMatchRepository SoccerMatches;
  static late final SoccerStandingsRepository SoccerStandings;
  static late final PrivateBookingsRepository PrivateBookings;
  static late final LobbyBookingsRepository LobbyBookings;
  static late final LobbyBookingParticipationRepository
  LobbyBookingParticipations;
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
    TournamentPartecipations = TournamentPartecipationRepository();
    CallUps = CallUpsRepository();
    FavoriteTournaments = FavoriteTournamentsRepository();
    SoccerMatches = SoccerMatchRepository();
    SoccerStandings = SoccerStandingsRepository();
    PrivateBookings = PrivateBookingsRepository();
    LobbyBookings = LobbyBookingsRepository();
    LobbyBookingParticipations = LobbyBookingParticipationRepository();
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
    int id,
    String? cityId,
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
      if ((await Teams.insertTeam(
            id,
            cityId,
            name,
            alias,
            description,
            captainId,
            catId,
            imageUrl,
            vip,
            visibility,
          )) ==
          false) {
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

      for (int playerId in selectedPlayerIds) {
        if ((await CallUps.addCallUp(tournamentId, teamId, playerId)) ==
            false) {
          await CallUps.deleteCallUps(tournamentId, teamId);
          return false;
        }
      }

      if ((await TournamentPartecipations.addPartecipation(
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
    int id,
    int fieldId,
    int ownerId,
    int maxPlayers,
    int playerToFind,
    double feePerPlayer,
    DateTime startDateTime,
    DateTime endDateTime,
  ) async {
    if (AppConfig.isDebug == true) {
      if ((await LobbyBookings.addLobbyBooking(
            id,
            ownerId,
            fieldId,
            startDateTime,
            endDateTime,
            maxPlayers,
            playerToFind,
            feePerPlayer,
          )) ==
          false) {
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

  Future<bool> leaveLobby(int lobbyBookingId, int playerId, {deleteAccount = false}) async {
    if (AppConfig.isDebug == true) {
      if ((await LobbyBookings.getById(lobbyBookingId))?.ownerId == playerId) {
        return deleteLobby(lobbyBookingId, playerId, deleteAccount: deleteAccount);
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

  Future<bool> deleteLobby(int lobbyBookingId, int playerId, {deleteAccount = false}) async {
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

  Future<bool> leaveTeam(int teamId, int playerId, {deleteAccount = false}) async {
    if (AppConfig.isDebug == true) {
      if ((await Teams.isTeamLeftable(teamId, playerId)) == false) {
        return false;
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
        if ((await Teams.deleteTeam(teamId)) == false) {
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
      if ((await Users.getById(id))?.passwordMD5 != passwordMD5) {
        return false;
      }

      if ((await Users.getById(id))!.isPlayer) {
        final playerId = (await Players.getById(id))!.playerId;
        final List<int> teamIds = await PlaysAt.getByPlayerId(
          playerId,
        ).then((playsAtList) => playsAtList!.map((pa) => pa.teamId).toList());

        for (final teamId in teamIds) {
          if ((await leaveTeam(teamId, playerId, deleteAccount: true)) == false) {
            return false;
          }
        }

        final List<int> lobbyIds =
            await LobbyBookingParticipations.getByPlayerId(playerId).then(
              (participations) =>
                  participations!.map((p) => p.lobbyBookingId).toList(),
            );

        for (final lobbyId in lobbyIds) {
          if ((await leaveLobby(lobbyId, playerId, deleteAccount: true)) == false) {
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
}
