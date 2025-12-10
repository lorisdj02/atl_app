import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../widgets/tournament_card.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/atl_floating_button.dart';
import '../../models/sport_category.dart';
import '../../models/user.dart';
import '../../models/tournament.dart';
import '../../utils/atl_colors.dart';
import '../../utils/navigation_helper.dart';
import '../../database/db_controller.dart';
import '../../l10n/app_localizations.dart';
import 'dart:async';
import 'tournament_detail_screen.dart';
import 'tournament_screen.dart';

class AllTournamentsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const AllTournamentsScreen({super.key, required this.currentSport});

  @override
  State<AllTournamentsScreen> createState() => _AllTournamentsScreenState();
}

class _AllTournamentsScreenState extends State<AllTournamentsScreen>
    with SingleTickerProviderStateMixin {
  List<Tournament>? _tournaments;
  bool _isLoading = true;
  late TabController _tabController;

  // Filtri
  final TextEditingController _searchController = TextEditingController();
  bool _showMyTournaments = false;

  // Filtri avanzati
  String? _selectedCity;
  int? _selectedNumTeams;
  RangeValues _prizeRange = const RangeValues(0, 2000);
  RangeValues _feeRange = const RangeValues(0, 50);

  // Filtri temporanei per il dialog
  String? _tempSelectedCity;
  int? _tempSelectedNumTeams;
  RangeValues _tempPrizeRange = const RangeValues(0, 2000);
  RangeValues _tempFeeRange = const RangeValues(0, 50);

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
        _loadTournaments();
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
      List<Tournament> tournaments = [];
      List<Tournament> participatingTournaments = [];
      List<Tournament> favoriteTournaments = [];

      if (!userProvider.isGuest) {
        if (userProvider.isPlayer) {
          participatingTournaments =
              await DB.Tournaments.getParticipatingTournamentByPlayerAndTeam(
                (await DB.Players.getById(
                  userProvider.activeUser!.id,
                ))!.playerId,
                //TODO: HAI IL PLAYER ID IN PROVIDER
                userProvider.currentTeamId!,
              );
        }

        favoriteTournaments = await DB.Tournaments.getFavoriteTournamentByUser(
          userProvider.activeUser!.id,
        );
      }

      // In "My tournaments" mostra solo quelli con cuore (favorite o participating)
      if (_showMyTournaments) {
        tournaments = participatingTournaments + favoriteTournaments;
        print(
          '🔧 [DEBUG] Loaded ${tournaments.length} favorite tournaments for user ${userProvider.activeUser!.id}',
        );
      } else {
        tournaments = await DB.Tournaments.getActive();
        if (!userProvider.isGuest) {
          // Rimuovi da tutti i tornei quelli già in favorite o participating
          tournaments.removeWhere(
            (t) =>
                favoriteTournaments.any((f) => f.id == t.id) ||
                participatingTournaments.any((p) => p.id == t.id),
          );
          tournaments =
              participatingTournaments + favoriteTournaments + tournaments;
        }

        print('🔧 [DEBUG] Loaded ${tournaments.length} active tournaments');
      }

      setState(() {
        _tournaments = tournaments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tournaments: $e')),
        );
      }
    }
  }

  void _showFilterDialog() {
    // Inizializza filtri temporanei con valori correnti
    _tempSelectedCity = _selectedCity;
    _tempSelectedNumTeams = _selectedNumTeams;
    _tempPrizeRange = _prizeRange;
    _tempFeeRange = _feeRange;

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
                  child: DropdownButton<String?>(
                    value: _tempSelectedCity,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(AppLocalizations.of(context).selectCity),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text(AppLocalizations.of(context).all),
                      ),
                      ...['Taranto', 'Milano', 'Torino', 'Roma'].map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
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
                  min: 0,
                  max: 2000,
                  divisions: 20,
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
                  min: 0,
                  max: 50,
                  divisions: 10,
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
              onPressed: () {
                setState(() {
                  _selectedCity = _tempSelectedCity;
                  _selectedNumTeams = _tempSelectedNumTeams;
                  _prizeRange = _tempPrizeRange;
                  _feeRange = _tempFeeRange;
                });
                Navigator.pop(context);
                // Aggiungi questa riga:
                _loadTournaments();
              },
              style: TextButton.styleFrom(foregroundColor: ATLColors.darkBlue),
              child: Text(AppLocalizations.of(context).apply),
            ),
          ],
        ),
      ),
    );
  }

  List<Tournament> _applyFilters(List<Tournament> tournaments) {
    return tournaments.where((t) {
      // Filtro città
      if (_selectedCity != null && t.city != _selectedCity) {
        return false;
      }

      // Filtro numero squadre
      if (_selectedNumTeams != null && t.numTeams != _selectedNumTeams) {
        return false;
      }

      // Filtro premio - APPLICA SOLO SE MODIFICATO
      if (_prizeRange != const RangeValues(0, 2000) &&
          (t.prize1 < _prizeRange.start || t.prize1 > _prizeRange.end)) {
        return false;
      }

      // Filtro fee - APPLICA SOLO SE MODIFICATO
      if (_feeRange != const RangeValues(0, 50) &&
          (t.fee < _feeRange.start || t.fee > _feeRange.end)) {
        return false;
      }

      return true;
    }).toList();
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
          AppLocalizations.of(context).tournaments.toUpperCase(),
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
                                  final results = await DB
                                      .Tournaments.filterByNameOrId(value);
                                  setState(() {
                                    _tournaments = results;
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
                    const Expanded(
                      child: Text(
                        'Guest mode: Login to interact with tournaments',
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
                : _tournaments == null ||
                      (_tournaments!.isEmpty && !_hasActiveFilters)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: widget.currentSport.primaryColor,
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showMyTournaments
                              ? AppLocalizations.of(
                                  context,
                                ).noTournamentsFavorite
                              : AppLocalizations.of(
                                  context,
                                ).noTournamentsRunning,
                          style: const TextStyle(
                            color: ATLColors.darkBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _showMyTournaments
                              ? AppLocalizations.of(context).addToFavorites
                              : AppLocalizations.of(context).comeBackLater,
                          style: const TextStyle(
                            color: ATLColors.subtext,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : (_tournaments!.isEmpty ||
                      _applyFilters(_tournaments!).isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: widget.currentSport.primaryColor,
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
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _applyFilters(_tournaments!).length,
                    itemBuilder: (context, index) {
                      final tournament = _applyFilters(_tournaments!)[index];
                      return TournamentCard(
                        tournament: tournament,
                        currentSport: widget.currentSport,
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
                          }
                          else if (tournament.status == TournamentStatus.scheduled){
                            //TODO: Navigare alla schermata del torneo in corso
                            if(tournament.sportName == 'FOOTBALL'){
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TournamentScreen(
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
              Provider.of<UserProvider>(context).activeUser!.role ==
                  UserRole.coordinator &&
              _showMyTournaments)
            Positioned(
              right: 16,
              bottom: 16,
              child: ATLFloatingButton(
                onPressed: () {
                  // TODO: Navigare a schermata creazione torneo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).comingSoon),
                    ),
                  );
                },
                backgroundColor: widget.currentSport.primaryColor,
                icon: Icons.add,
                label: 'New',
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
      ),
    );
  }

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
