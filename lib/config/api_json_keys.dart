class ApiJsonKeys {
  // All screens
  static const String error = 'error'; // String

  // PlayerHomeScreen,
  static const String bookings = 'bookings'; // List<dynamic>
  // PlayerHomeScreen, CoordinatorHomeScreen
  static const String activeTournaments =
      'activeTournaments'; // List<Tournament>
  // PlayerHomeScreen, CoordinatorHomeScreen, RefereeHomeScreen
  static const String minutesRoundPerTournament =
      'minutesRoundPerTournament'; // Map<int, int>
  // PlayerHomeScreen, CoordinatorHomeScreen, RefereeHomeScreen
  static const String minutesPausePerTournament =
      'minutesPausePerTournament'; // Map<int, int>
  // PlayerHomeScreen, CoordinatorHomeScreen
  static const String matchesPerTournament =
      'matchesPerTournament'; // Map<int, List<FootballMatch>>
  // PlayerHomeScreen,
  static const String standingsPerTournament =
      'standingsPerTournament'; // Map<int, List<FootballStanding>>
  // PlayerHomeScreen, CoordinatorHomeScreen, RefereeHomeScreen, OrganizationHomeScreen, TeamScreen
  static const String teamsCache = 'teamsCache'; // Map<int, Team>
  // PlayerHomeScreen,
  static const String userTeam = 'userTeam'; // Team?
  // PlayerHomeScreen,
  static const String maxPlayersPerLobby =
      'maxPlayersPerLobby'; // Map<int, int>
  // PlayerHomeScreen,
  static const String currentPlayersPerLobby =
      'currentPlayersPerLobby'; // Map<int, int>
  // PlayerHomeScreen,
  static const String completeAddressPerField =
      'completeAddressPerField'; // Map<int, String>
  // PlayerHomeScreen,
  static const String playersPaidPerBooking =
      'playersPaidPerBooking'; // Map<int, int>

  // RefereeHomeScreen
  static const String assignments = 'assignments'; // List<RefereeAssignment>
  // RefereeHomeScreen
  static const String assignedMatches =
      'assignedMatches'; // List<FootballMatch>

  // OrganizationHomeScreen
  static const String generalBookings = 'generalBookings'; // List<Booking>
  // OrganizationHomeScreen
  static const String cityNamePerField = 'cityNamePerField'; // Map<int, String>
  // OrganizationHomeScreen
  static const String detailedBookings =
      'detailedBookings'; // Map<int, dynamic>
  // OrganizationHomeScreen
  static const String matchPerBooking =
      'matchPerBooking'; // Map<int, FootballMatch>
  // OrganizationHomeScreen, PlayerHomeScreen
  static const String usernamePerBooking =
      'usernamePerBooking'; // Map<int, String>
  // OrganizationHomeScreen, CreateTournamentScreen, BookFieldScreen
  static const String fields = 'fields'; // List<Field>

  // TeamsScreen
  static const String captainNamePerTeam =
      'captainNamePerTeam'; // Map<int, String>

  // AbstractTeamScreen
  static const String team = 'team'; // Team
  // AbstractTeamScreen, FootballTournamentScreen
  static const String players = 'players'; // List<Player>
  // AbstractTeamScreen
  static const String palmares = 'palmares'; // List<Palmares>
  // AbstractTeamScreen, AllTournamentsScreen
  static const String tournaments = 'tournaments'; // List<Tournament>
  // AbstractTeamScreen
  static const String coordinatorCache =
      'coordinatorCache'; // Map<int, Coordinator>
  // AbstractTeamScreen
  static const String fieldCache = 'fieldCache'; // Map<int, Field>
  // AbstractTeamScreen, FootballTournamentScreen
  static const String playerStatsCache =
      'playerStatsCache'; // Map<int, TeamStats>
  // AbstractTeamScreen
  static const String historicalPlayers = 'historicalPlayers'; // List<Player>

  // JoinLobbyScreen, AllTournamentsScreen, CreateTournamentScreen
  static const String cities = 'cities'; // List<City>

  // AllTournamentsScreen
  static const String myTournaments = 'myTournaments'; // List<Tournament>
  // AllTournamentsScreen
  static const String coordinatorPertournament =
      'coordinatorPertournament'; // Map<int, Coordinator>
  // AllTournamentsScreen
  static const String participatingTournaments =
      'participatingTournaments'; // List<Tournament>
  // AllTournamentsScreen
  static const String favoriteTournaments =
      'favoriteTournaments'; // List<Tournament>
  // AllTournamentsScreen
  static const String prizeMin = 'prizeMin'; // double
  // AllTournamentsScreen
  static const String prizeMax = 'prizeMax'; // double
  // AllTournamentsScreen
  static const String feeMin = 'feeMin'; // double
  // AllTournamentsScreen
  static const String feeMax = 'feeMax'; // double

  // TournamentDetailScreen
  static const String tournament = 'tournament'; // Tournament
  // TournamentDetailScreen
  static const String field = 'field'; // Field
  // TournamentDetailScreen
  static const String cityName = 'cityName'; // String
  // TournamentDetailScreen
  static const String currentPlayer = 'currentPlayer'; // Player?
  // TournamentDetailScreen
  static const String coordinator = 'coordinator'; // Coordinator?
  // TournamentDetailScreen
  static const String teamParticipation = 'teamParticipation'; // TournamentParticipation?

  // CallUpsScreen
  static const String sport = 'sport'; // Sport

  // FootballTournamentScreen
  static const String matches = 'matches'; // List<FootballMatch>
  // FootballTournamentScreen
  static const String standings = 'standings'; // List<FootballStanding>
  // FootballTournamentScreen, FootballMatchDetailScreen
  static const String minutesPerRound = 'minutesPerRound'; // int
  // FootballTournamentScreen, FootballMatchDetailScreen
  static const String minutesPerPause = 'minutesPerPause'; // int

  // FootballMatchDetailScreen
  static const String match = 'match'; // FootballMatch
  // FootballMatchDetailScreen
  static const String events = 'events'; // List<FootballMatchEvent>
  // FootballMatchDetailScreen, MatchBracket
  static const String homeTeam = 'homeTeam'; // Team?
  // FootballMatchDetailScreen, MatchBracket
  static const String awayTeam = 'awayTeam'; // Team?
  // FootballMatchDetailScreen
  static const String availableRefereeRoles = 'availableRefereeRoles'; // List<RefereeRole>
  // FootballMatchDetailScreen
  static const String playersPerTeam = 'playersPerTeam'; // Map<int, List<Player>>
  // FootballMatchDetailScreen
  static const String assignmentPerRefereeNameSurname = 'assignmentPerRefereeNameSurname'; // Map<int, List<RefereeAssignment>> // key: Name+Surname, value: Role
  // FootballMatchDetailScreen
  static const String coordinatorId = 'coordinatorId'; // int
  // FootballMatchDetailScreen
  static const String refereeCheck = 'refereeCheck'; // bool
  // FootballMatchDetailScreen
  static const String canMatchFinish = 'canMatchFinish'; // bool

  // PayParticipationScreen
  static const String tournamentCache = 'tournamentCache'; // Map<int, Tournament>
  // PayParticipationScreen
  static const String tournamentParticipations = 'tournamentParticipations'; // List<TournamentParticipation>
  // PayParticipationScreen
  static const String isCalledUpPerTournament = 'isCalledUpPerTournament'; // Map<int, bool>

  // LoginScreen
  static const String user = 'user'; // User?
  // LoginScreen
  static const String roleId = 'roleId'; // int

  // ProfileScreen
  static const String level = 'level'; // String

  // CreateTournamentScreen
  static const String fee = 'fee'; // double
  // CreateTournamentScreen
  static const String coordinatorPay = 'coordinatorPay'; // double
  // CreateTournamentScreen
  static const String prize1 = 'prize1'; // double
  // CreateTournamentScreen
  static const String prize2 = 'prize2'; // double
  
  // PlayerRequestsScreen
  static const String teamRequests = 'teamRequests'; // List<TeamRequest>
  // PlayerRequestsScreen
  static const String playersCache = 'playersCache'; // Map<int, Player?>

  // EditInfosScreen
  static const String updatedUser = 'updatedUser'; // User?

  // WalletScreen
  static const String wallet = 'wallet'; // Wallet

  // TeamDetailScreen
  static const String isPlayerInTeam = 'isPlayerInTeam'; // bool
  // TeamDetailScreen
  static const String existingRequest = 'existingRequest'; // TeamRequest?

  // MatchBracket
  static const String winnerId = 'winnerId'; // int

  // SportSelectorWidget
  static const String sports = 'sports'; // List<Sport>

  // RefereeLicensesScreen
  static const String refereeLicenses = 'refereeLicenses'; // List<RefereeLicense>
}
