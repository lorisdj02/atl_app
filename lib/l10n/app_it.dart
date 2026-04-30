import 'app_localizations.dart';

/// Localizzazioni in italiano
class AppLocalizationsIt extends AppLocalizations {

  @override
  String get statusPendingPayments => 'Pagamenti in sospeso';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Hai dimenticato la password?';

  @override
  String get logIn => 'Accedi';

  @override
  String get invalidCredentials => 'Credenziali non valide';

  @override
  String get register => 'Registrati';

  @override
  String get continueAsGuest => 'Continua come ospite';

  @override
  String get forgotPasswordTitle => 'Recupero Password';

  @override
  String get forgotPasswordSubtitle =>
      'Inserisci la tua email e controlla la tua casella di posta';

  @override
  String get sendEmail => 'Invia email';

  @override
  String get cancel => 'Annulla';

  @override
  String get notAvailable => 'N/D';

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
  String get messageSentSuccess =>
      'Messaggio inviato correttamente, risponderemo il prima possibile';

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
  String get formatHomeAndAwayKnockoutStage =>
      'Andata e ritorno (Solo Fasi Finali)';

  @override
  String get formatFullHomeAndAway => 'Andata e ritorno (Completo)';

  // Common strings
  @override
  String get usernameOrEmail => 'Nome utente o Email';

  @override
  String get phone => 'Telefono';

  @override
  String get yourMessage => 'Il tuo messaggio';

  @override
  String get contactUsButton => 'Contattaci!';

  @override
  String get loading => 'Caricamento...';

  @override
  String get dark => 'Scuro';

  @override
  String get selectBirthday => 'Seleziona la tua data di nascita.';

  @override
  String get unknownAddress => 'Indirizzo sconosciuto';

  @override
  String get bookings => 'PRENOTAZIONI';

  @override
  String get needMore => 'NE VUOI DI PIÙ?';

  @override
  String get lookingForMorePassion => 'Cerchi più emozioni?';

  @override
  String get bookAField => 'PRENOTA UN CAMPO';

  @override
  String get browseTournaments => 'CERCA TORNEI';

  @override
  String get joinLobby => 'UNISCITI A UNA LOBBY';

  @override
  String get home => 'HOME';

  @override
  String get otherSportsComingSoon =>
      'Altri sport in arrivo! Solo calcio per ora.';

  @override
  String get darkModeComingSoonSnack => 'Modalità scura - In arrivo';

  @override
  String get fieldBookedSuccessfully => 'Campo prenotato con successo!';

  @override
  String get bookingCreatedSuccessfully => 'Prenotazione creata con successo!';

  @override
  String errorLoadingData(String error) => 'Errore nel caricamento dati: $error';

  // Registration
  @override
  String get nameRequired => 'Nome *';

  @override
  String get surnameRequired => 'Cognome *';

  @override
  String get birthdayRequired => 'Data di nascita *';

  @override
  String get phoneNumber => 'Numero di telefono';

  @override
  String get preferredCityOptional => 'Città preferita (opzionale)';

  @override
  String get emailRequired => 'Email *';

  @override
  String get usernameRequired => 'Nome utente *';

  @override
  String get passwordRequired => 'Password *';

  @override
  String get inviteCodeOptional => 'Codice invito (opzionale)';

  @override
  String get registering => 'Registrazione in corso...';

  @override
  String get continueText => 'Continua';

  // Forgot password
  @override
  String waitSecondsCount(int seconds) => 'Attendi ${seconds}s...';

  // Profile screen
  @override
  String hiUser(String username) => 'Ciao $username!';

  @override
  String levelLabel(int level) => 'Livello: $level';

  @override
  String get loadingLevel => 'Caricamento livello...';

  @override
  String get achievement => 'Traguardi';

  @override
  String get achievementsTitle => 'TRAGUARDI';

  @override
  String get achievementsComingSoon =>
      'I tuoi traguardi e il tuo palmares saranno disponibili presto!';

  @override
  String get wallet => 'Portafoglio';

  @override
  String get reviews => 'Recensioni';

  @override
  String get licenses => 'Licenze';

  @override
  String get myGrowth => 'La Mia Crescita';

  @override
  String get orders => 'Ordini';

  @override
  String get stats => 'Statistiche';

  @override
  String get inviteAFriend => 'Invita un amico!';

  @override
  String get editInfos => 'Modifica dati';

  @override
  String get settings => 'Impostazioni';

  @override
  String get contactUsMenuItem => 'Contattaci!';

  @override
  String get logout => 'Esci';

  // Book Field Screen
  @override
  String get selectBookingType => 'Seleziona il tipo di prenotazione';

  @override
  String get privateBooking => 'Prenotazione Privata';

  @override
  String get privateBookingDesc =>
      'Paghi tutto tu, è una prenotazione privata solo per te e i tuoi amici.';

  @override
  String get publicLobby => 'Lobby Pubblica';

  @override
  String get publicLobbyDesc =>
      'Crea una lobby e dividi il costo con altri giocatori...';

  @override
  String get insertBookingData => 'Inserisci i dati della prenotazione';

  @override
  String get selectCityRequired => 'Seleziona città *';

  @override
  String get selectDateRequired => 'Seleziona data *';

  @override
  String get startTimeRequired => 'Ora inizio *';

  @override
  String get endTimeRequired => 'Ora fine *';

  @override
  String get noTimeSlotsAvailable => 'Nessun orario disponibile';

  @override
  String get lobbyConfiguration => 'Configurazione Lobby';

  @override
  String get maxPlayersLabel => 'Numero massimo giocatori';

  @override
  String get playersPaidByOwner => 'Quanti giocatori paghi tu';

  @override
  String playersToFind(int count) => 'Giocatori da trovare: $count';

  @override
  String get selectField => 'Seleziona il campo';

  @override
  String get noFieldsAvailable =>
      'Nessun campo disponibile per questa fascia oraria';

  @override
  String fieldForSport(String sport) => 'Questo campo è per $sport';

  @override
  String get total => 'Totale';

  @override
  String get perPlayer => 'Per giocatore';

  @override
  String get fieldTooLargeWarning =>
      'Campo più grande del necessario - costo maggiore';

  @override
  String get bookingSummary => 'Riepilogo Prenotazione';

  @override
  String get labelType => 'Tipo';

  @override
  String get labelField => 'Campo';

  @override
  String get labelCity => 'Città';

  @override
  String get labelDate => 'Data';

  @override
  String get labelSchedule => 'Orario';

  @override
  String get labelTotalPlayers => 'Giocatori totali';

  @override
  String get labelPlayersPaid => 'Giocatori che paghi';

  @override
  String get totalCost => 'Costo Totale';

  @override
  String get costPerPlayer => 'Costo per Giocatore';

  @override
  String confirmBooking(String amount) =>
      'Conferma Prenotazione - €$amount';

  @override
  String get back => 'Indietro';

  @override
  String get continueStep => 'Continua';

  @override
  String errorLoadingCities(String error) =>
      'Errore nel caricamento delle città: $error';

  @override
  String get selectBookingTypeFirst => 'Seleziona un tipo di prenotazione';

  @override
  String get selectFieldFirst => 'Seleziona un campo';

  @override
  String get selectDateFirst => 'Seleziona prima una data';

  @override
  String errorLoadingFields(String error) =>
      'Errore nel caricamento dei campi: $error';

  @override
  String get userNotFound => 'Utente non trovato';

  // Callups screen
  @override
  String errorLoadingCallupsData(String error) =>
      'Errore nel caricamento dei convocati: $error';

  @override
  String get atLeastOneCaptain =>
      'È necessario selezionare almeno un capitano o vice';

  @override
  String get errorConfirmingCalups => 'Errore nella conferma delle convocazioni';

  @override
  String get callupsTitle => 'Convocazioni';

  @override
  String get noPlayersFoundInTeam => 'Nessun giocatore trovato in questa squadra';

  @override
  String selectedCount(int count) => 'Selezionati: $count';

  @override
  String minMaxPlayers(int min, int max) =>
      'Min $min giocatori, Max $max giocatori';

  @override
  String get confirmAndParticipate => 'Conferma e partecipa';

  // Join Lobby Screen
  @override
  String errorLoadingLobbies(String error) =>
      'Errore nel caricamento delle lobby: $error';

