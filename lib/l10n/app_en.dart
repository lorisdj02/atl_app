import 'app_localizations.dart';

/// Localizzazioni in inglese
class AppLocalizationsEn extends AppLocalizations {
  @override
  String get statusPendingPayments => 'Pending payments';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get logIn => 'Log in';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get register => 'Register';

  @override
  String get continueAsGuest => 'Continue as a guest';

  @override
  String get forgotPasswordTitle => 'Password Recovery';

  @override
  String get forgotPasswordSubtitle => 'Insert your email and check your inbox';

  @override
  String get sendEmail => 'Send email';

  @override
  String get cancel => 'Cancel';

  @override
  String get notAvailable => 'N/A';

  @override
  String get waitSeconds => 'Wait 30s...';

  @override
  String get coordinator => 'Coordinator';

  @override
  String get coordinatorDesc => 'Text for coordinator';

  @override
  String get player => 'Player';

  @override
  String get playerDesc => 'Text for player';

  @override
  String get referee => 'Referee';

  @override
  String get refereeDesc => 'Text for referee';

  @override
  String get organization => 'Organization';

  @override
  String get organizationDesc => 'Text for organization';

  @override
  String get name => 'Name';

  @override
  String get surname => 'Surname';

  @override
  String get city => 'City';

  @override
  String get birthday => 'Birthday';

  @override
  String get continueButton => 'Continue';

  @override
  String get username => 'Username';

  @override
  String get registerButton => 'Register';

  @override
  String get undo => 'Undo';

  @override
  String get appTitle => 'ATL App';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get error => 'Error';

  @override
  String get fillAllFields => 'Fill in all required fields';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get messageSentSuccess =>
      'Message sent successfully, we will respond as soon as possible';

  // Tournaments screen
  @override
  String get tournaments => 'Tournaments';

  @override
  String get search => 'Search';

  @override
  String get myTournaments => 'My\ntournaments';

  @override
  String get nameOrCode => 'Name/Code';

  @override
  String get filters => 'Filters';

  @override
  String get selectCity => 'Select city';

  @override
  String get all => 'All';

  @override
  String get numberOfTeams => 'Number of Teams';

  @override
  String get selectTeamCount => 'Select team count';

  @override
  String get prizeRange => 'Prize Range';

  @override
  String get feeRange => 'Fee Range';

  @override
  String get reset => 'RESET';

  @override
  String get apply => 'APPLY';

  @override
  String get noTournamentsFavorite => 'No favorite tournaments';

  @override
  String get noTournamentsRunning => 'No tournaments running.';

  @override
  String get addToFavorites => 'Add tournaments to favorites!';

  @override
  String get comeBackLater => 'Come back later!';

  @override
  String get noTournamentsFound => 'No tournaments found!';

  @override
  String get tryChangingFilters => 'Try changing the filters';

  @override
  String get favoriteFeatureComingSoon => 'Favorite feature coming soon!';

  @override
  String get tournamentDetails => 'Tournament details';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeComingSoon => 'Dark mode - Coming soon';

  @override
  String teamsCount(int paid, int total) => '$paid/$total';

  @override
  String teamsTotal(int count) => '$count teams';

  // Tournament Status
  @override
  String get statusCreated => 'Created';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusFinished => 'Finished';

  @override
  String get statusCanceled => 'Canceled';

  // Tournament Phase
  @override
  String get phaseGroupStage => 'Group Stage';

  @override
  String get phaseRoundOf32 => 'Round of 32';

  @override
  String get phaseRoundOf16 => 'Round of 16';

  @override
  String get phaseRoundOf8 => 'Round of 8';

  @override
  String get phaseQuarterFinals => 'Quarter Finals';

  @override
  String get phaseSemiFinals => 'Semi Finals';

  @override
  String get phaseFinal => 'Final';

  // Tournament Format
  @override
  String get formatSingleMatchOnly => 'Single match only';

  @override
  String get formatHomeAndAwayGroupStage => 'Home and away (Group Stage only)';

  @override
  String get formatHomeAndAwayKnockoutStage =>
      'Home and away (Knockout Stage only)';

  @override
  String get formatFullHomeAndAway => 'Full home and away';

  // Common strings
  @override
  String get usernameOrEmail => 'Username or Email';

  @override
  String get phone => 'Phone';

  @override
  String get yourMessage => 'Your message';

  @override
  String get contactUsButton => 'Contact us!';

  @override
  String get loading => 'Loading...';

  @override
  String get dark => 'Dark';

  @override
  String get selectBirthday => 'Please select your birthday.';

  @override
  String get unknownAddress => 'Unknown address';

  @override
  String get bookings => 'BOOKINGS';

  @override
  String get needMore => 'NEED MORE?';

  @override
  String get lookingForMorePassion => 'Looking for more passion?';

  @override
  String get bookAField => 'BOOK A FIELD';

  @override
  String get browseTournaments => 'BROWSE TOURNAMENTS';

  @override
  String get joinLobby => 'JOIN LOBBY';

  @override
  String get home => 'HOME';

  @override
  String get otherSportsComingSoon =>
      'Other sports coming soon! Football only for now.';

  @override
  String get darkModeComingSoonSnack => 'Dark mode - Coming soon';

  @override
  String get fieldBookedSuccessfully => 'Field booked successfully!';

  @override
  String get bookingCreatedSuccessfully => 'Booking created successfully!';

  @override
  String errorLoadingData(String error) => 'Error loading data: $error';

  // Registration
  @override
  String get nameRequired => 'Name *';

  @override
  String get surnameRequired => 'Surname *';

  @override
  String get birthdayRequired => 'Birthday *';

  @override
  String get phoneNumber => 'Phone number';

  @override
  String get preferredCityOptional => 'Preferred city (optional)';

  @override
  String get emailRequired => 'Email *';

  @override
  String get usernameRequired => 'Username *';

  @override
  String get passwordRequired => 'Password *';

  @override
  String get inviteCodeOptional => 'Invite code (optional)';

  @override
  String get registering => 'Registering...';

  @override
  String get continueText => 'Continue';

  // Forgot password
  @override
  String waitSecondsCount(int seconds) => 'Wait ${seconds}s...';

  // Profile screen
  @override
  String hiUser(String username) => 'Hi $username!';

  @override
  String levelLabel(int level) => 'Level: $level';

  @override
  String get loadingLevel => 'Loading level...';

  @override
  String get achievement => 'Achievement';

  @override
  String get achievementsTitle => 'ACHIEVEMENTS';

  @override
  String get achievementsComingSoon =>
      'Your achievements and palmares will be displayed here soon!';

  @override
  String get wallet => 'Wallet';

  @override
  String get reviews => 'Reviews';

  @override
  String get licenses => 'Licenses';

  @override
  String get myGrowth => 'My Growth';

  @override
  String get orders => 'Orders';

  @override
  String get stats => 'Stats';

  @override
  String get inviteAFriend => 'Invite a friend!';

  @override
  String get editInfos => 'Edit infos';

  @override
  String get settings => 'Settings';

  @override
  String get contactUsMenuItem => 'Contact Us!';

  @override
  String get logout => 'Logout';

  // Book Field Screen
  @override
  String get selectBookingType => 'Select booking type';

  @override
  String get privateBooking => 'Private Booking';

  @override
  String get privateBookingDesc =>
      'You pay everything, it\'s a private booking just for you and your friends.';

  @override
  String get publicLobby => 'Public Lobby';

  @override
  String get publicLobbyDesc =>
      'Create a lobby and split the cost with other players...';

