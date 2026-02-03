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
}
