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
