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
  }

  Future<bool> confirmCallUps(
    int tournamentId,
    int teamId,
    Set<int> selectedPlayerIds,
    double tournamentFee,
  ) async {
    await CallUps.deleteCallUps(tournamentId, teamId);

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
  }

  Future<bool> acceptRequestToTeam(int playerId, int teamId) async {
    
    if((await Players.joinTeam(playerId, teamId)) == false){
      return false;
    }
    if((await TeamRequests.deleteByPlayerId(playerId)) == false){
      return false;
    }
    return true;
  }

  Future<bool> createLobby(int id, int fieldId, int ownerId, int maxPlayers, int playerToFind, double feePerPlayer, DateTime startDateTime, DateTime endDateTime) async {
 
    if((await LobbyBookings.addLobbyBooking(
      id,
      ownerId,
      fieldId,
      startDateTime,
      endDateTime,
      maxPlayers,
      playerToFind,
      feePerPlayer
    )) == false){
      return false;
    }

    if((await LobbyBookingParticipations.addParticipation(
      id,
      ownerId,
      maxPlayers - playerToFind
    )) == false){
      return false;
    }

    return true;
  }

  Future<bool> joinLobby(int lobbyBookingId, int playerId, int playersPaid) async {
    if((await LobbyBookingParticipations.addParticipation(
        lobbyBookingId,
        playerId,
        playersPaid,
      )) == false){
      return false;
    }

    if((await LobbyBookings.decreasePlayersToFind(lobbyBookingId, playersPaid)) == false){
      await LobbyBookingParticipations.removeParticipation(
        playerId,
        lobbyBookingId,
      );
      return false;
    }
    return true;
  }
}