  @override
  String get insertBookingData => 'Insert booking data';

  @override
  String get selectCityRequired => 'Select city *';

  @override
  String get selectDateRequired => 'Select date *';

  @override
  String get startTimeRequired => 'Start time *';

  @override
  String get endTimeRequired => 'End time *';

  @override
  String get noTimeSlotsAvailable => 'No time slots available';

  @override
  String get lobbyConfiguration => 'Lobby Configuration';

  @override
  String get maxPlayersLabel => 'Maximum players';

  @override
  String get playersPaidByOwner => 'Players you pay for';

  @override
  String playersToFind(int count) => 'Players to find: $count';

  @override
  String get selectField => 'Select field';

  @override
  String get noFieldsAvailable => 'No fields available for this time slot';

  @override
  String fieldForSport(String sport) => 'This field is for $sport';

  @override
  String get total => 'Total';

  @override
  String get perPlayer => 'Per player';

  @override
  String get fieldTooLargeWarning => 'Field larger than needed - higher cost';

  @override
  String get bookingSummary => 'Booking Summary';

  @override
  String get labelType => 'Type';

  @override
  String get labelField => 'Field';

  @override
  String get labelCity => 'City';

  @override
  String get labelDate => 'Date';

  @override
  String get labelSchedule => 'Schedule';

  @override
  String get labelTotalPlayers => 'Total players';

  @override
  String get labelPlayersPaid => 'Players you pay for';

  @override
  String get totalCost => 'Total Cost';

  @override
  String get costPerPlayer => 'Cost per Player';

  @override
  String confirmBooking(String amount) => 'Confirm Booking - €$amount';

  @override
  String get back => 'Back';

  @override
  String get continueStep => 'Continue';

  @override
  String errorLoadingCities(String error) => 'Error loading cities: $error';

  @override
  String get selectBookingTypeFirst => 'Select a booking type first';

  @override
  String get selectFieldFirst => 'Select a field first';

  @override
  String get selectDateFirst => 'Select a date first';

  @override
  String errorLoadingFields(String error) => 'Error loading fields: $error';

  @override
  String get userNotFound => 'User not found';

  // Callups screen
  @override
  String errorLoadingCallupsData(String error) =>
      'Error loading call-ups data: $error';

  @override
  String get atLeastOneCaptain =>
      'At least one captain or vice must be selected';

  @override
  String get errorConfirmingCalups => 'Error confirming call-ups';

  @override
  String get callupsTitle => 'Call-ups';

  @override
  String get noPlayersFoundInTeam => 'No players found in this team';

  @override
  String selectedCount(int count) => 'Selected: $count';

  @override
  String minMaxPlayers(int min, int max) =>
      'Min $min players, Max $max players';

  @override
  String get confirmAndParticipate => 'Confirm and participate';

  // Join Lobby Screen
  @override
  String errorLoadingLobbies(String error) => 'Error loading lobbies: $error';

  @override
  String get selectDayFirst => 'Select a day first';

  @override
  String get startTimeLabel => 'Start time';

  @override
  String get endTimeLabel => 'End time';

  @override
  String get dayShort => 'Day';

  @override
  String get startShort => 'Start';

  @override
  String get endShort => 'End';

  @override
  String get players => 'Players';

  @override
  String get join => 'Join';

  @override
  String joinSpotsLeft(int spots) => 'Join ($spots spots left)';

  @override
  String get onlyOneSpotLeft => 'There is only 1 spot left in this lobby.';

  @override
  String get howManyPlayersPayingFor => 'How many players are you paying for?';

  @override
  String get totalFeeLabel => 'Total fee:';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get maxPay => 'Max Pay';

  @override
  String get cancelText => 'Cancel';

  @override
  String get noLobbiesAvailable => 'No lobbies available';

  // Create Team screen
  @override
  String errorLoadingCitiesShort(String error) =>
      'Error loading cities: $error';

  @override
  String errorLoadingImage(String error) => 'Error loading image: $error';

  @override
  String get teamCreatedSuccessfully => 'Team created successfully!';

  @override
  String get teamNameAlreadyInUse => 'Team name already in use';

  @override
  String get failedToCreateTeam => 'Failed to create team';

  @override
  String errorGeneric(String error) => 'Error: $error';

  @override
  String get uploadLogo => 'Upload logo';

  @override
  String get teamName => 'Name of the team';

  @override
  String get teamAlias => 'Team alias';

  @override
  String get teamDescription => 'Team description (optional)';

  @override
  String get enterTeamName => 'Enter the team name';

  @override
  String teamNameMinChars(int min) =>
      'The name must be at least $min characters long';

  @override
  String get enterTeamAlias => 'Enter the team alias';

  @override
  String teamAliasExactChars(int count) =>
      'The alias must be $count characters long';

  @override
  String get selectTeamCity => 'Select a city';

  @override
  String get createTeamButton => 'CREATE TEAM';

  @override
  String get selectCityHint => 'Select city';

  @override
  String get visibilityHint => 'Visibility (Public/Private)';

  @override
  String get public => 'Public';

  @override
  String get private => 'Private';

  // Pay participation screen
  @override
  String get pendingPaymentsTitle => 'Pending payments';

  @override
  String get noPendingPayments => 'No pending payments';

  // Player requests screen
  @override
  String errorLoadingRequests(String error) => 'Error loading requests: $error';

  @override
  String errorAcceptingRequest(String error) =>
      'Error accepting request: $error';

  @override
  String errorRejectingRequest(String error) =>
      'Error rejecting request: $error';

  @override
  String get allRequestsAccepted => 'All requests accepted';

  @override
  String get errorAcceptingAllRequests => 'Error accepting all requests';

  @override
  String get errorRejectingAllRequests => 'Error rejecting all requests';

  @override
  String get requestsTitle => 'Requests';

  @override
  String get noRequests => 'No requests';

  @override
  String get acceptAll => 'Accept all';

  @override
  String get rejectAll => 'Reject all';

  @override
  String playerJoinedTeam(String username) => '$username joined the team';

  // View callups screen
  @override
  String errorLoadingCallups(String error) => 'Error loading call-ups: $error';

  @override
  String get noCallupsFound => 'No call-ups found';

  // Coordinator home screen
  @override
  String get selectSport => 'Select Sport';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noTournaments => 'No tournaments';

  @override
  String get notCoordinatingAnyTournamentsYet =>
      'You are not coordinating any tournaments yet';

  @override
  String get noMatchesScheduled => 'No matches scheduled';

  @override
  String noMatchesOn(String date) => 'No matches on $date';

  // Create Tournament screen
  @override
  String get createTournamentTitle => 'Create Tournament';

  @override
  String get selectSportFirst => 'Select a sport to continue';

  @override
  String get completeTournamentDetails => 'Complete all tournament details';

  @override
  String get selectFieldFirst2 => 'Select a field to continue';

  @override
  String get insertNameAndDescription =>
      'Insert name and description of the tournament';

  @override
  String errorLoadingFieldsShort(String error) =>
      'Error loading fields: $error';

  @override
  String get tournamentCreatedSuccessfully =>
      'Tournament created successfully!';

  @override
  String errorCreatingTournament(String error) =>
      'Error creating tournament: $error';

  @override
  String get selectSportStep => 'Select the sport';

  @override
  String get chooseSportCategory =>
      'Choose the sport category for your tournament';

  @override
  String get logisticsDetailsTitle => 'Logistics details';