  @override
  String get selectDayFirst => 'Seleziona prima un giorno';

  @override
  String get startTimeLabel => 'Ora inizio';

  @override
  String get endTimeLabel => 'Ora fine';

  @override
  String get dayShort => 'Giorno';

  @override
  String get startShort => 'Inizio';

  @override
  String get endShort => 'Fine';

  @override
  String get players => 'Giocatori';

  @override
  String get join => 'Unisciti';

  @override
  String joinSpotsLeft(int spots) => 'Unisciti ($spots posti liberi)';

  @override
  String get onlyOneSpotLeft => 'C\'è solo 1 posto libero in questa lobby.';

  @override
  String get howManyPlayersPayingFor => 'Per quanti giocatori stai pagando?';

  @override
  String get totalFeeLabel => 'Costo totale:';

  @override
  String get clearFilters => 'Azzera filtri';

  @override
  String get maxPay => 'Max pagamento';

  @override
  String get cancelText => 'Annulla';

  @override
  String get noLobbiesAvailable => 'Nessuna lobby disponibile';

  // Create Team screen
  @override
  String errorLoadingCitiesShort(String error) =>
      'Errore nel caricamento città: $error';

  @override
  String errorLoadingImage(String error) =>
      'Errore nel caricamento immagine: $error';

  @override
  String get teamCreatedSuccessfully => 'Team creato con successo!';

  @override
  String get teamNameAlreadyInUse => 'Nome squadra già in uso';

  @override
  String get failedToCreateTeam => 'Impossibile creare la squadra';

  @override
  String errorGeneric(String error) => 'Errore: $error';

  @override
  String get uploadLogo => 'Carica logo';

  @override
  String get teamName => 'Nome della squadra';

  @override
  String get teamAlias => 'Alias della squadra';

  @override
  String get teamDescription => 'Descrizione squadra (opzionale)';

  @override
  String get enterTeamName => 'Inserisci il nome della squadra';

  @override
  String teamNameMinChars(int min) =>
      'Il nome deve essere di almeno $min caratteri';

  @override
  String get enterTeamAlias => 'Inserisci l\'alias della squadra';

  @override
  String teamAliasExactChars(int count) =>
      'L\'alias deve essere di $count caratteri';

  @override
  String get selectTeamCity => 'Seleziona una città';

  @override
  String get createTeamButton => 'CREA SQUADRA';

  @override
  String get selectCityHint => 'Seleziona città';

  @override
  String get visibilityHint => 'Visibilità (Pubblica/Privata)';

  @override
  String get public => 'Pubblica';

  @override
  String get private => 'Privata';

  // Pay participation screen
  @override
  String get pendingPaymentsTitle => 'Pagamenti in sospeso';

  @override
  String get noPendingPayments => 'Nessun pagamento in sospeso';

  // Player requests screen
  @override
  String errorLoadingRequests(String error) =>
      'Errore nel caricamento richieste: $error';

  @override
  String errorAcceptingRequest(String error) =>
      'Errore nell\'accettazione della richiesta: $error';

  @override
  String errorRejectingRequest(String error) =>
      'Errore nel rifiuto della richiesta: $error';

  @override
  String get allRequestsAccepted => 'Tutte le richieste accettate';

  @override
  String get errorAcceptingAllRequests =>
      'Errore nell\'accettazione di tutte le richieste';

  @override
  String get errorRejectingAllRequests =>
      'Errore nel rifiuto di tutte le richieste';

  @override
  String get requestsTitle => 'Richieste';

  @override
  String get noRequests => 'Nessuna richiesta';

  @override
  String get acceptAll => 'Accetta tutte';

  @override
  String get rejectAll => 'Rifiuta tutte';

  @override
  String playerJoinedTeam(String username) =>
      '$username è entrato nella squadra';

  // View callups screen
  @override
  String errorLoadingCallups(String error) =>
      'Errore nel caricamento delle convocazioni: $error';

  @override
  String get noCallupsFound => 'Nessuna convocazione trovata';

  // Coordinator home screen
  @override
  String get selectSport => 'Seleziona Sport';

  @override
  String get today => 'Oggi';

  @override
  String get tomorrow => 'Domani';

  @override
  String get yesterday => 'Ieri';

  @override
  String get noTournaments => 'Nessun torneo';

  @override
  String get notCoordinatingAnyTournamentsYet =>
      'Non stai ancora coordinando nessun torneo';

  @override
  String get noMatchesScheduled => 'Nessuna partita in programma';

  @override
  String noMatchesOn(String date) => 'Nessuna partita il $date';

  // Create Tournament screen
  @override
  String get createTournamentTitle => 'Crea Torneo';

  @override
  String get selectSportFirst => 'Seleziona uno sport per continuare';

  @override
  String get completeTournamentDetails =>
      'Completa tutti i dettagli del torneo';

  @override
  String get selectFieldFirst2 => 'Seleziona un campo per continuare';

  @override
  String get insertNameAndDescription =>
      'Inserisci nome e descrizione del torneo';

  @override
  String errorLoadingFieldsShort(String error) =>
      'Errore nel caricamento dei campi: $error';

  @override
  String get tournamentCreatedSuccessfully => 'Torneo creato con successo!';

  @override
  String errorCreatingTournament(String error) =>
      'Errore nella creazione del torneo: $error';

  @override
  String get selectSportStep => 'Seleziona lo sport';

  @override
  String get chooseSportCategory =>
      'Scegli la categoria sportiva per il tuo torneo';

  @override
  String get logisticsDetailsTitle => 'Dettagli logistici';

  @override
  String get firstPlacePrize => 'Premio 1° posto';

  @override
  String get secondPlacePrize => 'Premio 2° posto';

  @override
  String get visibilityLabel => 'Visibilità';

  @override
  String get forProfitTournament => 'Torneo a scopo di lucro';

  @override
  String get cityHint => 'Città';

  @override
  String get publicTournament => 'Pubblico';

  @override
  String get privateTournament => 'Privato';

  @override
  String get startMonthHint => 'Data inizio (mese)';

  @override
  String get asSoonAsPossible => 'Appena possibile';

  @override
  String get numberOfTeamsLabel => 'Numero di squadre';

  @override
  String get numberOfGroupsHint => 'Numero di gironi';

  @override
  String groupsCount(int count) => '$count gironi';

  @override
  String get homeAndAwayHint => 'Andata e ritorno';

  @override
  String get qualifiedTeamsHint => 'Squadre qualificate';

  @override
  String qualifiedTeamsCount(int count) => '$count squadre qualificate';

  @override
  String get tournamentNameHint => 'Nome del torneo';

  @override
  String get tournamentDescHint =>
      'Inserisci le regole e i dettagli del torneo...';

  @override
  String get roundFormatSingleMatch => 'Solo andata';

  @override
  String get roundFormatHomeAwayGroups => 'A/R solo ai gironi';

  @override
  String get roundFormatHomeAwayFinals => 'A/R solo nella fase finale';

  @override
  String get roundFormatFullHomeAway => 'A/R per tutto il torneo';

  @override
  String get noFieldsAvailableForCriteria =>
      'Nessun campo disponibile per i criteri selezionati';

  @override
  String get availableFieldsMapTodo => 'TODO: Mappa dei campi disponibili';

  @override
  String get insertDescriptionTitle => 'Inserisci descrizione';

  @override
  String get tournamentSummaryTitle => 'Riepilogo torneo';

  @override
  String get totalRevenueLabel => 'Ricavo totale';

  @override
  String get createTournamentButton => 'CREA +';

  @override
  String get oversizedFieldDialogTitle => 'Campo sovradimensionato';

  @override
  String oversizedFieldDialogMessage(int totalPlayers) =>
      'Il campo è pensato per più giocatori ($totalPlayers totali). '
      'Questo potrebbe significare una differente esperienza di gioco '
      'e una fee per squadra maggiore. Vuoi continuare?';

  // Guest screens
  @override
  String get welcomeToAtl => 'BENVENUTO IN ATL';

  @override
  String get chooseYourRole => 'SCEGLI IL TUO RUOLO';

  @override
  String get amateurTournamentsLeague => 'Lega Tornei Amatoriali';

