import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../database/db_controller.dart';
import '../../models/sport_category.dart';
import '../../models/team.dart';
import '../../models/player.dart';
import '../../models/palmares.dart';
import '../../models/tournament.dart';
import '../../models/coordinator.dart';
import '../../models/field.dart';
import '../../models/team_stats.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/palmares_widget.dart';
import '../../widgets/players_widget.dart';
import '../../widgets/players_stats_widget.dart';
import 'player_requests_screen.dart';
import 'pay_participation_screen.dart';

class MyTeamScreen extends StatefulWidget {
  final SportCategory currentSport;

  const MyTeamScreen({
    super.key,
    required this.currentSport,
  });

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Team? _myTeam;
  List<Player>? _players;
  List<Palmares>? _palmares;
  List<Tournament>? _tournaments;
  int _pendingPaymentsCount = 0;
  
  // Cache per palmares
  final Map<int, Coordinator?> _coordinatorCache = {};
  final Map<int, Field?> _fieldCache = {};
  
  // Cache per stats
  final Map<int, TeamStats?> _playerStatsCache = {};
  
  bool _playersLoaded = false;
  bool _palmaresLoaded = false;
  bool _statsLoaded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Load initial tab data
    _loadTabData(0);
    _loadPendingPaymentsCount();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    // Svuota la cache solo quando si esce completamente da MyTeamScreen
    _clearCache();
    super.dispose();
  }

  void _clearCache() {
    _coordinatorCache.clear();
    _fieldCache.clear();
    _playerStatsCache.clear();
  }

  void _onTabChanged() {
    if (!mounted) return;
    setState(() {
      _loadTabData(_tabController.index);
    });
  }

  Future<void> _loadTabData(int tabIndex) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int teamId = userProvider.currentTeamId!;

    switch (tabIndex) {
      case 0: // Players
        if (!_playersLoaded) {
          await _loadPlayersData(teamId);
        }
        break;
      case 1: // Palmares
        if (!_palmaresLoaded) {
          await _loadPalmaresData(teamId);
        }
        break;
      case 2: // Stats
        if (!_statsLoaded) {
          await _loadStatsData(teamId);
        }
        break;
    }
  }

  Future<void> _loadPlayersData(int teamId) async {
    try {
      final team = await DB.Teams.getById(teamId);
      final players = await DB.Players.getByTeam(teamId);
      
      if (mounted) {
        setState(() {
          _myTeam = team;
          _players = players;
          _playersLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading players: $e')),
        );
      }
    }
  }

  Future<void> _showRequestsScreen() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int? teamId = userProvider.currentTeamId;
    
    if (teamId == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlayerRequestsScreen(
          teamId: teamId,
          sportCategory: widget.currentSport,
        ),
      ),
    ).then((_) {
      // Quando si torna dalla schermata, aggiorna la tab Players
      _loadPlayersData(userProvider.currentTeamId!);
    });
  }

  Future<void> _loadPalmaresData(int teamId) async {
    try {
      final palmares = await DB.Palmares.getByTeam(teamId);
      
      // Carica i tornei associati al palmares
      final tournamentIds = palmares.map((p) => p.tournamentId).toSet();
      final tournaments = <Tournament>[];
      for (var id in tournamentIds) {
        final tournament = await DB.Tournaments.getById(id);
        if (tournament != null) {
          tournaments.add(tournament);
          
          // Pre-carica coordinator e field nella cache solo se non già presenti
          if (!_coordinatorCache.containsKey(tournament.coordinatorId)) {
            final coordinator = await DB.Coordinators.getByCoordinatorId(tournament.coordinatorId);
            _coordinatorCache[tournament.coordinatorId] = coordinator;
          }
          
          if (!_fieldCache.containsKey(tournament.fieldId)) {
            final field = await DB.Fields.getById(tournament.fieldId);
            _fieldCache[tournament.fieldId] = field;
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _palmares = palmares;
          _tournaments = tournaments;
          _palmaresLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading palmares: $e')),
        );
      }
    }
  }

  Future<void> _loadStatsData(int teamId) async {
    try {
      // Riutilizza i players se già caricati
      if (_players == null) {
        final players = await DB.Players.getByTeam(teamId);
        if (mounted) {
          setState(() {
            _players = players;
          });
        }
      }
      
      // Carica le statistiche per ogni giocatore
      if (_players != null) {
        for (var player in _players!) {
          if (!_playerStatsCache.containsKey(player.id)) {
            final stats = await DB.TeamStats.getStatsForPlayerInTeam(player.id, teamId);
            _playerStatsCache[player.id] = stats;
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _statsLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading stats: $e')),
        );
      }
    }
  }

  Future<void> _loadPendingPaymentsCount() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final int? teamId = userProvider.currentTeamId;
      
      if (teamId == null) return;
      
      final participations = await DB.TournamentPartecipations.getByTeamId(teamId);
      final pendingCount = participations.where((p) => (p.toPay ?? 0) > 0).length;
      
      if (mounted) {
        setState(() {
          _pendingPaymentsCount = pendingCount;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _showPaymentScreen() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final int? teamId = userProvider.currentTeamId;
    
    if (teamId == null) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PayParticipationScreen(
          teamId: teamId,
          sportCategory: widget.currentSport,
        ),
      ),
    ).then((_) {
      _loadPendingPaymentsCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: widget.currentSport.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 50,
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Players', 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton('Palmares', 1)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton('Stats', 2)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildPlayersTab(),
          _buildPalmaresTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showRequestsScreen,
              backgroundColor: widget.currentSport.primaryColor,
              icon: const Icon(Icons.inbox, color: Colors.white),
              label: const Text(
                'Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersTab() {
    if (!_playersLoaded) {
      return const LoadingATL();
    }

    return Column(
      children: [
        if (_pendingPaymentsCount > 0)
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _showPaymentScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.payment, size: 24),
              label: Text(
                'Pending Payments ($_pendingPaymentsCount)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        Expanded(
          child: PlayersWidget(
            players: _players ?? [],
            team: _myTeam,
            sportCategory: widget.currentSport,
          ),
        ),
      ],
    );
  }

  Widget _buildPalmaresTab() {
    if (!_palmaresLoaded) {
      return const LoadingATL();
    }

    if (_palmares == null || _palmares!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No trophies yet',
              style: TextStyle(fontSize: 18, color: ATLColors.subtext),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _palmares!.length,
      itemBuilder: (context, index) {
        final palmares = _palmares![index];
        final tournament = _tournaments?.firstWhere(
          (t) => t.id == palmares.tournamentId,
        );

        if (tournament == null) {
          return const SizedBox.shrink();
        }

        return PalmaresWidget(
          palmares: palmares,
          tournament: tournament,
          sportCategory: widget.currentSport,
          coordinator: _coordinatorCache[tournament.coordinatorId],
          field: _fieldCache[tournament.fieldId],
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (!_statsLoaded) {
      return const LoadingATL();
    }

    return PlayersStatsWidget(
      players: _players ?? [],
      sportCategory: widget.currentSport,
      playerStats: _playerStatsCache,
    );
  }
}
