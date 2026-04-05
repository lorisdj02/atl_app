import 'dart:math';
import 'dart:convert';
import 'package:atl_app/database/repositories/reviews_response.dart';
import 'package:atl_app/database/responses/abstract_team_response.dart';
import 'package:atl_app/database/responses/all_tournaments_response.dart';
import 'package:atl_app/database/responses/apply_tournament_filters_response.dart';
import 'package:atl_app/database/responses/available_matches_response.dart';
import 'package:atl_app/database/responses/callups_response.dart';
import 'package:atl_app/database/responses/checkout_response.dart';
import 'package:atl_app/database/responses/coordinator_home_response.dart';
import 'package:atl_app/database/responses/fields_and_max_players_per_field_response.dart';
import 'package:atl_app/database/responses/football_match_bracket_response.dart';
import 'package:atl_app/database/responses/football_match_events_response.dart';
import 'package:atl_app/database/responses/football_match_response.dart';
import 'package:atl_app/database/responses/football_tournament_response.dart';
import 'package:atl_app/database/responses/invite_friends_response.dart';
import 'package:atl_app/database/responses/join_lobby_response.dart';
import 'package:atl_app/database/responses/login_response.dart';
import 'package:atl_app/database/responses/my_growth_response.dart';
import 'package:atl_app/database/responses/organization_home_response.dart';
import 'package:atl_app/database/responses/past_assigned_matches_response.dart';
import 'package:atl_app/database/responses/pay_participation_response.dart';
import 'package:atl_app/database/responses/personal_player_stats_response.dart';
import 'package:atl_app/database/responses/player_home_response.dart';
import 'package:atl_app/database/responses/player_requests_response.dart';
import 'package:atl_app/database/responses/players_in_team_response.dart';
import 'package:atl_app/database/responses/referee_home_response.dart';
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
import 'package:atl_app/models/field_category.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/football_match_event.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/football_tournament_stats.dart';
import 'package:atl_app/models/growth_step.dart';
import 'package:atl_app/models/lobby_booking.dart';
import 'package:atl_app/models/lobby_booking_participation.dart';
import 'package:atl_app/models/match_booking.dart';
import 'package:atl_app/models/palmares.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/referee.dart';
import 'package:atl_app/models/referee_assignment.dart';
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
import 'responses/book_field_response.dart';