  @override
  String get guestHomeDescription =>
      'La piattaforma per lo sport amatoriale. Trova partite, unisciti ai tornei, '
      'prenota campi e fai crescere la tua carriera sportiva: tutto in un unico posto.';

  @override
  String get browseAsGuestHint =>
      'Naviga come ospite: registrati per sbloccare tutte le funzionalità';

  @override
  String get guestUserLabel => 'Utente ospite';

  @override
  String get limitedAccessLabel => 'Accesso limitato';

  @override
  String get loginToAccessAllFeatures =>
      'Accedi per usare tutte le funzionalità';

  @override
  String get guestRolePlayerDesc =>
      'Gioca, cresci e connettiti con i tuoi compagni di squadra.';

  @override
  String get guestRolePlayerFeature1 =>
      'Prenota campi nelle tue strutture preferite';

  @override
  String get guestRolePlayerFeature2 => 'Unisciti o crea squadre amatoriali';

  @override
  String get guestRolePlayerFeature3 => 'Partecipa a tornei con ranking';

  @override
  String get guestRoleCoordinatorDesc =>
      'Organizza e gestisci tornei end-to-end.';

  @override
  String get guestRoleCoordinatorFeature1 => 'Crea e gestisci tornei';

  @override
  String get guestRoleCoordinatorFeature2 => 'Pianifica partite e tabelloni';

  @override
  String get guestRoleCoordinatorFeature3 => 'Coordina squadre e strutture';

  @override
  String get guestRoleRefereeDesc =>
      'Arbitra le partite e traccia la tua carriera.';

  @override
  String get guestRoleRefereeFeature1 => 'Ricevi assegnazioni per arbitrare';

  @override
  String get guestRoleRefereeFeature2 =>
      'Registra eventi della partita in tempo reale';

  @override
  String get guestRoleRefereeFeature3 => 'Tieni traccia di guadagni e calendario';

  @override
  String get guestRoleOrganizationDesc =>
      'Gestisci il tuo club, le strutture e gli eventi.';

  @override
  String get guestRoleOrganizationFeature1 => 'Elenca e gestisci i tuoi campi';

  @override
  String get guestRoleOrganizationFeature2 => 'Gestisci iscrizioni e eventi';

  @override
  String get guestRoleOrganizationFeature3 =>
      'Supervisiona tutte le attività del club';

  // Organization screens
  @override
  String get noFieldsBooked => 'Nessun campo prenotato';

  @override
  String noBookingsOn(String date) => 'Nessuna prenotazione il $date';

  @override
  String get unknown => 'Sconosciuto';

  // Referee screens
  @override
  String get licenseDeletedSuccessfully => 'Licenza eliminata con successo.';

  @override
  String get failedToDeleteLicense =>
      'Impossibile eliminare la licenza. Riprova.';

  @override
  String errorText(String error) => 'Errore: $error';

  @override
  String get alreadyHasLicenseAllSports =>
      'Hai già una licenza per tutti gli sport disponibili.';

  @override
  String get deleteText => 'Elimina';

  @override
  String get cannotDeleteLicenseNotVerifiedStatus =>
      "Non puoi eliminare una licenza che non e' nello stato 'Not Verified'.";

  @override
  String get deleteLicenseTitle => 'Elimina licenza';

  @override
  String confirmDeleteLicense(String licenseName, String licenseId) =>
      'Sei sicuro di voler eliminare la licenza $licenseName (ID: $licenseId)?\nQuesta azione non puo\' essere annullata.';

  @override
  String get licenseGenericName => 'licenza';

  @override
  String get noLicensesTitle => 'Nessuna licenza';

  @override
  String get noLicensesSubtitle =>
      'Tocca il pulsante + per aggiungere la tua prima licenza.';

  @override
  String get noMatchHistoryTitle => 'Nessuna cronologia partite';

  @override
  String get noMatchHistorySubtitle =>
      'Non ti e\' stata ancora assegnata alcuna partita';

  // Contact us screen
  @override
  String get messageSentSuccessfully =>
      'Messaggio inviato con successo! Ti risponderemo al più presto.';

  @override
  String errorSendingMessage(String error) =>
      'Errore nell\'invio del messaggio: $error';

  @override
  String get contactUsTitle => 'CONTATTACI';

  @override
  String get getInTouch => 'Contattaci';

  @override
  String get getInTouchSubtitle =>
      'Siamo qui per aiutarti. Mandaci un messaggio...';

  @override
  String get categoryLabel => 'Categoria';

  @override
  String get subjectLabel => 'Oggetto';

  @override
  String get enterSubject => 'Inserisci oggetto';

  @override
  String get messageLabel => 'Messaggio';

  @override
  String get typeYourMessage => 'Scrivi qui il tuo messaggio...';

  @override
  String get sendingText => 'Invio...';

  @override
  String get sendMessage => 'Invia Messaggio';

  @override
  String get faqComingSoon => 'FAQ in arrivo';

  @override
  String get checkOurFaq => 'Consulta le FAQ';

  @override
  String get generalInquiry => 'Domanda generale';

  @override
  String get technicalIssue => 'Problema tecnico';

  @override
  String get accountProblem => 'Problema account';

  @override
  String get paymentIssue => 'Problema pagamento';

  @override
  String get featureRequest => 'Richiesta funzione';

  @override
  String get reportBug => 'Segnala bug';

  @override
  String get other => 'Altro';

  @override
  String get emailContact => 'Email';

  @override
  String get phoneContact => 'Telefono';

  // Edit infos screen
  @override
  String get enterCurrentPassword => 'Inserisci la password attuale';

  @override
  String get enterNewPassword => 'Inserisci una nuova password';

  @override
  String get newPasswordMinLength =>
      'La nuova password deve avere almeno 6 caratteri';

  @override
  String get currentPasswordIncorrect => 'La password attuale non è corretta';

  @override
  String get profileUpdatedSuccessfully => 'Profilo aggiornato con successo';

  @override
  String errorUpdatingProfile(String error) =>
      'Errore nell\'aggiornamento del profilo: $error';

  @override
  String get editProfileTitle => 'MODIFICA PROFILO';

  @override
  String get photoUploadComingSoon => 'Caricamento foto in arrivo';

  @override
  String get editableInformation => 'Informazioni modificabili';

  @override
  String get usernameLabel => 'Nome utente';

  @override
  String get enterUsername => 'Inserisci nome utente';

  @override
  String get phoneLabel => 'Telefono';

  @override
  String get enterPhone => 'Inserisci numero di telefono';

  @override
  String get preferredCityLabel => 'Città preferita';

  @override
  String get selectCityText => 'Seleziona città';

  @override
  String get changePassword => 'Cambia Password';

  @override
  String get currentPasswordLabel => 'Password attuale';

  @override
  String get enterCurrentPasswordHint => 'Inserisci password attuale';

  @override
  String get newPasswordLabel => 'Nuova Password';

  @override
  String get enterNewPasswordHint =>
      'Inserisci nuova password (min 6 caratteri)';

  @override
  String get accountDetails => 'Dettagli account';

  @override
  String get emailLabel => 'Email';

  @override
  String get nameLabel => 'Nome';

  @override
  String get surnameLabel => 'Cognome';

  @override
  String get birthDateLabel => 'Data di nascita';

  @override
  String get roleLabel => 'Ruolo';

  @override
  String get memberSinceLabel => 'Membro da';

  @override
  String get vipStatusLabel => 'Stato VIP';

  @override
  String get active => 'Attivo';

  @override
  String get inactive => 'Non attivo';

  @override
  String get savingText => 'Salvataggio...';

  @override
  String get saveChanges => 'Salva Modifiche';

  @override
  String get naFallback => 'N/D';

  // Invite friends screen
  @override
  String get codeCopied => 'Codice copiato negli appunti!';

  @override
  String get inviteBalance => 'Saldo inviti';

  @override
  String get earnMoreByInviting => 'Guadagna di più invitando amici!';

  @override
  String get yourReferralCode => 'Il tuo codice referral';

  @override
  String get copyCode => 'Copia codice';

  @override
  String get copyAndShare => 'Copia e Condividi';

  @override
  String get friendsJoined => 'Amici iscritti';

  @override
  String get redeems => 'Riscatti';

  @override
  String get shareCodeInfo =>
      'Condividi il tuo codice con gli amici. Quando si iscrivono...';

