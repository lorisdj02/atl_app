import 'dart:math';
import 'dart:convert';
import 'package:atl_app/database/repositories/reviews_response.dart';
import 'package:atl_app/database/responses/abstract_team_response.dart';
import 'package:atl_app/database/responses/all_tournaments_response.dart';
import 'package:atl_app/database/responses/apply_tournament_filters_response.dart';
import 'package:atl_app/database/responses/callups_response.dart';
import 'package:atl_app/database/responses/checkout_response.dart';
import 'package:atl_app/database/responses/football_match_bracket_response.dart';
import 'package:atl_app/database/responses/football_tournament_response.dart';
import 'package:atl_app/database/responses/invite_friends_response.dart';
import 'package:atl_app/database/responses/my_growth_response.dart';
import 'package:atl_app/database/responses/pay_participation_response.dart';
import 'package:atl_app/database/responses/personal_player_stats_response.dart';
import 'package:atl_app/database/responses/player_requests_response.dart';
import 'package:atl_app/database/responses/players_in_team_response.dart';
import 'package:atl_app/database/responses/referee_licenses_response.dart';
import 'package:atl_app/database/responses/road_to_victory_response.dart';
import 'package:atl_app/database/responses/schedule_match_response.dart';
import 'package:atl_app/database/responses/team_details_response.dart';
import 'package:atl_app/database/responses/teams_response.dart';
import 'package:atl_app/database/responses/tournament_details_response.dart';
import 'package:atl_app/database/responses/tournament_parameters_response.dart';
import 'package:atl_app/database/responses/tournament_summary_response.dart';
import 'package:atl_app/database/responses/wallet_response.dart';
import 'package:atl_app/models/booking.dart';
import 'package:atl_app/models/callup.dart';
import 'package:atl_app/models/city.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/football_tournament_stats.dart';
import 'package:atl_app/models/growth_step.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/lobby_booking_participation.dart';
import 'package:atl_app/models/palmares.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/referee.dart';
import 'package:atl_app/models/referee_license.dart';
import 'package:atl_app/models/referee_roles.dart';
import 'package:atl_app/models/review.dart';
import 'package:atl_app/models/sport.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:atl_app/models/account.dart';
import 'package:atl_app/models/wallet.dart';
import 'package:flutter/material.dart';
import 'db_controller.dart';
import '../config/app_config.dart';
import '../../models/sport_category.dart';
import '../../models/plays_at.dart';
import '../../models/checkout_session.dart';
import '../config/api_json_keys.dart';

