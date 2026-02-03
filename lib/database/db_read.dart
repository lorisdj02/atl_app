import 'package:atl_app/models/booking.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/palmares.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/private_bookings.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/models/team_stats.dart';
import 'package:atl_app/models/tournament.dart';
import 'db_controller.dart';
import '../config/app_config.dart';
import '../../models/sport_category.dart';
import '../../models/plays_at.dart';
import '../config/api_json_keys.dart';

class DBRead {
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
        final lobbyBooking = await DB.LobbyBookings.getById(lobbyBookingId);
        if (lobbyBooking != null) {
          lobbyBookings.add(lobbyBooking);
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
          captainNamePerTeam[team.id] = "${captain.username}";
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
}
