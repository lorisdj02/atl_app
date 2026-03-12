import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/database/db_read.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team.dart';
import '../../models/sport_category.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/atl_floating_button.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../player/my_team_screen.dart';
import '../player/create_team_screen.dart';
import '../../models/user.dart';
import '../../widgets/search_team_widget.dart';
import '../../widgets/ranks_team_widget.dart';
import '../../widgets/search_dialog_widget.dart';
import 'team_detail_screen.dart';

class TeamScreen extends StatefulWidget {
  final SportCategory currentSport;

  const TeamScreen({super.key, required this.currentSport});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen>
    with SingleTickerProviderStateMixin {
  List<Team>? _teams;
  bool _isLoading = true;
  TabController? _tabController;
  int _previousTabIndex = 0;
  Key _scaffoldKey = UniqueKey(); // Chiave per forzare rebuild

  // Cache unificata: associa teamId -> team e captainName
  Map<int, Team> _teamsCache = {};
  Map<int, String> _captainNamePerTeam = {};

  // Filtri
  final TextEditingController _searchController = TextEditingController();

  // Filtri avanzati
  String? _selectedCity;
  bool? _vipFilter;
  RangeValues _playersRange = const RangeValues(1, 24);

  // Filtri temporanei per il dialog
  String? _tempSelectedCity;
  bool? _tempVipFilter;
  RangeValues _tempPlayersRange = const RangeValues(1, 24);

  /// Verifica se ci sono filtri attivi
  bool get _hasActiveFilters {
    return _selectedCity != null ||
        _vipFilter != null ||
        _playersRange != const RangeValues(1, 24);
  }

  @override
  void initState() {
    super.initState();
    _refreshState();
  }

  void _refreshState() {
    // Dispose del vecchio controller PRIMA del setState
    _tabController?.removeListener(() {});
    _tabController?.dispose();

    setState(() {
      final UserProvider userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      final isPlayer = userProvider.isPlayer;
      int? teamId = userProvider.currentTeamId;
      final showMyTeamTab =
          !userProvider.isGuest && isPlayer && teamId != null && teamId != -1;

      // Forza rebuild completo
      _scaffoldKey = UniqueKey();

      // Guest: 2 tabs (Search + Ranks)
      // Coordinator: 2 tabs (Search + Ranks)
      // Player con team: 3 tabs (Search + My team + Ranks)
      _tabController = TabController(
        length: showMyTeamTab ? 3 : 2,
        vsync: this,
      );

      if (showMyTeamTab) {
        _tabController!.addListener(() {
          // Naviga a My Team screen quando il tab 1 è selezionato (solo se showMyTeamTab è true)
          if (_tabController!.index == 1 && _tabController!.indexIsChanging) {
            // Resetta subito al tab precedente per evitare l'animazione
            _tabController!.index = _previousTabIndex;

            Future.microtask(() {
              if (mounted) {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MyTeamScreen(currentSport: widget.currentSport),
                      ),
                    )
                    .then((_) {
                      // Ricarica i dati quando si torna da My Team
                      if (mounted) {
                        _loadTeams();
                      }
                    });
              }
            });
          } else if (_tabController!.index != 1) {
            // Salva l'indice corrente come precedente solo se non è My team
            _previousTabIndex = _tabController!.index;
            _loadTeams();
          }
        });
      } else {
        _tabController!.addListener(() {
          // Senza My team tab, tutti gli indici sono validi
          _previousTabIndex = _tabController!.index;
          _loadTeams();
        });
      }
    });

    _loadTeams();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    // Svuota la cache solo quando si esce dalla sezione team
    _teamsCache.clear();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    setState(() => _isLoading = true);
    try {
      final UserProvider userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      final isPlayer = userProvider.activeUser?.role == UserRole.player;

      final data = await DBRead.getTeamsScreen(widget.currentSport);
      final Map<int, Team> teamsCache = data[ApiJsonKeys.teamsCache];
      final Map<int, String> captainNamePerTeam =
          data[ApiJsonKeys.captainNamePerTeam];

      // Calcola l'indice di Ranks in base alla presenza di My team tab
      final ranksTabIndex = (!userProvider.isGuest && isPlayer) ? 2 : 1;

      List<Team> teams = teamsCache.values.toList();
      // In "Ranks" ordina per rankPts - con controllo null-safe
      if (_tabController != null && _tabController!.index == ranksTabIndex) {
        teams.sort((a, b) => (b.rankPts ?? 0).compareTo(a.rankPts ?? 0));
      }

      setState(() {
        _teams = teams;
        _teamsCache = teamsCache;
        _captainNamePerTeam = captainNamePerTeam;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading teams: $e')));
      }
    }
  }

