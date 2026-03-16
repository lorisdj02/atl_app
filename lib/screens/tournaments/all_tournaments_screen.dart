import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/database/db_read.dart';
import 'package:atl_app/models/coordinator.dart';
import 'package:atl_app/models/field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../widgets/tournament_card.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/atl_floating_button.dart';
import '../../models/sport_category.dart';
import '../../models/city.dart';
import '../coordinator/create_tournament_screen.dart';
import '../../models/tournament.dart';
import '../../utils/atl_colors.dart';
import '../../utils/navigation_helper.dart';
import '../../l10n/app_localizations.dart';
import 'dart:async';
import 'tournament_detail_screen.dart';
import 'football_tournament_screen.dart';
import '../../widgets/search_dialog_widget.dart';

class AllTournamentsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const AllTournamentsScreen({super.key, required this.currentSport});

  @override
  State<AllTournamentsScreen> createState() => _AllTournamentsScreenState();
}

class _AllTournamentsScreenState extends State<AllTournamentsScreen>
    with SingleTickerProviderStateMixin {
  List<Tournament> _tournaments = [];
  List<Tournament> _myTournaments = [];
  Map<int, Coordinator> _coordinatorCache = {};
  Map<int, Field> _fieldCache = {};
  Map<int, String> _cityNamePerField = {};

  bool _isLoading = true;
  late TabController _tabController;

  // Filtri
  final TextEditingController _searchController = TextEditingController();
  bool _showMyTournaments = false;

  // Filtri avanzati
  int? _selectedCity;
  List<City> _availableCities = [];
  int? _selectedNumTeams;
  RangeValues _prizeRange = const RangeValues(0, 2000);
  RangeValues _feeRange = const RangeValues(0, 50);

  // Filtri temporanei per il dialog
  int? _tempSelectedCity;
  int? _tempSelectedNumTeams;
  RangeValues _tempPrizeRange = const RangeValues(0, 2000);
  RangeValues _tempFeeRange = const RangeValues(0, 50);

  double prizeMin = 0;
  double prizeMax = 2000;
  double feeMin = 0;
  double feeMax = 200;


  /// Verifica se ci sono filtri attivi
  bool get _hasActiveFilters {
    return _selectedCity != null ||
        _selectedNumTeams != null ||
        _prizeRange != const RangeValues(0, 2000) ||
        _feeRange != const RangeValues(0, 50) ||
        _searchController.text.isNotEmpty; // Aggiungi questo
  }

  @override
  void initState() {
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    super.initState();
    // Se guest, solo 1 tab (Search), altrimenti 2 tabs
    _tabController = TabController(
      length: userProvider.isGuest ? 1 : 2,
      vsync: this,
    );
    if (!userProvider.isGuest) {
      _tabController.addListener(() {
        setState(() {
          _showMyTournaments = _tabController.index == 1;
        });
      });
    }
    _loadTournaments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTournaments() async {
    UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DBRead.getAllTournamentsScreen(
        !userProvider.isGuest ? userProvider.activeUser?.id : null,
        userProvider.currentTeamId,
        widget.currentSport,
      );

      setState(() {
        _tournaments = data[ApiJsonKeys.tournaments];
        _coordinatorCache = data[ApiJsonKeys.coordinatorCache];
        _fieldCache = data[ApiJsonKeys.fieldCache];
        _myTournaments = data[ApiJsonKeys.myTournaments];
        _availableCities = data[ApiJsonKeys.cities];
        _cityNamePerField = data[ApiJsonKeys.cityNamePerField];
        prizeMin = data[ApiJsonKeys.prizeMin];
        prizeMax = data[ApiJsonKeys.prizeMax];
        feeMin = data[ApiJsonKeys.feeMin];
        feeMax = data[ApiJsonKeys.feeMax];

        // Ensure current ranges are within the newly loaded min/max
        _prizeRange = RangeValues(prizeMin, prizeMax);
        _feeRange = RangeValues(feeMin, feeMax);

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).errorLoadingTournaments(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _showFilterDialog() {
    // Inizializza filtri temporanei con valori correnti
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );

    // copy current selections into temporaries so sliders start on current values
    _tempSelectedCity = _selectedCity;
    _tempSelectedNumTeams = _selectedNumTeams;

    // Dialog-local min/max: if min==max (no variation), provide a sensible fallback
    double dialogPrizeMin = prizeMin;
    double dialogPrizeMax = prizeMax;
    if (dialogPrizeMin >= dialogPrizeMax) {
      dialogPrizeMin = 0.0;
      dialogPrizeMax = (prizeMax > dialogPrizeMin)
          ? prizeMax
          : dialogPrizeMin + 1.0;
    }

    double dialogFeeMin = feeMin;
    double dialogFeeMax = feeMax;
    if (dialogFeeMin >= dialogFeeMax) {
      dialogFeeMin = 0.0;
      dialogFeeMax = (feeMax > dialogFeeMin) ? feeMax : dialogFeeMin + 1.0;
    }

    _tempPrizeRange = RangeValues(
      (_prizeRange.start.clamp(dialogPrizeMin, dialogPrizeMax)),
      (_prizeRange.end.clamp(dialogPrizeMin, dialogPrizeMax)),
    );

    _tempFeeRange = RangeValues(
      (_feeRange.start.clamp(dialogFeeMin, dialogFeeMax)),
      (_feeRange.end.clamp(dialogFeeMin, dialogFeeMax)),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ATLColors.background,
          title: Text(AppLocalizations.of(context).filters),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro Città
                Text(
                  AppLocalizations.of(context).city,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<int?>(
                    value: _tempSelectedCity,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(AppLocalizations.of(context).selectCity),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(AppLocalizations.of(context).all),
                      ),
                      ..._availableCities.map((city) {
                        return DropdownMenuItem(
                          value: city.id,
                          child: Text(city.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _tempSelectedCity = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Filtro Numero Squadre
                Text(
                  AppLocalizations.of(context).numberOfTeams,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<int?>(
                    value: _tempSelectedNumTeams,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(AppLocalizations.of(context).selectTeamCount),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(AppLocalizations.of(context).all),
                      ),
                      ...[8, 12, 16].map((num) {
                        return DropdownMenuItem(
                          value: num,
                          child: Text(
                            AppLocalizations.of(context).teamsTotal(num),
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _tempSelectedNumTeams = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Filtro Premio
                Text(
                  AppLocalizations.of(context).prizeRange,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _tempPrizeRange,
                  min: dialogPrizeMin,
                  max: dialogPrizeMax,
                  activeColor: ATLColors.darkBlue,
                  labels: RangeLabels(
                    '€${_tempPrizeRange.start.round()}',
                    '€${_tempPrizeRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setDialogState(() {
                      _tempPrizeRange = values;
                    });
                  },
                ),
                Text(
                  '€${_tempPrizeRange.start.round()} - €${_tempPrizeRange.end.round()}',
                  style: const TextStyle(fontSize: 12),
                ),

                const SizedBox(height: 16),

                // Filtro Fee
                Text(
                  AppLocalizations.of(context).feeRange,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _tempFeeRange,
                  min: dialogFeeMin,
                  max: dialogFeeMax,
                  activeColor: ATLColors.darkBlue,
                  labels: RangeLabels(
                    '€${_tempFeeRange.start.round()}',
                    '€${_tempFeeRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setDialogState(() {
                      _tempFeeRange = values;
                    });
                  },
                ),
                Text(
                  '€${_tempFeeRange.start.round()} - €${_tempFeeRange.end.round()}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCity = null;
                  _selectedNumTeams = null;
                  _prizeRange = const RangeValues(0, 2000);
                  _feeRange = const RangeValues(0, 50);
                });
                Navigator.pop(context);
                _loadTournaments();
              },
              style: TextButton.styleFrom(foregroundColor: ATLColors.darkBlue),
              child: Text(AppLocalizations.of(context).reset),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _selectedCity = _tempSelectedCity;
                  _selectedNumTeams = _tempSelectedNumTeams;
                  _prizeRange = _tempPrizeRange;
                  _feeRange = _tempFeeRange;
                });
                Navigator.pop(context);

                setState(() {
                  _isLoading = true;
                });

                try {
                  final results = await DBRead.applyTournamentFilters(
                    userProvider.activeUser?.id,
                    userProvider.currentTeamId,
                    cityId: _selectedCity,
                    numTeams: _selectedNumTeams,
                    prizeRange: _prizeRange,
                    feeRange: _feeRange,
                    nameOrCode: null,
                    sportCategory: widget.currentSport,
                  );

                  setState(() {
                    _tournaments = results[ApiJsonKeys.tournaments];
                    _isLoading = false;
                  });
                } catch (e) {
                  setState(() => _isLoading = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)
                              .errorApplyingFilters(e.toString()),
                        ),
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: ATLColors.darkBlue),
              child: Text(AppLocalizations.of(context).apply),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer? _debounce;
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "${widget.currentSport.name.toUpperCase()} TOURNAMENTS", // "TOURNAMENTS" LOCALIZZATO
          style: const TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: ATLColors.darkBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).darkModeComingSoon,
                  ),
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(userProvider.isGuest ? 50 : 100),
          child: Column(
            children: [
              // Tabs: Search / My tournaments - SOLO se non guest
              if (!userProvider.isGuest)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          AppLocalizations.of(context).search,
                          0,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabButton(
                          AppLocalizations.of(context).myTournaments,
                          1,
                        ),
                      ),
                    ],
                  ),
                ),

              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).nameOrCode,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();

                          _debounce = Timer(
                            const Duration(milliseconds: 300),
                            () {
                              setState(() {
                                _isLoading = true;
                              });

                              // Filtra i tornei in base al testo di ricerca
                              if (value.isEmpty) {
                                // Se campo vuoto, ricarica tutti
                                _loadTournaments();
                              } else {
                                Future.microtask(() async {
                                  final toFilter = _showMyTournaments
                                      ? _myTournaments
                                      : _tournaments;
                                  final results = toFilter
                                      .where(
                                        (t) =>
                                            t.name.toLowerCase().contains(
                                              value.toLowerCase(),
                                            ) ||
                                            t.id.toString().contains(value),
                                      )
                                      .toList();
                                  setState(() {
                                    if (_showMyTournaments) {
                                      _myTournaments = results;
                                    } else {
                                      _tournaments = results;
                                    }
                                    _isLoading = false;
                                  });
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),
                    // Filter button
                    if (!_showMyTournaments) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: _showFilterDialog,
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    // ID search button
                    Container(
                      decoration: BoxDecoration(
                        color: ATLColors.darkBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton.icon(
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: Text(
                          AppLocalizations.of(context).idLabel,
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => SearchDialogWidget(
                              tournamentId: null,
                              isTeam: false,
                              isTournament: true,
                              onFound: (team, tournament) {
                                if (tournament != null) {
                                  if (tournament.status ==
                                      TournamentStatus.created) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TournamentDetailScreen(
                                              tournament: tournament,
                                              currentSport: widget.currentSport,
                                            ),
                                      ),
                                    );
                                  } else if (widget.currentSport ==
                                      SportCategory.football) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FootballTournamentScreen(
                                              tournament: tournament,
                                              sportCategory:
                                                  widget.currentSport,
                                            ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Guest mode banner
          if (userProvider.isGuest)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).guestModeLoginTournaments,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Lista tornei
          Positioned.fill(
            top: userProvider.isGuest ? 44 : 0,
            child: _isLoading
                ? const LoadingATL()
                : (() {
                    // Determine which list to check based on current tab
                    final currentList = _showMyTournaments ? _myTournaments : _tournaments;
                    final isEmpty = currentList.isEmpty;

                    if (isEmpty) {
                      // Show different messages based on tab and filter state
                      if (_showMyTournaments) {
                        // If user searched in "My Tournaments" and no results, suggest changing search/filters
                        if (_searchController.text.isNotEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  color: ATLColors.getPrimaryColor(widget.currentSport),
                                  size: 80,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context).noTournamentsFound,
                                  style: const TextStyle(
                                    color: ATLColors.darkBlue,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context).tryChangingFilters,
                                  style: const TextStyle(
                                    color: ATLColors.subtext,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }
                        // My Tournaments without active search: show "no favorites"
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: ATLColors.getPrimaryColor(widget.currentSport),
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).noTournamentsFavorite,
                                style: const TextStyle(
                                  color: ATLColors.darkBlue,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context).addToFavorites,
                                style: const TextStyle(
                                  color: ATLColors.subtext,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else if (_hasActiveFilters) {
                        // Search tab with active filters: suggest widening filters
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                color: ATLColors.getPrimaryColor(widget.currentSport),
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).noTournamentsFound,
                                style: const TextStyle(
                                  color: ATLColors.darkBlue,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context).tryChangingFilters,
                                style: const TextStyle(
                                  color: ATLColors.subtext,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Search tab without filters: no tournaments available
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: ATLColors.getPrimaryColor(widget.currentSport),
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).noTournamentsRunning,
                                style: const TextStyle(
                                  color: ATLColors.darkBlue,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context).comeBackLater,
                                style: const TextStyle(
                                  color: ATLColors.subtext,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                    }

                    // Show the list
                    return null;
                  }()) ??
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: (_showMyTournaments ? _myTournaments : _tournaments).length,
                    itemBuilder: (context, index) {
                      final tournament = (_showMyTournaments
                          ? _myTournaments
                          : _tournaments)[index];
                      return TournamentCard(
                        key: ValueKey(tournament.id),
                        tournament: tournament,
                        currentSport: widget.currentSport,
                        field: _fieldCache[tournament.fieldId]!,
                        coordinator:
                            _coordinatorCache[tournament.coordinatorId]!,
                        cityName:
                            _cityNamePerField[tournament.fieldId] ??
                            AppLocalizations.of(context)
                                .unknownCity, // Usa la mappa cityNamePerField
                        onFavoriteToggle: () {
                          setState(() {
                            tournament.isFavorite = !tournament.isFavorite;
                            if (tournament.isFavorite) {
                              _myTournaments.add(tournament);
                            } else {
                              _myTournaments.removeWhere((t) => t.id == tournament.id);
                            }
                            _myTournaments.sort((a, b) => a.name.compareTo(b.name));
                          });
                        },
                        onTap: () async {
                          if (tournament.status == TournamentStatus.created) {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TournamentDetailScreen(
                                  tournament: tournament,
                                  currentSport: widget.currentSport,
                                ),
                              ),
                            );
                          } else if (tournament.status ==
                              TournamentStatus.scheduled) {
                            //TODO: Navigare alla schermata del torneo in corso
                            if (widget.currentSport == SportCategory.football) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FootballTournamentScreen(
                                        tournament: tournament,
                                        sportCategory: widget.currentSport,
                                      ),
                                ),
                              );
                            }
                          }
                          setState(() {
                            _isLoading = true;
                            _loadTournaments();
                            _isLoading = false;
                          });
                        },
                      );
                    },
                  ),
          ),
          // Floating Action Button "New" - SOLO per coordinatori in My Tournaments
          if (!Provider.of<UserProvider>(context).isGuest &&
              Provider.of<UserProvider>(context).activeUser != null &&
              Provider.of<UserProvider>(context).isCoordinator &&
              _showMyTournaments)
            Positioned(
              right: 16,
              bottom: 16,
              child: ATLFloatingButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateTournamentScreen(
                        currentSport: widget.currentSport,
                      ),
                    ),
                  );
                },
                backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
                icon: Icons.add,
                label: AppLocalizations.of(context).newLabel,
              ),
            ),
        ],
      ),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 1,
        onTap: (index) {
          NavigationHelper.navigateToSection(
            context: context,
            index: index,
            currentSport: widget.currentSport,
            currentIndex: 1,
          );
        },
        currentSport: widget.currentSport,
        isHome: false,
        userId: userProvider.activeUser?.id,
      ),
    );}

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? ATLColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : ATLColors.darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              height: 1.2, // Spacing tra le righe per il testo multilinea
            ),
          ),
        ),
      ),
    );
  }
}