  @override
  String get firstPlacePrize => '1st place prize';

  @override
  String get secondPlacePrize => '2nd place prize';

  @override
  String get visibilityLabel => 'Visibility';

  @override
  String get forProfitTournament => 'For-profit tournament';

  @override
  String get cityHint => 'City';

  @override
  String get publicTournament => 'Public';

  @override
  String get privateTournament => 'Private';

  @override
  String get startMonthHint => 'Start month';

  @override
  String get asSoonAsPossible => 'As soon as possible';

  @override
  String get numberOfTeamsLabel => 'Number of teams';

  @override
  String get numberOfGroupsHint => 'Number of groups';

  @override
  String groupsCount(int count) => '$count groups';

  @override
  String get homeAndAwayHint => 'Home and away';

  @override
  String get qualifiedTeamsHint => 'Qualified teams';

  @override
  String qualifiedTeamsCount(int count) => '$count qualified teams';

  @override
  String get tournamentNameHint => 'Tournament name';

  @override
  String get tournamentDescHint =>
      'Enter the rules and details of the tournament...';

  @override
  String get roundFormatSingleMatch => 'Single match only';

  @override
  String get roundFormatHomeAwayGroups => 'Home and away (Groups only)';

  @override
  String get roundFormatHomeAwayFinals => 'Home and away (Finals only)';

  @override
  String get roundFormatFullHomeAway => 'Home and away (Full)';

  @override
  String get noFieldsAvailableForCriteria =>
      'No fields available for the selected criteria';

  @override
  String get availableFieldsMapTodo => 'TODO: Map of available fields';

  @override
  String get insertDescriptionTitle => 'Enter description';

  @override
  String get tournamentSummaryTitle => 'Tournament summary';

  @override
  String get totalRevenueLabel => 'Total revenue';

  @override
  String get createTournamentButton => 'CREATE +';

  @override
  String get oversizedFieldDialogTitle => 'Oversized field';

  @override
  String oversizedFieldDialogMessage(int totalPlayers) =>
      'The field is designed for more players ($totalPlayers total). '
      'This could mean a different playing experience '
      'and a higher fee per team. Do you want to continue?';

  // Guest screens
  @override
  String get welcomeToAtl => 'WELCOME TO ATL';

  @override
  String get chooseYourRole => 'CHOOSE YOUR ROLE';

  @override
  String get amateurTournamentsLeague => 'Amateur Tournaments League';

  @override
  String get guestHomeDescription =>
      'The platform for amateur sports. Find matches, join tournaments, book fields '
      'and grow your athletic career - all in one place.';

  @override
  String get browseAsGuestHint =>
      'Browse as guest - register to unlock all features';

  @override
  String get guestUserLabel => 'Guest User';

  @override
  String get limitedAccessLabel => 'Limited Access';

  @override
  String get loginToAccessAllFeatures => 'Log in to access all features';

  @override
  String get guestRolePlayerDesc =>
      'Play, grow and connect with your teammates.';

  @override
  String get guestRolePlayerFeature1 => 'Book fields at your favourite venues';

  @override
  String get guestRolePlayerFeature2 => 'Join or create amateur teams';

  @override
  String get guestRolePlayerFeature3 => 'Participate in ranked tournaments';

  @override
  String get guestRoleCoordinatorDesc =>
      'Organise and run tournaments end-to-end.';

  @override
  String get guestRoleCoordinatorFeature1 => 'Create and manage tournaments';

  @override
  String get guestRoleCoordinatorFeature2 => 'Schedule matches and brackets';

  @override
  String get guestRoleCoordinatorFeature3 => 'Coordinate teams and venues';

  @override
  String get guestRoleRefereeDesc => 'Officiate matches and track your career.';

  @override
  String get guestRoleRefereeFeature1 =>
      'Receive match officiating assignments';

  @override
  String get guestRoleRefereeFeature2 => 'Report match events in real time';

  @override
  String get guestRoleRefereeFeature3 => 'Track earnings and schedule';

  @override
  String get guestRoleOrganizationDesc =>
      'Manage your club, venues and events.';

  @override
  String get guestRoleOrganizationFeature1 => 'List and manage your fields';

  @override
  String get guestRoleOrganizationFeature2 => 'Handle memberships and events';

  @override
  String get guestRoleOrganizationFeature3 => 'Oversee all club activities';

  // Organization screens
  @override
  String get noFieldsBooked => 'No fields booked';

  @override
  String noBookingsOn(String date) => 'No bookings on $date';

  @override
  String get unknown => 'Unknown';

  // Referee screens
  @override
  String get licenseDeletedSuccessfully => 'License deleted successfully.';

  @override
  String get failedToDeleteLicense => 'Failed to delete license. Try again.';

  @override
  String errorText(String error) => 'Error: $error';

  @override
  String get alreadyHasLicenseAllSports =>
      'You already have a license for all available sports.';

  @override
  String get deleteText => 'Delete';

  @override
  String get cannotDeleteLicenseNotVerifiedStatus =>
      "You can't delete a license that is not in 'Not Verified' status.";

  @override
  String get deleteLicenseTitle => 'Delete License';

  @override
  String confirmDeleteLicense(String licenseName, String licenseId) =>
      'Are you sure you want to delete the $licenseName license (ID: $licenseId)?\nThis action cannot be undone.';

  @override
  String get licenseGenericName => 'license';

  @override
  String get noLicensesTitle => 'No Licenses';

  @override
  String get noLicensesSubtitle =>
      'Tap the + button to add your first license.';

  @override
  String get noMatchHistoryTitle => 'No match history';

  @override
  String get noMatchHistorySubtitle =>
      'You have not been assigned to any matches yet';

  // Contact us screen
  @override
  String get messageSentSuccessfully =>
      'Message sent successfully! We will get back to you soon.';

  @override
  String errorSendingMessage(String error) => 'Error sending message: $error';

  @override
  String get contactUsTitle => 'CONTACT US';

  @override
  String get getInTouch => 'Get in Touch';

  @override
  String get getInTouchSubtitle =>
      'We\'d love to hear from you. Send us a message...';

  @override
  String get categoryLabel => 'Category';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get enterSubject => 'Enter subject';

  @override
  String get messageLabel => 'Message';

  @override
  String get typeYourMessage => 'Type your message here...';

  @override
  String get sendingText => 'Sending...';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get faqComingSoon => 'FAQ coming soon';

  @override
  String get checkOurFaq => 'Check our FAQ';

  @override
  String get generalInquiry => 'General Inquiry';

  @override
  String get technicalIssue => 'Technical Issue';

  @override
  String get accountProblem => 'Account Problem';

  @override
  String get paymentIssue => 'Payment Issue';

  @override
  String get featureRequest => 'Feature Request';

  @override
  String get reportBug => 'Report Bug';

  @override
  String get other => 'Other';

  @override
  String get emailContact => 'Email';

  @override
  String get phoneContact => 'Phone';

  // Edit infos screen
  @override
  String get enterCurrentPassword => 'Please enter your current password';

  @override
  String get enterNewPassword => 'Please enter a new password';

  @override
  String get newPasswordMinLength =>
      'New password must be at least 6 characters';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String errorUpdatingProfile(String error) => 'Error updating profile: $error';

  @override
  String get editProfileTitle => 'EDIT PROFILE';

  @override
  String get photoUploadComingSoon => 'Photo upload coming soon';

  @override
  String get editableInformation => 'Editable Information';

  @override
  String get usernameLabel => 'Username';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get enterPhone => 'Enter phone number';

