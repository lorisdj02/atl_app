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
  static const String footballMatchesPerTournament =
      'footballMatchesPerTournament'; // Map<int, List<FootballMatch>>
  // PlayerHomeScreen,
  static const String footballStandingsPerTournament =
      'footballStandingsPerTournament'; // Map<int, List<FootballStanding>>
  // PlayerHomeScreen, CoordinatorHomeScreen, RefereeHomeScreen, OrganizationHomeScreen, TeamScreen
  static const String teamsCache = 'teamsCache'; // Map<int, Team>
  // PlayerHomeScreen,
  static const String accountTeam = 'accountTeam'; // Team?
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
  static const String assignedFootballMatches =
      'assignedFootballMatches'; // List<FootballMatch>

  // OrganizationHomeScreen
  static const String generalBookings = 'generalBookings'; // List<Booking>
  // OrganizationHomeScreen
  static const String cityNamePerField = 'cityNamePerField'; // Map<int, String>
  // OrganizationHomeScreen
  static const String detailedBookings =
      'detailedBookings'; // Map<int, dynamic>
  // OrganizationHomeScreen
  static const String footballMatchPerBooking =
      'footballMatchPerBooking'; // Map<int, FootballMatch>
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
  static const String coordinatorsCache =
      'coordinatorsCache'; // Map<int, Coordinator>
  // AbstractTeamScreen
  static const String fieldsCache = 'fieldsCache'; // Map<int, Field>
  // AbstractTeamScreen, FootballTournamentScreen
  static const String footballPlayerStatsCache =
      'footballPlayerStatsCache'; // Map<int, FootballTeamStats>
  // AbstractTeamScreen
  static const String historicalPlayers = 'historicalPlayers'; // List<Player>

  // JoinLobbyScreen, AllTournamentsScreen, CreateTournamentScreen
  static const String cities = 'cities'; // List<City>

  // JoinLobbyScreen
  static const String lobbies = 'lobbies'; // List<LobbyBooking>

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
  // CallUpsScreen
  static const String calledUpPlayerIds = 'calledUpPlayerIds'; // List<int>

  // FootballTournamentScreen
  static const String matches = 'matches'; // List<FootballMatch>
  // FootballTournamentScreen
  static const String standings = 'standings'; // List<FootballStanding>
  // FootballTournamentScreen, FootballMatchScreen
  static const String minutesPerRound = 'minutesPerRound'; // int
  // FootballTournamentScreen, FootballMatchScreen
  static const String minutesPerPause = 'minutesPerPause'; // int

  // FootballMatchScreen
  static const String match = 'match'; // FootballMatch
  // FootballMatchScreen
  static const String events = 'events'; // List<FootballMatchEvent>
  // FootballMatchScreen, MatchBracket
  static const String homeTeam = 'homeTeam'; // Team?
  // FootballMatchScreen, MatchBracket
  static const String awayTeam = 'awayTeam'; // Team?
  // FootballMatchScreen
  static const String availableRefereeRoles = 'availableRefereeRoles'; // List<RefereeRole>
  // FootballMatchScreen
  static const String playersPerTeam = 'playersPerTeam'; // Map<int, List<Player>>
  // FootballMatchScreen
  static const String assignmentPerRefereeNameSurname = 'assignmentPerRefereeNameSurname'; // Map<int, List<RefereeAssignment>> // key: Name+Surname, value: Role
  // FootballMatchScreen
  static const String coordinatorId = 'coordinatorId'; // int
  // FootballMatchScreen
  static const String refereeCheck = 'refereeCheck'; // bool
  // FootballMatchScreen
  static const String canMatchFinish = 'canMatchFinish'; // bool
  // FootballMatchScreen
  static const String hasRefereeLicense = 'hasRefereeLicense'; // bool
  // FootballMatchScreen
  static const String payPerRole = 'payPerRole'; // Map<String, double>

  // PayParticipationScreen
  static const String tournamentsCache = 'tournamentsCache'; // Map<int, Tournament>
  // PayParticipationScreen
  static const String tournamentParticipations = 'tournamentParticipations'; // List<TournamentParticipation>
  // PayParticipationScreen
  static const String isCalledUpPerTournament = 'isCalledUpPerTournament'; // Map<int, bool>

  // LoginScreen
  static const String account = 'account'; // Account?
  // LoginScreen
  static const String roleId = 'roleId'; // int?

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
  // CreateTournamentScreen
  static const String maxPlayersPerField = 'maxPlayersPerField'; // Map<int, int>
  
  // PlayerRequestsScreen
  static const String teamRequests = 'teamRequests'; // List<TeamRequest>
  // PlayerRequestsScreen
  static const String playersCache = 'playersCache'; // Map<int, Player?>

  // EditInfosScreen
  static const String updatedAccount = 'updatedAccount'; // Account?

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

  // AvailableMatchesScreen
  static const String matchesPerSport = 'matchesPerSport'; // Map<int, List<FootballMatch>>
  // AvailableMatchesScreen
  static const String sportNames = 'sportNames'; // Map<int, String>

  // StatsScreen
  static const String statsPerCategory = 'statsPerCategory'; // Map<SportCategory, dynamic>
  // StatsScreen
  static const String numTournamentPerCategory = 'numTournamentPerCategory'; // Map<SportCategory, int>
  // StatsScreen
  static const String numLobbyJoinedPerCategory = 'numLobbyJoinedPerCategory'; // Map<SportCategory, int>
  // StatsScreen
  static const String numPrivateBookingPerCategory = 'numPrivateBookingPerCategory'; // Map<SportCategory, int>

  // Bottom bars
  static const String hasUnreadNotifications = 'hasUnreadNotifications'; // bool

  // ReviewsScreen
  static const String reviews = 'reviews'; // List<Review>
  // ReviewsScreen
  static const String accountPerReview = 'accountPerReview'; // Map<int, Account>
  // ReviewsScreen
  static const String matchTeamsStringPerReview = 'matchTeamsStringPerReview'; // Map<int, String>

  // InviteFriendsScreen
  static const String referralCode = 'referralCode'; // String
  // InviteFriendsScreen
  static const String inviteBalance = 'inviteBalance'; // double
  // InviteFriendsScreen
  static const String numRedeemed = "numRedeemed"; // int
  // InviteFriendsScreen
  static const String numInvites = "numInvites"; // int

  // CheckoutScreen
  static const String checkoutSession = 'checkoutSession'; // CheckoutSession
  // CheckoutScreen
  static const String tournamentName = 'tournamentName'; // String
  // CheckoutScreen
  static const String fieldName = 'fieldName'; // String
  // CheckoutScreen
  static const String fieldAddress = 'fieldAddress'; // String
  // CheckoutScreen
  static const String bookingUsername = 'bookingUsername'; // String
  // CheckoutScreen
  static const String playersToPay = 'playersToPay'; // int
  // CheckoutScreen
  static const String startTime = 'startTime'; // DateTime
  // CheckoutScreen
  static const String endTime = 'endTime'; // DateTime
  // CheckoutScreen
  static const String maxPlayers = 'maxPlayers'; // int

  // BookFieldScreen
  static const String minOpeningTimePerCity = 'minOpeningTimePerCity'; // Map<int, TimeOfDay>
  // BookFieldScreen
  static const String maxClosingTimePerCity = 'maxClosingTimePerCity'; // Map<int, TimeOfDay>

  // GrowthScreen
  static const String growthSteps = 'growthSteps'; // List<GrowthStep>
  // GrowthScreen
  static const String minRefereePayPerCategoryPerLevel = 'minRefereePayPerCategoryPerLevel'; // Map<int, Map<SportCategory, double>>
  // Growth Screen
  static const String maxRefereePayPerCategoryPerLevel = 'maxRefereePayPerCategoryPerLevel'; // Map<int, Map<SportCategory, double>>

  // Login Screen
  static const String teamId = 'teamId'; // int?

  // AvailableMatchesScreen
  static const String footballMatches = 'footballMatches'; // List<FootballMatch>
}