class DBRead {
  // DONE
  static Future<PlayerHomeResponse> getPlayerHomeScreen({
    required int playerId,
    required SportCategory currentSport,
  }) async {
    if (AppConfig.isDebug) {
      Map<int, Team> teamsCache = {};
      List<Tournament> activeTournaments = [];
      Map<int, int> minutesRoundPerTournament = {};
      Map<int, int> minutesPausePerTournament = {};
      Map<int, List<FootballMatch>> matchesPerTournament = {};
      Map<int, List<FootballStanding>> standingsPerTournament = {};
      Map<int, Field> fieldsCache = {};
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
          await DB.PrivateBookings.getActiveByPlayerId(playerId);
      final List<int> lobbyBookingsIds =
          (await DB.LobbyBookingParticipations.getActiveByPlayerId(
            playerId,
          )).map((p) => p.lobbyBookingId).toList();
      List<LobbyBooking> lobbyBookings = [];
      for (var lobbyBookingId in lobbyBookingsIds) {
        final LobbyBooking? lobbyBooking = await DB.LobbyBookings.getById(
          lobbyBookingId,
        );
        if (lobbyBooking != null &&
            lobbyBooking.status != BookingStatus.refund &&
            lobbyBooking.status != BookingStatus.finished) {
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

      for (var booking in privateBookings) {
        final Field? field = await DB.Fields.getById(booking.fieldId);
        if (field == null) {
          throw Exception("Field not found for booking.");
        }
        if (!fieldsCache.containsKey(field.id)) {
          fieldsCache[field.id] = field;
        }
        if (!completeAddressPerField.containsKey(field.id)) {
          final city = await DB.Cities.getById(field.cityId);
          String cityName = city != null ? city.name : 'Unknown';
          completeAddressPerField[field.id] = "${field.address}, $cityName";
        }
      }

      for (var booking in lobbyBookings) {
        final Field? field = await DB.Fields.getById(booking.fieldId);
        if (field == null) {
          throw Exception("Field not found for booking.");
        }
        if (!fieldsCache.containsKey(field.id)) {
          fieldsCache[field.id] = field;
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

      return PlayerHomeResponse(
        privateBookings: privateBookings,
        lobbies: lobbyBookings,
        activeTournaments: activeTournaments,
        minutesRoundPerTournament: minutesRoundPerTournament,
        minutesPausePerTournament: minutesPausePerTournament,
        footballMatchesPerTournament: matchesPerTournament,
        footballStandingsPerTournament: standingsPerTournament,
        teamsCache: teamsCache,
        accountTeam: userTeam,
        usernamePerBooking: usernamePerBooking,
        fieldsCache: fieldsCache,
        maxPlayersPerLobby: maxPlayersPerLobby,
        currentPlayersPerLobby: currentPlayersPerLobby,
        completeAddressPerField: completeAddressPerField,
        playersPaidPerBooking: playersPaidPerBooking,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<CoordinatorHomeResponse> getCoordinatorHomeScreen({
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

      return CoordinatorHomeResponse(
        activeTournaments: activeTournaments,
        footballMatchesPerTournament: matchesByTournament,
        teamsCache: teamsCache,
        minutesRoundPerTournament: minutesRoundPerTournament,
        minutesPausePerTournament: minutesPausePerTournament,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<RefereeHomeResponse> getRefereeHomeScreen({
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

      return RefereeHomeResponse(
        assignedFootballMatches: assignedMatches,
        teamsCache: teamsCache,
        minutesRoundPerTournament: minutesRoundPerTournament,
        minutesPausePerTournament: minutesPausePerTournament,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<OrganizationHomeResponse> getOrganizationHomeScreen({
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
                lobbyBooking.ownerPlayerId,
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

      return OrganizationHomeResponse(
        fields: fields,
        generalBookings: generalBookings,
        cityNamePerField: cityNamePerField,
        lobbyBookingsCache: Map<int, LobbyBooking>.fromEntries(
          detailedBookings.entries
              .where((e) => e.value is LobbyBooking)
              .map((e) => MapEntry(e.key, e.value as LobbyBooking)),
        ),
        privateBookingsCache: Map<int, PrivateBooking>.fromEntries(
          detailedBookings.entries
              .where((e) => e.value is PrivateBooking)
              .map((e) => MapEntry(e.key, e.value as PrivateBooking)),
        ),
        matchBookingsCache: Map<int, MatchBooking>.fromEntries(
          detailedBookings.entries
              .where((e) => e.value is MatchBooking)
              .map((e) => MapEntry(e.key, e.value as MatchBooking)),
        ),
        footballMatchPerBooking: matchPerBooking,
        teamsCache: teamCache,
        usernamePerBooking: usernamePerBooking,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<BookFieldResponse> getBookFieldScreen() async {
    if (AppConfig.isDebug) {
      Map<int, TimeOfDay> minOpeningTimePerCity = {};
      Map<int, TimeOfDay> maxClosingTimePerCity = {};
      List<City> cities = await DB.Cities.getAll();

      for (var city in cities) {
        minOpeningTimePerCity[city.id] = TimeOfDay(hour: 23, minute: 59);
        maxClosingTimePerCity[city.id] = TimeOfDay(hour: 0, minute: 0);
      }

      for (var city in cities) {
        final cityFields = await DB.Fields.getByCity(city.id);
        for (var field in cityFields) {
          final openingMins =
              field.openingTime.hour * 60 + field.openingTime.minute;
          final minMins =
              minOpeningTimePerCity[field.cityId]!.hour * 60 +
              minOpeningTimePerCity[field.cityId]!.minute;
          if (openingMins < minMins) {
            minOpeningTimePerCity[city.id] = field.openingTime;
          }
          final closingMins =
              field.closingTime.hour * 60 + field.closingTime.minute;
          final maxMins =
              maxClosingTimePerCity[field.cityId]!.hour * 60 +
              maxClosingTimePerCity[field.cityId]!.minute;
          if (closingMins > maxMins) {
            maxClosingTimePerCity[city.id] = field.closingTime;
          }
        }
      }
      return BookFieldResponse(
        cities: cities,
        minOpeningTimePerCity: minOpeningTimePerCity,
        maxClosingTimePerCity: maxClosingTimePerCity,
      );
    } else {
      throw UnimplementedError();
    }
  }

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
  static Future<int?> getUserLevel(int userId) async {
    if (AppConfig.isDebug) {
      final Account? user = await DB.Accounts.getByAccountId(userId);
      if (user == null) {
        throw Exception("Account not found");
      }
      if (user.role == AccountRole.coordinator) {
        final Coordinator? coordinator = await DB.Coordinators.getByAccountId(
          userId,
        );
        if (coordinator == null) {
          throw Exception("Coordinator not found for user");
        }
        return coordinator.level;
      } else if (user.role == AccountRole.referee) {
        final Referee? referee = await DB.Referees.getByAccountId(userId);
        if (referee == null) {
          throw Exception("Referee not found for user");
        }
        return referee.level;
      } else {
        return null;
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
  static Future<JoinLobbyResponse> getJoinLobbyScreen(
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
      Map<int, Field> fieldsCache = {};
      Map<int, String> completeAddressPerField = {};
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
        fieldsCache[lobby.fieldId] = data[ApiJsonKeys.fields] as Field;
        completeAddressPerField[lobby.fieldId] =
            data[ApiJsonKeys.completeAddressPerField] as String;
      }

      return JoinLobbyResponse(
        usernamePerBooking: usernamePerBooking,
        maxPlayersPerLobby: maxPlayersPerLobby,
        currentPlayersPerLobby: currentPlayersPerLobby,
        playersPaidPerBooking: playersPaidPerBooking,
        fieldsCache: fieldsCache,
        completeAddressPerField: completeAddressPerField,
        cities: availableCities,
        lobbies: lobbies,
      );
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
  static Future<AvailableMatchesResponse> getAvailableMatchesScreen(
    SportCategory sportCategory,
    int refereeId, {
    required int cityId,
    int? sportId,
  }) async {
    if (AppConfig.isDebug) {
      if (sportCategory != SportCategory.football) {
        throw Exception(
          "Sport category not supported for available matches screen",
        );
      }
      List<Tournament> tournaments = await DB.Tournaments.getBySportCategory(
        sportCategory,
      );

      List<Sport> sports = await DB.Sports.getByCategory(sportCategory);

      List<FootballMatch> availableMatches = [];
      Map<int, Team> teamsCache = {};
      Map<int, int> minutesPausePerTournament = {};
      Map<int, int> minutesRoundPerTournament = {};
      Map<int, List<FootballMatch>> matchesPerSport = {};

      matchesPerSport = {for (var sport in sports) sport.id: []};
      final Map<int, String> sportNames = {
        for (var sport in sports) sport.id: sport.name,
      };

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
          matchesPerSport[tournament.sportId]!.add(match);
        }
      }

      return AvailableMatchesResponse(
        footballMatches: availableMatches,
        teamsCache: teamsCache,
        minutesRoundPerTournament: minutesRoundPerTournament,
        minutesPausePerTournament: minutesPausePerTournament,
        footballMatchesPerSport: matchesPerSport,
        sportNames: sportNames,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<PastAssignedMatchesResponse> getPastAssignedMatchesScreen(
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

      return PastAssignedMatchesResponse(
        footballMatches: matches,
        teamsCache: teamsCache,
        minutesRoundPerTournament: minutesRoundPerTournament,
        minutesPausePerTournament: minutesPausePerTournament,
      );
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
        maxPlayers: maxPlayers,
        playersToPay: playersToPay,
      );
    } else {
      throw UnimplementedError();
    }
  }

  // DONE, ho aggiunto anche il BRACKET per la fase finale (risultato aggregato)
  static Future<FootballMatchResponse> getFootballMatchScreen(
    int matchId, {
    int? refereeId,
  }) async {
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

      final Field? field = await DB.Fields.getById(tournament.fieldId);
      if (field == null) {
        throw Exception("Field not found for tournament");
      }

      final city = await DB.Cities.getById(field.cityId);
      final String cityName = city != null ? city.name : 'Unknown';

      final FootballMatchEventsResponse eventData =
          await getFootballMatchEvents(matchId);
      final List<FootballMatchEvent> events = eventData.events;
      final bool canMatchFinish = eventData.canMatchFinish;

      final bool refereeCheck = availableRoles
          .isEmpty; // Se non ci sono ruoli disponibili, significa che tutti i ruoli richiesti sono stati assegnati, quindi il check è passato

      bool hasRefereeLicense = false;
      if (availableRoles.isNotEmpty && refereeId != null) {
        if (await DB.RefereeLicenses.isRefereeLicensed(refereeId, sportId)) {
          hasRefereeLicense = true;
        }
      }
      Map<String, double> payPerRole = {};
      if (refereeId != null) {
        final Referee? referee = await DB.Referees.getByRefereeId(refereeId);
        if (referee == null) {
          throw Exception("Referee not found");
        }

        for (String role in requiredRoles) {
          final double pay = await DB.RefereeRoles.getPayPerMatch(
            sportId,
            role,
            referee.level,
          );
          payPerRole[role] = pay;
        }
      }

      return FootballMatchResponse(
        match: match,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        events: events,
        minutesPerRound: minutesPerRound,
        minutesPerPause: minutesPerPause,
        availableRefereeRoles: availableRoles,
        playersPerTeam: playersPerTeam,
        assignmentPerRefereeNameSurname: assignmentPerRefereeNameSurname,
        field: field,
        cityName: cityName,
        coordinatorId: tournament.coordinatorId,
        refereeCheck: refereeCheck,
        canMatchFinish: canMatchFinish,
        hasRefereeLicense: hasRefereeLicense,
        payPerRole: payPerRole,
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
  static Future<LoginResponse> handleLogin(
    String usernameOrEmail,
    String password,
  ) async {
    if (AppConfig.isDebug) {
      final Account? user = await DB.Accounts.getByEmailOrUsername(
        usernameOrEmail,
        password,
      );
      if (user == null) {
        return LoginResponse(account: null, roleId: null, teamId: null);
      }

      final AccountRole userRole = user.role;

      switch (userRole) {
        case AccountRole.player:
          final int playerId = await DB.Players.getPlayerIdByAccountId(user.id);
          if (playerId < 1) {
            throw Exception("Player not found for user");
          }

          final PlaysAt? playsAt = await DB.PlaysAt.getByPlayerIdAndCategory(
            playerId,
            SportCategory.football,
          );
          Team? userTeam;

          return LoginResponse(
            account: user,
            roleId: playerId,
            teamId: playsAt != null ? playsAt.teamId : null,
          );
        case AccountRole.coordinator:
          final int coordinatorId =
              await DB.Coordinators.getCoordinatorIdByAccountId(user.id);
          if (coordinatorId < 1) {
            throw Exception("Coordinator not found for user");
          }
          return LoginResponse(
            account: user,
            roleId: coordinatorId,
            teamId: null,
          );
        case AccountRole.referee:
          final int refereeId = await DB.Referees.getRefereeIdByAccountId(
            user.id,
          );
          if (refereeId < 1) {
            throw Exception("Referee not found for user");
          }
          return LoginResponse(
            account: user,
            roleId: refereeId,
            teamId: null,
          );
        case AccountRole.organization:
          final int organizationId =
              await DB.Organizations.getOrganizationIdByAccountId(user.id);
          if (organizationId < 1) {
            throw Exception("Organization not found for user");
          }
          return LoginResponse(
            account: user,
            roleId: organizationId,
            teamId: null,
          );
        default:
          throw Exception("Unknown user role");
      }
    } else {
      throw UnimplementedError();
    }
  }

  // DONE
  static Future<List<City>> getCities() async {
    if (AppConfig.isDebug) {
      List<City> cities = await DB.Cities.getAll();
      return cities;
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

  // DONE
  static Future<FieldsAndMaxPlayersPerFieldResponse>
  getFieldsByPlayersAndCityAndSportCategory({
    required int maxPlayers,
    required int cityId,
    required SportCategory sportCategory,
  }) async {
    if (AppConfig.isDebug) {
      final List<Field> fields =
          await DB.Fields.getByMaxPlayersAndCityAndSportCategory(
            maxPlayers,
            cityId,
            sportCategory,
          );

      Map<int, int> maxPlayerPerField = {};

      for (var field in fields) {
        final FieldCategory? fieldCategory =
            await DB.FieldCategories.getByFieldIdAndSportCategory(
              field.id,
              sportCategory,
            );
        if (fieldCategory != null) {
          maxPlayerPerField[field.id] = fieldCategory.maxPlayers;
        } else {
          maxPlayerPerField[field.id] = 0; // Default se non trovato
        }
      }
      return FieldsAndMaxPlayersPerFieldResponse(
        fields: fields,
        maxPlayersPerField: maxPlayerPerField,
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

  // DONE
  static Future<FootballMatchEventsResponse> getFootballMatchEvents(
    int matchId,
  ) async {
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

          return FootballMatchEventsResponse(
            events: events,
            canMatchFinish: canMatchFinish,
          );
        } else {
          throw Exception("Sport is not football");
        }
      } catch (e) {
        return FootballMatchEventsResponse(events: [], canMatchFinish: false);
      }
    } else {
      throw UnimplementedError();
    }
  }

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

  static Future<FieldsAndMaxPlayersPerFieldResponse>
  getFreeFieldsByPlayerAndCityAndDate({
    required int maxPlayers,
    required int cityId,
    required DateTime startDateTime,
    required DateTime endDateTime,
    required SportCategory sportCategory,
  }) async {
    if (AppConfig.isDebug) {
      final allFields = await DB.Fields.getByMaxPlayersAndCityAndSportCategory(
        maxPlayers,
        cityId,
        sportCategory,
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

      Map<int, int> maxPlayerPerField = {};
      for (var field in fields) {
        final FieldCategory? fieldCategory =
            await DB.FieldCategories.getByFieldIdAndSportCategory(
              field.id,
              sportCategory,
            );
        if (fieldCategory != null) {
          maxPlayerPerField[field.id] = fieldCategory.maxPlayers;
        } else {
          maxPlayerPerField[field.id] = 0; // Default se non trovato
        }
      }
      return FieldsAndMaxPlayersPerFieldResponse(
        fields: fields,
        maxPlayersPerField: maxPlayerPerField,
      );
    } else {
      throw UnimplementedError();
    }
  }

  static Future<bool> hasNotification(int userId) async {
    if (AppConfig.isDebug) {
      final List<Review> reviews =
          await DB.Reviews.getPendingReviewsForReviewerAccountId(userId);
      return reviews.isNotEmpty;
    } else {
      throw UnimplementedError();
    }
  }

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

  static Future<List<Sport>> getSportsByCategory(SportCategory category) async {
    if (AppConfig.isDebug) {
      final List<Sport> sports = await DB.Sports.getByCategory(category);
      return sports;
    } else {
      throw UnimplementedError();
    }
  }

  static Future<TournamentSummaryResponse> getTournamentSummary(
    int tournamentId,
  ) async {
    if (AppConfig.isDebug) {
      final Tournament? tournament =
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