  @override
  String get preferredCityLabel => 'Preferred City';

  @override
  String get selectCityText => 'Select city';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get enterCurrentPasswordHint => 'Enter current password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get enterNewPasswordHint => 'Enter new password (min 6 characters)';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get emailLabel => 'Email';

  @override
  String get nameLabel => 'Name';

  @override
  String get surnameLabel => 'Surname';

  @override
  String get birthDateLabel => 'Birth Date';

  @override
  String get roleLabel => 'Role';

  @override
  String get memberSinceLabel => 'Member since';

  @override
  String get vipStatusLabel => 'VIP Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get savingText => 'Saving...';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get naFallback => 'N/A';

  // Invite friends screen
  @override
  String get codeCopied => 'Code copied to clipboard!';

  @override
  String get inviteBalance => 'Invite Balance';

  @override
  String get earnMoreByInviting => 'Earn more by inviting friends!';

  @override
  String get yourReferralCode => 'Your referral code';

  @override
  String get copyCode => 'Copy code';

  @override
  String get copyAndShare => 'Copy & Share';

  @override
  String get friendsJoined => 'Friends joined';

  @override
  String get redeems => 'Redeems';

  @override
  String get shareCodeInfo =>
      'Share your code with friends. When they sign up...';

  @override
  String get inviteAFriendTitle => 'INVITE A FRIEND';

  // My growth screen
  @override
  String get myGrowthTitle => 'MY GROWTH';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get growthPath => 'GROWTH PATH';

  // Orders screen
  @override
  String get ordersTitle => 'ORDERS';

  @override
  String get comingSoonText => 'Coming Soon';

  @override
  String get ordersComingSoon => 'Your orders will be displayed here soon!';

  // Reviews screen
  @override
  String failedToLoadReviews(String error) =>
      'Failed to load reviews data: $error';

  @override
  String get reviewsTitle => 'REVIEWS';

  @override
  String pendingCount(int count) => '$count pending';

  @override
  String get reviewInfoText =>
      'By reviewing, you improve the experience for everyone! Choose wisely!...';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get noPendingReviews => 'No pending reviews.';

  // Settings screen
  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get notifications => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get enableNotificationsSubtitle =>
      'Receive notifications about matches and tournaments';

  @override
  String get settingsSavedSoon => 'Settings will be saved soon';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get emailNotificationsSubtitle => 'Receive notifications via email';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle =>
      'Receive push notifications on your device';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkModeLabel => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Use dark theme';

  @override
  String get darkModeComingSoonMsg => 'Dark mode coming soon';

  @override
  String get language => 'Language';

  @override
  String get privacySecurity => 'Privacy & Security';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'Read our privacy policy';

  @override
  String get privacyComingSoon => 'Privacy policy coming soon';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get termsOfServiceSubtitle => 'Read our terms of service';

  @override
  String get termsComingSoon => 'Terms of service coming soon';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get autoPlayVideos => 'Auto-play Videos';

  @override
  String get autoPlayVideosSubtitle => 'Automatically play videos in feed';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get helpAndSupportSubtitle => 'Get help with the app';

  @override
  String get helpComingSoon => 'Help & support coming soon';

  @override
  String get rateUs => 'Rate Us';

  @override
  String get rateUsSubtitle => 'Rate us on the app store';

  @override
  String get rateUsComingSoon => 'Rate us coming soon';

  @override
  String get dangerZone => 'Danger Zone';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle => 'Permanently delete your account';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get englishLanguage => 'English';

  @override
  String get italianLanguage => 'Italian';

  @override
  String get languageComingSoon => 'Language support coming soon';

  @override
  String get deleteAccountTitle => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. All your data will be permanently deleted.';

  @override
  String get enterPasswordToConfirm => 'Please enter your password to confirm:';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get deleteAccountButton => 'Delete Account';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String get failedToDeleteAccount =>
      'Failed to delete account. Check if your owned teams have Vice Captains assigned.';

  // Stats screen
  @override
  String get vipFeature => 'VIP Feature';

  @override
  String get vipFeatureDesc =>
      'This feature is available for VIP members only. Upgrade to VIP to access detailed statistics and analytics.';

  @override
  String get vipUpgradeComingSoon => 'VIP upgrade coming soon';

  @override
  String get upgradeToVip => 'Upgrade to VIP';

  @override
  String get statsTitle => 'STATS';

  @override
  String get vipBadge => 'VIP';

  @override
  String get tournamentsPlayed => 'Tournaments played';

  @override
  String get careerStats => 'Career Stats';

  // Wallet screen
  @override
  String get walletInfoPlayer =>
      'Personal balance contains refund money, withdrawable once a week with no commission removed...';

  @override
  String get walletInfoCoordinator =>
      'The balance contains refund money and earnings for each tournament...';

  @override
  String get walletInfoReferee =>
      'The balance contains refund money and earnings for each match you refereed...';

  @override
  String get walletInfoOrganization =>
      'The balance contains refund money and earnings for each booking you made...';

  @override
  String get walletInfoFallback => 'No wallet information available.';

  @override
  String get walletInfo => 'Wallet Info';

  @override
  String get ok => 'OK';

  @override
  String get withdrawOptions => 'Withdraw Options';

  @override
  String get withdrawAll => 'Withdraw ALL';

  @override
  String get withdrawAllComingSoon => 'Withdraw ALL coming soon';

  @override
  String get withdrawPersonalBalance => 'Withdraw Personal Balance Only';

  @override
  String get withdrawPersonalComingSoon =>
      'Withdraw Personal Balance coming soon';

  @override
  String get withdrawPrizeBalance => 'Withdraw Prize Balance Only';

  @override
  String get withdrawPrizeComingSoon => 'Withdraw Prize Balance coming soon';

  @override
  String get walletTitle => 'WALLET';

  @override
  String get personalBalance => 'Personal Balance';

  @override
  String get prizeBalance => 'Prize Balance';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get withdrawComingSoon => 'Withdraw coming soon';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get comingSoonText2 => 'Coming Soon';

  @override
  String get transactionHistory =>
      'Transaction history will be available soon!';

    @override
    String get noTransactionsTitle => 'You have no transactions!';

    @override
    String get noTransactionsSubtitle => 'Try leaving reviews.';

    @override
    String get possibleNewPaymentsTitle => 'You may have new payments!';

  // Shop screen
  @override
  String get shopTitle => 'SHOP';

  @override
  String get shopLabel => 'Shop';

  @override
  String get shopComingSoon => 'Coming soon';

  @override
  String get loginToPurchase => 'Login to purchase items';

  @override
  String get guestLoginRequired => 'Guest mode: Login required to purchase';

  // Checkout screen
  @override
  String errorLoadingCheckout(String error) => 'Error loading checkout: $error';

  @override
  String get paymentCompletedSuccessfully => 'Payment completed successfully!';

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get lobbyBookingType => 'Lobby Booking';

  @override
  String playersDetail(int paid, int total) =>
      'Players: $paid paid / $total total';

  @override
  String ownerDetail(String owner) => 'Owner: $owner';

  @override
  String get privateBookingType => 'Private Booking';

  @override
  String get discountCode => 'Discount Code';

  @override
  String get enterDiscountCode => 'Enter discount code';

  @override
  String get invalidDiscountCode => 'Invalid discount code.';

  @override
  String get applyButton => 'Apply';

  @override
  String get walletSection => 'Wallet';

  @override
  String get useWalletBalance => 'Use wallet balance';