class DBRead {
  // DONE
  static Future<MyGrowthResponse> getMyGrowthScreen(int userId) async {
    if (AppConfig.isDebug) {
      final Account? user = await DB.Accounts.getByAccountId(userId);
      if (user == null) {
        throw Exception("User not found");
      }

      switch (user.role) {
        case AccountRole.coordinator:
          final Coordinator? coordinator = await DB.Coordinators.getByAccountId(
            userId,
          );
          if (coordinator == null) {
            throw Exception("Coordinator not found for user");
          }

          final int level = coordinator.level;
          final List<GrowthStep> growthSteps = await DB
              .GrowthSteps.getGrowthStepByType(GrowthStepType.coordinator);
          return MyGrowthResponse(
            growthSteps: growthSteps,
            level: level,
            minRefereePayPerCategoryPerLevel: {},
            maxRefereePayPerCategoryPerLevel: {},
          );
        case AccountRole.referee:
          final Referee? referee = await DB.Referees.getByAccountId(userId);
          if (referee == null) {
            throw Exception("Referee not found for Account");
          }
          final int level = referee.level;
          final List<GrowthStep> growthSteps =
              await DB.GrowthSteps.getGrowthStepByType(GrowthStepType.referee);

          Map<int, Map<SportCategory, double>>
          minRefereePayPerCategoryPerLevel = {};
          Map<int, Map<SportCategory, double>>
          maxRefereePayPerCategoryPerLevel = {};

          for (int x = 1; x <= growthSteps.length; x++) {
            minRefereePayPerCategoryPerLevel[x] = {};
            maxRefereePayPerCategoryPerLevel[x] = {};
          }

          for (var category in SportCategory.values) {
            final List<Sport> sportsInCategory = await DB.Sports.getByCategory(
              category,
            );

            for (var sport in sportsInCategory) {
              final List<RefereeRoles> roles =
                  await DB.RefereeRoles.getBySportId(sport.id);

              for (var role in roles) {
                minRefereePayPerCategoryPerLevel[role.level]!.update(
                  category,
                  (existing) => min(existing, role.payPerMatch),
                  ifAbsent: () => role.payPerMatch,
                );

                maxRefereePayPerCategoryPerLevel[role.level]!.update(
                  category,
                  (existing) => max(existing, role.payPerMatch),
                  ifAbsent: () => role.payPerMatch,
                );
              }
            }
          }

          return MyGrowthResponse(
            growthSteps: growthSteps,
            level: level,
            minRefereePayPerCategoryPerLevel: minRefereePayPerCategoryPerLevel,
            maxRefereePayPerCategoryPerLevel: maxRefereePayPerCategoryPerLevel,
          );
        default:
          return MyGrowthResponse(
            growthSteps: [],
            level: 0,
            minRefereePayPerCategoryPerLevel: {},
            maxRefereePayPerCategoryPerLevel: {},
          );
      }
    } else {
      throw UnimplementedError();
    }
  }
  // DONE
  static Future<TeamsResponse> getTeamsScreen(
    SportCategory currentSport,
  ) async {
    if (AppConfig.isDebug) {
      Map<int, Team> teamCache = {};
      Map<int, String> captainNamePerTeam = {};

      List<Team> teams = await DB.Teams.getAllVisible();
      teams.removeWhere((team) => team.sportCategory != currentSport);
      // Pre-carica i team e i capitani nella cache unificata
      for (var team in teams) {
        teamCache[team.id] = team;
        final captain = await DB.Players.getByPlayerId(team.captainId);
        if (captain != null) {
          captainNamePerTeam[team.id] = captain.username;
        }
      }
      return TeamsResponse(
        teamsCache: teamCache,
        captainNamePerTeam: captainNamePerTeam,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<AbstractTeamResponse> getAbstractTeamScreen(int teamId) async {
    if (AppConfig.isDebug) {
      final Team? team = await DB.Teams.getById(teamId);
      if (team == null) {
        throw Exception("Team not found");
      }

      List<Palmares> palmares = [];
      List<Tournament> tournaments = [];
      Map<int, Coordinator> coordinatorCache = {};
      Map<int, Field> fieldsCache = {};
      Map<int, FootballTeamStats> playerStatsCache = {};
      Map<int, String> cityNamePerField = {};

      if (team.vip || team.players == 0) {
        palmares = await DB.Palmares.getByTeam(team.id);
        for (Palmares palmaresEntry in palmares) {
          Tournament? tournament = await DB.Tournaments.getById(
            palmaresEntry.tournamentId,
          );
          if (tournament != null) {
            tournaments.add(tournament);
            if (!coordinatorCache.containsKey(tournament.coordinatorId)) {
              final coordinator = await DB.Coordinators.getByCoordinatorId(
                tournament.coordinatorId,
              );
              if (coordinator != null) {
                coordinatorCache[tournament.coordinatorId] = coordinator;
              }
            }
            if (!fieldsCache.containsKey(tournament.fieldId)) {
              final field = await DB.Fields.getById(tournament.fieldId);
              if (field == null) {
                throw Exception("Field not found for tournament");
              }
              fieldsCache[tournament.fieldId] = field;
              final city = await DB.Cities.getById(field.cityId);
              if (city != null) {
                cityNamePerField[field.id] = city.name;
              }
            }
          }
        }
      }

      final PlayersInTeamResponse playerData = await getPlayersInTeam(team.id);

      List<FootballTeamStats> playerStats =
          await DB.FootballTeamStats.getByTeamId(team.id);
      List<PlaysAt> playsAtEntries = await DB.PlaysAt.getByTeamId(team.id);

      for (var stats in playerStats) {
        if (team.vip ||
            (playsAtEntries.any(
              (p) => p.playerId == stats.playerId && p.teamId == team.id,
            )) ||
            team.players == 0) {
          playerStatsCache[stats.playerId] = stats;
        }
      }

      return AbstractTeamResponse(
        team: team,
        players: playerData.players,
        palmares: palmares,
        tournaments: tournaments,
        coordinatorsCache: coordinatorCache,
        fieldsCache: fieldsCache,
        footballPlayerStatsCache: playerStatsCache,
        cityNamePerField: cityNamePerField,
        historicalPlayers: playerData.historicalPlayers,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // Non presente un uso negli screen. Non uso un response perchè non ci sarà nel frontend. DONE
  static Future<Map<String, dynamic>> getLobbyInfo(
    int lobbyBookingId,
    int playerId,
  ) async {
    if (AppConfig.isDebug) {
      String username = '';
      int maxPlayers = 0;
      int currentPlayers = 0;
      String completeAddress = '';
      int playersPaid = 0;
      Field? field;

      final LobbyBooking? lobbyBooking = await DB.LobbyBookings.getById(
        lobbyBookingId,
      );
      if (lobbyBooking == null) {
        throw Exception("LobbyBooking not found");
      }

      field = await DB.Fields.getById(lobbyBooking.fieldId);

      if (field == null) {
        throw Exception("Field not found for lobby booking");
      }

      final city = await DB.Cities.getById(field.cityId);
      String cityName = city != null ? city.name : 'Unknown';
      completeAddress = "${field.address}, $cityName";

      final Player? owner = await DB.Players.getByPlayerId(
        lobbyBooking.ownerPlayerId,
      );

      if (owner != null) {
        username = "${owner.username} (${owner.name} ${owner.surname})";
      }

      maxPlayers = lobbyBooking.maxPlayers;

      currentPlayers = await DB.LobbyBookingParticipations.getParticipantCount(
        lobbyBooking.id,
      );

      LobbyBookingParticipation? participation =
          await DB.LobbyBookingParticipations.getByPlayerAndLobbyBookingId(
            playerId,
            lobbyBooking.id,
          );

      if (participation != null) {
        playersPaid = participation.playersPaid;
      }

      return {
        ApiJsonKeys.lobbyBooking: lobbyBooking,
        ApiJsonKeys.usernamePerBooking: username,
        ApiJsonKeys.maxPlayersPerLobby: maxPlayers,
        ApiJsonKeys.currentPlayersPerLobby: currentPlayers,
        ApiJsonKeys.completeAddressPerField: completeAddress,
        ApiJsonKeys.playersPaidPerBooking: playersPaid,
        ApiJsonKeys.fields: field,
      };
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<AllTournamentsResponse> getAllTournamentsScreen(
    int? userId,
    int? teamId,
    SportCategory currentSport,
  ) async {
    if (AppConfig.isDebug) {
      List<Tournament> tournaments = await DB.Tournaments.getActive(
        sportCategory: currentSport,
      );
      Map<int, Coordinator> coordinatorCache = {};
      Map<int, Field> fieldsCache = {};
      Map<int, String> cityNamePerField = {};
      List<Tournament> myTournaments = [];
      double prizeMin = 0;
      double prizeMax = 0;
      double feeMin = 0;
      double feeMax = 0;

      if (userId != null) {
        final myTournamentsData = await getMyTournaments(
          userId,
          teamId,
          currentSport,
        );
        myTournaments = myTournamentsData[ApiJsonKeys.myTournaments];
      }

      tournaments.removeWhere(
        (t) => myTournaments.any((fav) => fav.id == t.id),
      );

      tournaments.addAll(myTournaments);

      tournaments.sort((a, b) => a.name.compareTo(b.name));

      for (var tournament in tournaments) {
        if (!coordinatorCache.containsKey(tournament.coordinatorId)) {
          final coordinator = await DB.Coordinators.getByCoordinatorId(
            tournament.coordinatorId,
          );
          if (coordinator != null) {
            coordinatorCache[tournament.coordinatorId] = coordinator;
          }
        }
        if (!fieldsCache.containsKey(tournament.fieldId)) {
          final Field? field = await DB.Fields.getById(tournament.fieldId);
          if (field == null) {
            throw Exception("Field not found for tournament");
          }
          fieldsCache[tournament.fieldId] = field;
          if (!cityNamePerField.containsKey(field.cityId)) {
            final city = await DB.Cities.getById(field.cityId);
            if (city != null) {
              cityNamePerField[field.cityId] = city.name;
            }
          }
        }
      }

      if (tournaments.isNotEmpty) {
        prizeMin = tournaments
            .map((t) => t.prize1)
            .reduce((a, b) => a < b ? a : b);
        prizeMax = tournaments
            .map((t) => t.prize1)
            .reduce((a, b) => a > b ? a : b);
        feeMin = tournaments.map((t) => t.fee).reduce((a, b) => a < b ? a : b);
        feeMax = tournaments.map((t) => t.fee).reduce((a, b) => a > b ? a : b);
      } else {
        prizeMin = 0;
        prizeMax = 0;
        feeMin = 0;
        feeMax = 0;
      }

      final cities = await DB.Cities.getAll();

      return AllTournamentsResponse(
        tournaments: tournaments,
        myTournaments: myTournaments,
        coordinatorsCache: coordinatorCache,
        fieldsCache: fieldsCache,
        cityNamePerField: cityNamePerField,
        cities: cities,
        prizeMin: prizeMin,
        prizeMax: prizeMax,
        feeMin: feeMin,
        feeMax: feeMax,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // Non presente un uso negli screen. Non uso un response perchè non ci sarà nel frontend. DONE
  static Future<Map<String, dynamic>> getMyTournaments(
    int userId,
    int? teamId,
    SportCategory currentSport,
  ) async {
    if (AppConfig.isDebug) {
      List<Tournament> participatingTournaments = [];
      List<Tournament> favoriteTournaments = [];

      final Account? user = await DB.Accounts.getByAccountId(userId);
      if (user == null) {
        throw Exception("Account not found");
      }

      if (user.isPlayer) {
        final int playerId = await DB.Players.getPlayerIdByAccountId(userId);
        final PlaysAt? playsAt = await DB.PlaysAt.getByPlayerIdAndCategory(
          playerId,
          currentSport,
        );
        if (teamId != null && playsAt != null && playsAt.teamId == teamId) {
          participatingTournaments =
              await DB
                  .Tournaments.getActiveParticipatingTournamentByPlayerAndTeam(
                playerId,
                teamId,
                currentSport,
              );
        }
      } else if (user.isCoordinator) {
        final int coordinatorId =
            await DB.Coordinators.getCoordinatorIdByAccountId(userId);
        participatingTournaments =
            await DB.Tournaments.getActiveOwnedByCoordinatorId(
              coordinatorId,
              currentSport,
            );
      }

      favoriteTournaments = await DB.Tournaments.getFavoriteTournamentByUser(
        userId,
      );

      participatingTournaments.sort((a, b) => a.name.compareTo(b.name));
      favoriteTournaments.sort((a, b) => a.name.compareTo(b.name));

      for (var fav in favoriteTournaments) {
        fav.isFavorite = true;
      }

      return {
        ApiJsonKeys.myTournaments:
            (participatingTournaments + favoriteTournaments)
              ..sort((a, b) => a.name.compareTo(b.name)),
      };
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<TournamentDetailsResponse> getTournamentDetailsScreen(
    int tournamentId,
    SportCategory sportCategory,
    int? userId,
  ) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await DB.Tournaments.getById(tournamentId);
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      final Coordinator? coordinator = await DB.Coordinators.getByCoordinatorId(
        tournament.coordinatorId,
      );

      if (coordinator == null) {
        throw Exception("Coordinator not found");
      }

      final Field? field = await DB.Fields.getById(tournament.fieldId);
      if (field == null) {
        throw Exception("Field not found for tournament");
      }

      final String cityName = await DB.Cities.getById(
        field.cityId,
      ).then((city) => city != null ? city.name : 'Unknown');

      List<TournamentParticipation> participations = [];
      Map<int, Team> teamsCache = {};

      if (!tournament.isATL) {
        participations = await DB.TournamentParticipations.getByTournamentId(
          tournamentId,
        );

        for (var participation in participations) {
          final team = await DB.Teams.getById(participation.teamId);
          if (team != null && !teamsCache.containsKey(team.id)) {
            teamsCache[team.id] = team;
          }
        }
      }

      Player? currentPlayer;
      Team? userTeam;
      TournamentParticipation? teamParticipation;
      if (userId != null) {
        final Account? user = await DB.Accounts.getByAccountId(userId);
        if (user != null && user.isPlayer) {
          final int playerId = await DB.Players.getPlayerIdByAccountId(userId);
          currentPlayer = await DB.Players.getByPlayerId(playerId);
          PlaysAt? playsAt = await DB.PlaysAt.getByPlayerIdAndCategory(
            playerId,
            sportCategory,
          );
          if (playsAt != null) {
            userTeam = await DB.Teams.getById(playsAt.teamId);
          }
        }

        if (userTeam != null) {
          teamParticipation =
              await DB.TournamentParticipations.getByTournamentAndTeam(
                tournamentId,
                userTeam.id,
              );
        }
      }

      return TournamentDetailsResponse(
        coordinator: coordinator,
        field: field,
        cityName: cityName,
        teamsCache: teamsCache,
        currentPlayer: currentPlayer,
        accountTeam: userTeam,
        teamParticipation: teamParticipation,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<List<Player>> getViewCallupsScreen(
    int tournamentId,
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      final List<Callup> callups = await DB.CallUps.getByTournamentAndTeam(
        tournamentId,
        teamId,
      );

      List<Player> players = [];
      for (var callup in callups) {
        final player = await DB.Players.getByPlayerId(callup.playerId);
        if (player != null) {
          players.add(player);
        }
      }

      return players;
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<CallupsResponse> getCallupsScreen(
    int tournamentId,
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await DB.Tournaments.getById(tournamentId);
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      final playersData = await getPlayersInTeam(teamId);
      final List<Player> teamPlayers = playersData.players;

      final Sport? sport = await DB.Sports.getById(tournament.sportId);
      if (sport == null) {
        throw Exception("Sport not found");
      }

      final TournamentParticipation? teamParticipation =
          await DB.TournamentParticipations.getByTournamentAndTeam(
            tournamentId,
            teamId,
          );

      if (teamParticipation == null) {
        throw Exception("Team is not participating in the tournament");
      }

      final List<Callup> callups = await DB.CallUps.getByTournamentAndTeam(
        tournamentId,
        teamId,
      );

      List<Player> callupPlayers = [];
      if (callups.isNotEmpty) {
        for (var callup in callups) {
          final player = await DB.Players.getByPlayerId(callup.playerId);
          if (player != null) {
            callupPlayers.add(player);
          }
        }
      }

      final List<int> calledUpPlayerIds = callups
          .map((c) => c.playerId)
          .toList();

      return CallupsResponse(
        players: teamPlayers,
        sport: sport,
        calledUpPlayerIds: calledUpPlayerIds,
        tournament: tournament,
      );
    } else {
      throw UnimplementedError();
    }
  }

  //DONE, adesso si chiama getTournamentScreen. Generico per ogni sport, poi si specializza nei singoli sport se serve. Per ora solo football, ma dovrebbe bastare per tutti gli sport di squadra.
  // TODO: Ho inserito finalStageBracket!
  static Future<FootballTournamentResponse> getFootballTournamentScreen(
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await DB.Tournaments.getById(tournamentId);
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      final List<FootballMatch> matches =
          await DB.FootballMatches.getMatchesByTournament(tournamentId);
      final List<FootballStanding> standings =
          await DB.FootballStandings.getStandingsByTournament(tournamentId);
      List<Player> players = [];
      Map<int, Team> teamsCache = {};

      final int minutesPerRound = await DB.Tournaments.getMinutesPerRoundById(
        tournamentId,
      );
      final int minutesPerPause = await DB.Tournaments.getMinutesPerPauseById(
        tournamentId,
      );

      final List<Callup> callups = await DB.CallUps.getByTournament(
        tournamentId,
      );

      final List<TournamentParticipation> participations =
          await DB.TournamentParticipations.getByTournamentId(tournamentId);

      for (var participation in participations) {
        final team = await DB.Teams.getById(participation.teamId);
        if (team != null && !teamsCache.containsKey(team.id)) {
          teamsCache[team.id] = team;
        }
      }

      for (var callup in callups) {
        final player = await DB.Players.getByPlayerId(callup.playerId);
        if (player != null) {
          players.add(player);
        }
      }

      final List<FootballTournamentStats> tournamentStats =
          await DB.FootballTournamentStats.getByTournamentId(tournamentId);

      Map<int, FootballTeamStats> playerStatsCache = {};

      for (var stats in tournamentStats) {
        if (stats.motm == 0 && stats.goals == 0) {
          continue; // Skip players with no stats
        }
        playerStatsCache[stats.playerId] = FootballTeamStats(
          playerId: stats.playerId,
          teamId: stats.teamId,
          motm: stats.motm,
          goals: stats.goals,
        );
      }

      return FootballTournamentResponse(
        matches: matches,
        standings: standings,
        players: players,
        teamsCache: teamsCache,
        footballPlayerStatsCache: playerStatsCache,
        minutesPerRound: minutesPerRound,
        minutesPerPause: minutesPerPause,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<PayParticipationResponse> getPayParticipationScreen(
    int playerId,
    SportCategory sportCategory,
  ) async {
    if (AppConfig.isDebug) {
      Map<int, Tournament> tournamentCache = {};
      List<TournamentParticipation> participations = [];
      Map<int, bool> isCalledUpPerTournament = {};
      final PlaysAt? playsAt = await DB.PlaysAt.getByPlayerIdAndCategory(
        playerId,
        sportCategory,
      );

      if (playsAt != null) {
        final teamId = playsAt.teamId;
        participations = await DB.TournamentParticipations.getByTeamId(teamId);
        participations.removeWhere((p) => p.toPay == 0);
        for (TournamentParticipation participation in participations) {
          final tournamentId = participation.tournamentId;
          if (!tournamentCache.containsKey(tournamentId)) {
            final tournament = await DB.Tournaments.getById(tournamentId);
            if (tournament != null) {
              tournamentCache[tournamentId] = tournament;
              final callup = await DB.CallUps.getByTournamentAndTeam(
                tournamentId,
                teamId,
              );
              isCalledUpPerTournament[tournamentId] = callup.any(
                (c) => c.playerId == playerId,
              );
            }
          }
        }
      }

      return PayParticipationResponse(
        tournamentsCache: tournamentCache,
        tournamentParticipations: participations,
        isCalledUpPerTournament: isCalledUpPerTournament,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<PlayerRequestsResponse> getTeamRequestsScreen(
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      final Team? team = await DB.Teams.getById(teamId);
      if (team == null) {
        throw Exception("Team not found");
      }
      List<TeamRequest> teamRequests = await DB.TeamRequests.getByTeamId(
        teamId,
      );
      Map<int, Player> playersCache = {};

      for (var request in teamRequests) {
        if (!playersCache.containsKey(request.playerId)) {
          final player = await DB.Players.getByPlayerId(request.playerId);
          if (player != null) {
            playersCache[request.playerId] = player;
          }
        }
      }

      return PlayerRequestsResponse(
        teamRequests: teamRequests,
        playersCache: playersCache,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, ADESSO ARRIVANO ANCHE LE TRANSAZIONI. MODIFICA IL RESPONSE
  static Future<WalletResponse> getWalletScreen(int userId) async {
    if (AppConfig.isDebug) {
      final Wallet? wallet = await DB.Wallets.getByAccountId(userId);
      if (wallet == null) {
        throw Exception("Wallet not found");
      }
      //ApiJsonKeys.walletTransactions: transactions,
      //TODO: List<WalletTransaction> transactions = await DB.WalletTransactions.getByAccountId(userId);
      return WalletResponse(wallet: wallet);
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<TeamDetailsResponse> getTeamDetailsScreen(
    int playerId,
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      final Team? team = await DB.Teams.getById(teamId);
      if (team == null) {
        throw Exception("Team not found");
      }

      final Player? player = await DB.Players.getByPlayerId(playerId);
      if (player == null) {
        throw Exception("Player not found");
      }

      final PlaysAt? playsAt = await DB.PlaysAt.getByPlayerIdAndCategory(
        playerId,
        team.sportCategory,
      );

      TeamRequest? existingRequest;
      if (playsAt == null) {
        existingRequest = await DB.TeamRequests.getByTeamAndPlayer(
          teamId,
          playerId,
        );
      }

      final AbstractTeamResponse abstractData = await getAbstractTeamScreen(
        teamId,
      );

      return TeamDetailsResponse(
        isPlayerInTeam: playsAt != null,
        existingRequest: existingRequest,
        team: team,
        players: abstractData.players,
        palmares: abstractData.palmares,
        tournaments: abstractData.tournaments,
        coordinatorsCache: abstractData.coordinatorsCache,
        fieldsCache: abstractData.fieldsCache,
        footballPlayerStatsCache: abstractData.footballPlayerStatsCache,
        cityNamePerField: abstractData.cityNamePerField,
        historicalPlayers: abstractData.historicalPlayers,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<RefereeLicensesResponse> getRefereeLicensesScreen(
    int refereeId,
  ) async {
    if (AppConfig.isDebug) {
      final List<RefereeLicense> licenses =
          await DB.RefereeLicenses.getByRefereeId(refereeId);
      final List<Sport> sports = await DB.Sports.getAll();
      return RefereeLicensesResponse(refereeLicenses: licenses, sports: sports);
    } else {
      return throw UnimplementedError();
    }
  }

  // DONE, nel frontend non stampi lobby e booking, attento eh
  static Future<PersonalPlayerStatsResponse> getPersonalPlayerStatsScreen(
    int playerId,
  ) async {
    if (AppConfig.isDebug) {
      final Player? player = await DB.Players.getByPlayerId(playerId);
      if (player == null) {
        throw Exception("Player not found");
      }

      Map<SportCategory, int> numTournamentPerCategory = {};

      if (player.isVip == false) {
        throw Exception("Stats are only available for VIP players");
      }

      FootballTeamStats footballStats =
          await DB.FootballTeamStats.getAggregatedStatsByPlayer(playerId);

      // Count number of tournaments played in per category
      Map<SportCategory, List<Sport>> sportPerCategory = {};
      sportPerCategory[SportCategory.football] = await DB.Sports.getByCategory(
        SportCategory.football,
      );

      final List<Callup> callups = await DB.CallUps.getByPlayerId(playerId);

      for (var category in SportCategory.values) {
        final sports = sportPerCategory[category];
        if (sports != null && sports.isNotEmpty) {
          for (var callUp in callups) {
            final tournament = await DB.Tournaments.getById(
              callUp.tournamentId,
            );
            if (tournament != null) {
              if (sports.any((s) => s.id == tournament.sportId)) {
                numTournamentPerCategory[category] =
                    (numTournamentPerCategory[category] ?? 0) + 1;
              }
            }
          }
        }
      }

      Map<SportCategory, int> numPrivateBookingPerCategory = {};
      Map<SportCategory, int> numLobbyJoinedPerCategory = {};

      final List<PrivateBooking> privateBookings =
          (await DB.PrivateBookings.getByPlayerId(playerId))
              .where((booking) => booking.status != BookingStatus.refund)
              .toList();

      final List<LobbyBookingParticipation> lobbyParticipations =
          await DB.LobbyBookingParticipations.getByPlayerId(playerId);

      List<LobbyBooking> lobbyBookings = [];
      for (var participation in lobbyParticipations) {
        final lobbyBooking = await DB.LobbyBookings.getById(
          participation.lobbyBookingId,
        );
        if (lobbyBooking != null) {
          lobbyBookings.add(lobbyBooking);
        }
      }

      for (var category in SportCategory.values) {
        numPrivateBookingPerCategory[category] = privateBookings
            .where((booking) => booking.sportCategory == category)
            .length;
        numLobbyJoinedPerCategory[category] = lobbyBookings
            .where((booking) => booking.sportCategory == category)
            .length;
      }

      return PersonalPlayerStatsResponse(
        footballStats: footballStats,
        numTournamentPerCategory: numTournamentPerCategory,
        numPrivateBookingPerCategory: numPrivateBookingPerCategory,
        numLobbyJoinedPerCategory: numLobbyJoinedPerCategory,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<ReviewsResponse> getReviewsScreen(int userId) async {
    if (AppConfig.isDebug) {
      /*
      final List<Review> reviews =
          await DB.Reviews.getPendingReviewsForReviewerId(userId);
          */
      final List<Review> reviews = await DB.Reviews.getByReviewerAccountId(
        userId,
      );
      Map<int, Account> userPerReview = {};
      Map<int, String> matchTeamsStringPerReview = {};

      for (var review in reviews) {
        switch (review.reviewType) {
          case ReviewType.coordinatorToReferee:
            if (review.matchId == null) {
              throw Exception("Match ID is null for review ${review.id}");
            }
            final Referee? referee = await DB.Referees.getByAccountId(
              review.reviewedAccountId,
            );
            if (referee != null) {
              final Account? user = await DB.Accounts.getByAccountId(
                referee.id,
              );
              if (user != null) {
                userPerReview[review.id] = user;
              }
            } else {
              throw Exception("Referee not found for review ${review.id}");
            }
            break;
          case ReviewType.refereeToCoordinator ||
              ReviewType.playerToCoordinator:
            final Coordinator? coordinator =
                await DB.Coordinators.getByAccountId(review.reviewedAccountId);
            if (coordinator != null) {
              final Account? user = await DB.Accounts.getByAccountId(
                coordinator.id,
              );
              if (user != null) {
                userPerReview[review.id] = user;
              }
            } else {
              throw Exception("Coordinator not found for review ${review.id}");
            }
            break;
        }
        if (review.sportCategory == SportCategory.football &&
            review.matchId != null) {
          final FootballMatch? match = await DB.FootballMatches.getById(
            review.matchId!,
          );
          if (match != null) {
            final Team? homeTeam = match.homeTeamId != null
                ? await DB.Teams.getById(match.homeTeamId!)
                : null;
            final Team? awayTeam = match.awayTeamId != null
                ? await DB.Teams.getById(match.awayTeamId!)
                : null;
            matchTeamsStringPerReview[review.id] =
                "${homeTeam?.name} vs ${awayTeam?.name}";
          }
        }
      }
      return ReviewsResponse(
        reviews: reviews,
        accountPerReview: userPerReview,
        matchTeamsStringPerReview: matchTeamsStringPerReview,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<InviteFriendsResponse> getInviteFriendsScreen(
    int userId,
  ) async {
    if (AppConfig.isDebug) {
      final Wallet? wallet = await DB.Wallets.getByAccountId(userId);
      if (wallet == null) {
        throw Exception("Wallet not found");
      }
      final double inviteBalance = wallet.inviteBalance;

      final Account? user = await DB.Accounts.getByAccountId(userId);
      if (user == null) {
        throw Exception("Account not found");
      }

      final int numRedeemed =
          await DB.FriendInvites.countRedeemedInvitesByAccountId(userId);
      final int numInvites = await DB.FriendInvites.countInvitesByAccountId(
        userId,
      );

      return InviteFriendsResponse(
        inviteBalance: inviteBalance,
        referralCode: user.username,
        numRedeemed: numRedeemed,
        numInvites: numInvites,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, VERIFICA CheckountPayload
  static Future<CheckoutResponse> getCheckoutScreen(int sessionId) async {
    if (AppConfig.isDebug) {
      final CheckoutSession? session = await DB.CheckoutSessions.getById(
        sessionId,
      );
      if (session == null) {
        throw Exception("Checkout session not found");
      }
      if (session.expiresAt.isBefore(DateTime.now())) {
        throw Exception("Checkout session has expired");
      }
      if (session.status != CheckoutSessionStatus.pending) {
        throw Exception("Checkout session is not pending");
      }

      final Wallet? wallet = await DB.Wallets.getByAccountId(session.userId);
      if (wallet == null) {
        throw Exception("Wallet not found for user");
      }
      final Map<String, dynamic> payload = jsonDecode(session.payload);

      String? tournamentName;
      String? bookingUsername;
      String? cityName;
      String? fieldName;
      String? fieldAddress;
      DateTime? startTime;
      DateTime? endTime;
      int? maxPlayers;
      int? playersToPay;

      switch (session.type) {
        case CheckoutType.tournamentFee:
          final int? tournamentId = payload["tournamentId"];
          if (tournamentId == null) {
            throw Exception("Tournament ID not found in payload");
          }
          final Tournament? tournament = await DB.Tournaments.getById(
            tournamentId,
          );
          if (tournament == null) {
            throw Exception("Tournament not found for ID $tournamentId");
          }
          tournamentName = tournament.name;
          break;

        case CheckoutType.lobbyBookingParticipate:
          final int? lobbyId = payload["lobbyId"];
          if (lobbyId == null) throw Exception("Lobby ID not found in payload");
          final LobbyBooking? lobby = await DB.LobbyBookings.getById(lobbyId);
          if (lobby == null) throw Exception("Lobby not found for ID $lobbyId");
          final Field? field = await DB.Fields.getById(lobby.fieldId);
          if (field == null) {
            throw Exception("Field not found for ID ${lobby.fieldId}");
          }
          final City? city = await DB.Cities.getById(field.cityId);
          if (city == null) {
            throw Exception("City not found for ID ${field.cityId}");
          }
          final Player? owner = await DB.Players.getByPlayerId(
            lobby.ownerPlayerId,
          );
          if (owner == null) {
            throw Exception(
              "Owner player not found for ID ${lobby.ownerPlayerId}",
            );
          }
          fieldName = field.name;
          fieldAddress = field.address;
          cityName = city.name;
          bookingUsername = owner.username;
          startTime = lobby.startTime;
          endTime = lobby.finishTime;
          maxPlayers = lobby.maxPlayers;
          playersToPay = payload["playersPaid"] as int?;
          break;

        case CheckoutType.lobbyBookingCreate:
          final int? fieldId = payload["fieldId"];
          final int? ownerPlayerId = payload["ownerPlayerId"];
          final String? startStr = payload["startDateTime"];
          final String? endStr = payload["endDateTime"];
          final int? maxPl = payload["maxPlayers"] as int?;
          final int? playersToFind = payload["playersToFind"] as int?;
          if (fieldId == null ||
              ownerPlayerId == null ||
              startStr == null ||
              endStr == null) {
            throw Exception("Error in fetching checkout");
          }
          final Field? field = await DB.Fields.getById(fieldId);
          if (field == null) throw Exception("Field not found for ID $fieldId");
          final City? city = await DB.Cities.getById(field.cityId);
          if (city == null) {
            throw Exception("City not found for ID ${field.cityId}");
          }
          final Player? owner = await DB.Players.getByPlayerId(ownerPlayerId);
          if (owner == null) {
            throw Exception("Owner player not found for ID $ownerPlayerId");
          }
          fieldName = field.name;
          fieldAddress = field.address;
          cityName = city.name;
          bookingUsername = owner.username;
          startTime = DateTime.parse(startStr);
          endTime = DateTime.parse(endStr);
          maxPlayers = maxPl;
          playersToPay = (maxPl != null && playersToFind != null)
              ? maxPl - playersToFind
              : null;
          break;

        case CheckoutType.privateBooking:
          final int? fieldId = payload["fieldId"];
          final String? startStr = payload["startDateTime"];
          final String? endStr = payload["endDateTime"];
          if (fieldId == null || startStr == null || endStr == null) {
            throw Exception("Missing fields in privateBooking payload");
          }
          final Field? field = await DB.Fields.getById(fieldId);
          if (field == null) throw Exception("Field not found for ID $fieldId");
          final City? city = await DB.Cities.getById(field.cityId);
          if (city == null) {
            throw Exception("City not found for ID ${field.cityId}");
          }
          fieldName = field.name;
          fieldAddress = field.address;
          cityName = city.name;
          startTime = DateTime.parse(startStr);
          endTime = DateTime.parse(endStr);
          break;
      }

      return CheckoutResponse(
        checkoutSession: session,
        wallet: wallet,
        tournamentName: tournamentName,
        bookingUsername: bookingUsername,
        cityName: cityName,
        fieldName: fieldName,
        fieldAddress: fieldAddress,
        startTime: startTime,
        finishTime: endTime,
        totalPlayers: maxPlayers,
        playersToPay: playersToPay,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // NOT SCREENS

  // DONE
  static Future<bool> checkTeamNameInCategory(
    String teamName,
    SportCategory category,
  ) async {
    if (AppConfig.isDebug) {
      return await DB.Teams.isNameUniqueInCategory(teamName, category);
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<PlayersInTeamResponse> getPlayersInTeam(int teamId) async {
    if (AppConfig.isDebug) {
      final Team? team = await DB.Teams.getById(teamId);
      if (team == null) {
        throw Exception("Team not found");
      }

      List<PlaysAt> playsAtEntries = await DB.PlaysAt.getByTeamId(team.id);
      List<Player> players = [];

      for (var entry in playsAtEntries) {
        final player = await DB.Players.getByPlayerId(entry.playerId);
        if (player != null) {
          players.add(player);
        }
      }

      List<Player> historicalPlayers = [...players];
      List<FootballTeamStats> allStats = await DB.FootballTeamStats.getByTeamId(
        team.id,
      );
      for (var stats in allStats) {
        if ((team.vip || team.players == 0) &&
            !historicalPlayers.any((p) => p.id == stats.playerId)) {
          final player = await DB.Players.getByPlayerId(stats.playerId);
          if (player != null) {
            historicalPlayers.add(player);
          }
        }
      }

      return PlayersInTeamResponse(
        players: players,
        historicalPlayers: historicalPlayers,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, è inutile mettere i BOOL, basta leggere il tournament mettendo inizializzati prize1 e prize2 != 0 se vuoi usarli
  // Ritorna anche numMatches giusto per
  static Future<TournamentParametersResponse> calculateTournamentParameters(
    Tournament fictitiousTournament,
    bool prize1,
    bool prize2,
  ) async {
    if (AppConfig.isDebug) {
      final fee = await DB.Tournaments.calculateTournamentFee(
        fictitiousTournament,
      );
      final coordinatorPay = await DB.Tournaments.calculatePayCoordinator(
        fictitiousTournament,
      );

      // Calculate prizes only if requested
      final prize1Value = prize1
          ? await DB.Tournaments.calculatePrize1(fictitiousTournament)
          : null;
      final prize2Value = prize2
          ? await DB.Tournaments.calculatePrize2(fictitiousTournament)
          : null;

      return TournamentParametersResponse(
        fee: fee,
        coordinatorPay: coordinatorPay,
        prize1: prize1Value,
        prize2: prize2Value,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, Ho separato numTeams in numTeamsMin e Max. Ora si può cercare solo per Name non per Code
  static Future<ApplyTournamentFiltersResponse> applyTournamentFilters(
    int? userId,
    int? teamId, {
    int? cityId,
    int? numTeams,
    RangeValues? prizeRange,
    RangeValues? feeRange,
    String? nameOrCode,
    required SportCategory sportCategory,
  }) async {
    if (AppConfig.isDebug) {
      Map<int, String> cityNamePerField = {};
      Map<int, Field> fieldsCache = {};
      Map<int, Coordinator> coordinatorCache = {};

      List<Tournament> filteredTournaments =
          await DB.Tournaments.getFilteredTournaments(
            cityId: cityId,
            numTeams: numTeams,
            prizeRange: prizeRange,
            feeRange: feeRange,
            nameOrCode: nameOrCode,
            sportCategory: sportCategory,
          );

      filteredTournaments.sort((a, b) => a.name.compareTo(b.name));

      for (var tournament in filteredTournaments) {
        if (!coordinatorCache.containsKey(tournament.coordinatorId)) {
          final coordinator = await DB.Coordinators.getByCoordinatorId(
            tournament.coordinatorId,
          );
          if (coordinator != null) {
            coordinatorCache[tournament.coordinatorId] = coordinator;
          }
        }
        if (!fieldsCache.containsKey(tournament.fieldId)) {
          final Field? field = await DB.Fields.getById(tournament.fieldId);
          if (field == null) {
            throw Exception("Field not found for tournament");
          }
          fieldsCache[tournament.fieldId] = field;
          if (!cityNamePerField.containsKey(field.cityId)) {
            final city = await DB.Cities.getById(field.cityId);
            if (city != null) {
              cityNamePerField[field.cityId] = city.name;
            }
          }
        }
      }

      return ApplyTournamentFiltersResponse(
        tournaments: filteredTournaments,
        cityNamePerField: cityNamePerField,
        fieldsCache: fieldsCache,
        coordinatorsCache: coordinatorCache,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, si chiama getNotPaidTeamParticipations
  static Future<List<TournamentParticipation>> getTeamParticipations(
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      List<TournamentParticipation> participations =
          await DB.TournamentParticipations.getByTeamId(teamId);
      return participations.where((p) => p.toPay > 0).toList();
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, sono due API separate sul backend, ma unite qui nel frontend.
  // getTeamById e getTournamentById
  static Future<T> searchTeamOrTournament<T>(
    int id, {
    required bool isTeam,
    required bool isTournament,
  }) async {
    if (AppConfig.isDebug) {
      if (isTeam && isTournament) {
        throw Exception(
          "Cannot search for both team and tournament at the same time",
        );
      }

      if (isTeam) {
        final Team? team = await DB.Teams.getById(id);
        if (team == null) {
          throw Exception("Team not found");
        }
        return team as T;
      } else if (isTournament) {
        final Tournament? tournament = await DB.Tournaments.getById(id);
        if (tournament == null) {
          throw Exception("Tournament not found");
        }
        return tournament as T;
      } else {
        throw Exception("Invalid search parameters");
      }
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, è inutile controllare anche il passato, basta controllare le prenotazioni future (da now in poi)
  static Future<ScheduleMatchResponse> getScheduleData(int tournamentId) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await DB.Tournaments.getById(tournamentId);
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      final int minutesPerRound = await DB.Tournaments.getMinutesPerRoundById(
        tournamentId,
      );
      final int minutesPerPause = await DB.Tournaments.getMinutesPerPauseById(
        tournamentId,
      );

      final existingBookings = await DB.Bookings.getByFieldId(
        tournament.fieldId,
      );

      return ScheduleMatchResponse(
        minutesPerRound: minutesPerRound,
        minutesPerPause: minutesPerPause,
        bookings: existingBookings,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<List<Sport>> getSportsByCategory(SportCategory category) async {
    if (AppConfig.isDebug) {
      final List<Sport> sports = await DB.Sports.getByCategory(category);
      return sports;
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<TournamentSummaryResponse> getTournamentSummary(
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await
          DB.Tournaments.getById(tournamentId) as Tournament?;
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      final Sport? sport = await DB.Sports.getById(tournament.sportId);
      if (sport == null) {
        throw Exception("Sport not found");
      }

      final Field? field = await DB.Fields.getById(tournament.fieldId);

      if (field == null) {
        throw Exception("Field not found");
      }

      final City? city = await DB.Cities.getById(field.cityId);

      if (city == null) {
        throw Exception("City not found");
      }

      final String cityName = city.name;

      return TournamentSummaryResponse(
        tournament: tournament,
        sport: sport,
        field: field,
        cityName: cityName,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // TODO: Questi non servono più, sono implementati con final stage brackets
  // super inefficiente. Cerca di mandare tutti i dati a road_to_victory widget.
  // pensa a:
  // Map<int, int[2]> per mappare matchId -> [homeTeamId, awayTeamId]
  // Map<int, Team> per mappare teamId -> Team (così da non dover fare tante query per i team)
  // Map<int, int[2]> per mappare matchId -> [homeTeamGoals, awayTeamGoals]
  // Map<int?[2], int?> per mappare [matchId andata, eventuale matchId ritorno] -> partita successiva (così da capire quale partita è la successiva in base a quale partita è stata giocata)
  // Map<int, FootballMatch> per mappare matchId -> FootballMatch (così da avere tutti i dati della partita)
  static Future<FootballMatchBracketResponse> getFootballMatchBracket(
    int matchId,
    SportCategory sportCategory, {
    required bool isFinal,
  }) async {
    if (AppConfig.isDebug) {
      if (sportCategory != SportCategory.football) {
        throw Exception("MatchBracket is only implemented for football");
      }

      final FootballMatch? match = await DB.FootballMatches.getById(matchId);
      if (match == null) {
        throw Exception("Match not found");
      }

      Team? homeTeam;
      Team? awayTeam;
      int? winnerId;

      if (match.homeTeamId != null) {
        homeTeam = await DB.Teams.getById(match.homeTeamId!);
      }

      if (match.awayTeamId != null) {
        awayTeam = await DB.Teams.getById(match.awayTeamId!);
      }

      if (isFinal && match.status == FootballMatchStatus.finished) {
        winnerId = await DB.FootballMatches.getMatchWinner(matchId);
        if (winnerId == -1) winnerId = null;
      }

      return FootballMatchBracketResponse(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        winnerId: winnerId,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // uniscilo con il precedente e manda tutto a road_to_victory widget. In questo modo hai tutti i dati necessari per costruire l'albero del torneo in un'unica chiamata, evitando di dover fare tante chiamate per ogni partita per ottenere i dati dei team, dei risultati, ecc.
  static Future<RoadToVictoryResponse> getRoadToVictoryWidget(
    int tournamentId,
    SportCategory sportCategory,
  ) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await DB.Tournaments.getById(tournamentId);
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      if (sportCategory != SportCategory.football) {
        throw Exception(
          "Matches in tournament is only implemented for football",
        );
      }

      final List<FootballMatch> matches =
          await DB.FootballMatches.getMatchesByTournament(tournamentId);

      return RoadToVictoryResponse(tournament: tournament, matches: matches);
    } else {
      throw UnimplementedError();
    }
  }
}