  void _showFilterDialog() {
    // Inizializza filtri temporanei con valori correnti
    _tempSelectedCity = _selectedCity;
    _tempVipFilter = _vipFilter;
    _tempPlayersRange = _playersRange;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: ATLColors.background,
          title: const Text('Filtri'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filtro Città
                const Text(
                  'Città',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                    hint: const Text('Seleziona città'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Tutte')),
                      ...['1', '2', '3'].map((city) {
                        return DropdownMenuItem(
                          value: city,
                          child: Text('Città $city'),
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

                // Filtro VIP
                const Text(
                  'VIP',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<bool?>(
                    value: _tempVipFilter,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Tutti'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tutti')),
                      DropdownMenuItem(value: true, child: Text('Solo VIP')),
                      DropdownMenuItem(value: false, child: Text('Non VIP')),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        _tempVipFilter = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Filtro Numero Giocatori
                const Text(
                  'Numero Giocatori',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _tempPlayersRange,
                  min: 1,
                  max: 24,
                  divisions: 24,
                  activeColor: ATLColors.darkBlue,
                  labels: RangeLabels(
                    '${_tempPlayersRange.start.round()}',
                    '${_tempPlayersRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setDialogState(() {
                      _tempPlayersRange = values;
                    });
                  },
                ),
                Text(
                  '${_tempPlayersRange.start.round()} - ${_tempPlayersRange.end.round()} giocatori',
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
                  _vipFilter = null;
                  _playersRange = const RangeValues(1, 24);
                });
                Navigator.pop(context);
                _loadTeams();
              },
              style: TextButton.styleFrom(foregroundColor: ATLColors.darkBlue),
              child: const Text('Reset'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCity = _tempSelectedCity;
                  _vipFilter = _tempVipFilter;
                  _playersRange = _tempPlayersRange;
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: ATLColors.darkBlue),
              child: const Text('Applica'),
            ),
          ],
        ),
      ),
    );
  }

  List<Team> _applyFilters(List<Team> teams) {
    return teams.where((t) {
      // Filtro città
      if (_selectedCity != null && t.cityId != _selectedCity) {
        return false;
      }

      // Filtro VIP
      if (_vipFilter != null && t.vip != _vipFilter) {
        return false;
      }

      // Filtro numero giocatori
      if (t.players < _playersRange.start || t.players > _playersRange.end) {
        return false;
      }

      // Filtro ricerca per nome o alias
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final matchesName = t.name.toLowerCase().contains(query);
        final matchesAlias = t.alias?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesAlias) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final isPlayer = userProvider.activeUser?.role == UserRole.player;
    final isGuest = userProvider.isGuest;
    final currentTab = _tabController?.index ?? 0;
    final int? teamId = userProvider.currentTeamId;
    final showMyTeamTab =
        !isGuest && isPlayer && teamId != null && teamId != -1;

    return Scaffold(
      key: _scaffoldKey, // Aggiungi chiave per forzare rebuild
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        // Info icon - SOLO nel tab Ranks, in alto a sinistra
        leading: currentTab == (showMyTeamTab ? 2 : 1)
            ? IconButton(
                icon: const Icon(Icons.info_outline, color: ATLColors.darkBlue),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: ATLColors.background,
                      title: const Text('Ranks Info'),
                      content: const Text(
                        'I team sono ordinati per punti ranking (Rank Pts). '
                        'Più alto è il punteggio, migliore è la posizione in classifica.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: ATLColors.darkBlue,
                          ),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
        title: Text(
          '${widget.currentSport.name.toUpperCase()} TEAMS',
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
                const SnackBar(content: Text('Dark mode coming soon')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(106),
          child: Column(
            children: [
              // Tabs: Search / My team / Ranks
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                height: 44,
                child: Row(
                  children: [
                    Expanded(child: _buildTabButton('Search', 0)),
                    // My team - SOLO per player (non guest)
                    if (showMyTeamTab) ...[
                      const SizedBox(width: 12),
                      Expanded(child: _buildTabButton('My team', 1)),
                    ],
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTabButton('Ranks', showMyTeamTab ? 2 : 1),
                    ),
                  ],
                ),
              ),

              // Search bar + Filter + ID search
              Padding(
                padding: currentTab == 0
                    ? const EdgeInsets.fromLTRB(16, 4, 16, 8)
                    : const EdgeInsets.fromLTRB(16, 4, 0, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: (() {
                        return Center(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Name (Alias)',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        );
                      }()),
                    ),
                    const SizedBox(width: 12),
                    // Filter button - only in Search tab (index 0)
                    if (currentTab == 0)
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
                    const SizedBox(width: 12),
                    // ID search button - only in Search tab (index 0)
                    if (currentTab == 0)
                      Container(
                        decoration: BoxDecoration(
                          color: ATLColors.darkBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextButton.icon(
                          icon: const Icon(Icons.search, color: Colors.white),
                          label: const Text(
                            'ID',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => SearchDialogWidget(
                                teamId: null,
                                isTeam: true,
                                isTournament: false,
                                onFound: (team, tournament) {
                                  if (team != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TeamDetailScreen(
                                          currentSport: widget.currentSport,
                                          teamId: team.id,
                                        ),
                                      ),
                                    );
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
          // Guest mode banner - SOLO per guest
          if (isGuest)
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
                        'Guest mode: Login to create/join teams',
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

          // Lista team
          Positioned.fill(
            top: isGuest ? 44 : 0,
            child: _isLoading
                ? const LoadingATL()
                : _teams == null || _teams!.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group,
                          color: ATLColors.getPrimaryColor(widget.currentSport),
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nessun team disponibile',
                          style: TextStyle(
                            color: ATLColors.darkBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Torna più tardi',
                          style: TextStyle(
                            color: ATLColors.subtext,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _applyFilters(_teams!).isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: ATLColors.getPrimaryColor(widget.currentSport),
                          size: 80,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nessun team trovato',
                          style: TextStyle(
                            color: ATLColors.darkBlue,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hasActiveFilters
                              ? 'Prova a modificare i filtri'
                              : 'Torna più tardi',
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
                    itemCount: _applyFilters(_teams!).length,
                    itemBuilder: (context, index) {
                      final filteredTeams = _applyFilters(_teams!);
                      final team = filteredTeams[index];

                      // Calcola l'indice corretto per Ranks in base alla presenza di My team
                      final ranksTabIndex = showMyTeamTab ? 2 : 1;
                      final showRankPts = currentTab == ranksTabIndex;

                      if (showRankPts) {
                        return RanksTeamWidget(
                          team: team,
                          imageUrl: team.imageUrl,
                          rankPts: showRankPts ? (team.rankPts ?? 0) : null,
                          sportCategory: widget.currentSport,
                          captainName: _captainNamePerTeam[team.id],
                          rank: _teams!.indexOf(team) + 1,
                          color: _teams!.indexOf(team) == 0
                              ? ATLColors.getPrimaryColor(widget.currentSport)
                              : _teams!.indexOf(team) == 1
                              ? ATLColors.getSecondaryColor(widget.currentSport)
                              : _teams!.indexOf(team) == 2
                              ? ATLColors.getTertiaryColor(widget.currentSport)
                              : Colors.white,
                        );
                      } else {
                        return SearchTeamWidget(
                          team: team,
                          sportCategory: widget.currentSport,
                          imageUrl: team.imageUrl,
                          captainName: _captainNamePerTeam[team.id],
                        );
                      }
                    },
                  ),
          ),

          // Floating Action Button "Crea" - SOLO per player (non guest) in Search tab senza team
          if (!isGuest &&
              isPlayer &&
              currentTab == 0 &&
              (teamId == null || teamId == -1))
            Positioned(
              right: 16,
              bottom: 16,
              child: ATLFloatingButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateTeamScreen(currentSport: widget.currentSport),
                    ),
                  );

                  // Se il team è stato creato, ricarica completamente lo screen
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            TeamScreen(currentSport: widget.currentSport),
                      ),
                    );
                  }
                },
                backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
                icon: Icons.add,
                label: 'Crea',
              ),
            ),
        ],
      ),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 2,
        onTap: (index) {
          NavigationHelper.navigateToSection(
            context: context,
            index: index,
            currentSport: widget.currentSport,
            currentIndex: 2,
          );
        },
        currentSport: widget.currentSport,
        isHome: false,
        userId: userProvider.activeUser?.id,
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController?.index == index;
    return GestureDetector(
      onTap: () => _tabController?.animateTo(index),
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
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
