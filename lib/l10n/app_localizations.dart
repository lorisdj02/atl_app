import 'package:flutter/material.dart';

/// Classe astratta per le localizzazioni dell'app
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Login Screen
  String get email;
  String get password;
  String get forgotPassword;
  String get logIn;
  String get register;
  String get continueAsGuest;
  String get invalidCredentials;

  // Forgot Password Screen
  String get forgotPasswordTitle;
  String get forgotPasswordSubtitle;
  String get sendEmail;
  String get cancel;
  String get notAvailable;
  String get waitSeconds;

  // Registration
  String get coordinator;
  String get coordinatorDesc;
  String get player;
  String get playerDesc;
  String get referee;
  String get refereeDesc;
  String get organization;
  String get organizationDesc;
  String get name;
  String get surname;
  String get city;
  String get birthday;
  String get continueButton;
  String get username;
  String get registerButton;
  String get undo;

  // Tournaments screen
  String get tournaments;
  String get search;
  String get myTournaments;
  String get nameOrCode;
  String get filters;
  String get selectCity;
  String get all;
  String get numberOfTeams;
  String get selectTeamCount;
  String get prizeRange;
  String get feeRange;
  String get reset;
  String get apply;
  String get noTournamentsFavorite;
  String get noTournamentsRunning;
  String get addToFavorites;
  String get comeBackLater;
  String get noTournamentsFound;
  String get tryChangingFilters;
  String get favoriteFeatureComingSoon;
  String get tournamentDetails;

  // Common
  String get comingSoon;
  String get darkMode;
  String get darkModeComingSoon;
  String get appTitle;
  String get selectImageSource;
  String get gallery;
  String get camera;
  String get error;

  // Validation
  String get fillAllFields;
  String get invalidEmail;
  String get invalidPhone;
  String get messageSentSuccess;

  // Teams count (methods with parameters)
  String teamsCount(int paid, int total);
  String teamsTotal(int count);

  // Tournament Status
  String get statusCreated;
  String get statusScheduled;
  String get statusFinished;
  String get statusCanceled;
  String get statusPendingPayments;

  // Tournament Phase
  String get phaseGroupStage;
  String get phaseRoundOf32;
  String get phaseRoundOf16;
  String get phaseRoundOf8;
  String get phaseQuarterFinals;
  String get phaseSemiFinals;
  String get phaseFinal;

  // Tournament Format
  String get formatSingleMatchOnly;
  String get formatHomeAndAwayGroupStage;
  String get formatHomeAndAwayKnockoutStage;
  String get formatFullHomeAndAway;

  // Common strings
  String get usernameOrEmail;
  String get phone;
  String get yourMessage;
  String get contactUsButton;
  String get loading;
  String get dark;
  String get selectBirthday;
  String get unknownAddress;
  String get bookings;
  String get needMore;
  String get lookingForMorePassion;
  String get bookAField;
  String get browseTournaments;
  String get joinLobby;
  String get home;
  String get otherSportsComingSoon;
  String get darkModeComingSoonSnack;
  String get fieldBookedSuccessfully;
  String get bookingCreatedSuccessfully;
  String errorLoadingData(String error);

  // Registration
  String get nameRequired;
  String get surnameRequired;
  String get birthdayRequired;
  String get phoneNumber;
  String get preferredCityOptional;
  String get emailRequired;
  String get usernameRequired;
  String get passwordRequired;
  String get inviteCodeOptional;
  String get registering;
  String get continueText;

  // Forgot password
  String waitSecondsCount(int seconds);

  // Profile screen
  String hiUser(String username);
  String levelLabel(int level);
  String get loadingLevel;
  String get achievement;
  String get achievementsTitle;
  String get achievementsComingSoon;
  String get wallet;
  String get reviews;
  String get licenses;
  String get myGrowth;
  String get orders;
  String get stats;
  String get inviteAFriend;
  String get editInfos;
  String get settings;
  String get contactUsMenuItem;
  String get logout;

  // Book Field Screen
  String get selectBookingType;
  String get privateBooking;
  String get privateBookingDesc;
  String get publicLobby;
  String get publicLobbyDesc;
  String get insertBookingData;
  String get selectCityRequired;
  String get selectDateRequired;
  String get startTimeRequired;
  String get endTimeRequired;
  String get noTimeSlotsAvailable;
  String get lobbyConfiguration;
  String get maxPlayersLabel;
  String get playersPaidByOwner;
  String playersToFind(int count);
  String get selectField;
  String get noFieldsAvailable;
  String fieldForSport(String sport);
  String get total;
  String get perPlayer;
  String get fieldTooLargeWarning;
  String get bookingSummary;
  String get labelType;
  String get labelField;
  String get labelCity;
  String get labelDate;
  String get labelSchedule;
  String get labelTotalPlayers;
  String get labelPlayersPaid;
  String get totalCost;
  String get costPerPlayer;
  String confirmBooking(String amount);
  String get back;
  String get continueStep;
  String errorLoadingCities(String error);
  String get selectBookingTypeFirst;
  String get selectFieldFirst;
  String get selectDateFirst;
  String errorLoadingFields(String error);
  String get userNotFound;

  // Callups screen
  String errorLoadingCallupsData(String error);
  String get atLeastOneCaptain;
  String get errorConfirmingCalups;
  String get callupsTitle;
  String get noPlayersFoundInTeam;
  String selectedCount(int count);
  String minMaxPlayers(int min, int max);
  String get confirmAndParticipate;

  // Join Lobby Screen
  String errorLoadingLobbies(String error);
  String get selectDayFirst;
  String get startTimeLabel;
  String get endTimeLabel;
  String get dayShort;
  String get startShort;
  String get endShort;
  String get players;
  String get join;
  String joinSpotsLeft(int spots);
  String get onlyOneSpotLeft;
  String get howManyPlayersPayingFor;
  String get totalFeeLabel;
  String get clearFilters;
  String get maxPay;
  String get cancelText;
  String get noLobbiesAvailable;

  // Create Team screen
  String get footballTeamsTitle;
  String errorLoadingCitiesShort(String error);
  String errorLoadingImage(String error);
  String get teamCreatedSuccessfully;
  String get teamNameAlreadyInUse;
  String get failedToCreateTeam;
  String errorGeneric(String error);
  String get uploadLogo;
  String get teamName;
  String get teamAlias;
  String get teamDescription;
  String get enterTeamName;
  String teamNameMinChars(int min);
  String get enterTeamAlias;
  String teamAliasExactChars(int count);
  String get selectTeamCity;
  String get createTeamButton;
  String get selectCityHint;
  String get visibilityHint;
  String get public;
  String get private;

  // Pay participation screen
  String get pendingPaymentsTitle;
  String get noPendingPayments;

  // Player requests screen
  String errorLoadingRequests(String error);
  String errorAcceptingRequest(String error);
  String errorRejectingRequest(String error);
  String get allRequestsAccepted;
  String get errorAcceptingAllRequests;
  String get errorRejectingAllRequests;
  String get requestsTitle;
  String get noRequests;
  String get acceptAll;
  String get rejectAll;
  String playerJoinedTeam(String username);

  // View callups screen
  String errorLoadingCallups(String error);
  String get noCallupsFound;

  // Coordinator home screen
  String get selectSport;
  String get today;
  String get tomorrow;
  String get yesterday;
  String get noTournaments;
  String get notCoordinatingAnyTournamentsYet;
  String get noMatchesScheduled;
  String noMatchesOn(String date);

  // Create Tournament screen
  String get createTournamentTitle;
  String get selectSportFirst;
  String get completeTournamentDetails;
  String get selectFieldFirst2;
  String get insertNameAndDescription;
  String errorLoadingFieldsShort(String error);
  String get tournamentCreatedSuccessfully;
  String errorCreatingTournament(String error);
  String get selectSportStep;
  String get chooseSportCategory;
  String get logisticsDetailsTitle;
  String get firstPlacePrize;
  String get secondPlacePrize;
  String get visibilityLabel;
  String get forProfitTournament;
  String get cityHint;
  String get publicTournament;
  String get privateTournament;
  String get startMonthHint;
  String get asSoonAsPossible;
  String get numberOfTeamsLabel;
  String get numberOfGroupsHint;
  String groupsCount(int count);
  String get homeAndAwayHint;
  String get qualifiedTeamsHint;
  String qualifiedTeamsCount(int count);
  String get tournamentNameHint;
  String get tournamentDescHint;
  String get roundFormatSingleMatch;
  String get roundFormatHomeAwayGroups;
  String get roundFormatHomeAwayFinals;
  String get roundFormatFullHomeAway;
  String get noFieldsAvailableForCriteria;
  String get availableFieldsMapTodo;
  String get insertDescriptionTitle;
  String get tournamentSummaryTitle;
  String get totalRevenueLabel;
  String get createTournamentButton;
  String get oversizedFieldDialogTitle;
  String oversizedFieldDialogMessage(int totalPlayers);

  // Guest screens
  String get welcomeToAtl;
  String get chooseYourRole;
  String get amateurTournamentsLeague;
  String get guestHomeDescription;
  String get browseAsGuestHint;
  String get guestUserLabel;
  String get limitedAccessLabel;
  String get loginToAccessAllFeatures;
  String get guestRolePlayerDesc;
  String get guestRolePlayerFeature1;
  String get guestRolePlayerFeature2;
  String get guestRolePlayerFeature3;
  String get guestRoleCoordinatorDesc;
  String get guestRoleCoordinatorFeature1;
  String get guestRoleCoordinatorFeature2;
  String get guestRoleCoordinatorFeature3;
  String get guestRoleRefereeDesc;
  String get guestRoleRefereeFeature1;
  String get guestRoleRefereeFeature2;
  String get guestRoleRefereeFeature3;
  String get guestRoleOrganizationDesc;
  String get guestRoleOrganizationFeature1;
  String get guestRoleOrganizationFeature2;
  String get guestRoleOrganizationFeature3;

  // Organization screens
  String get noFieldsBooked;
  String noBookingsOn(String date);
  String get unknown;

  // Referee screens
  String get licenseDeletedSuccessfully;
  String get failedToDeleteLicense;
  String errorText(String error);
  String get alreadyHasLicenseAllSports;
  String get deleteText;
  String get cannotDeleteLicenseNotVerifiedStatus;
  String get deleteLicenseTitle;
  String confirmDeleteLicense(String licenseName, String licenseId);
  String get licenseGenericName;
  String get noLicensesTitle;
  String get noLicensesSubtitle;
  String get noMatchHistoryTitle;
  String get noMatchHistorySubtitle;

  // Contact us screen
  String get messageSentSuccessfully;
  String errorSendingMessage(String error);
  String get contactUsTitle;
  String get getInTouch;
  String get getInTouchSubtitle;
  String get categoryLabel;
  String get subjectLabel;
  String get enterSubject;
  String get messageLabel;
  String get typeYourMessage;
  String get sendingText;
  String get sendMessage;
  String get faqComingSoon;
  String get checkOurFaq;
  String get generalInquiry;
  String get technicalIssue;
  String get accountProblem;
  String get paymentIssue;
  String get featureRequest;
  String get reportBug;
  String get other;
  String get emailContact;
  String get phoneContact;

  // Edit infos screen
  String get enterCurrentPassword;
  String get enterNewPassword;
  String get newPasswordMinLength;
  String get currentPasswordIncorrect;
  String get profileUpdatedSuccessfully;
  String errorUpdatingProfile(String error);
  String get editProfileTitle;
  String get photoUploadComingSoon;
  String get editableInformation;
  String get usernameLabel;
  String get enterUsername;
  String get phoneLabel;
  String get enterPhone;
  String get preferredCityLabel;
  String get selectCityText;
  String get changePassword;
  String get currentPasswordLabel;
  String get enterCurrentPasswordHint;
  String get newPasswordLabel;
  String get enterNewPasswordHint;
  String get accountDetails;
  String get emailLabel;
  String get nameLabel;
  String get surnameLabel;
  String get birthDateLabel;
  String get roleLabel;
  String get memberSinceLabel;
  String get vipStatusLabel;
  String get active;
  String get inactive;
  String get savingText;
  String get saveChanges;
  String get naFallback;

  // Invite friends screen
  String get codeCopied;
  String get inviteBalance;
  String get earnMoreByInviting;
  String get yourReferralCode;
  String get copyCode;
  String get copyAndShare;
  String get friendsJoined;
  String get redeems;
  String get shareCodeInfo;
  String get inviteAFriendTitle;

  // My growth screen
  String get myGrowthTitle;
  String get noDataAvailable;
  String get growthPath;

  // Orders screen
  String get ordersTitle;
  String get comingSoonText;
  String get ordersComingSoon;

  // Reviews screen
  String failedToLoadReviews(String error);
  String get reviewsTitle;
  String pendingCount(int count);
  String get reviewInfoText;
  String get allCaughtUp;
  String get noPendingReviews;

  // Settings screen
  String get settingsTitle;
  String get notifications;
  String get enableNotifications;
  String get enableNotificationsSubtitle;
  String get settingsSavedSoon;
  String get emailNotifications;
  String get emailNotificationsSubtitle;
  String get pushNotifications;
  String get pushNotificationsSubtitle;
  String get appearance;
  String get darkModeLabel;
  String get darkModeSubtitle;
  String get darkModeComingSoonMsg;
  String get language;
  String get privacySecurity;
  String get privacyPolicy;
  String get privacyPolicySubtitle;
  String get privacyComingSoon;
  String get termsOfService;
  String get termsOfServiceSubtitle;
  String get termsComingSoon;
  String get appPreferences;
  String get autoPlayVideos;
  String get autoPlayVideosSubtitle;
  String get about;
  String get appVersion;
  String get helpAndSupport;
  String get helpAndSupportSubtitle;
  String get helpComingSoon;
  String get rateUs;
  String get rateUsSubtitle;
  String get rateUsComingSoon;
  String get dangerZone;
  String get deleteAccount;
  String get deleteAccountSubtitle;
  String get selectLanguage;
  String get englishLanguage;
  String get italianLanguage;
  String get languageComingSoon;
  String get deleteAccountTitle;
  String get deleteAccountWarning;
  String get enterPasswordToConfirm;
  String get enterYourPassword;
  String get pleaseEnterPassword;
  String get incorrectPassword;
  String get deleteAccountButton;
  String get accountDeletedSuccessfully;
  String get failedToDeleteAccount;

  // Stats screen
  String get vipFeature;
  String get vipFeatureDesc;
  String get vipUpgradeComingSoon;
  String get upgradeToVip;
  String get statsTitle;
  String get vipBadge;
  String get tournamentsPlayed;
  String get privateBookingsCount;
  String get lobbiesJoinedCount;
  String get careerStats;

  // Wallet screen
  String get walletInfoPlayer;
  String get walletInfoCoordinator;
  String get walletInfoReferee;
  String get walletInfoOrganization;
  String get walletInfoFallback;
  String get walletInfo;
  String get ok;
  String get withdrawOptions;
  String get withdrawAll;
  String get withdrawAllComingSoon;
  String get withdrawPersonalBalance;
  String get withdrawPersonalComingSoon;
  String get withdrawPrizeBalance;
  String get withdrawPrizeComingSoon;
  String get walletTitle;
  String get personalBalance;
  String get prizeBalance;
  String get currentBalance;
  String get withdrawComingSoon;
  String get withdraw;
  String get comingSoonText2;
  String get transactionHistory;
  String get noTransactionsTitle;
  String get noTransactionsSubtitle;
  String get possibleNewPaymentsTitle;

  // Shop screen
  String get shopTitle;
  String get shopLabel;
  String get shopComingSoon;
  String get loginToPurchase;
  String get guestLoginRequired;

  // Checkout screen
  String errorLoadingCheckout(String error);
  String get paymentCompletedSuccessfully;
  String get paymentFailed;
  String get orderSummary;
  String get lobbyBookingType;
  String playersDetail(int paid, int total);
  String ownerDetail(String owner);
  String get privateBookingType;
  String get discountCode;
  String get enterDiscountCode;
  String get invalidDiscountCode;
  String get applyButton;
  String get walletSection;
  String get useWalletBalance;
  String get walletOrderInfo;
  String get prizeBalanceLabel;
  String get inviteBalanceLabel;
  String get personalBalanceLabel;
  String get totalAvailable;
  String walletDeduction(String amount);
  String get noWalletBalance;
  String get priceSummary;
  String get subtotal;
  String discount(String code);
  String get walletDeductionLabel;
  String get totalToPay;
  String get checkoutTitle;
  String get confirmFree;
  String payAmount(String amount);
  String discountApplied(String code, String amount);
  String get feeLabel;

  // All tournaments screen
  String errorLoadingTournaments(String error);
  String errorApplyingFilters(String error);
  String get newLabel;
  String get guestModeLoginTournaments;
  String get unknownCity;

  // Coordinator create tournament
  String get coordinatorNotFound;

  // Tournament detail screen
  String errorLoadingTournamentDetails(String error);
  String get fullInfoLabel;
  String get prizesTitle;
  String get locationLabel;
  String get typeLabel;
  String get tba;
  String get atlEventType;
  String get tournamentType;
  String tournamentIdLabel(double id);
  String get startTournamentTitle;
  String get startTournamentConfirm;
  String get startButton;
  String get failedToStartTournament;
  String get tournamentFull;
  String get participatingTeamsTitle;
  String get loadingTeams;
  String get noParticipatingTeams;
  String get loginToManageCallUps;
  String get joinTeamToManageCalups;
  String get viewCallUps;
  String get contactCaptain;
  String get callUpsUpdated;
  String get selectCallUps;
  String get modifyCallUps;
  String get deleteCallUpsTitle;
  String get deleteCallUpsConfirm;
  String get callUpsDeleted;
  String get failedToDeleteCallUps;

  // Football match screen
  String get errorRefereeNotFound;
  String get allRefereeRolesAssigned;
  String get noValidRefereeLicense;
  String get assignmentCreated;
  String get failedToCreateAssignment;
  String get errorCreatingAssignment;
  String get errorFieldNotAvailable;
  String get startMatchTitle;
  String get startMatchConfirm;
  String get halftimeTitle;
  String get halftimeConfirm;
  String get startSecondHalfConfirm;
  String get finishMatchTitle;
  String get finishMatchConfirm;
  String get startPenaltyShootoutTitle;
  String get startPenaltyShootoutConfirm;
  String get matchScheduledSuccessfully;
  String get matchRescheduledSuccessfully;
  String get failedToScheduleFieldUnavailable;
  String get cannotRescheduleWithin24h;
  String get matchDetailsTitle;
  String get eventsTitle;
  String get matchNotFound;
  String get noEventsYet;
  String get bothTeamsTbdMessage;
  String get homeTeamTbdMessage;
  String get awayTeamTbdMessage;
  String get matchStartedEvent;
  String get halftimeEvent;
  String get secondHalfStartedEvent;
  String get fullTimeEvent;
  String get penaltyShootoutEvent;
  String matchIdLabel(int id);
  String get unknownPlayer;
  String matchActionSuccess(String action);
  String failedToMatchAction(String action);
  String get penaltyShootoutStarted;
  String get failedToStartPenalty;
  String get motmAdded;
  String get failedToAddMotm;
  String get onlyCoordinatorCanDelete;
  String get cannotDeleteNotLast;
  String get onlyPlayerEventsCanBeDeleted;
  String get deleteEventTitle;
  String get deleteEventConfirm;
  String get eventDeleted;
  String get failedToDeleteEvent;
  String get selectMotmLabel;
  String get scheduleMatchLabel;
  String get rescheduleMatchLabel;
  String get manageMatchLabel;
  String get startSecondHalf;
  String get endMatch;
  String get addPlayerEventLabel;
  String get insertPenalty;
  String get refereeTheMatch;
  String get penaltyShootoutInfo;
  String get penaltyShootoutAbbrev;
  String get cancelButton;
  String get confirmButton;
  String get closeButton;

  // Football tournament screen
  String errorLoadingDataGeneric(String error);
  String get chatComingSoon;
  String get chatLabel;
  String get fixturesTab;
  String get tablesTab;
  String dayLabel(int day);
  String get roundOf16Label;
  String get quarterFinalsLabel;
  String get semiFinalsLabel;
  String get finalLabel;
  String groupLabel(String group);
  String get teamsTbdAfterGroupStage;
  String winnersOfSemifinals(int semi1, int semi2);
  String winnersOfRoundOf16(int match1, int match2);
  String winnersOfQuarterFinals(int match1, int match2);
  String get noMatchesForPhaseYet;
  String get noStandingsAvailable;
  String get teamLabel;
  String get standingsHeaderAbbrev;
  String get noStatsAvailable;
  String get groupStageTab;
  String get roadToVictoryTab;
  String get goToNextPhaseLabel;
  String get goToFinalStageLabel;
  String get closeTournamentLabel;
  String get goToNextPhaseSuccess;
  String get finalStageStarted;
  String get tournamentClosed;
  String goToNextPhaseError(String error);
  String get assignPrizesLabel;
  String get assignPrizesTitle;
  String errorLoadingAssignPrizes(String error);
  String errorAssigningPrizes(String error);
  String get prizeAssignedSuccess;
  String totalPrizeLabel(String amount);
  String totalAssignedLabel(String amount);
  String remainingPrizeLabel(String amount);
  String get prizeTotalExceeded;
  String percentOfTotal(double percent);
  String get prizeAmountLabel;
  String contributionLabel(String stats);
  String get contributionUnavailable;

  // My team screen
  String get promoteToBViceCaptain;
  String get demote;
  String get expelFromTeam;
  String get maxViceCaptains;
  String promotedToVC(String name);
  String get failedToPromote;
  String demoted(String name);
  String get failedToDemote;
  String get expelPlayerTitle;
  String expelPlayerConfirm(String name);
  String expelled(String name);
  String get failedToExpel;
  String get failedToAcceptRequest;
  String get leaveTeamTitle;
  String get leaveTeamConfirm;
  String get leaveButton;
  String get leaveTeamLabel;
  String get requestsLabel;
  String get expelButton;

  // Team screen
  String get filtersTitle;
  String get allCities;
  String get allTeams;
  String get vipOnly;
  String get nonVip;
  String get applyText;
  String get resetText;
  String get ranksInfo;
  String get nameAlias;
  String get idLabel;
  String get createTeamLabel;
  String errorLoadingTeams(String error);
  String get ranksInfoDescription;
  String get myTeamTab;
  String get ranksTab;
  String get noTeamsAvailable;
  String get noTeamsFound;
  String get guestModeLoginTeams;
  String get numberOfPlayersLabel;
  String playersRangeLabel(int min, int max);

  // Team detail screen
  String errorLoadingTeamData(String error);
  String get errorSendingRequest;
  String get requestSentSuccessfully;
  String errorSendingRequestDetail(String error);
  String get errorCancellingRequest;
  String get requestCancelled;
  String errorCancellingRequestDetail(String error);
  String get cancelRequest;
  String get joinTeam;

  // Abstract team screen
  String get vipUpgradeComingSoonTeam;
  String get vipPalmaresDesc;
  String get actualPlayersToggle;
  String get allPlayersToggle;
  String get noTrophiesYet;
  String get captainCannotLeaveTeam;
  String get errorLeavingTeam;
  String pendingPaymentsCount(int count);
  String get statsTab;
  String get palmaresTab;
  String get teamDetailsTitle;

  // Add referee license dialog
  String get selectSportFirst2;
  String get selectIssueDate;
  String get failedToAddLicense;
  String get addLicenseTitle;
  String get sportLabel;
  String get selectSportHint;
  String get photoLabel;
  String get photoUploadComingSoonMsg;
  String get uploadPhotoComingSoon;
  String get licenseIdLabel;
  String get licenseIdHint;
  String get enterLicenseId;
  String get addButton;

  // Booking widget
  String get chatComingSoonWidget;
  String get fullLobby;
  String youPaidForPlayers(int count);
  String get openChat;
  String get deleteLobbyTitle;
  String get deleteLobbyMessage;
  String get leaveLobbyTitle;
  String get leaveLobbyMessage;
  String get deleteBookingTitle;
  String get deleteBookingMessage;
  String get lobbyDeleted;
  String get lobbyLeft;
  String get bookingDeleted;
  String get failedToDeleteLobby;
  String get failedToLeavelobby;
  String get failedToDeleteBooking;

  // Football MOTM dialog
  String errorLoadingPlayers(String error);
  String get selectMotmTitle;

  // Football stat card
  String get goalsLabel;
  String get motmLabel;
  String get yellowCardsLabel;
  String get redCardsLabel;

  // Growth hero card
  String get levelAbbrev;
  String get refereeRole;
  String get coordinatorRole;

  // Growth pay note
  String get growthPayNote;

  // Growth timeline item
  String get currentBadge;
  String get startingLevel;
  String minGamesRefereed(int count);
  String avgRatingGames(double rating, int games);
  String minTournamentsCoordinated(int count);
  String avgRatingTournaments(double rating, int tournaments);
  String payPerMatch(String amount);

  // Match event dialog
  String get confirmEventTitle;
  String get selectEventType;
  String get selectPlayer;
  String get failedToAddEvent;

  // Match info card
  String get dateLabel;
  String get timeLabel;
  String get fieldLabel;
  String get refereesLabel;

  // Bottom bars
  String get shopNavLabel;
  String get meNavLabel;
  String get tournamentsNavLabel;
  String get teamNavLabel;
  String get matchesNavLabel;
  String get historyNavLabel;

  // Participation card
  String get enterValidAmount;
  String get userNotLoggedIn;
  String get continueParticipation;

  // Review widget
  String get rateAllFieldsMsg;
  String get reviewSubmitted;
  String get reviewSubmittedLabel;
  String get failedToSubmitReview;

  // Search dialog widget
  String get searchByTeamId;
  String get searchByTournamentId;
  String get searchButton;

  // Sport selector widget
  String errorLoadingSports(String error);

  // Tournament summary
  String get feePerTeam;
  String get fieldLabel2;
  String get sportLabel2;
  String get startLabel;
  String get teamsLabel;
  String get groupsLabel;
  String get qualifiedTeamsLabel;
  String get totalMatchesLabel;
  String get homeAndAwayLabel;
  String get descriptionLabel;

  // Referee match dialog
  String get confirmAssignmentTitle;

  // Available matches screen
  String get allFilter;
  String get selectCityToSeeMatchesTitle;
  String get selectCityToSeeMatchesSubtitle;
  String get noMatchesAvailable;
  String get noScheduledMatchesForSelectedFilters;
  String sportWithId(double sportId);
  String noScheduledMatchesInSport(String sportName);

  // Rank teams widget
  String ptsLabel(int pts);

  // Transaction card
  String daysAgo(int days);

  // Tournament card home
  String get participatingInTournamentMsg;

  // Abstract team dialog
  String get pleaseSelectTeamFirst;

  // Players widget
  String get noPlayersFound;
  String get teamDisabledMsg;
  String get captainAbbr;
  String get viceCaptainAbbr;
  String teamAliasAndId(String alias, double id);

  // Abstract football match widget - match statuses
  String get matchStatusLive;
  String get matchStatusHalftime;
  String get matchStatusLive2ndHalf;
  String get matchStatusPenaltyShootout;
  String get matchStatusFullTime;
  String get matchStatusToBeScheduled;
  String get matchStatusRetired;
  String get matchStatusCanceled;
  String matchStatusScheduled(String date, String time);

  // Shared
  String get tbd;
  String get motmWarningMsg;

  // Team widgets
  String captainLabel(String name);
  String get cannotChangeFavMsg;

  // Organization booking
  String get tournamentMatchLabel;
  String get vsLabel;
  String coordinatorPrefix(String name);
  String playerPrefix(String name);

  // Match event dialog
  String get eventGoal;
  String get eventPenalty;
  String get eventMissedPenalty;
  String get eventOwnGoal;
  String get eventYellowCard;
  String get eventRedCard;
  String get eventDoubleYellowCard;
  String get addEventButton;
  String confirmEventMsg(String eventName, String playerName);
  String get noPlayersAvailable;

  // Match info card
  String get matchInformationTitle;
  String get matchNotScheduledYet;
  String get noRefereesAssigned;

  // Schedule match dialog
  String get selectDateButton;
  String get availableTimeSlotsLabel;
  String get noAvailableTimeSlotsForDate;
  String fieldBookedInfo(String from, String to, String date, String kickoff);
  String get failedToLoadTimeData;

  // Search dialog widget
  String get pleaseEnterIdError;
  String get invalidIdFormatError;
  String get teamNotFoundError;
  String get tournamentNotFoundError;
  String errorSearching(String e);
  String get enterTeamIdHint;
  String get enterTournamentIdHint;

  // Road to victory
  String get invalidBracketConfig;
  String roundOf16NumLabel(String group);
  String quarterFinalNumLabel(String group);
  String semifinalNumLabel(String group);

  // Sport selector
  String get noSportsAvailable;
  String sportPlayersMinutesLabel(int min, int max, int minutes);

  // Tournament summary
  String get round2ForAll;
  String get round2GroupStageOnly;
  String get round2FinalStageOnly;
  String get noDescriptionProvided;
  String get firstPlaceLabel;
  String get secondPlaceLabel;
  String get round2Label;
  String monthName(int month);

  // Referee license widget
  String get licenseStatusNotVerified;
  String get licenseStatusSuspended;
  String get licenseStatusRevoked;
  String get licenseIssuedLabel;
  String get licenseSubmittedLabel;
  String get licenseVerifiedLabel;
  String get holdToDeleteHint;

  // Referee match dialog
  String get mainRefereeRole;
  String get assistantRef1Role;
  String get assistantRef2Role;
  String get refereeThisMatchTitle;
  String get selectYourRoleLabel;
  String confirmRefereeMsg(String role);

  // Review widget
  String get reviewingLabel;
  String get impartialityField;
  String get competenceField;
  String get matchManagementField;
  String get organisationField;
  String get communicationField;
  String get availabilityField;
  String get coordinatorToRefereeLabel;
  String get refereeToCoordinatorLabel;
  String get playerToCoordinatorLabel;
  String get commentOptionalLabel;
  String get writeACommentHint;
  String get submittingLabel;
  String get commitReviewButton;

  // Participation card
  String get calledUpLabel;
  String get notCalledUpLabel;
  String get payButton;
  String get howMuchToPayTitle;
  String amountDueLabel(double amount);
  String get amountToPayLabel;

  // Months
  String get january;
  String get february;
  String get march;
  String get april;
  String get may;
  String get june;
  String get july;
  String get august;
  String get september;
  String get october;
  String get november;
  String get december;

  // Search dialog
  String get specifyTeamOrTournament;

  String get tournamentLabel;

  String payOutOf(String paid, String total);

  String get unknownLocation;

  String get eventTypeLabel;

  String get issuedAtLabel;

  String get selectADate;

  String get startDateLabel;

  String get unknownDate;

  String get unknownTime;

  String get transactionStatusConfirmed;

  String get transactionStatusRefunded;
}
