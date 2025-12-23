import 'dart:math';

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
import '../../models/team_request.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/palmares_widget.dart';
import '../../widgets/players_widget.dart';
import '../../widgets/players_stats_widget.dart';
import '../../widgets/atl_floating_button.dart';

class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  final SportCategory currentSport;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
    required this.currentSport,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Team? _team;
  late UserProvider userProvider;
  late int playerId;

  List<Player>? _players;
  List<Palmares>? _palmares;
  List<Tournament>? _tournaments;

  // Cache per palmares
  final Map<int, Coordinator?> _coordinatorCache = {};
  final Map<int, Field?> _fieldCache = {};

  // Cache per stats
  final Map<int, TeamStats?> _playerStatsCache = {};

  bool _playersLoaded = false;
  bool _palmaresLoaded = false;
  bool _statsLoaded = false;

  // Request tracking
  TeamRequest? _existingRequest;
  bool _requestLoaded = false;
  bool _isPlayerInTeam = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    playerId = userProvider.activeRoleId!;
    // Load initial tab data
    _loadTabData(0);
    _checkPlayerInTeam();
    _loadRequestStatus();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
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
    switch (tabIndex) {
      case 0: // Players
        if (!_playersLoaded) {
          await _loadPlayersData(widget.teamId);
        }
        break;
      case 1: // Palmares
        if (!_palmaresLoaded) {
          await _loadPalmaresData(widget.teamId);
        }
        break;
      case 2: // Stats
        if (!_statsLoaded) {
          await _loadStatsData(widget.teamId);
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
          _team = team;
          _players = players;
          _playersLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading players: $e')));
      }
    }
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
            final coordinator = await DB.Coordinators.getByCoordinatorId(
              tournament.coordinatorId,
            );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading palmares: $e')));
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
            final stats = await DB.TeamStats.getStatsForPlayerInTeam(
              player.id,
              teamId,
            );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading stats: $e')));
      }
    }
  }

  Future<void> _loadRequestStatus() async {
    try {
      final TeamRequest? existingRequest = await DB.TeamRequests.getByTeamAndPlayer(widget.teamId, playerId);
      print("Existing request: $existingRequest");
      if (mounted) {
        setState(() {
          _existingRequest = existingRequest;
          _requestLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _requestLoaded = true;
        });
      }
    }
  }

  Future<void> _checkPlayerInTeam() async {
    try {
      final playAt = await DB.PlaysAt.getByPlayerIdAndCategory(playerId, widget.currentSport);
      if (mounted) {
        setState(() {
          _isPlayerInTeam = playAt != null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlayerInTeam = false;
        });
      }
    }
  }

  Future<void> _handleJoinTeam() async {
    try {
      if(await DB.TeamRequests.addRequest(widget.teamId, playerId) == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error sending request')),
          );
        }
        return;
      }
      await _loadRequestStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending request: $e')));
      }
    }
  }

  Future<void> _handleCancelRequest() async {
    if (_existingRequest == null) return;

    try {
      if (await DB.TeamRequests.deleteRequest(
            _existingRequest!.teamId,
            _existingRequest!.playerId,
          ) ==
          false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error cancelling request')),
          );
        }
        return;
      }
      await _loadRequestStatus();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cancelling request: $e')));
      }
    }
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
        title: Text(
          _team?.name ?? 'Team Details',
          style: const TextStyle(
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
        children: [_buildPlayersTab(), _buildPalmaresTab(), _buildStatsTab()],
      ),
      floatingActionButton: (_requestLoaded && !_isPlayerInTeam)
          ? ATLFloatingButton(
              heroTag: 'join_team_fab',
              onPressed: _existingRequest != null
                  ? _handleCancelRequest
                  : _handleJoinTeam,
              backgroundColor: _existingRequest != null
                  ? Colors.red
                  : widget.currentSport.primaryColor,
              icon: _existingRequest != null ? Icons.cancel : Icons.add,
              label: _existingRequest != null ? 'Cancel Request' : 'Join Team',
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

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: PlayersWidget(
            players: _players ?? [],
            team: _team,
            sportCategory: widget.currentSport,
          ),
        ),
        if (!_isPlayerInTeam)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ATLColors.background.withOpacity(0.0),
                      ATLColors.background.withOpacity(0.7),
                      ATLColors.background,
                    ],
                  ),
                ),
              ),
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

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: ListView.builder(
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
          ),
        ),
        if (!_isPlayerInTeam)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ATLColors.background.withOpacity(0.0),
                      ATLColors.background.withOpacity(0.7),
                      ATLColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsTab() {
    if (!_statsLoaded) {
      return const LoadingATL();
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: PlayersStatsWidget(
            players: _players ?? [],
            sportCategory: widget.currentSport,
            playerStats: _playerStatsCache,
          ),
        ),
        if (!_isPlayerInTeam)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ATLColors.background.withOpacity(0.0),
                      ATLColors.background.withOpacity(0.7),
                      ATLColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
