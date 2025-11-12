import 'app_localizations.dart';

/// Localizzazioni in italiano
class AppLocalizationsIt extends AppLocalizations {
  @override
  String get email => 'Email';
  
  @override
  String get password => 'Password';
  
  @override
  String get forgotPassword => 'Hai dimenticato la password?';
  
  @override
  String get logIn => 'Accedi';
  
  @override
  String get register => 'Registrati';
  
  @override
  String get continueAsGuest => 'Continua come ospite';
  
  @override
  String get forgotPasswordTitle => 'Recupero Password';
  
  @override
  String get forgotPasswordSubtitle => 'Inserisci la tua email e controlla la tua casella di posta';
  
  @override
  String get sendEmail => 'Invia email';
  
  @override
  String get cancel => 'Annulla';
  
  @override
  String get waitSeconds => 'Attendi 30s...';
  
  @override
  String get coordinator => 'Coordinatore';
  
  @override
  String get coordinatorDesc => 'Testo per coordinatore';
  
  @override
  String get player => 'Giocatore';
  
  @override
  String get playerDesc => 'Testo per giocatore';
  
  @override
  String get referee => 'Arbitro';
  
  @override
  String get refereeDesc => 'Testo per arbitro';
  
  @override
  String get organization => 'Organizzazione';
  
  @override
  String get organizationDesc => 'Testo per organizzazione';
  
  @override
  String get name => 'Nome';
  
  @override
  String get surname => 'Cognome';
  
  @override
  String get city => 'Città';
  
  @override
  String get birthday => 'Data di nascita';
  
  @override
  String get continueButton => 'Continua';
  
  @override
  String get username => 'Nome utente';
  
  @override
  String get registerButton => 'Registrati';
  
  @override
  String get undo => 'Annulla';
  
  @override
  String get appTitle => 'ATL App';
  
  @override
  String get selectImageSource => 'Seleziona sorgente immagine';
  
  @override
  String get gallery => 'Galleria';
  
  @override
  String get camera => 'Fotocamera';
  
  @override
  String get error => 'Errore';
  
  @override
  String get fillAllFields => 'Compila tutti i campi obbligatori';
  
  @override
  String get invalidEmail => 'Inserisci un\'email valida';
  
  @override
  String get invalidPhone => 'Inserisci un numero di telefono valido';
  
  @override
  String get messageSentSuccess => 'Messaggio inviato correttamente, risponderemo il prima possibile';
  
  // Tournaments screen
  @override
  String get tournaments => 'Tornei';
  
  @override
  String get search => 'Cerca';
  
  @override
  String get myTournaments => 'I miei\ntornei';
  
  @override
  String get nameOrCode => 'Nome/Codice';
  
  @override
  String get filters => 'Filtri';
  
  @override
  String get selectCity => 'Seleziona città';
  
  @override
  String get all => 'Tutti';
  
  @override
  String get numberOfTeams => 'Numero di Squadre';
  
  @override
  String get selectTeamCount => 'Seleziona numero squadre';
  
  @override
  String get prizeRange => 'Range Premio';
  
  @override
  String get feeRange => 'Range Quota';
  
  @override
  String get reset => 'RESET';
  
  @override
  String get apply => 'APPLICA';
  
  @override
  String get noTournamentsFavorite => 'Nessun torneo preferito';
  
  @override
  String get noTournamentsRunning => 'Nessun torneo è in corso.';
  
  @override
  String get addToFavorites => 'Aggiungi tornei ai preferiti!';
  
  @override
  String get comeBackLater => 'Torna più tardi!';
  
  @override
  String get noTournamentsFound => 'Nessun torneo trovato!';
  
  @override
  String get tryChangingFilters => 'Prova a cambiare i filtri';
  
  @override
  String get favoriteFeatureComingSoon => 'Funzione preferiti in arrivo!';
  
  @override
  String get tournamentDetails => 'Dettagli torneo';
  
  @override
  String get comingSoon => 'In arrivo';
  
  @override
  String get darkMode => 'Modalità scura';
  
  @override
  String get darkModeComingSoon => 'Modalità scura - In arrivo';
  
  @override
  String teamsCount(int paid, int total) => '$paid/$total';
  
  @override
  String teamsTotal(int count) => '$count squadre';
  
  // Tournament Status
  @override
  String get statusCreated => 'Creato';
  
  @override
  String get statusScheduled => 'Programmato';
  
  @override
  String get statusFinished => 'Terminato';
  
  @override
  String get statusCanceled => 'Cancellato';
  
  // Tournament Phase
  @override
  String get phaseGroupStage => 'Fase a Gironi';
  
  @override
  String get phaseRoundOf32 => 'Sedicesimi di Finale';
  
  @override
  String get phaseRoundOf16 => 'Ottavi di Finale';
  
  @override
  String get phaseRoundOf8 => 'Quarti di Finale';
  
  @override
  String get phaseQuarterFinals => 'Quarti di Finale';
  
  @override
  String get phaseSemiFinals => 'Semifinali';
  
  @override
  String get phaseFinal => 'Finale';
  
  // Tournament Format
  @override
  String get formatSingleMatchOnly => 'Solo partite secche';
  
  @override
  String get formatHomeAndAwayGroupStage => 'Andata e ritorno (Solo Gironi)';
  
  @override
  String get formatHomeAndAwayKnockoutStage => 'Andata e ritorno (Solo Fasi Finali)';
  
  @override
  String get formatFullHomeAndAway => 'Andata e ritorno (Completo)';
}
