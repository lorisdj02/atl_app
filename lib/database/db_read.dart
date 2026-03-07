import 'dart:math';

import 'package:atl_app/models/booking.dart';
import 'package:atl_app/models/callup.dart';
import 'package:atl_app/models/city.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_match_event.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/football_tournament_stats.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/lobby_booking_participation.dart';
import 'package:atl_app/models/palmares.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/referee.dart';
import 'package:atl_app/models/referee_assignment.dart';
import 'package:atl_app/models/sport.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_request.dart';
import 'package:atl_app/models/team_stats.dart';
import 'package:atl_app/models/tournament.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:atl_app/models/user.dart';
import 'package:atl_app/models/wallet.dart';
import 'package:flutter/material.dart';
import 'db_controller.dart';
import '../config/app_config.dart';
import '../../models/sport_category.dart';
import '../../models/plays_at.dart';
import '../config/api_json_keys.dart';

class DBRead {
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

  // la password è in chiaro, ma tanto è un mock, quindi non importa
  static Future<Map<String, dynamic>> handleLogin(
    String usernameOrEmail,
    String password,
  ) async {
    if (AppConfig.isDebug) {
      final User? user = await DB.Users.getByEmailOrUsername(
        usernameOrEmail,
        password,
      );
      if (user == null) {
        return {ApiJsonKeys.user: null};
      }

      final UserRole userRole = user.role;

      switch (userRole) {
        case UserRole.player:
          final int playerId = await DB.Players.getPlayerIdByUserId(user.id);
          if (playerId < 1) {
            throw Exception("Player not found for user");
          }

          final PlaysAt? playsAt = await DB.PlaysAt.getByPlayerIdAndCategory(
            playerId,
            SportCategory.football,
          );
          Team? userTeam;

          return {
            ApiJsonKeys.user: user,
            ApiJsonKeys.roleId: playerId,
            ApiJsonKeys.team: playsAt != null ? playsAt.teamId : null,
          };
        case UserRole.coordinator:
          final int coordinatorId =
              await DB.Coordinators.getCoordinatorIdByUserId(user.id);
          if (coordinatorId < 1) {
            throw Exception("Coordinator not found for user");
          }
          return {ApiJsonKeys.user: user, ApiJsonKeys.roleId: coordinatorId};
        case UserRole.referee:
          final int refereeId = await DB.Referees.getRefereeIdByUserId(user.id);
          if (refereeId < 1) {
            throw Exception("Referee not found for user");
          }
          return {ApiJsonKeys.user: user, ApiJsonKeys.roleId: refereeId};
        case UserRole.organization:
          final int organizationId =
              await DB.Organizations.getOrganizationIdByUserId(user.id);
          if (organizationId < 1) {
            throw Exception("Organization not found for user");
          }
          return {ApiJsonKeys.user: user, ApiJsonKeys.roleId: organizationId};
        default:
          throw Exception("Unknown user role");
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getCities() async {
    if (AppConfig.isDebug) {
      List<City> cities = await DB.Cities.getAll();
      return {ApiJsonKeys.cities: cities};
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getFieldsByPlayersAndCity({
    required int maxPlayers,
    required int cityId,
  }) async {
    if (AppConfig.isDebug) {
      final List<Field> fields = await DB.Fields.getByMaxPlayersAndCity(
        maxPlayers,
        cityId,
      );
      return {ApiJsonKeys.fields: fields};
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> calculateTournamentParameters(
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

      return {
        ApiJsonKeys.fee: fee,
        ApiJsonKeys.coordinatorPay: coordinatorPay,
        ApiJsonKeys.prize1: prize1Value,
        ApiJsonKeys.prize2: prize2Value,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getFreeFieldsByPlayerAndCityAndDate({
    required int maxPlayers,
    required int cityId,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    if (AppConfig.isDebug) {
      final allFields = await DB.Fields.getByMaxPlayersAndCity(
        maxPlayers,
        cityId,
      );

      // Get free field IDs
      final allFieldIds = allFields.map((f) => f.id).toList();

      final freeFieldIds = await DB.LobbyBookings.getFreeFieldIds(
        startDateTime,
        endDateTime,
        allFieldIds,
      );

      // Filter fields to keep only free ones
      final fields = allFields
          .where((field) => freeFieldIds.contains(field.id))
          .toList();
      return {ApiJsonKeys.fields: fields};
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getUserLevel(int userId) async {
    if (AppConfig.isDebug) {
      final User? user = await DB.Users.getByUserId(userId);
      if (user == null) {
        throw Exception("User not found");
      }
      if (user.role == UserRole.coordinator) {
        final Coordinator? coordinator = await DB.Coordinators.getByUserId(
          userId,
        );
        if (coordinator == null) {
          throw Exception("Coordinator not found for user");
        }
        return {ApiJsonKeys.level: coordinator.level};
      } else if (user.role == UserRole.referee) {
        final Referee? referee = await DB.Referees.getByUserId(userId);
        if (referee == null) {
          throw Exception("Referee not found for user");
        }
        return {ApiJsonKeys.level: referee.level};
      } else {
        return {};
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getPlayerHomeScreen({
    required int playerId,
    required SportCategory currentSport,
  }) async {
    if (AppConfig.isDebug) {
      List<dynamic> bookings = [];
      Map<int, Team> teamsCache = {};
      List<Tournament> activeTournaments = [];
      Map<int, int> minutesRoundPerTournament = {};
      Map<int, int> minutesPausePerTournament = {};
      Map<int, List<FootballMatch>> matchesPerTournament = {};
      Map<int, List<FootballStanding>> standingsPerTournament = {};
      Map<int, Field> fieldCache = {};
      Map<int, String> completeAddressPerField = {};

      Map<int, String> usernamePerBooking = {};
      Map<int, int> maxPlayersPerLobby = {};
      Map<int, int> currentPlayersPerLobby = {};
      Map<int, int> playersPaidPerBooking = {};

      Team? userTeam;

      int? teamId;

      final PlaysAt? playerPlays = (await DB.PlaysAt.getByPlayerIdAndCategory(
        playerId,
        currentSport,
      ));

      if (playerPlays != null && playerPlays.teamId != -1) {
        teamId = playerPlays.teamId;
        userTeam = await DB.Teams.getById(teamId);
      }

      final List<PrivateBooking> privateBookings =
          await DB.PrivateBookings.getByPlayerId(playerId);
      final List<int> lobbyBookingsIds =
          (await DB.LobbyBookingParticipations.getByPlayerId(
            playerId,
          )).map((p) => p.lobbyBookingId).toList();
      List<LobbyBooking> lobbyBookings = [];
      for (var lobbyBookingId in lobbyBookingsIds) {
        final LobbyBooking? lobbyBooking = await DB.LobbyBookings.getById(
          lobbyBookingId,
        );
        if (lobbyBooking != null) {
          lobbyBookings.add(lobbyBooking);
          final lobbyData = await getLobbyInfo(lobbyBookingId, playerId);
          usernamePerBooking[lobbyBooking.id] =
              lobbyData[ApiJsonKeys.usernamePerBooking];
          maxPlayersPerLobby[lobbyBooking.id] =
              lobbyData[ApiJsonKeys.maxPlayersPerLobby];
          currentPlayersPerLobby[lobbyBooking.id] =
              lobbyData[ApiJsonKeys.currentPlayersPerLobby];
          playersPaidPerBooking[lobbyBooking.id] =
              lobbyData[ApiJsonKeys.playersPaidPerBooking];
        }
      }

      // Combina e ordina per startTime
      final List<dynamic> allBookings = [...privateBookings, ...lobbyBookings];
      allBookings.sort((a, b) {
        final aTime = a is PrivateBooking
            ? a.startTime
            : (a as LobbyBooking).startTime;
        final bTime = b is PrivateBooking
            ? b.startTime
            : (b as LobbyBooking).startTime;
        return aTime.compareTo(bTime);
      });

      bookings = allBookings;

      for (var booking in bookings) {
        Field field = await DB.Fields.getById(booking.fieldId);
        if (!fieldCache.containsKey(field.id)) {
          fieldCache[field.id] = field;
        }
        if (!completeAddressPerField.containsKey(field.id)) {
          final city = await DB.Cities.getById(field.cityId);
          String cityName = city != null ? city.name : 'Unknown';
          completeAddressPerField[field.id] = "${field.address}, $cityName";
        }
      }

      // Load user's team using teamId from user
      if (teamId != null &&
          teamId != -1 &&
          currentSport == SportCategory.football) {
        userTeam = (await DB.Teams.getById(teamId))!;

        final List<int> activeTournamentsId =
            (await DB.TournamentParticipations.getPaidByTeamId(
              teamId,
            )).map((p) => p.tournamentId).toList();

        activeTournaments = (await DB.Tournaments.getBySportCategory(
          currentSport,
        )).where((t) => activeTournamentsId.contains(t.id)).toList();

        // Load matches and standings for each tournament
        for (var tournament in activeTournaments) {
          final matches = await DB.FootballMatches.getMatchesByTournament(
            tournament.id,
          );
          final standings = await DB.FootballStandings.getStandingsByTournament(
            tournament.id,
          );

          final int minutesPerRoundValue =
              await DB.Tournaments.getMinutesPerRoundById(tournament.id);
          final int minutesPerPauseValue =
              await DB.Tournaments.getMinutesPerPauseById(tournament.id);

          minutesRoundPerTournament[tournament.id] = minutesPerRoundValue;
          minutesPausePerTournament[tournament.id] = minutesPerPauseValue;
          matchesPerTournament[tournament.id] = matches;
          standingsPerTournament[tournament.id] = standings;

          // Cache teams
          final teamIds = <int>{};
          for (var match in matches) {
            if (match.homeTeamId != null) {
              teamIds.add(match.homeTeamId!);
            }
            if (match.awayTeamId != null) {
              teamIds.add(match.awayTeamId!);
            }
          }
          for (var standing in standings) {
            teamIds.add(standing.teamId);
          }

          for (var teamId in teamIds) {
            if (!teamsCache.containsKey(teamId)) {
              final team = await DB.Teams.getById(teamId);
              if (team != null) {
                teamsCache[teamId] = team;
              }
            }
          }
        }
      }

      return {
        ApiJsonKeys.bookings: bookings,
        ApiJsonKeys.activeTournaments: activeTournaments,
        ApiJsonKeys.minutesRoundPerTournament: minutesRoundPerTournament,
        ApiJsonKeys.minutesPausePerTournament: minutesPausePerTournament,
        ApiJsonKeys.matchesPerTournament: matchesPerTournament,
        ApiJsonKeys.standingsPerTournament: standingsPerTournament,
        ApiJsonKeys.teamsCache: teamsCache,
        ApiJsonKeys.userTeam: userTeam,
        ApiJsonKeys.usernamePerBooking: usernamePerBooking,
        ApiJsonKeys.fieldCache: fieldCache,
        ApiJsonKeys.maxPlayersPerLobby: maxPlayersPerLobby,
        ApiJsonKeys.currentPlayersPerLobby: currentPlayersPerLobby,
        ApiJsonKeys.completeAddressPerField: completeAddressPerField,
        ApiJsonKeys.playersPaidPerBooking: playersPaidPerBooking,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getCoordinatorHomeScreen({
    required int coordinatorId,
    required SportCategory currentSport,
  }) async {
    if (AppConfig.isDebug) {
      if (SportCategory.football != currentSport) {
        throw UnimplementedError();
      }

      // Load tournaments where user is coordinator
      final activeTournaments =
          (await DB.Tournaments.getByCoordinatorAndCategory(
                coordinatorId,
                currentSport,
              ))
              .where(
                (t) =>
                    t.status != TournamentStatus.finished &&
                    t.status != TournamentStatus.created,
              )
              .toList();
      Map<int, Team> teamsCache = {};
      Map<int, int> minutesRoundPerTournament = {};
      Map<int, int> minutesPausePerTournament = {};

      final matchesByTournament = <int, List<FootballMatch>>{};

      for (var tournament in activeTournaments) {
        final List<FootballMatch> matches =
            await DB.FootballMatches.getMatchesByTournament(tournament.id);

        final List<FootballMatch> scheduledMatches = matches
            .where((m) => m.scheduledStart != null)
            .toList();

        if (scheduledMatches.isNotEmpty) {
          matchesByTournament[tournament.id] = scheduledMatches;

          // Load teams for these scheduledMatches
          for (var match in scheduledMatches) {
            if (match.homeTeamId != null &&
                !teamsCache.containsKey(match.homeTeamId)) {
              final team = await DB.Teams.getById(match.homeTeamId!);
              if (team != null) teamsCache[match.homeTeamId!] = team;
            }
            if (match.awayTeamId != null &&
                !teamsCache.containsKey(match.awayTeamId)) {
              final team = await DB.Teams.getById(match.awayTeamId!);
              if (team != null) teamsCache[match.awayTeamId!] = team;
            }
          }
        }

        // Load minutes per round and pause
        minutesRoundPerTournament[tournament.id] =
            await DB.Tournaments.getMinutesPerRoundById(tournament.id);
        minutesPausePerTournament[tournament.id] =
            await DB.Tournaments.getMinutesPerPauseById(tournament.id);
      }

      return {
        ApiJsonKeys.activeTournaments: activeTournaments,
        ApiJsonKeys.matchesPerTournament: matchesByTournament,
        ApiJsonKeys.teamsCache: teamsCache,
        ApiJsonKeys.minutesRoundPerTournament: minutesRoundPerTournament,
        ApiJsonKeys.minutesPausePerTournament: minutesPausePerTournament,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getRefereeHomeScreen({
    required int refereeId,
    required SportCategory currentSport,
  }) async {
    if (AppConfig.isDebug) {
      if (SportCategory.football != currentSport) {
        throw UnimplementedError();
      }
      // Load referee assignments
      final assignments = await DB.RefereeAssignments.getByRefereeId(refereeId);

      // Load matches for selected date
      final assignedMatches = <FootballMatch>[];
      Map<int, Team> teamsCache = {};
      Map<int, int> minutesRoundPerTournament = {};
      Map<int, int> minutesPausePerTournament = {};

      for (var assignment in assignments) {
        final match = await DB.FootballMatches.getById(assignment.matchId);
        if (match != null && match.scheduledStart != null) {
          assignedMatches.add(match);

          // Load teams for this match
          if (match.homeTeamId != null &&
              !teamsCache.containsKey(match.homeTeamId)) {
            final team = await DB.Teams.getById(match.homeTeamId!);
            if (team != null) teamsCache[match.homeTeamId!] = team;
          }
          if (match.awayTeamId != null &&
              !teamsCache.containsKey(match.awayTeamId)) {
            final team = await DB.Teams.getById(match.awayTeamId!);
            if (team != null) teamsCache[match.awayTeamId!] = team;
          }

          // Load minutes per round and pause for the tournament
          if (!minutesRoundPerTournament.containsKey(match.tournamentId)) {
            minutesRoundPerTournament[match.tournamentId] =
                await DB.Tournaments.getMinutesPerRoundById(match.tournamentId);
          }
          if (!minutesPausePerTournament.containsKey(match.tournamentId)) {
            minutesPausePerTournament[match.tournamentId] =
                await DB.Tournaments.getMinutesPerPauseById(match.tournamentId);
          }
        }
      }
      return {
        ApiJsonKeys.assignments: assignments,
        ApiJsonKeys.assignedMatches: assignedMatches,
        ApiJsonKeys.teamsCache: teamsCache,
        ApiJsonKeys.minutesRoundPerTournament: minutesRoundPerTournament,
        ApiJsonKeys.minutesPausePerTournament: minutesPausePerTournament,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getOrganizationHomeScreen({
    required int organizationId,
    required SportCategory currentSport,
  }) async {
    if (AppConfig.isDebug) {
      // Load sports managed by organization

      // Load Fields for the organization
      final List<Field> fields = await DB.Fields.getByOrganization(
        organizationId,
      );

      Map<int, FootballMatch> matchPerBooking = {};
      Map<int, dynamic> detailedBookings = {};
      Map<int, Team> teamCache = {};
      Map<int, String> usernamePerBooking = {};

      // Load Bookings for those fields on the selected date
      List<Booking> generalBookings = [];
      Map<int, String> cityNamePerField = {};
      for (final field in fields) {
        final fieldBookings = await DB.Bookings.getByFieldId(field.id);
        generalBookings.addAll(fieldBookings);
        if (!cityNamePerField.containsKey(field.cityId)) {
          cityNamePerField[field.cityId] = await DB.Cities.getById(
            field.cityId,
          ).then((city) => city?.name ?? 'Unknown');
        }
        // Separate bookings by type
        for (var booking in fieldBookings) {
          if (booking.type == BookingType.lobby) {
            final lobbyBooking = await DB.LobbyBookings.getById(booking.id);
            if (lobbyBooking != null) {
              detailedBookings[booking.id] = lobbyBooking;
              final Player? player = await DB.Players.getByPlayerId(
                lobbyBooking.ownerId,
              );
              if (player != null) {
                usernamePerBooking[booking.id] =
                    "${player.username} (${player.name} ${player.surname})";
              }
            }
          } else if (booking.type == BookingType.match) {
            final matchBooking = await DB.MatchBookings.getById(booking.id);
            if (matchBooking != null) {
              detailedBookings[booking.id] = matchBooking;
              final FootballMatch? match = await DB.FootballMatches.getById(
                matchBooking.matchId,
              );
              if (match != null) {
                matchPerBooking[booking.id] = match;
                // Cache teams
                if (match.homeTeamId != null &&
                    !teamCache.containsKey(match.homeTeamId)) {
                  final team = await DB.Teams.getById(match.homeTeamId!);
                  if (team != null) {
                    teamCache[match.homeTeamId!] = team;
                  }
                }
                if (match.awayTeamId != null &&
                    !teamCache.containsKey(match.awayTeamId)) {
                  final team = await DB.Teams.getById(match.awayTeamId!);
                  if (team != null) {
                    teamCache[match.awayTeamId!] = team;
                  }
                }

                final Tournament? tournament = (await DB.Tournaments.getById(
                  match.tournamentId,
                ));
                // Cache coordinator username
                if (!usernamePerBooking.containsKey(booking.id) &&
                    tournament != null) {
                  final coordinator = await DB.Coordinators.getByCoordinatorId(
                    tournament.coordinatorId,
                  );
                  if (coordinator != null) {
                    usernamePerBooking[booking.id] =
                        "${coordinator.username} (${coordinator.name} ${coordinator.surname})";
                  }
                }
              }
            }
          } else if (booking.type == BookingType.private) {
            final privateBooking = await DB.PrivateBookings.getById(booking.id);
            if (privateBooking != null) {
              detailedBookings[booking.id] = privateBooking;
              final Player? player = await DB.Players.getByPlayerId(
                privateBooking.playerId,
              );
              if (player != null) {
                usernamePerBooking[booking.id] =
                    "${player.username} (${player.name} ${player.surname})";
              }
            }
          }
        }
      }

      return {
        ApiJsonKeys.fields: fields,
        ApiJsonKeys.generalBookings: generalBookings,
        ApiJsonKeys.cityNamePerField: cityNamePerField,
        ApiJsonKeys.detailedBookings: detailedBookings,
        ApiJsonKeys.matchPerBooking: matchPerBooking,
        ApiJsonKeys.teamsCache: teamCache,
        ApiJsonKeys.usernamePerBooking: usernamePerBooking,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getTeamsScreen(
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
      return {
        ApiJsonKeys.teamsCache: teamCache,
        ApiJsonKeys.captainNamePerTeam: captainNamePerTeam,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getAbstractTeamScreen(int teamId) async {
    if (AppConfig.isDebug) {
      Team? team = await DB.Teams.getById(teamId);
      if (team == null) {
        throw Exception("Team not found");
      }

      List<Palmares> palmares = [];
      List<Tournament> tournaments = [];
      Map<int, Coordinator> coordinatorCache = {};
      Map<int, Field> fieldCache = {};
      Map<int, TeamStats> playerStatsCache = {};
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
            if (!fieldCache.containsKey(tournament.fieldId)) {
              final field = await DB.Fields.getById(tournament.fieldId);
              fieldCache[tournament.fieldId] = field;
              final city = await DB.Cities.getById(field.cityId);
              if (city != null) {
                cityNamePerField[field.id] = city.name;
              }
            }
          }
        }
      }

      final playerData = await getPlayersInTeam(team.id);

      List<TeamStats> playerStats = await DB.TeamStats.getByTeamId(team.id);
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

      return {
        ApiJsonKeys.team: team,
        ApiJsonKeys.players: playerData[ApiJsonKeys.players],
        ApiJsonKeys.palmares: palmares,
        ApiJsonKeys.tournaments: tournaments,
        ApiJsonKeys.coordinatorCache: coordinatorCache,
        ApiJsonKeys.fieldCache: fieldCache,
        ApiJsonKeys.playerStatsCache: playerStatsCache,
        ApiJsonKeys.cityNamePerField: cityNamePerField,
        ApiJsonKeys.historicalPlayers:
            playerData[ApiJsonKeys.historicalPlayers] ?? [],
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getPlayersInTeam(int teamId) async {
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
      List<TeamStats> allStats = await DB.TeamStats.getByTeamId(team.id);
      for (var stats in allStats) {
        if ((team.vip || team.players == 0) &&
            !historicalPlayers.any((p) => p.id == stats.playerId)) {
          final player = await DB.Players.getByPlayerId(stats.playerId);
          if (player != null) {
            historicalPlayers.add(player);
          }
        }
      }

      return {
        ApiJsonKeys.players: players,
        ApiJsonKeys.historicalPlayers: historicalPlayers,
      };
    } else {
      throw UnimplementedError();
    }
  }

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
      Field field;

      final LobbyBooking? lobbyBooking = await DB.LobbyBookings.getById(
        lobbyBookingId,
      );
      if (lobbyBooking == null) {
        throw Exception("LobbyBooking not found");
      }

      field = await DB.Fields.getById(lobbyBooking.fieldId);

      final city = await DB.Cities.getById(field.cityId);
      String cityName = city != null ? city.name : 'Unknown';
      completeAddress = "${field.address}, $cityName";

      final Player? owner = await DB.Players.getByPlayerId(
        lobbyBooking.ownerId,
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
        ApiJsonKeys.bookings: lobbyBooking,
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

  static Future<Map<String, dynamic>> getJoinLobbyScreen(
    int playerId,
    int? totalPlayers,
    int? selectedCity,
    DateTime? startTime,
    DateTime? endTime,
  ) async {
    if (AppConfig.isDebug) {
      Map<int, String> usernamePerBooking = {};
      Map<int, int> maxPlayersPerLobby = {};
      Map<int, int> currentPlayersPerLobby = {};
      Map<int, int> playersPaidPerBooking = {};
      List<City> availableCities = await DB.Cities.getAll();

      List<LobbyBooking> lobbies =
          await DB.LobbyBookings.getBookedLobbyBookings(
            totalPlayers,
            selectedCity,
            startTime,
            endTime,
            null,
          );

      for (var lobby in lobbies) {
        final data = await getLobbyInfo(lobby.id, playerId);
        usernamePerBooking[lobby.id] = data[ApiJsonKeys.usernamePerBooking];
        maxPlayersPerLobby[lobby.id] = data[ApiJsonKeys.maxPlayersPerLobby];
        currentPlayersPerLobby[lobby.id] =
            data[ApiJsonKeys.currentPlayersPerLobby];
        playersPaidPerBooking[lobby.id] =
            data[ApiJsonKeys.playersPaidPerBooking];
      }

      return {
        ApiJsonKeys.usernamePerBooking: usernamePerBooking,
        ApiJsonKeys.bookings: lobbies,
        ApiJsonKeys.maxPlayersPerLobby: maxPlayersPerLobby,
        ApiJsonKeys.currentPlayersPerLobby: currentPlayersPerLobby,
        ApiJsonKeys.playersPaidPerBooking: playersPaidPerBooking,
        ApiJsonKeys.cities: availableCities,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getAllTournamentsScreen(
    int? userId,
    int? teamId,
    SportCategory currentSport,
  ) async {
    if (AppConfig.isDebug) {
      List<Tournament> tournaments = await DB.Tournaments.getActive(
        sportCategory: currentSport,
      );
      Map<int, Coordinator> coordinatorCache = {};
      Map<int, Field> fieldCache = {};
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
        if (!fieldCache.containsKey(tournament.fieldId)) {
          final field = await DB.Fields.getById(tournament.fieldId);
          fieldCache[tournament.fieldId] = field;
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

      return {
        ApiJsonKeys.tournaments: tournaments,
        ApiJsonKeys.myTournaments: myTournaments,
        ApiJsonKeys.coordinatorCache: coordinatorCache,
        ApiJsonKeys.fieldCache: fieldCache,
        ApiJsonKeys.cities: await DB.Cities.getAll(),
        ApiJsonKeys.cityNamePerField: cityNamePerField,
        ApiJsonKeys.prizeMin: prizeMin,
        ApiJsonKeys.prizeMax: prizeMax,
        ApiJsonKeys.feeMin: feeMin,
        ApiJsonKeys.feeMax: feeMax,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getMyTournaments(
    int userId,
    int? teamId,
    SportCategory currentSport,
  ) async {
    if (AppConfig.isDebug) {
      List<Tournament> participatingTournaments = [];
      List<Tournament> favoriteTournaments = [];

      final User? user = await DB.Users.getByUserId(userId);
      if (user == null) {
        throw Exception("User not found");
      }

      if (user.isPlayer) {
        final int playerId = await DB.Players.getPlayerIdByUserId(userId);
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
            await DB.Coordinators.getCoordinatorIdByUserId(userId);
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

  static Future<Map<String, dynamic>> applyTournamentFilters(
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
      Map<int, Field> fieldCache = {};
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
        if (!fieldCache.containsKey(tournament.fieldId)) {
          final field = await DB.Fields.getById(tournament.fieldId);
          fieldCache[tournament.fieldId] = field;
          if (!cityNamePerField.containsKey(field.cityId)) {
            final city = await DB.Cities.getById(field.cityId);
            if (city != null) {
              cityNamePerField[field.cityId] = city.name;
            }
          }
        }
      }

      return {
        ApiJsonKeys.tournaments: filteredTournaments,
        ApiJsonKeys.cityNamePerField: cityNamePerField,
        ApiJsonKeys.fieldCache: fieldCache,
        ApiJsonKeys.coordinatorCache: coordinatorCache,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getTournamentDetailScreen(
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

      final Field field = await DB.Fields.getById(tournament.fieldId);

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
        final User? user = await DB.Users.getByUserId(userId);
        if (user != null && user.isPlayer) {
          final int playerId = await DB.Players.getPlayerIdByUserId(userId);
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
      return {
        ApiJsonKeys.field: field,
        ApiJsonKeys.cityName: cityName,
        ApiJsonKeys.teamsCache: teamsCache,
        ApiJsonKeys.currentPlayer: currentPlayer,
        ApiJsonKeys.userTeam: userTeam,
        ApiJsonKeys.teamParticipation: teamParticipation,
        ApiJsonKeys.coordinator: coordinator,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getViewCallupsScreen(
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

      return {ApiJsonKeys.players: players};
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getCallupsScreen(
    int tournamentId,
    int teamId,
  ) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament = await DB.Tournaments.getById(tournamentId);
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      final playersData = await getPlayersInTeam(teamId);
      final List<Player> teamPlayers = playersData[ApiJsonKeys.players];

      final Sport? sport = await DB.Sports.getById(tournament.sportId);
      if (sport == null) {
        throw Exception("Sport not found");
      }

      final TournamentParticipation? teamParticipation =
          await DB.TournamentParticipations.getByTournamentAndTeam(
            tournamentId,
            teamId,
          );

      return {
        ApiJsonKeys.players: teamPlayers,
        ApiJsonKeys.sport: sport,
        ApiJsonKeys.teamParticipation: teamParticipation,
        ApiJsonKeys.tournament: tournament,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getFootballTournamentScreen(
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

      Map<int, TeamStats> playerStatsCache = {};

      for (var stats in tournamentStats) {
        if (stats.motm == 0 && stats.goals == 0) {
          continue; // Skip players with no stats
        }
        playerStatsCache[stats.playerId] = TeamStats(
          id: Random().nextInt(1000000),
          playerId: stats.playerId,
          teamId: stats.teamId,
          motm: stats.motm,
          goals: stats.goals,
        );
      }

      return {
        ApiJsonKeys.matches: matches,
        ApiJsonKeys.standings: standings,
        ApiJsonKeys.players: players,
        ApiJsonKeys.teamsCache: teamsCache,
        ApiJsonKeys.playerStatsCache: playerStatsCache,
        ApiJsonKeys.minutesPerRound: minutesPerRound,
        ApiJsonKeys.minutesPerPause: minutesPerPause,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getFootballMatchScreen(
    int matchId,
  ) async {
    if (AppConfig.isDebug) {
      final FootballMatch? match = await DB.FootballMatches.getById(matchId);
      if (match == null) {
        throw Exception("Match not found");
      }

      final Tournament? tournament = await DB.Tournaments.getById(
        match.tournamentId,
      );
      if (tournament == null) {
        throw Exception("Tournament not found");
      }

      final Team? homeTeam = match.homeTeamId != null
          ? await DB.Teams.getById(match.homeTeamId!)
          : null;
      final Team? awayTeam = match.awayTeamId != null
          ? await DB.Teams.getById(match.awayTeamId!)
          : null;

      final int minutesPerRound = await DB.Tournaments.getMinutesPerRoundById(
        match.tournamentId,
      );

      final int minutesPerPause = await DB.Tournaments.getMinutesPerPauseById(
        match.tournamentId,
      );

      final int? sportId = (await DB.Tournaments.getById(
        match.tournamentId,
      ))?.sportId;

      if (sportId == null) {
        throw Exception("Sport not found for tournament");
      }

      List<String> requiredRoles = [];
      if (sportId == 1 || sportId == 2 || sportId == 3) {
        requiredRoles = ['MAIN'];
      } else if (sportId == 4) {
        requiredRoles = ['MAIN', 'ASSISTANT1', 'ASSISTANT2'];
      }

      // Get existing assignments for this match
      final assignments = await DB.RefereeAssignments.getByMatchId(matchId);
      final assignedRoles = assignments.map((a) => a.role).toSet();

      // Find available roles (required roles that are not yet assigned)
      final availableRoles = requiredRoles
          .where((role) => !assignedRoles.contains(role))
          .toList();

      Map<int, List<Player>> playersPerTeam = {};
      if (homeTeam != null) {
        final List<Callup> homeCallup = await DB.CallUps.getByTournamentAndTeam(
          match.tournamentId,
          homeTeam.id,
        );
        for (Callup callup in homeCallup) {
          final player = await DB.Players.getByPlayerId(callup.playerId);
          if (player != null) {
            playersPerTeam.putIfAbsent(homeTeam.id, () => []).add(player);
          }
        }
      }
      if (awayTeam != null) {
        final List<Callup> awayCallup = await DB.CallUps.getByTournamentAndTeam(
          match.tournamentId,
          awayTeam.id,
        );
        for (Callup callup in awayCallup) {
          final player = await DB.Players.getByPlayerId(callup.playerId);
          if (player != null) {
            playersPerTeam.putIfAbsent(awayTeam.id, () => []).add(player);
          }
        }
      }

      final List<RefereeAssignment> refereeAssignments =
          await DB.RefereeAssignments.getByMatchId(matchId);
      Map<String, String> assignmentPerRefereeNameSurname = {};

      for (var assignment in refereeAssignments) {
        final referee = await DB.Referees.getByRefereeId(assignment.refereeId);
        if (referee != null) {
          assignmentPerRefereeNameSurname["${referee.name} ${referee.surname}"] =
              assignment.role;
        }
      }

      final Field field = await DB.Fields.getById(tournament.fieldId);

      final city = await DB.Cities.getById(field.cityId);
      final String cityName = city != null ? city.name : 'Unknown';

      final eventData = await getMatchEvents(matchId);
      final List<FootballMatchEvent> events = eventData[ApiJsonKeys.events];
      final bool canMatchFinish = eventData[ApiJsonKeys.canMatchFinish];

      return {
        ApiJsonKeys.match: match,
        ApiJsonKeys.homeTeam: homeTeam,
        ApiJsonKeys.awayTeam: awayTeam,
        ApiJsonKeys.events: events,
        ApiJsonKeys.minutesPerRound: minutesPerRound,
        ApiJsonKeys.minutesPerPause: minutesPerPause,
        ApiJsonKeys.availableRefereeRoles: availableRoles,
        ApiJsonKeys.playersPerTeam: playersPerTeam,
        ApiJsonKeys.assignmentPerRefereeNameSurname:
            assignmentPerRefereeNameSurname,
        ApiJsonKeys.field: field,
        ApiJsonKeys.cityName: cityName,
        ApiJsonKeys.coordinatorId: tournament.coordinatorId,
        ApiJsonKeys.refereeCheck: availableRoles.isEmpty,
        ApiJsonKeys.canMatchFinish: canMatchFinish,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getMatchEvents(int matchId) async {
    if (AppConfig.isDebug) {
      try {
        final FootballMatch? match = await DB.FootballMatches.getById(matchId);
        if (match == null) {
          throw Exception("Match not found");
        }

        final Tournament? tournament = await DB.Tournaments.getById(
          match.tournamentId,
        );
        if (tournament == null) {
          throw Exception("Tournament not found");
        }

        final Sport? sport = await DB.Sports.getById(tournament.sportId);
        if (sport == null) {
          throw Exception("Sport not found for tournament");
        }

        if (sport.category == SportCategory.football) {
          final List<FootballMatchEvent> events =
              await DB.FootballMatchEvents.getByMatchId(matchId);
          final bool canMatchFinish = await DB.FootballMatches.canMatchFinish(
            matchId,
          );
          return {
            ApiJsonKeys.events: events,
            ApiJsonKeys.canMatchFinish: canMatchFinish,
          };
        } else {
          throw Exception("Sport is not football");
        }
      } catch (e) {
        return {ApiJsonKeys.events: [], ApiJsonKeys.canMatchFinish: false};
      }
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getTeamParticipations(int teamId) async {
    if (AppConfig.isDebug) {
      List<TournamentParticipation> participations =
          await DB.TournamentParticipations.getByTeamId(teamId);
      return {ApiJsonKeys.tournamentParticipations: participations};
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getPayParticipationScreen(
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

      return {
        ApiJsonKeys.tournamentCache: tournamentCache,
        ApiJsonKeys.tournamentParticipations: participations,
        ApiJsonKeys.isCalledUpPerTournament: isCalledUpPerTournament,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getTeamRequestsScreen(int teamId) async {
    if (AppConfig.isDebug) {
      final Team? team = await DB.Teams.getById(teamId);
      if (team == null) {
        throw Exception("Team not found");
      }
      List<TeamRequest> teamRequests = await DB.TeamRequests.getByTeamId(
        teamId,
      );
      Map<int, Player?> playersCache = {};

      for (var request in teamRequests) {
        if (!playersCache.containsKey(request.playerId)) {
          final player = await DB.Players.getByPlayerId(request.playerId);
          playersCache[request.playerId] = player;
        }
      }

      return {
        ApiJsonKeys.teamRequests: teamRequests,
        ApiJsonKeys.playersCache: playersCache,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getWalletScreen(int userId) async {
    if (AppConfig.isDebug) {
      final Wallet? wallet = await DB.Wallets.getByUserId(userId);
      //TODO: List<WalletTransaction> transactions = await DB.WalletTransactions.getByUserId(userId);
      return {
        ApiJsonKeys.wallet: wallet,
        //ApiJsonKeys.walletTransactions: transactions,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getAvailableMatchesScreen(
    SportCategory sportCategory, {
    required int cityId,
    int? sportId,
  }) async {
    if (AppConfig.isDebug) {
      List<Tournament> tournaments = await DB.Tournaments.getBySportCategory(
        sportCategory,
      );

      List<FootballMatch> availableMatches = [];
      Map<int, Team> teamsCache = {};
      Map<int, int> minutesPausePerTournament = {};
      Map<int, int> minutesRoundPerTournament = {};

      if (sportId != null) {
        tournaments = tournaments
            .where((t) => t.sportId == sportId && t.cityId == cityId)
            .toList();
      } else {
        tournaments = tournaments.where((t) => t.cityId == cityId).toList();
      }

      for (var tournament in tournaments) {
        final matches = await DB
            .FootballMatches.getScheduledMatchesByTournament(tournament.id);

        for (var match in matches) {
          availableMatches.add(match);

          // Load teams for this match
          if (match.homeTeamId != null &&
              !teamsCache.containsKey(match.homeTeamId)) {
            final team = await DB.Teams.getById(match.homeTeamId!);
            if (team != null) teamsCache[match.homeTeamId!] = team;
          }
          if (match.awayTeamId != null &&
              !teamsCache.containsKey(match.awayTeamId)) {
            final team = await DB.Teams.getById(match.awayTeamId!);
            if (team != null) teamsCache[match.awayTeamId!] = team;
          }

          // Load minutes per round and pause
          if (!minutesRoundPerTournament.containsKey(match.tournamentId)) {
            minutesRoundPerTournament[match.tournamentId] =
                await DB.Tournaments.getMinutesPerRoundById(match.tournamentId);
          }
          if (!minutesPausePerTournament.containsKey(match.tournamentId)) {
            minutesPausePerTournament[match.tournamentId] =
                await DB.Tournaments.getMinutesPerPauseById(match.tournamentId);
          }
        }
      }
      return {
        ApiJsonKeys.matches: availableMatches,
        ApiJsonKeys.teamsCache: teamsCache,
        ApiJsonKeys.minutesRoundPerTournament: minutesRoundPerTournament,
        ApiJsonKeys.minutesPausePerTournament: minutesPausePerTournament,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getPastRefereeAssignedMatchesScreen(
    int refereeId,
  ) async {
    if (AppConfig.isDebug) {
      List<RefereeAssignment> assignments =
          await DB.RefereeAssignments.getByRefereeId(refereeId);
      List<FootballMatch> matches = [];
      Map<int, Tournament> tournamentCache = {};
      Map<int, Team> teamsCache = {};
      Map<int, int> minutesPausePerTournament = {};
      Map<int, int> minutesRoundPerTournament = {};

      for (var assignment in assignments) {
        final match = await DB.FootballMatches.getById(assignment.matchId);
        if (match != null) {
          matches.add(match);

          if (!tournamentCache.containsKey(match.tournamentId)) {
            final tournament = await DB.Tournaments.getById(match.tournamentId);
            if (tournament != null) {
              tournamentCache[match.tournamentId] = tournament;
            }
          }

          if (match.homeTeamId != null &&
              !teamsCache.containsKey(match.homeTeamId)) {
            final team = await DB.Teams.getById(match.homeTeamId!);
            if (team != null) teamsCache[match.homeTeamId!] = team;
          }
          if (match.awayTeamId != null &&
              !teamsCache.containsKey(match.awayTeamId)) {
            final team = await DB.Teams.getById(match.awayTeamId!);
            if (team != null) teamsCache[match.awayTeamId!] = team;
          }
          if (!minutesRoundPerTournament.containsKey(match.tournamentId)) {
            minutesRoundPerTournament[match.tournamentId] =
                await DB.Tournaments.getMinutesPerRoundById(match.tournamentId);
          }
          if (!minutesPausePerTournament.containsKey(match.tournamentId)) {
            minutesPausePerTournament[match.tournamentId] =
                await DB.Tournaments.getMinutesPerPauseById(match.tournamentId);
          }
        }
      }

      return {
        ApiJsonKeys.matches: matches,
        ApiJsonKeys.teamsCache: teamsCache,
        ApiJsonKeys.minutesRoundPerTournament: minutesRoundPerTournament,
        ApiJsonKeys.minutesPausePerTournament: minutesPausePerTournament,
      };
    } else {
      throw UnimplementedError();
    }
  }

  static Future<Map<String, dynamic>> getTeamDetailScreen(
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
        return {
          ApiJsonKeys.existingRequest: existingRequest,
          ApiJsonKeys.isPlayerInTeam: false,
        };
      }else{
        return{
          ApiJsonKeys.isPlayerInTeam: true,
        };
      }
    } else {
      throw UnimplementedError();
    }
  }

}