  @override
  String get inviteAFriendTitle => 'INVITA UN AMICO';

  // My growth screen
  @override
  String get myGrowthTitle => 'LA MIA CRESCITA';

  @override
  String get noDataAvailable => 'Nessun dato disponibile';

  @override
  String get growthPath => 'PERCORSO DI CRESCITA';

  // Orders screen
  @override
  String get ordersTitle => 'ORDINI';

  @override
  String get comingSoonText => 'In arrivo';

  @override
  String get ordersComingSoon =>
      'I tuoi ordini saranno disponibili presto!';

  // Reviews screen
  @override
  String failedToLoadReviews(String error) =>
      'Impossibile caricare le recensioni: $error';

  @override
  String get reviewsTitle => 'RECENSIONI';

  @override
  String pendingCount(int count) => '$count in attesa';

  @override
  String get reviewInfoText =>
      'Recensendo, migliori l\'esperienza per tutti! Scegli con cura!...';

  @override
  String get allCaughtUp => 'Tutto aggiornato!';

  @override
  String get noPendingReviews => 'Nessuna recensione in attesa.';

  // Settings screen
  @override
  String get settingsTitle => 'IMPOSTAZIONI';

  @override
  String get notifications => 'Notifiche';

  @override
  String get enableNotifications => 'Abilita notifiche';

  @override
  String get enableNotificationsSubtitle =>
      'Ricevi notifiche su partite e tornei';

  @override
  String get settingsSavedSoon => 'Le impostazioni verranno salvate presto';

  @override
  String get emailNotifications => 'Notifiche email';

  @override
  String get emailNotificationsSubtitle => 'Ricevi notifiche via email';

  @override
  String get pushNotifications => 'Notifiche push';

  @override
  String get pushNotificationsSubtitle =>
      'Ricevi notifiche push sul tuo dispositivo';

  @override
  String get appearance => 'Aspetto';

  @override
  String get darkModeLabel => 'Modalità scura';

  @override
  String get darkModeSubtitle => 'Usa il tema scuro';

  @override
  String get darkModeComingSoonMsg => 'Modalità scura in arrivo';

  @override
  String get language => 'Lingua';

  @override
  String get privacySecurity => 'Privacy e Sicurezza';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get privacyPolicySubtitle => 'Leggi la nostra informativa sulla privacy';

  @override
  String get privacyComingSoon => 'Informativa sulla privacy in arrivo';

  @override
  String get termsOfService => 'Termini di servizio';

  @override
  String get termsOfServiceSubtitle => 'Leggi i nostri termini di servizio';

  @override
  String get termsComingSoon => 'Termini di servizio in arrivo';

  @override
  String get appPreferences => 'Preferenze app';

  @override
  String get autoPlayVideos => 'Riproduzione automatica video';

  @override
  String get autoPlayVideosSubtitle =>
      'Riproduci automaticamente i video nel feed';

  @override
  String get about => 'Info';

  @override
  String get appVersion => 'Versione app';

  @override
  String get helpAndSupport => 'Aiuto e supporto';

  @override
  String get helpAndSupportSubtitle => 'Ottieni aiuto con l\'app';

  @override
  String get helpComingSoon => 'Aiuto e supporto in arrivo';

  @override
  String get rateUs => 'Valutaci';

  @override
  String get rateUsSubtitle => 'Valutaci sull\'app store';

  @override
  String get rateUsComingSoon => 'Valutazione in arrivo';

  @override
  String get dangerZone => 'Zona pericolosa';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountSubtitle => 'Elimina definitivamente il tuo account';

  @override
  String get selectLanguage => 'Seleziona lingua';

  @override
  String get englishLanguage => 'Inglese';

  @override
  String get italianLanguage => 'Italiano';

  @override
  String get languageComingSoon => 'Supporto lingua in arrivo';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String get deleteAccountWarning =>
      'Questa azione non può essere annullata. Tutti i tuoi dati verranno eliminati definitivamente.';

  @override
  String get enterPasswordToConfirm =>
      'Inserisci la password per confermare:';

  @override
  String get enterYourPassword => 'Inserisci la tua password';

  @override
  String get pleaseEnterPassword => 'Inserisci la password';

  @override
  String get incorrectPassword => 'Password non corretta';

  @override
  String get deleteAccountButton => 'Elimina account';

  @override
  String get accountDeletedSuccessfully => 'Account eliminato con successo';

  @override
  String get failedToDeleteAccount =>
      'Impossibile eliminare l\'account. Verifica che le tue squadre abbiano dei Vice Capitani assegnati.';

  // Stats screen
  @override
  String get vipFeature => 'Funzione VIP';

  @override
  String get vipFeatureDesc =>
      'Questa funzione è disponibile solo per i membri VIP. Aggiorna a VIP per accedere a statistiche dettagliate.';

  @override
  String get vipUpgradeComingSoon => 'Aggiornamento VIP in arrivo';

  @override
  String get upgradeToVip => 'Aggiorna a VIP';

  @override
  String get statsTitle => 'STATISTICHE';

  @override
  String get vipBadge => 'VIP';

  @override
  String get tournamentsPlayed => 'Tornei giocati';

  @override
  String get careerStats => 'Statistiche carriera';

  // Wallet screen
  @override
  String get walletInfoPlayer =>
      'Il saldo personale contiene rimborsi, prelevabile una volta a settimana senza commissioni...';

  @override
  String get walletInfoCoordinator =>
      'Il saldo contiene rimborsi e guadagni per ogni torneo...';

  @override
  String get walletInfoReferee =>
      'Il saldo contiene rimborsi e guadagni per ogni partita arbitrata...';

  @override
  String get walletInfoOrganization =>
      'Il saldo contiene rimborsi e guadagni per ogni prenotazione effettuata...';

  @override
  String get walletInfoFallback => 'Nessuna informazione portafoglio disponibile.';

  @override
  String get walletInfo => 'Info portafoglio';

  @override
  String get ok => 'OK';

  @override
  String get withdrawOptions => 'Opzioni prelievo';

  @override
  String get withdrawAll => 'Preleva TUTTO';

  @override
  String get withdrawAllComingSoon => 'Prelievo TUTTO in arrivo';

  @override
  String get withdrawPersonalBalance => 'Preleva solo saldo personale';

  @override
  String get withdrawPersonalComingSoon =>
      'Prelievo saldo personale in arrivo';

  @override
  String get withdrawPrizeBalance => 'Preleva solo saldo premi';

  @override
  String get withdrawPrizeComingSoon => 'Prelievo saldo premi in arrivo';

  @override
  String get walletTitle => 'PORTAFOGLIO';

  @override
  String get personalBalance => 'Saldo Personale';

  @override
  String get prizeBalance => 'Saldo Premi';

  @override
  String get currentBalance => 'Saldo Attuale';

  @override
  String get withdrawComingSoon => 'Prelievo in arrivo';

  @override
  String get withdraw => 'Preleva';

  @override
  String get comingSoonText2 => 'In arrivo';

  @override
  String get transactionHistory =>
      'La cronologia delle transazioni sarà disponibile presto!';

  // Shop screen
  @override
  String get shopTitle => 'NEGOZIO';

  @override
  String get shopLabel => 'Negozio';

  @override
  String get shopComingSoon => 'In arrivo';

  @override
  String get loginToPurchase => 'Accedi per acquistare';

  @override
  String get guestLoginRequired =>
      'Modalità ospite: accedi per acquistare';

  // Checkout screen
  @override
  String errorLoadingCheckout(String error) =>
      'Errore nel caricamento del checkout: $error';

  @override
  String get paymentCompletedSuccessfully =>
      'Pagamento completato con successo!';

  @override
  String get paymentFailed => 'Pagamento fallito. Riprova.';

  @override
  String get orderSummary => 'Riepilogo ordine';

  @override
  String get lobbyBookingType => 'Prenotazione Lobby';

  @override
  String playersDetail(int paid, int total) =>
      'Giocatori: $paid pagati / $total totali';

  @override
  String ownerDetail(String owner) => 'Proprietario: $owner';

  @override
  String get privateBookingType => 'Prenotazione Privata';

  @override
  String get discountCode => 'Codice sconto';

