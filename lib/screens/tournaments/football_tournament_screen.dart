import 'package:flutter/material.dart';
import '../../database/db_controller.dart';
import '../../models/tournament.dart';
import '../../models/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/football_standing.dart';
import '../../models/team.dart';
import '../../models/player.dart';
import '../../models/football_tournament_stats.dart';
import '../../models/team_stats.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/small_football_match_widget.dart';
import '../../widgets/football_standings_team_widget.dart';
import '../../widgets/players_stats_widget.dart';

class FootballTournamentScreen extends StatefulWidget {
  final Tournament tournament;
  final SportCategory sportCategory;

  const FootballTournamentScreen({
    super.key,
    required this.tournament,
    required this.sportCategory,
  });

  @override
  State<FootballTournamentScreen> createState() =>
      _FootballTournamentScreenState();
}

class _FootballTournamentScreenState extends State<FootballTournamentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<FootballMatch>? _matches;
  List<FootballStanding>? _standings;
  List<Player>? _players;
  Map<int, Team> _teamsCache = {};
  Map<int, String> _captainNamesCache = {};
  Map<int, TeamStats?> _playerStatsCache = {};

  bool _fixturesLoaded = false;
  bool _tablesLoaded = false;
  bool _statsLoaded = false;

  int _selectedDay = 1;
  int _currentIndex = 0;

  int? _minutesPerRound;
  int? _minutesPerPause;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTabData(0);
    _loadMinutes();
  }

  Future<void> _loadMinutes() async {
    _minutesPerRound = await DB.Tournaments.getMinutesPerRoundById(
      widget.tournament.id,
    );
    _minutesPerPause = await DB.Tournaments.getMinutesPerPauseById(
      widget.tournament.id,
    );

    if (mounted && (_minutesPerRound == null || _minutesPerPause == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading sport settings')),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    final newIndex = _tabController.index;
    if (_currentIndex != newIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
      _loadTabData(newIndex);
    }
  }

  Future<void> _loadTabData(int tabIndex) async {
    switch (tabIndex) {
      case 0: // Fixtures
        if (!_fixturesLoaded) {
          await _loadFixtures();
        }
        break;
      case 1: // Tables
        if (!_tablesLoaded) {
          await _loadTables();
        }
        break;
      case 2: // Stats
        if (!_statsLoaded) {
          await _loadStats();
        }
        break;
    }
  }

  Future<void> _loadFixtures() async {
    try {
      final matches = await DB.FootballMatches.getMatchesByTournament(
        widget.tournament.id,
      );

      // Load teams for matches
      final teamIds = <int>{};
      for (var match in matches) {
        teamIds.add(match.homeTeamId);
        teamIds.add(match.awayTeamId);
      }

      for (var teamId in teamIds) {
        if (!_teamsCache.containsKey(teamId)) {
          final team = await DB.Teams.getById(teamId);
          if (team != null) {
            _teamsCache[teamId] = team;
          }
        }
      }

      if (mounted) {
        setState(() {
          _matches = matches;
          _fixturesLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading fixtures: $e')));
      }
    }
  }

  Future<void> _reloadFixtures() async {
    setState(() {
      _fixturesLoaded = false;
    });
    await _loadFixtures();
  }

  Future<void> _loadTables() async {
    try {
      final standings = await DB.FootballStandings.getStandingsByTournament(
        widget.tournament.id,
      );

      // Load teams and captains
      final teamIds = standings.map((s) => s.teamId).toSet();

      for (var teamId in teamIds) {
        if (!_teamsCache.containsKey(teamId)) {
          final team = await DB.Teams.getById(teamId);
          if (team != null) {
            _teamsCache[teamId] = team;

            // Load captain name
            final captain = await DB.Players.getByPlayerId(team.captainId);
            if (captain != null) {
              _captainNamesCache[teamId] = '${captain.name} ${captain.surname}';
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _standings = standings;
          _tablesLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading tables: $e')));
      }
    }
  }

  Future<void> _loadStats() async {
    try {
      // Carica le statistiche del torneo
      final List<FootballTournamentStats> stats = await DB
          .FootballTournamentStats.getByTournamentId(widget.tournament.id);

      // Carica i giocatori e i team
      final playerIds = stats.map((s) => s.playerId).toList();
      final teamIds = stats.map((s) => s.teamId).toList();

      final loadedPlayers = <Player>[];

      for (var playerId in playerIds) {
        final player = await DB.Players.getByPlayerId(playerId);
        if (player != null) {
          loadedPlayers.add(player);
        }
      }

      for (var teamId in teamIds) {
        if (!_teamsCache.containsKey(teamId)) {
          final team = await DB.Teams.getById(teamId);
          if (team != null) {
            _teamsCache[teamId] = team;
          }
        }
      }

      // Converti FootballTournamentStats in TeamStats per la compatibilità con il widget
      for (var stat in stats) {
        _playerStatsCache[stat.playerId] = TeamStats(
          playerId: stat.playerId,
          teamId: stat.teamId,
          motm: stat.motm,
          goals: stat.goals,
        );
      }

      if (mounted) {
        setState(() {
          _players = loadedPlayers;
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

  List<String> _getGroups() {
    final groupCount = widget.tournament.numGroups;
    return List.generate(
      groupCount,
      (i) => String.fromCharCode(65 + i),
    ); // A, B, C...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.tournament.name,
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
                Expanded(child: _buildTabButton('Fixtures', 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton('Tables', 1)),
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
        children: [_buildFixturesTab(), _buildTablesTab(), _buildStatsTab()],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Navigate to chat
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat coming soon')),
                );
              },
              backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
              icon: const Icon(Icons.chat_bubble, color: Colors.white),
              label: const Text(
                'Chat',
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
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
        setState(() {
          _currentIndex = index;
        });
        _loadTabData(index);
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

  Widget _buildFixturesTab() {
    if (!_fixturesLoaded) {
      return const LoadingATL();
    }

    if (_matches == null || _matches!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No matches scheduled',
              style: TextStyle(fontSize: 18, color: ATLColors.subtext),
            ),
          ],
        ),
      );
    }

    final groups = _getGroups();
    final maxDay = _matches!.fold<int>(
      0,
      (max, match) => match.day != null && match.day! > max ? match.day! : max,
    );

    return Column(
      children: [
        // Day selector
        Container(
          margin: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(maxDay, (index) {
                final day = index + 1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('Day $day'),
                    selected: _selectedDay == day,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDay = day;
                        });
                      }
                    },
                    selectedColor: ATLColors.getPrimaryColor(
                      widget.sportCategory,
                    ),
                    labelStyle: TextStyle(
                      color: _selectedDay == day
                          ? Colors.white
                          : ATLColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
        // Matches by group
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupMatches = _matches!
                  .where((m) => m.group == group && m.day == _selectedDay)
                  .toList();

              if (groupMatches.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'GROUP $group',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.darkBlue,
                      ),
                    ),
                  ),
                  ...groupMatches.map(
                    (match) => SmallFootballMatchWidget(
                      match: match,
                      homeTeam: _teamsCache[match.homeTeamId],
                      awayTeam: _teamsCache[match.awayTeamId],
                      currentSport: widget.sportCategory,
                      minutesPerRound: _minutesPerRound!,
                      minutesPerPause: _minutesPerPause!,
                      onMatchUpdated: () => _reloadFixtures(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTablesTab() {
    if (!_tablesLoaded) {
      return const LoadingATL();
    }

    if (_standings == null || _standings!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No standings available',
              style: TextStyle(fontSize: 18, color: ATLColors.subtext),
            ),
          ],
        ),
      );
    }

    final groups = _getGroups();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupStandings =
                  _standings!.where((s) => s.group == group).toList()
                    // Ordina per rank (gestito dal DB)
                    ..sort((a, b) => a.rank.compareTo(b.rank));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'GROUP $group',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.darkBlue,
                      ),
                    ),
                  ),
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 40),
                        const Expanded(
                          child: Text(
                            'Team',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.title,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 140,
                          child: Text(
                            'Pts - W - D - L - GD',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.title,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...groupStandings.map((standing) {
                    final team = _teamsCache[standing.teamId];

                    if (team == null) return const SizedBox.shrink();

                    // Colora i team qualificati (basato su standing.qualified dal DB)
                    Color bgColor = Colors.white;
                    if (standing.qualified) {
                      bgColor = ATLColors.getPrimaryColor(widget.sportCategory);
                    }

                    // Calcola la Goal Difference
                    final goalDifference =
                        standing.goalsScored - standing.goalsConceded;

                    return FootballStandingsTeamWidget(
                      team: team,
                      color: bgColor,
                      rank: standing.rank,
                      sportCategory: widget.sportCategory,
                      standingRecord:
                          '${standing.points} - ${standing.won} - ${standing.drawn} - ${standing.lost}',
                      goalDifference: goalDifference,
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: ATLColors.background,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                'Tournament ID: #${widget.tournament.id}',
                style: TextStyle(
                  color: ATLColors.subtext,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
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

    if (_players == null || _players!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No stats available. Keep playing!',
              style: TextStyle(fontSize: 18, color: ATLColors.subtext),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PlayersStatsWidget(
            players: _players!,
            sportCategory: widget.sportCategory,
            playerStats: _playerStatsCache,
            inTournament: true,
            teamsCache: _teamsCache,
          ),
        ),
      ],
    );
  }
}