  @override
  String get walletOrderInfo =>
      'Wallets are applied in order: Prize → Invite → Personal.';

  @override
  String get prizeBalanceLabel => 'Prize balance';

  @override
  String get inviteBalanceLabel => 'Invite balance';

  @override
  String get personalBalanceLabel => 'Personal balance';

  @override
  String get totalAvailable => 'Total available';

  @override
  String walletDeduction(String amount) =>
      '€$amount will be deducted from your wallet.';

  @override
  String get noWalletBalance => 'No wallet balance available.';

  @override
  String get priceSummary => 'Price Summary';

  @override
  String get subtotal => 'Subtotal';

  @override
  String discount(String code) => 'Discount ($code)';

  @override
  String get walletDeductionLabel => 'Wallet deduction';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get confirmFree => 'Confirm (Free)';

  @override
  String payAmount(String amount) => 'Pay $amount';

  @override
  String discountApplied(String code, String amount) =>
      'Code "$code" applied – $amount';

  @override
  String get feeLabel => 'Fee';

  // All tournaments screen
  @override
  String errorLoadingTournaments(String error) =>
      'Error loading tournaments: $error';

  @override
  String errorApplyingFilters(String error) => 'Error applying filters: $error';

  @override
  String get newLabel => 'New';

  @override
  String get guestModeLoginTournaments =>
      'Guest mode: Login to interact with tournaments';

  @override
  String get unknownCity => 'Unknown city';

  // Coordinator create tournament
  @override
  String get coordinatorNotFound => 'Coordinator not found';

  // Tournament detail screen
  @override
  String errorLoadingTournamentDetails(String error) =>
      'Error loading tournament details: $error';

  @override
  String get fullInfoLabel => 'Full info';

  @override
  String get prizesTitle => 'Prizes';

  @override
  String get locationLabel => 'Location';

  @override
  String get typeLabel => 'Type';

  @override
  String get tba => 'TBA';

  @override
  String get atlEventType => 'ATL Event';

  @override
  String get tournamentType => 'Tournament';

  @override
  String tournamentIdLabel(double id) =>
      'Tournament ID: #${id.toStringAsFixed(0)}';

  @override
  String get startTournamentTitle => 'Start Tournament';

  @override
  String get startTournamentConfirm =>
      'Are you sure you want to start this tournament? This action cannot be undone.';

  @override
  String get startButton => 'Start';

  @override
  String get failedToStartTournament =>
      'Failed to start tournament. Please try again.';

  @override
  String get tournamentFull => 'Tournament Full';

  @override
  String get participatingTeamsTitle => 'Participating teams';

  @override
  String get loadingTeams => 'Loading teams...';

  @override
  String get noParticipatingTeams => 'No participating teams';

  @override
  String get loginToManageCallUps => 'Login to manage call-ups';

  @override
  String get joinTeamToManageCalups => 'Join a team to manage call-ups';

  @override
  String get viewCallUps => 'VIEW CALL-UPS';

  @override
  String get contactCaptain =>
      'Contact your team captain or vice-captains to manage call-ups';

  @override
  String get callUpsUpdated => 'Call-ups updated successfully';

  @override
  String get selectCallUps => 'SELECT CALL-UPS';

  @override
  String get modifyCallUps => 'MODIFY CALL-UPS';

  @override
  String get deleteCallUpsTitle => 'Delete Call-ups';

  @override
  String get deleteCallUpsConfirm =>
      'Are you sure you want to delete all call-ups for this tournament?';

  @override
  String get callUpsDeleted => 'Call-ups deleted successfully';

  @override
  String get failedToDeleteCallUps => 'Failed to delete call-ups';

  // Football match screen
  @override
  String get errorRefereeNotFound => 'Error: Referee ID not found';

  @override
  String get allRefereeRolesAssigned =>
      'All referee roles for this match have already been assigned';

  @override
  String get noValidRefereeLicense =>
      'You do not have a valid referee license for this sport';

  @override
  String get assignmentCreated => 'Assignment created successfully';

  @override
  String get failedToCreateAssignment => 'Failed to create assignment';

  @override
  String get errorCreatingAssignment => 'Error creating assignment';

  @override
  String get errorFieldNotAvailable => 'Error: Field information not available';

  @override
  String get startMatchTitle => 'Start Match';

  @override
  String get startMatchConfirm => 'Are you sure you want to start the match?';

  @override
  String get halftimeTitle => 'Go to Halftime';

  @override
  String get halftimeConfirm => 'Are you sure you want to end the first half?';

  @override
  String get startSecondHalfConfirm =>
      'Are you sure you want to start the second half?';

  @override
  String get finishMatchTitle => 'Finish Match';

  @override
  String get finishMatchConfirm =>
      'Are you sure you want to finish the match? This action cannot be undone.';

  @override
  String get startPenaltyShootoutTitle => 'Start Penalty Shootout';

  @override
  String get startPenaltyShootoutConfirm =>
      'Are you sure you want to start the penalty shootout?';

  @override
  String get matchScheduledSuccessfully => 'Match scheduled successfully';

  @override
  String get matchRescheduledSuccessfully => 'Match rescheduled successfully';

  @override
  String get failedToScheduleFieldUnavailable =>
      'Failed to schedule match. The field might not be available.';

  @override
  String get cannotRescheduleWithin24h =>
      'Cannot reschedule match within 24 hours of start time';

  @override
  String get matchDetailsTitle => 'Match Details';

  @override
  String get eventsTitle => 'Events';

  @override
  String get matchNotFound => 'Match not found';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String get bothTeamsTbdMessage =>
      'Both teams must be determined from previous phase results. Keep playing!';

  @override
  String get homeTeamTbdMessage =>
      'Home team must be determined from previous phase results. Keep playing!';

  @override
  String get awayTeamTbdMessage =>
      'Away team must be determined from previous phase results. Keep playing!';

  @override
  String get matchStartedEvent => 'Match started';

  @override
  String get halftimeEvent => 'Halftime';

  @override
  String get secondHalfStartedEvent => 'Second half started';

  @override
  String get fullTimeEvent => 'Full time';

  @override
  String get penaltyShootoutEvent => 'Penalty Shootout';

  @override
  String matchIdLabel(int id) => 'Match ID: #$id';

  @override
  String get unknownPlayer => 'Unknown Player';

  @override
  String matchActionSuccess(String action) => 'Match $action successfully';

  @override
  String failedToMatchAction(String action) => 'Failed to $action match';

  @override
  String get penaltyShootoutStarted => 'Penalty shootout started';

  @override
  String get failedToStartPenalty => 'Failed to start penalty shootout';

  @override
  String get motmAdded => 'MOTM added successfully';

  @override
  String get failedToAddMotm => 'Failed to add MOTM';

  @override
  String get onlyCoordinatorCanDelete =>
      'Only the tournament coordinator can delete events';

  @override
  String get cannotDeleteNotLast =>
      'Cannot delete event if it\'s not the last one';

  @override
  String get onlyPlayerEventsCanBeDeleted =>
      'You can only delete player events';

  @override
  String get deleteEventTitle => 'Delete Event';

  @override
  String get deleteEventConfirm => 'Do you want to delete this event?';

  @override
  String get eventDeleted => 'Event deleted successfully';

  @override
  String get failedToDeleteEvent => 'Failed to delete event';

  @override
  String get selectMotmLabel => 'Select MOTM';

  @override
  String get scheduleMatchLabel => 'Schedule Match';

  @override
  String get rescheduleMatchLabel => 'Reschedule Match';