  @override
  String get enterDiscountCode => 'Inserisci codice sconto';

  @override
  String get invalidDiscountCode => 'Codice sconto non valido.';

  @override
  String get applyButton => 'Applica';

  @override
  String get walletSection => 'Portafoglio';

  @override
  String get useWalletBalance => 'Usa saldo portafoglio';

  @override
  String get walletOrderInfo =>
      'I portafogli vengono applicati nell\'ordine: Premi → Inviti → Personale.';

  @override
  String get prizeBalanceLabel => 'Saldo premi';

  @override
  String get inviteBalanceLabel => 'Saldo inviti';

  @override
  String get personalBalanceLabel => 'Saldo personale';

  @override
  String get totalAvailable => 'Totale disponibile';

  @override
  String walletDeduction(String amount) =>
      '€$amount verrà detratto dal tuo portafoglio.';

  @override
  String get noWalletBalance => 'Nessun saldo disponibile.';

  @override
  String get priceSummary => 'Riepilogo prezzi';

  @override
  String get subtotal => 'Subtotale';

  @override
  String discount(String code) => 'Sconto ($code)';

  @override
  String get walletDeductionLabel => 'Detrazione portafoglio';

  @override
  String get totalToPay => 'Totale da pagare';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get confirmFree => 'Conferma (Gratis)';

  @override
  String payAmount(String amount) => 'Paga $amount';

  @override
  String discountApplied(String code, String amount) =>
      'Codice "$code" applicato – $amount';

  @override
  String get feeLabel => 'Quota';

  // All tournaments screen
  @override
  String errorLoadingTournaments(String error) =>
      'Errore nel caricamento dei tornei: $error';

  @override
  String errorApplyingFilters(String error) =>
      'Errore nell\'applicazione dei filtri: $error';

  @override
  String get newLabel => 'Nuovo';

  @override
  String get guestModeLoginTournaments =>
      'Modalità ospite: Accedi per interagire con i tornei';

  @override
  String get unknownCity => 'Città sconosciuta';

  // Coordinator create tournament
  @override
  String get coordinatorNotFound => 'Coordinatore non trovato';

  // Tournament detail screen
  @override
  String errorLoadingTournamentDetails(String error) =>
      'Errore nel caricamento dei dettagli del torneo: $error';

  @override
  String get fullInfoLabel => 'Info complete';

  @override
  String get prizesTitle => 'Premi';

  @override
  String get locationLabel => 'Luogo';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get tba => 'Da definire';

  @override
  String get atlEventType => 'Evento ATL';

  @override
  String get tournamentType => 'Torneo';

  @override
  String tournamentIdLabel(double id) => 'ID torneo: #$id';

  @override
  String get startTournamentTitle => 'Inizia Torneo';

  @override
  String get startTournamentConfirm =>
      'Vuoi davvero iniziare questo torneo? Questa azione non può essere annullata.';

  @override
  String get startButton => 'Inizia';

  @override
  String get failedToStartTournament =>
      'Impossibile avviare il torneo. Riprova.';

  @override
  String get tournamentFull => 'Torneo Completo';

  @override
  String get participatingTeamsTitle => 'Squadre partecipanti';

  @override
  String get loadingTeams => 'Caricamento squadre...';

  @override
  String get noParticipatingTeams => 'Nessuna squadra partecipante';

  @override
  String get loginToManageCallUps => 'Accedi per gestire le convocazioni';

  @override
  String get joinTeamToManageCalups =>
      'Unisciti a una squadra per gestire le convocazioni';

  @override
  String get viewCallUps => 'VEDI CONVOCAZIONI';

  @override
  String get contactCaptain =>
      'Contatta il capitano o i vice-capitani della tua squadra per gestire le convocazioni';

  @override
  String get callUpsUpdated => 'Convocazioni aggiornate con successo';

  @override
  String get selectCallUps => 'SELEZIONA CONVOCAZIONI';

  @override
  String get modifyCallUps => 'MODIFICA CONVOCAZIONI';

  @override
  String get deleteCallUpsTitle => 'Elimina Convocazioni';

  @override
  String get deleteCallUpsConfirm =>
      'Vuoi eliminare tutte le convocazioni per questo torneo?';

  @override
  String get callUpsDeleted => 'Convocazioni eliminate con successo';

  @override
  String get failedToDeleteCallUps =>
      'Impossibile eliminare le convocazioni';

  // Football match screen
  @override
  String get errorRefereeNotFound => 'Errore: ID arbitro non trovato';

  @override
  String get allRefereeRolesAssigned =>
      'Tutti i ruoli arbitro per questa partita sono già stati assegnati';

  @override
  String get noValidRefereeLicense =>
      'Non hai una licenza arbitrale valida per questo sport';

  @override
  String get assignmentCreated => 'Assegnazione creata con successo';

  @override
  String get failedToCreateAssignment => 'Impossibile creare l\'assegnazione';

  @override
  String get errorCreatingAssignment =>
      'Errore nella creazione dell\'assegnazione';

  @override
  String get errorFieldNotAvailable =>
      'Errore: informazioni campo non disponibili';

  @override
  String get startMatchTitle => 'Inizia Partita';

  @override
  String get startMatchConfirm => 'Vuoi davvero iniziare la partita?';

  @override
  String get halftimeTitle => 'Vai all\'Intervallo';

  @override
  String get halftimeConfirm => 'Vuoi davvero terminare il primo tempo?';

  @override
  String get startSecondHalfConfirm =>
      'Vuoi davvero iniziare il secondo tempo?';

  @override
  String get finishMatchTitle => 'Termina Partita';

  @override
  String get finishMatchConfirm =>
      'Vuoi davvero terminare la partita? Questa azione non può essere annullata.';

  @override
  String get startPenaltyShootoutTitle => 'Inizia Calci di Rigore';

  @override
  String get startPenaltyShootoutConfirm =>
      'Vuoi davvero iniziare i calci di rigore?';

  @override
  String get matchScheduledSuccessfully => 'Partita programmata con successo';

  @override
  String get matchRescheduledSuccessfully => 'Partita riprogrammata con successo';

  @override
  String get failedToScheduleFieldUnavailable =>
      'Impossibile programmare la partita. Il campo potrebbe non essere disponibile.';

  @override
  String get cannotRescheduleWithin24h =>
      'Non puoi riprogrammare la partita entro 24 ore dall\'inizio';

  @override
  String get matchDetailsTitle => 'Dettagli Partita';

  @override
  String get eventsTitle => 'Eventi';

  @override
  String get matchNotFound => 'Partita non trovata';

  @override
  String get noEventsYet => 'Nessun evento ancora';

  @override
  String get bothTeamsTbdMessage =>
      'Entrambe le squadre devono essere determinate dai risultati della fase precedente. Continua a giocare!';

  @override
  String get homeTeamTbdMessage =>
      'La squadra di casa deve essere determinata dai risultati della fase precedente. Continua a giocare!';

  @override
  String get awayTeamTbdMessage =>
      'La squadra ospite deve essere determinata dai risultati della fase precedente. Continua a giocare!';

  @override
  String get matchStartedEvent => 'Partita iniziata';

  @override
  String get halftimeEvent => 'Intervallo';

  @override
  String get secondHalfStartedEvent => 'Secondo tempo iniziato';

  @override
  String get fullTimeEvent => 'Fine partita';

  @override
  String get penaltyShootoutEvent => 'Calci di rigore';

  @override
  String matchIdLabel(double id) => 'ID partita: #$id';

  @override
  String get unknownPlayer => 'Giocatore sconosciuto';

  @override
  String matchActionSuccess(String action) => 'Partita $action con successo';

  @override
  String failedToMatchAction(String action) =>
      'Impossibile $action la partita';

  @override
  String get penaltyShootoutStarted => 'Calci di rigore iniziati';

  @override
  String get failedToStartPenalty =>
      'Impossibile iniziare i calci di rigore';

  @override
  String get motmAdded => 'MDC aggiunto con successo';

  @override
  String get failedToAddMotm => 'Impossibile aggiungere MDC';

  @override
  String get onlyCoordinatorCanDelete =>
      'Solo il coordinatore del torneo può eliminare gli eventi';

  @override
  String get cannotDeleteNotLast =>
      'Impossibile eliminare l\'evento se non è l\'ultimo';

