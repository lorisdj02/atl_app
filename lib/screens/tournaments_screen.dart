import 'package:flutter/material.dart';
import '../widgets/player_coordinator_bottom_bar.dart';
import '../widgets/tournament_card.dart';
import '../widgets/loading_atl.dart';
import '../widgets/atl_floating_button.dart';
import '../models/sport_category.dart';
import '../models/user.dart';
import '../models/tournament.dart';
import '../utils/atl_colors.dart';
import '../utils/navigation_helper.dart';
import '../database/db_controller.dart';
import '../l10n/app_localizations.dart';

class TournamentsScreen extends StatefulWidget {
  final SportCategory currentSport;
  final User? user; // null se guest

  const TournamentsScreen({
    super.key,
    required this.currentSport,
    required this.user,
  });

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> with SingleTickerProviderStateMixin {
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
           _feeRange != const RangeValues(0, 50);
  }

  bool get _isGuest => widget.user == null;

  @override
  void initState() {
    super.initState();
    // Se guest, solo 1 tab (Search), altrimenti 2 tabs
    _tabController = TabController(length: _isGuest ? 1 : 2, vsync: this);
    if (!_isGuest) {
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
    setState(() => _isLoading = true);
    
    try {
      List<Tournament> tournaments = await DB.Tournaments.getActive();
      
      // In "My tournaments" mostra solo quelli con cuore (favorite o participating)
      if (_showMyTournaments) {
        tournaments = tournaments.where((t) {
          final status = _getUserStatus(t);
          return status == TournamentUserStatus.favorite ||
                 status == TournamentUserStatus.participating;
        }).toList();
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

  void _toggleFavorite(Tournament tournament) {
    if (_isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login required to add favorites'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).favoriteFeatureComingSoon),
        duration: const Duration(seconds: 1),
      ),
    );
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
                Text(AppLocalizations.of(context).city, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context).all)),
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
                Text(AppLocalizations.of(context).numberOfTeams, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      DropdownMenuItem(value: null, child: Text(AppLocalizations.of(context).all)),
                      ...[8, 12, 16].map((num) {
                        return DropdownMenuItem(value: num, child: Text(AppLocalizations.of(context).teamsTotal(num)));
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
                Text(AppLocalizations.of(context).prizeRange, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                Text(AppLocalizations.of(context).feeRange, style: const TextStyle(fontWeight: FontWeight.bold)),
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
              style: TextButton.styleFrom(
                foregroundColor: ATLColors.darkBlue,
              ),
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
              },
              style: TextButton.styleFrom(
                foregroundColor: ATLColors.darkBlue,
              ),
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
      
      // Filtro premio
      if (t.prize1 < _prizeRange.start || t.prize1 > _prizeRange.end) {
        return false;
      }
      
      // Filtro fee
      if (t.fee < _feeRange.start || t.fee > _feeRange.end) {
        return false;
      }
      
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
                SnackBar(content: Text(AppLocalizations.of(context).darkModeComingSoon)),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_isGuest ? 50 : 100),
          child: Column(
            children: [
              // Tabs: Search / My tournaments - SOLO se non guest
              if (!_isGuest)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  height: 50,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(AppLocalizations.of(context).search, 0),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTabButton(AppLocalizations.of(context).myTournaments, 1),
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
                          // TODO: Implementare ricerca
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
          if (_isGuest)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
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
            top: _isGuest ? 44 : 0,
            child: _isLoading
                ? const LoadingATL()
                : _tournaments == null || _tournaments!.isEmpty
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
                                  ? AppLocalizations.of(context).noTournamentsFavorite
                                  : AppLocalizations.of(context).noTournamentsRunning,
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
                    : _applyFilters(_tournaments!).isEmpty
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
                                  _hasActiveFilters
                                      ? AppLocalizations.of(context).tryChangingFilters
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
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _applyFilters(_tournaments!).length,
                            itemBuilder: (context, index) {
                              final filteredTournaments = _applyFilters(_tournaments!);
                              final tournament = filteredTournaments[index];
                              return TournamentCard(
                                tournament: tournament,
                                currentSport: widget.currentSport,
                                userStatus: _getUserStatus(tournament),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${AppLocalizations.of(context).tournamentDetails} - ${tournament.description}'),
                                    ),
                                  );
                                },
                                onFavoriteToggle: () => _toggleFavorite(tournament),
                              );
                            },
                          ),
          ),
          // Floating Action Button "New" - SOLO per coordinatori in My Tournaments
          if (!_isGuest && widget.user != null && widget.user!.role == UserRole.coordinator && _showMyTournaments)
            Positioned(
              right: 16,
              bottom: 16,
              child: ATLFloatingButton(
                onPressed: () {
                  // TODO: Navigare a schermata creazione torneo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).comingSoon)),
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
            user: widget.user,
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

  TournamentUserStatus _getUserStatus(Tournament tournament) {
    // TODO: Implementare logica reale per verificare stato utente
    // Per ora mock data:
    if (tournament.id == 1) return TournamentUserStatus.favorite;
    if (tournament.id == 2) return TournamentUserStatus.participating;
    return TournamentUserStatus.none;
  }
}