  @override
  String get manageMatchLabel => 'Manage Match';

  @override
  String get startSecondHalf => 'Start Second Half';

  @override
  String get endMatch => 'End Match';

  @override
  String get addPlayerEventLabel => 'Add Player Event';

  @override
  String get insertPenalty => 'Insert Penalty';

  @override
  String get refereeTheMatch => 'Referee the Match';

    @override
    String get penaltyShootoutInfo =>
            'Each team takes 5 penalties, then it goes to sudden death.';

    @override
    String get penaltyShootoutAbbrev => 'PSO';

  @override
  String get cancelButton => 'CANCEL';

  @override
  String get confirmButton => 'CONFIRM';

    @override
    String get closeButton => 'CLOSE';

  // Football tournament screen
  @override
  String errorLoadingDataGeneric(String error) => 'Error loading data: $error';

  @override
  String get chatComingSoon => 'Chat coming soon';

  @override
  String get chatLabel => 'Chat';

  @override
  String get fixturesTab => 'Fixtures';

  @override
  String get tablesTab => 'Tables';

  @override
  String dayLabel(int day) => 'Day $day';

  @override
  String get roundOf16Label => 'Round of 16';

  @override
  String get quarterFinalsLabel => 'Quarter Finals';

  @override
  String get semiFinalsLabel => 'Semifinals';

  @override
  String get finalLabel => 'Final';

  @override
  String groupLabel(String group) => 'GROUP $group';

  @override
  String get teamsTbdAfterGroupStage =>
      'Teams will be determined at the end of group stage';

  @override
  String winnersOfSemifinals(int semi1, int semi2) =>
      'Winners of Semifinal $semi1 and Semifinal $semi2';

  @override
  String winnersOfRoundOf16(int match1, int match2) =>
      'Winners of Round of 16 #$match1 and Round of 16 #$match2';

  @override
  String winnersOfQuarterFinals(int match1, int match2) =>
      'Winners of Quarter Final $match1 and Quarter Final $match2';

  @override
  String get noMatchesForPhaseYet => 'No matches for this phase yet';

  @override
  String get noStandingsAvailable => 'No standings available';

  @override
  String get teamLabel => 'Team';

  @override
  String get standingsHeaderAbbrev => 'Pts - W - D - L - GD';

  @override
  String get noStatsAvailable => 'No stats available. Keep playing!';

  @override
  String get groupStageTab => 'Group Stage';

  @override
  String get roadToVictoryTab => 'Road to Victory';

  @override
  String get goToNextPhaseLabel => 'Go To Next Phase';

    @override
    String get goToFinalStageLabel => 'Go To Final Stage';

    @override
    String get closeTournamentLabel => 'Close Tournament';

  @override
  String get goToNextPhaseSuccess => 'Next phase started';

  @override
  String goToNextPhaseError(String error) =>
      'Failed to go to next phase: $error';

  @override
  String get assignPrizesLabel => 'Assign Prizes';

  @override
  String get assignPrizesTitle => 'Assign Prizes';

  @override
  String errorLoadingAssignPrizes(String error) =>
      'Error loading prizes data: $error';

  @override
  String errorAssigningPrizes(String error) =>
      'Error assigning prizes: $error';

  @override
  String get prizeAssignedSuccess => 'Prize assigned successfully';

  @override
  String totalPrizeLabel(String amount) => 'Total prize: $amount';

  @override
  String totalAssignedLabel(String amount) => 'Assigned: $amount';

  @override
  String remainingPrizeLabel(String amount) => 'Remaining: $amount';

  @override
  String get prizeTotalExceeded =>
      'Total assigned exceeds the available prize';

  @override
  String percentOfTotal(double percent) =>
      '${percent.toStringAsFixed(1)}% of total';

  @override
  String get prizeAmountLabel => 'Prize';

  @override
  String contributionLabel(String stats) => 'Contribution: $stats';

  @override
  String get contributionUnavailable => 'Contribution not available';

  // My team screen
  @override
  String get promoteToBViceCaptain => 'Promote to Vice Captain';

  @override
  String get demote => 'Demote';

  @override
  String get expelFromTeam => 'Expel from Team';

  @override
  String get maxViceCaptains =>
      'Maximum 2 Vice Captains allowed. Demote one first.';

  @override
  String promotedToVC(String name) => '$name promoted to Vice Captain';

  @override
  String get failedToPromote => 'Failed to promote player to Vice Captain';

  @override
  String demoted(String name) => '$name demoted';

  @override
  String get failedToDemote => 'Failed to demote player';

  @override
  String get expelPlayerTitle => 'Expel Player';

  @override
  String expelPlayerConfirm(String name) =>
      'Are you sure you want to expel $name from the team?';

  @override
  String expelled(String name) => '$name expelled from team';

  @override
  String get failedToExpel => 'Failed to expel player';

  @override
  String get failedToAcceptRequest => 'Failed to accept request';

  @override
  String get leaveTeamTitle => 'Leave Team';

  @override
  String get leaveTeamConfirm => 'Are you sure you want to leave this team?';

  @override
  String get leaveButton => 'Leave';

  @override
  String get leaveTeamLabel => 'Leave Team';

  @override
  String get requestsLabel => 'Requests';

  @override
  String get expelButton => 'Expel';

  // Team screen
  @override
  String get footballTeamsTitle => 'Football Teams';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get allCities => 'All';

  @override
  String get allTeams => 'All';

  @override
  String get vipOnly => 'VIP Only';

  @override
  String get nonVip => 'Non VIP';

  @override
  String get applyText => 'Apply';

  @override
  String get resetText => 'Reset';

  @override
  String get ranksInfo => 'Ranks Info';

  @override
  String get nameAlias => 'Name (Alias)';

  @override
  String get idLabel => 'ID';

  @override
  String get createTeamLabel => 'Create';

  @override
  String errorLoadingTeams(String error) => 'Error loading teams: $error';

  @override
  String get ranksInfoDescription =>
      'Teams are sorted by rank points (Rank Pts). The higher the score, the better the ranking position.';

  @override
  String get myTeamTab => 'My Team';

  @override
  String get ranksTab => 'Ranks';

  @override
  String get noTeamsAvailable => 'No teams available';

  @override
  String get noTeamsFound => 'No teams found';

  @override
  String get guestModeLoginTeams => 'Guest mode: Login to create/join teams';

  @override
  String get numberOfPlayersLabel => 'Number of Players';

  @override
  String playersRangeLabel(int min, int max) => '$min - $max players';

  // Team detail screen
  @override
  String errorLoadingTeamData(String error) =>
      'Error loading team data: $error';

  @override
  String get errorSendingRequest => 'Error sending request';

  @override
  String get requestSentSuccessfully => 'Request sent successfully';

  @override
  String errorSendingRequestDetail(String error) =>
      'Error sending request: $error';

  @override
  String get errorCancellingRequest => 'Error cancelling request';

  @override
  String get requestCancelled => 'Request cancelled';

  @override
  String errorCancellingRequestDetail(String error) =>
      'Error cancelling request: $error';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get joinTeam => 'Join Team';

  // Abstract team screen
  @override
  String get vipUpgradeComingSoonTeam => 'VIP upgrade coming soon';

  @override
  String get vipPalmaresDesc =>
      'This section is available for VIP teams only. Upgrade to VIP to view the team palmares.';

  @override
  String get actualPlayersToggle => 'Actual Players';

  @override
  String get allPlayersToggle => 'All Players';