  @override
  String get onlyPlayerEventsCanBeDeleted =>
      'Puoi eliminare solo gli eventi dei giocatori';

  @override
  String get deleteEventTitle => 'Elimina Evento';

  @override
  String get deleteEventConfirm => 'Vuoi eliminare questo evento?';

  @override
  String get eventDeleted => 'Evento eliminato con successo';

  @override
  String get failedToDeleteEvent => 'Impossibile eliminare l\'evento';

  @override
  String get selectMotmLabel => 'Seleziona MDC';

  @override
  String get scheduleMatchLabel => 'Programma Partita';

  @override
  String get rescheduleMatchLabel => 'Riprogramma Partita';

  @override
  String get manageMatchLabel => 'Gestisci Partita';

  @override
  String get startSecondHalf => 'Inizia Secondo Tempo';

  @override
  String get endMatch => 'Termina Partita';

  @override
  String get addPlayerEventLabel => 'Aggiungi Evento Giocatore';

  @override
  String get insertPenalty => 'Inserisci Rigore';

  @override
  String get refereeTheMatch => 'Arbitra la Partita';

  @override
  String get cancelButton => 'ANNULLA';

  @override
  String get confirmButton => 'CONFERMA';

  // Football tournament screen
  @override
  String errorLoadingDataGeneric(String error) =>
      'Errore nel caricamento dati: $error';

  @override
  String get chatComingSoon => 'Chat in arrivo';

  @override
  String get chatLabel => 'Chat';

  @override
  String get fixturesTab => 'Partite';

  @override
  String get tablesTab => 'Classifiche';

  @override
  String dayLabel(int day) => 'Giornata $day';

  @override
  String get roundOf16Label => 'Ottavi di Finale';

  @override
  String get quarterFinalsLabel => 'Quarti di Finale';

  @override
  String get semiFinalsLabel => 'Semifinali';

  @override
  String get finalLabel => 'Finale';

  @override
  String groupLabel(String group) => 'GIRONE $group';

  @override
  String get teamsTbdAfterGroupStage =>
      'Le squadre saranno determinate al termine della fase a gironi';

  @override
  String winnersOfSemifinals(int semi1, int semi2) =>
      'Vincitori della Semifinale $semi1 e della Semifinale $semi2';

  @override
  String winnersOfRoundOf16(int match1, int match2) =>
      'Vincitori dell\'Ottavo di Finale #$match1 e dell\'Ottavo di Finale #$match2';

  @override
  String winnersOfQuarterFinals(int match1, int match2) =>
      'Vincitori del Quarto di Finale $match1 e del Quarto di Finale $match2';

  @override
  String get noMatchesForPhaseYet => 'Nessuna partita per questa fase';

  @override
  String get noStandingsAvailable => 'Nessuna classifica disponibile';

  @override
  String get teamLabel => 'Squadra';

  @override
  String get standingsHeaderAbbrev => 'Pts - V - N - P - DR';

  @override
  String get noStatsAvailable =>
      'Nessuna statistica disponibile. Continua a giocare!';

  @override
  String get groupStageTab => 'Fase a Gironi';

  @override
  String get roadToVictoryTab => 'Strada alla Vittoria';

  // My team screen
  @override
  String get promoteToBViceCaptain => 'Promuovi a Vice Capitano';

  @override
  String get demote => 'Retrocedi';

  @override
  String get expelFromTeam => 'Espelli dalla squadra';

  @override
  String get maxViceCaptains =>
      'Massimo 2 Vice Capitani consentiti. Prima retrocedine uno.';

  @override
  String promotedToVC(String name) => '$name promosso a Vice Capitano';

  @override
  String get failedToPromote =>
      'Impossibile promuovere il giocatore a Vice Capitano';

  @override
  String demoted(String name) => '$name retrocesso';

  @override
  String get failedToDemote => 'Impossibile retrocedere il giocatore';

  @override
  String get expelPlayerTitle => 'Espelli giocatore';

  @override
  String expelPlayerConfirm(String name) =>
      'Sei sicuro di voler espellere $name dalla squadra?';

  @override
  String expelled(String name) => '$name espulso dalla squadra';

  @override
  String get failedToExpel => 'Impossibile espellere il giocatore';

  @override
  String get failedToAcceptRequest => 'Impossibile accettare la richiesta';

  @override
  String get leaveTeamTitle => 'Lascia squadra';

  @override
  String get leaveTeamConfirm =>
      'Sei sicuro di voler lasciare questa squadra?';

  @override
  String get leaveButton => 'Lascia';

  @override
  String get leaveTeamLabel => 'Lascia Squadra';

  @override
  String get requestsLabel => 'Richieste';

  @override
  String get expelButton => 'Espelli';

  // Team screen
   @override
  String get footballTeamsTitle => 'Squadre di calcio';

  @override
  String get filtersTitle => 'Filtri';

  @override
  String get allCities => 'Tutte';

  @override
  String get allTeams => 'Tutti';

  @override
  String get vipOnly => 'Solo VIP';

  @override
  String get nonVip => 'Non VIP';

  @override
  String get applyText => 'Applica';

  @override
  String get resetText => 'Reset';

  @override
  String get ranksInfo => 'Info Classifiche';

  @override
  String get nameAlias => 'Nome (Alias)';

  @override
  String get idLabel => 'ID';

  @override
  String get createTeamLabel => 'Crea';

  @override
  String errorLoadingTeams(String error) =>
      'Errore nel caricamento delle squadre: $error';

  @override
  String get ranksInfoDescription =>
      'Le squadre sono ordinate per punti ranking (Rank Pts). Più alto è il punteggio, migliore è la posizione in classifica.';

  @override
  String get myTeamTab => 'La Mia Squadra';

  @override
  String get ranksTab => 'Classifica';

  @override
  String get noTeamsAvailable => 'Nessuna squadra disponibile';

  @override
  String get noTeamsFound => 'Nessuna squadra trovata';

  @override
  String get guestModeLoginTeams => 'Modalità ospite: Accedi per creare/unirsi a squadre';

  @override
  String get numberOfPlayersLabel => 'Numero Giocatori';

  @override
  String playersRangeLabel(int min, int max) => '$min - $max giocatori';

  // Team detail screen
  @override
  String errorLoadingTeamData(String error) =>
      'Errore nel caricamento dati squadra: $error';

  @override
  String get errorSendingRequest => 'Errore nell\'invio della richiesta';

  @override
  String get requestSentSuccessfully => 'Richiesta inviata con successo';

  @override
  String errorSendingRequestDetail(String error) =>
      'Errore nell\'invio della richiesta: $error';

  @override
  String get errorCancellingRequest =>
      'Errore nella cancellazione della richiesta';

  @override
  String get requestCancelled => 'Richiesta annullata';

  @override
  String errorCancellingRequestDetail(String error) =>
      'Errore nella cancellazione della richiesta: $error';

  @override
  String get cancelRequest => 'Annulla Richiesta';

  @override
  String get joinTeam => 'Unisciti alla squadra';

  // Abstract team screen
  @override
  String get vipUpgradeComingSoonTeam => 'Aggiornamento VIP in arrivo';

  @override
  String get vipPalmaresDesc =>
      'Questa sezione è disponibile solo per le squadre VIP. Passa al VIP per visualizzare il palmares della squadra.';

  @override
  String get actualPlayersToggle => 'Giocatori Attuali';

  @override
  String get allPlayersToggle => 'Tutti i Giocatori';

  @override
  String get noTrophiesYet => 'Nessun trofeo ancora';

  @override
  String get captainCannotLeaveTeam =>
      'I capitani non possono abbandonare la squadra. Assegna un vice-capitano prima di uscire.';

  @override
  String get errorLeavingTeam =>
      'Errore nell\'uscita dalla squadra. Riprova più tardi.';

  @override
  String pendingPaymentsCount(int count) => 'Pagamenti in sospeso ($count)';

  @override
  String get statsTab => 'Statistiche';

  @override
  String get palmaresTab => 'Palmares';

  @override
  String get teamDetailsTitle => 'Dettagli Squadra';

  // Add referee license dialog
  @override
  String get selectSportFirst2 => 'Seleziona uno sport';

  @override
  String get selectIssueDate => 'Seleziona la data di rilascio';

