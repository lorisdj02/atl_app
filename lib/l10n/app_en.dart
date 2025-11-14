import 'app_localizations.dart';

/// Localizzazioni in inglese
class AppLocalizationsEn extends AppLocalizations {
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
  String get messageSentSuccess => 'Message sent successfully, we will respond as soon as possible';
  
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
  String get formatHomeAndAwayKnockoutStage => 'Home and away (Knockout Stage only)';
  
  @override
  String get formatFullHomeAndAway => 'Full home and away';
}