  @override
  String get noTrophiesYet => 'No trophies yet';

  @override
  String get captainCannotLeaveTeam =>
      'Captains cannot leave the team. Please assign a vice-captain before leaving.';

  @override
  String get errorLeavingTeam =>
      'Error leaving the team. Please try again later.';

  @override
  String pendingPaymentsCount(int count) => 'Pending Payments ($count)';

  @override
  String get statsTab => 'Stats';

  @override
  String get palmaresTab => 'Palmares';

  @override
  String get teamDetailsTitle => 'Team Details';

  // Add referee license dialog
  @override
  String get selectSportFirst2 => 'Please select a sport';

  @override
  String get selectIssueDate => 'Please select the issue date';

  @override
  String get failedToAddLicense => 'Failed to add license. Try again.';

  @override
  String get addLicenseTitle => 'Add License';

  @override
  String get sportLabel => 'Sport';

  @override
  String get selectSportHint => 'Select sport';

  @override
  String get photoLabel => 'Photo';

  @override
  String get photoUploadComingSoonMsg => 'Photo upload — Coming soon';

  @override
  String get uploadPhotoComingSoon => 'Upload photo (coming soon)';

  @override
  String get licenseIdLabel => 'License ID';

  @override
  String get licenseIdHint => 'e.g. ABC-2024-001';

  @override
  String get enterLicenseId => 'Please enter the license ID';

  @override
  String get addButton => 'Add';

  // Booking widget
  @override
  String get chatComingSoonWidget => 'Chat - Coming soon';

  @override
  String get fullLobby => 'Full Lobby';

  @override
  String youPaidForPlayers(int count) =>
      count == 1 ? 'You paid for 1 player' : 'You paid for $count players';

  @override
  String get openChat => 'Open Chat';

  @override
  String get deleteLobbyTitle => 'Delete Lobby';

  @override
  String get deleteLobbyMessage =>
      'Are you sure you want to delete this lobby? All participants will be removed.';

  @override
  String get leaveLobbyTitle => 'Leave Lobby';

  @override
  String get leaveLobbyMessage => 'Are you sure you want to leave this lobby?';

  @override
  String get deleteBookingTitle => 'Delete Booking';

  @override
  String get deleteBookingMessage =>
      'Are you sure you want to delete this private booking?';

  @override
  String get lobbyDeleted => 'Lobby deleted';

  @override
  String get lobbyLeft => 'Lobby left';

  @override
  String get bookingDeleted => 'Booking deleted';

  @override
  String get failedToDeleteLobby => 'Failed to delete lobby';

  @override
  String get failedToLeavelobby => 'Failed to leave lobby';

  @override
  String get failedToDeleteBooking => 'Failed to delete booking';

  // Football MOTM dialog
  @override
  String errorLoadingPlayers(String error) => 'Error loading players: $error';

  @override
  String get selectMotmTitle => 'Select Man of the Match';

  // Football stat card
  @override
  String get goalsLabel => 'Goals';

  @override
  String get motmLabel => 'MOTM';

  @override
  String get yellowCardsLabel => 'Yellow Cards';

  @override
  String get redCardsLabel => 'Red Cards';

  // Growth hero card
  @override
  String get levelAbbrev => 'LVL';

  @override
  String get refereeRole => 'Referee';

  @override
  String get coordinatorRole => 'Coordinator';

  // Growth pay note
  @override
  String get growthPayNote =>
      'Pay may vary by role within the same sport category. Figures shown are the min–max range across all roles for that level.';

  // Growth timeline item
  @override
  String get currentBadge => 'CURRENT';

  @override
  String get startingLevel => 'Starting level — no requirements';

  @override
  String minGamesRefereed(int count) => 'Min. $count games refereed';

  @override
  String avgRatingGames(double rating, int games) =>
      'Avg. rating ≥ $rating over last $games games';

  @override
  String minTournamentsCoordinated(int count) =>
      'Min. $count tournaments coordinated';

  @override
  String avgRatingTournaments(double rating, int tournaments) =>
      'Avg. rating ≥ $rating over last $tournaments tournaments';

  @override
  String payPerMatch(String amount) => '€$amount / match';

  // Match event dialog
  @override
  String get confirmEventTitle => 'Confirm Event';

  @override
  String get selectEventType => 'Select event type';

  @override
  String get selectPlayer => 'Select player';

  @override
  String get failedToAddEvent => 'Failed to add event';

  // Match info card
  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get fieldLabel => 'Field';

  @override
  String get refereesLabel => 'Referees';

  // Bottom bars
  @override
  String get shopNavLabel => 'Shop';

  @override
  String get meNavLabel => 'Me';

  @override
  String get tournamentsNavLabel => 'Tournaments';

  @override
  String get teamNavLabel => 'Team';

  @override
  String get matchesNavLabel => 'Matches';

  @override
  String get historyNavLabel => 'History';

  // Participation card
  @override
  String get enterValidAmount => 'Enter a valid amount';

  @override
  String get userNotLoggedIn => 'User not logged in';

  @override
  String get continueParticipation => 'Continue';

  // Review widget
  @override
  String get rateAllFieldsMsg =>
      'Please rate all fields (minimum 0.5 stars each).';

  @override
  String get reviewSubmitted => 'Review submitted!';

  @override
  String get reviewSubmittedLabel => 'Submitted';

  @override
  String get failedToSubmitReview => 'Failed to submit review.';

  // Search dialog widget
  @override
  String get searchByTeamId => 'Search By Team ID';

  @override
  String get searchByTournamentId => 'Search By Tournament ID';

  @override
  String get searchButton => 'Search';

  // Sport selector widget
  @override
  String errorLoadingSports(String error) => 'Error loading sports: $error';

  // Tournament summary
  @override
  String get feePerTeam => 'Fee per team';

  @override
  String get fieldLabel2 => 'Field';

  @override
  String get sportLabel2 => 'Sport';

  @override
  String get startLabel => 'Start';

  @override
  String get teamsLabel => 'Teams';

  @override
  String get groupsLabel => 'Groups';

  @override
  String get qualifiedTeamsLabel => 'Teams qualified for finals';

  @override
  String get totalMatchesLabel => 'Total matches';

  @override
  String get homeAndAwayLabel => 'Home and away';

  @override
  String get descriptionLabel => 'Description';

  // Referee match dialog
  @override
  String get confirmAssignmentTitle => 'Confirm Assignment';

  // Available matches screen
  @override
  String get allFilter => 'All';

  @override
  String get selectCityToSeeMatchesTitle => 'Select a city';

  @override
  String get selectCityToSeeMatchesSubtitle =>
      'Choose a city to see available matches';

  @override
  String get noMatchesAvailable => 'No matches available';

  @override
  String get noScheduledMatchesForSelectedFilters =>
      'No scheduled matches for the selected filters';

  @override
  String sportWithId(double sportId) => 'Sport $sportId';

  @override
  String noScheduledMatchesInSport(String sportName) =>
      'No scheduled matches in: $sportName';

  // Rank teams widget
  @override
  String ptsLabel(int pts) => '$pts pts';

  // Transaction card
  @override
  String daysAgo(int days) => '$days days ago';

  // Tournament card home
  @override
  String get participatingInTournamentMsg =>
      'You are participating in the tournament. When it fills up, you will see your upcoming matches!';

  // Abstract team dialog
  @override
  String get pleaseSelectTeamFirst => 'Please select a team first';

  // Players widget
  @override
  String get noPlayersFound => 'No Players Found';