  @override
  String get failedToAddLicense =>
      'Impossibile aggiungere la licenza. Riprova.';

  @override
  String get addLicenseTitle => 'Aggiungi licenza';

  @override
  String get sportLabel => 'Sport';

  @override
  String get selectSportHint => 'Seleziona sport';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoUploadComingSoonMsg => 'Caricamento foto — In arrivo';

  @override
  String get uploadPhotoComingSoon => 'Carica foto (in arrivo)';

  @override
  String get licenseIdLabel => 'ID licenza';

  @override
  String get licenseIdHint => 'es. ABC-2024-001';

  @override
  String get enterLicenseId => 'Inserisci l\'ID della licenza';

  @override
  String get addButton => 'Aggiungi';

  // Booking widget
  @override
  String get chatComingSoonWidget => 'Chat - In arrivo';

  @override
  String get fullLobby => 'Lobby Piena';

  @override
  String youPaidForPlayers(int count) =>
      count == 1 ? 'Hai pagato per 1 giocatore' : 'Hai pagato per $count giocatori';

  @override
  String get openChat => 'Apri Chat';

  @override
  String get deleteLobbyTitle => 'Elimina Lobby';

  @override
  String get deleteLobbyMessage =>
      'Sei sicuro di voler eliminare questa lobby? Tutti i partecipanti verranno rimossi.';

  @override
  String get leaveLobbyTitle => 'Abbandona Lobby';

  @override
  String get leaveLobbyMessage =>
      'Sei sicuro di voler abbandonare questa lobby?';

  @override
  String get deleteBookingTitle => 'Elimina Prenotazione';

  @override
  String get deleteBookingMessage =>
      'Sei sicuro di voler eliminare questa prenotazione privata?';

  @override
  String get lobbyDeleted => 'Lobby eliminata';

  @override
  String get lobbyLeft => 'Lobby abbandonata';

  @override
  String get bookingDeleted => 'Prenotazione eliminata';

  @override
  String get failedToDeleteLobby => 'Impossibile eliminare la lobby';

  @override
  String get failedToLeavelobby => 'Impossibile abbandonare la lobby';

  @override
  String get failedToDeleteBooking => 'Impossibile eliminare la prenotazione';

  // Football MOTM dialog
  @override
  String errorLoadingPlayers(String error) =>
      'Errore nel caricamento giocatori: $error';

  @override
  String get selectMotmTitle => 'Seleziona Uomo della Partita';

  // Football stat card
  @override
  String get goalsLabel => 'Gol';

  @override
  String get motmLabel => 'MDC';

  @override
  String get yellowCardsLabel => 'Cartellini Gialli';

  @override
  String get redCardsLabel => 'Cartellini Rossi';

  // Growth hero card
  @override
  String get levelAbbrev => 'LVL';

  @override
  String get refereeRole => 'Arbitro';

  @override
  String get coordinatorRole => 'Coordinatore';

  // Growth pay note
  @override
  String get growthPayNote =>
      'La retribuzione può variare in base al ruolo all\'interno della stessa categoria sportiva. I valori mostrati sono il range min–max tra tutti i ruoli per quel livello.';

  // Growth timeline item
  @override
  String get currentBadge => 'ATTUALE';

  @override
  String get startingLevel => 'Livello iniziale — nessun requisito';

  @override
  String minGamesRefereed(int count) => 'Min. $count partite arbitrate';

  @override
  String avgRatingGames(double rating, int games) =>
      'Valutazione media ≥ $rating nelle ultime $games partite';

  @override
  String minTournamentsCoordinated(int count) =>
      'Min. $count tornei coordinati';

  @override
  String avgRatingTournaments(double rating, int tournaments) =>
      'Valutazione media ≥ $rating negli ultimi $tournaments tornei';

  @override
  String payPerMatch(String amount) => '€$amount / partita';

  // Match event dialog
  @override
  String get confirmEventTitle => 'Conferma Evento';

  @override
  String get selectEventType => 'Seleziona tipo evento';

  @override
  String get selectPlayer => 'Seleziona giocatore';

  @override
  String get failedToAddEvent => 'Impossibile aggiungere l\'evento';

  // Match info card
  @override
  String get dateLabel => 'Data';

  @override
  String get timeLabel => 'Ora';

  @override
  String get fieldLabel => 'Campo';

  @override
  String get refereesLabel => 'Arbitri';

  // Bottom bars
  @override
  String get shopNavLabel => 'Negozio';

  @override
  String get meNavLabel => 'Io';

  @override
  String get tournamentsNavLabel => 'Tornei';

  @override
  String get teamNavLabel => 'Squadra';

  @override
  String get matchesNavLabel => 'Partite';

  @override
  String get historyNavLabel => 'Storico';

  // Participation card
  @override
  String get enterValidAmount => 'Inserisci un importo valido';

  @override
  String get userNotLoggedIn => 'Utente non connesso';

  @override
  String get continueParticipation => 'Continua';

  // Review widget
  @override
  String get rateAllFieldsMsg =>
      'Valuta tutti i campi (minimo 0,5 stelle ciascuno).';

  @override
  String get reviewSubmitted => 'Recensione inviata!';

  @override
  String get failedToSubmitReview => 'Impossibile inviare la recensione.';

  // Search dialog widget
  @override
  String get searchByTeamId => 'Cerca per ID squadra';

  @override
  String get searchByTournamentId => 'Cerca per ID torneo';

  @override
  String get searchButton => 'Cerca';

  // Sport selector widget
  @override
  String errorLoadingSports(String error) =>
      'Errore nel caricamento degli sport: $error';

  // Tournament summary
  @override
  String get feePerTeam => 'Quota per squadra';

  @override
  String get fieldLabel2 => 'Campo';

  @override
  String get sportLabel2 => 'Sport';

  @override
  String get startLabel => 'Inizio';

  @override
  String get teamsLabel => 'Squadre';

  @override
  String get groupsLabel => 'Gironi';

  @override
  String get qualifiedTeamsLabel => 'Squadre qualificate alla fase finale';

  @override
  String get totalMatchesLabel => 'Partite totali';

  @override
  String get homeAndAwayLabel => 'Andata e ritorno';

  @override
  String get descriptionLabel => 'Descrizione';

  // Referee match dialog
  @override
  String get confirmAssignmentTitle => 'Conferma Assegnazione';

  // Available matches screen
  @override
  String get allFilter => 'Tutti';

  @override
  String get selectCityToSeeMatchesTitle => 'Seleziona una citta\'';

  @override
  String get selectCityToSeeMatchesSubtitle =>
      'Scegli una citta\' per vedere le partite disponibili';

  @override
  String get noMatchesAvailable => 'Nessuna partita disponibile';

  @override
  String get noScheduledMatchesForSelectedFilters =>
      'Nessuna partita in programma per i filtri selezionati';

  @override
  String sportWithId(double sportId) => 'Sport $sportId';

  @override
  String noScheduledMatchesInSport(String sportName) =>
      'Nessuna partita in programma in: $sportName';

  // Rank teams widget
  @override
  String ptsLabel(int pts) => '$pts pts';

  // Transaction card
  @override
  String daysAgo(int days) => '$days giorni fa';

  // Tournament card home
  @override
  String get participatingInTournamentMsg =>
      'Stai partecipando al torneo. Quando sarà al completo, vedrai le tue prossime partite!';

  // Abstract team dialog
  @override
  String get pleaseSelectTeamFirst => 'Seleziona prima una squadra';

  // Players widget
  @override
  String get noPlayersFound => 'Nessun giocatore trovato';

  @override
  String get teamDisabledMsg => 'Questa squadra è disabilitata.';

  @override
  String get captainAbbr => 'C';

  @override
  String get viceCaptainAbbr => 'VC';

  @override
  String teamAliasAndId(String alias, double id) => "Alias: ${alias} - ID: ${id}";

  // Abstract football match widget - match statuses
  @override
  String get matchStatusLive => 'In corso';

  @override
  String get matchStatusHalftime => 'Intervallo';

  @override
  String get matchStatusLive2ndHalf => 'In corso - 2° Tempo';

  @override
  String get matchStatusPenaltyShootout => 'Rigori';

  @override
  String get matchStatusFullTime => 'Finita';

  @override
  String get matchStatusToBeScheduled => 'Da pianificare';

  @override
  String get matchStatusRetired => 'Ritirato';

  @override
  String get matchStatusCanceled => 'Annullata';

  @override
  String matchStatusScheduled(String date, String time) =>
      'Programmata ($date alle $time)';

  // Shared
  @override
  String get tbd => 'TBD';

  @override
  String get motmWarningMsg => 'Attenzione: MOTM mancante';

  // Team widgets
  @override
  String captainLabel(String name) => 'Capitano: $name';

  @override
  String get cannotChangeFavMsg =>
      'Non puoi modificare i preferiti mentre partecipi.';

  // Organization booking
  @override
  String get tournamentMatchLabel => 'Partita del Torneo';

  @override
  String get vsLabel => 'VS';

  @override
  String coordinatorPrefix(String name) => 'Coordinatore: $name';

  @override
  String playerPrefix(String name) => 'Giocatore: $name';

  // Match event dialog
  @override
  String get eventGoal => 'Gol';

  @override
  String get eventPenalty => 'Rigore';

  @override
  String get eventMissedPenalty => 'Rigore Sbagliato';

  @override
  String get eventOwnGoal => 'Autogol';

  @override
  String get eventYellowCard => 'Cartellino Giallo';

  @override
  String get eventRedCard => 'Cartellino Rosso';

  @override
  String get eventDoubleYellowCard => 'Doppio Giallo';

  @override
  String get addEventButton => 'Aggiungi Evento';

  @override
  String confirmEventMsg(String eventName, String playerName) =>
      'Sei sicuro di voler aggiungere $eventName per $playerName?';

  @override
  String get noPlayersAvailable => 'Nessun giocatore disponibile';

  // Match info card
  @override
  String get matchInformationTitle => 'Informazioni Partita';

  @override
  String get matchNotScheduledYet => 'Partita non ancora programmata';

  @override
  String get noRefereesAssigned => 'Nessun arbitro assegnato';

  // Schedule match dialog
  @override
  String get selectDateButton => 'Seleziona Data';

  @override
  String get availableTimeSlotsLabel =>
      'Orari Disponibili (Calcio d\'inizio):';

  @override
  String get noAvailableTimeSlotsForDate =>
      'Nessun orario disponibile per questa data';

  @override
  String fieldBookedInfo(
          String from, String to, String date, String kickoff) =>
      'Campo prenotato dalle $from alle $to il $date con calcio d\'inizio alle $kickoff';

  // Search dialog widget
  @override
  String get pleaseEnterIdError => 'Inserisci un ID';

  @override
  String get invalidIdFormatError => 'Formato ID non valido';

  @override
  String get teamNotFoundError => 'Squadra non trovata';

  @override
  String get tournamentNotFoundError => 'Torneo non trovato';

  @override
  String errorSearching(String e) => 'Errore durante la ricerca: $e';

  @override
  String get enterTeamIdHint => 'Inserisci ID Squadra';

  @override
  String get enterTournamentIdHint => 'Inserisci ID Torneo';

  // Road to victory
  @override
  String get invalidBracketConfig => 'Configurazione del tabellone non valida';

  @override
  String roundOf16NumLabel(String group) => 'Ottavi di Finale #$group';

  @override
  String quarterFinalNumLabel(String group) => 'Quarto di Finale $group';

  @override
  String semifinalNumLabel(String group) => 'Semifinale $group';

  // Sport selector
  @override
  String get noSportsAvailable => 'Nessuno sport disponibile';

  @override
  String sportPlayersMinutesLabel(int min, int max, int minutes) =>
      '$min-$max giocatori • $minutes\' per tempo';

  // Tournament summary
  @override
  String get round2ForAll => 'Per tutto il torneo';

  @override
  String get round2GroupStageOnly => 'Solo ai gironi';

  @override
  String get round2FinalStageOnly => 'Solo nella fase finale';

  @override
  String get noDescriptionProvided => 'Nessuna descrizione fornita';

  @override
  String get firstPlaceLabel => '1° posto';

  @override
  String get secondPlaceLabel => '2° posto';

  @override
  String monthName(int month) {
    switch (month) {
      case 1:
        return 'gennaio';
      case 2:
        return 'febbraio';
      case 3:
        return 'marzo';
      case 4:
        return 'aprile';
      case 5:
        return 'maggio';
      case 6:
        return 'giugno';
      case 7:
        return 'luglio';
      case 8:
        return 'agosto';
      case 9:
        return 'settembre';
      case 10:
        return 'ottobre';
      case 11:
        return 'novembre';
      case 12:
        return 'dicembre';
      default:
        return '';
    }
  }

  // Referee license widget
  @override
  String get licenseStatusNotVerified => 'Non Verificata';

  @override
  String get licenseStatusSuspended => 'Sospesa';

  @override
  String get licenseStatusRevoked => 'Revocata';

  @override
  String get licenseIssuedLabel => 'Rilasciata';

  @override
  String get licenseSubmittedLabel => 'Inviata';

  @override
  String get licenseVerifiedLabel => 'Verificata';

  @override
  String get holdToDeleteHint => 'Tieni premuto per eliminare';

  // Referee match dialog
  @override
  String get mainRefereeRole => 'Arbitro principale';

  @override
  String get assistantRef1Role => 'Assistente 1';

  @override
  String get assistantRef2Role => 'Assistente 2';

  @override
  String get refereeThisMatchTitle => 'Arbitra questa Partita';

  @override
  String get selectYourRoleLabel => 'Seleziona il tuo ruolo:';

  @override
  String confirmRefereeMsg(String role) =>
      'Sei sicuro di voler arbitrare questa partita come $role?';

  // Review widget
  @override
  String get reviewingLabel => 'Recensendo';

  @override
  String get impartialityField => 'Imparzialità';

  @override
  String get competenceField => 'Competenza';

  @override
  String get matchManagementField => 'Gestione della partita';

  @override
  String get organisationField => 'Organizzazione';

  @override
  String get communicationField => 'Comunicazione';

  @override
  String get availabilityField => 'Disponibilità';

  @override
  String get coordinatorToRefereeLabel => 'Coordinatore → Arbitro';

  @override
  String get refereeToCoordinatorLabel => 'Arbitro → Coordinatore';

  @override
  String get playerToCoordinatorLabel => 'Giocatore → Coordinatore';

  @override
  String get commentOptionalLabel => 'Commento (opzionale)';

  @override
  String get writeACommentHint => 'Scrivi un commento...';

  @override
  String get submittingLabel => 'Invio in corso...';

  @override
  String get commitReviewButton => 'Invia Recensione';

  // Participation card
  @override
  String get calledUpLabel => 'Convocato';

  @override
  String get notCalledUpLabel => 'Non convocato';

  @override
  String get payButton => 'Paga';

  @override
  String get howMuchToPayTitle => 'Quanto vuoi pagare?';

  @override
  String amountDueLabel(double amount) =>
      'Importo dovuto: €${amount.toStringAsFixed(2)}';

  @override
  String get amountToPayLabel => 'Importo da pagare';

  @override 
  String get january => 'Gennaio';

  @override
  String get february => 'Febbraio';

  @override
  String get march => 'Marzo';

  @override
  String get april => 'Aprile';

  @override
  String get may => 'Maggio';

  @override
  String get june => 'Giugno';

  @override
  String get july => 'Luglio';

  @override
  String get august => 'Agosto';

  @override
  String get september => 'Settembre';

  @override
  String get october => 'Ottobre';

  @override
  String get november => 'Novembre';

  @override
  String get december => 'Dicembre';

  
  @override
  String get round2Label => 'Andata e ritorno';

  @override
  String get specifyTeamOrTournament => 'Devi specificare la ricerca per squadra o torneo.';

  @override
  String get failedToLoadTimeData => 'Impossibile caricare i dati temporali. Riprova.';

  @override
  String get tournamentLabel => 'Torneo';

  @override
  String payOutOf(String paid, String total) => 'Pagato €$paid di €$total';

  @override
  String get unknownLocation => 'Luogo sconosciuto';

  @override
  String get eventTypeLabel => 'Tipo di evento';

  @override
  String get issuedAtLabel => 'Rilasciata il';

  @override
  String get selectADate => 'Seleziona una data';
}