  @override
  String get teamDisabledMsg => 'This team is disabled.';

  @override
  String get captainAbbr => 'C';

  @override
  String get viceCaptainAbbr => 'VC';

  @override
  String teamAliasAndId(String alias, double id) =>
      "Alias: ${alias} - ID: ${id.toStringAsFixed(0)}";

  // Abstract football match widget - match statuses
  @override
  String get matchStatusLive => 'Live';

  @override
  String get matchStatusHalftime => 'Halftime';

  @override
  String get matchStatusLive2ndHalf => 'Live - 2nd Half';

  @override
  String get matchStatusPenaltyShootout => 'Penalty shoot-out';

  @override
  String get matchStatusFullTime => 'Full-time';

  @override
  String get matchStatusToBeScheduled => 'To be scheduled';

  @override
  String get matchStatusRetired => 'Retired';

  @override
  String get matchStatusCanceled => 'Canceled';

  @override
  String matchStatusScheduled(String date, String time) =>
      'Scheduled ($date at $time)';

  // Shared
  @override
  String get tbd => 'TBD';

  @override
  String get motmWarningMsg => 'Warning: MOTM missing';

  // Team widgets
  @override
  String captainLabel(String name) => 'Captain: $name';

  @override
  String get cannotChangeFavMsg =>
      'Cannot change favorite status while participating.';

  // Organization booking
  @override
  String get tournamentMatchLabel => 'Tournament Match';

  @override
  String get vsLabel => 'VS';

  @override
  String coordinatorPrefix(String name) => 'Coordinator: $name';

  @override
  String playerPrefix(String name) => 'Player: $name';

  // Match event dialog
  @override
  String get eventGoal => 'Goal';

  @override
  String get eventPenalty => 'Penalty';

  @override
  String get eventMissedPenalty => 'Missed Penalty';

  @override
  String get eventOwnGoal => 'Own Goal';

  @override
  String get eventYellowCard => 'Yellow Card';

  @override
  String get eventRedCard => 'Red Card';

  @override
  String get eventDoubleYellowCard => 'Double Yellow Card';

  @override
  String get addEventButton => 'Add Event';

  @override
  String confirmEventMsg(String eventName, String playerName) =>
      'Are you sure you want to add $eventName for $playerName?';

  @override
  String get noPlayersAvailable => 'No players available';

  // Match info card
  @override
  String get matchInformationTitle => 'Match Information';

  @override
  String get matchNotScheduledYet => 'Match not scheduled yet';

  @override
  String get noRefereesAssigned => 'No referees assigned';

  // Schedule match dialog
  @override
  String get selectDateButton => 'Select Date';

  @override
  String get availableTimeSlotsLabel => 'Available Time Slots (Kickoff Time):';

  @override
  String get noAvailableTimeSlotsForDate =>
      'No available time slots for this date';

  @override
  String fieldBookedInfo(String from, String to, String date, String kickoff) =>
      'Field booked from $from to $to on $date with kickoff scheduled at $kickoff';

  // Search dialog widget
  @override
  String get pleaseEnterIdError => 'Please enter an ID';

  @override
  String get invalidIdFormatError => 'Invalid ID format';

  @override
  String get teamNotFoundError => 'Team not found';

  @override
  String get tournamentNotFoundError => 'Tournament not found';

  @override
  String errorSearching(String e) => 'Error searching: $e';

  @override
  String get enterTeamIdHint => 'Enter Team ID';

  @override
  String get enterTournamentIdHint => 'Enter Tournament ID';

  // Road to victory
  @override
  String get invalidBracketConfig => 'Invalid bracket configuration';

  @override
  String roundOf16NumLabel(String group) => 'Round of 16 #$group';

  @override
  String quarterFinalNumLabel(String group) => 'Quarter Final $group';

  @override
  String semifinalNumLabel(String group) => 'Semifinal $group';

  // Sport selector
  @override
  String get noSportsAvailable => 'No sports available';

  @override
  String sportPlayersMinutesLabel(int min, int max, int minutes) =>
      '$min-$max players • $minutes\' per half';

  // Tournament summary
  @override
  String get round2ForAll => 'For the whole tournament';

  @override
  String get round2GroupStageOnly => 'Group stage only';

  @override
  String get round2FinalStageOnly => 'Final stage only';

  @override
  String get noDescriptionProvided => 'No description provided';

  @override
  String get firstPlaceLabel => '1st place';

  @override
  String get secondPlaceLabel => '2nd place';

  @override
  String monthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  // Referee license widget
  @override
  String get licenseStatusNotVerified => 'Not Verified';

  @override
  String get licenseStatusSuspended => 'Suspended';

  @override
  String get licenseStatusRevoked => 'Revoked';

  @override
  String get licenseIssuedLabel => 'Issued';

  @override
  String get licenseSubmittedLabel => 'Submitted';

  @override
  String get licenseVerifiedLabel => 'Verified';

  @override
  String get holdToDeleteHint => 'Hold to delete';

  // Referee match dialog
  @override
  String get mainRefereeRole => 'Main Referee';

  @override
  String get assistantRef1Role => 'Assistant Referee 1';

  @override
  String get assistantRef2Role => 'Assistant Referee 2';

  @override
  String get refereeThisMatchTitle => 'Referee this Match';

  @override
  String get selectYourRoleLabel => 'Select your role:';

  @override
  String confirmRefereeMsg(String role) =>
      'Are you sure you want to referee this match as $role?';

  // Review widget
  @override
  String get reviewingLabel => 'Reviewing';

  @override
  String get impartialityField => 'Impartiality';

  @override
  String get competenceField => 'Competence';

  @override
  String get matchManagementField => 'Match management';

  @override
  String get organisationField => 'Organisation';

  @override
  String get communicationField => 'Communication';

  @override
  String get availabilityField => 'Availability';

  @override
  String get coordinatorToRefereeLabel => 'Coordinator → Referee';

  @override
  String get refereeToCoordinatorLabel => 'Referee → Coordinator';

  @override
  String get playerToCoordinatorLabel => 'Player → Coordinator';

  @override
  String get commentOptionalLabel => 'Comment (optional)';

  @override
  String get writeACommentHint => 'Write a comment...';

  @override
  String get submittingLabel => 'Submitting...';

  @override
  String get commitReviewButton => 'Commit Review';

  // Participation card
  @override
  String get calledUpLabel => 'Called up';

  @override
  String get notCalledUpLabel => 'Not called up';

  @override
  String get payButton => 'Pay';

  @override
  String get howMuchToPayTitle => 'How much do you want to pay?';

  @override
  String amountDueLabel(double amount) =>
      'Amount due: €${amount.toStringAsFixed(2)}';

  @override
  String get amountToPayLabel => 'Amount to pay';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get round2Label => 'Round 2';

  @override
  String get specifyTeamOrTournament =>
      'Must specify either team or tournament search.';

  @override
  String get failedToLoadTimeData =>
      'Failed to load time data. Please try again.';

  @override
  String get tournamentLabel => 'Tournament';

  @override
  String payOutOf(String paid, String total) => 'Pay €$paid out of €$total';

  @override
  String get unknownLocation => 'Unknown location';

  @override
  String get eventTypeLabel => 'Event type';

  @override
  String get issuedAtLabel => 'Issued at';

  @override
  String get selectADate => 'Select a date';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get unknownTime => 'Unknown time';

  @override
  String get transactionStatusRefunded => 'Refunded';

  @override
  String get transactionStatusConfirmed => 'Accredited';
}
