import 'package:flutter/material.dart';
import '../../database/db_controller.dart';
import '../../models/tournament.dart';
import '../../models/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/football_standing.dart';
import '../../models/team.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/small_football_match_widget.dart';
import '../../widgets/standings_team_widget.dart';

class FootballTournamentScreen extends StatefulWidget {
  final Tournament tournament;
  final SportCategory sportCategory;

  const FootballTournamentScreen({
    super.key,
    required this.tournament,
    required this.sportCategory,
  });

  @override
  State<FootballTournamentScreen> createState() => _FootballTournamentScreenState();
}

class _FootballTournamentScreenState extends State<FootballTournamentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<FootballMatch>? _matches;
  List<FootballStanding>? _standings;
  Map<int, Team> _teamsCache = {};
  Map<int, String> _captainNamesCache = {};
  
  bool _fixturesLoaded = false;
  bool _tablesLoaded = false;
  
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
    _minutesPerRound = await DB.Tournaments.getMinutesPerRoundById(widget.tournament.id);
    _minutesPerPause = await DB.Tournaments.getMinutesPerPauseById(widget.tournament.id);

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
        // TODO: Load stats
        break;
    }
  }

  Future<void> _loadFixtures() async {
    try {
      final matches = await DB.FootballMatches.getMatchesByTournament(widget.tournament.id);
      
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading fixtures: $e')),
        );
      }
    }
  }

  Future<void> _loadTables() async {
    try {
      final standings = await DB.FootballStandings.getStandingsByTournament(widget.tournament.id);
      
      // Load teams and captains
      final teamIds = standings.map((s) => s.teamId).toSet();
      
      for (var teamId in teamIds) {
        if (!_teamsCache.containsKey(teamId)) {
          final team = await DB.Teams.getById(teamId);
          if (team != null) {
            _teamsCache[teamId] = team;
            
            // Load captain name
            final captain = await DB.Players.getByUserId(team.captainId);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tables: $e')),
        );
      }
    }
  }

  List<String> _getGroups() {
    final groupCount = widget.tournament.numGroups;
    return List.generate(groupCount, (i) => String.fromCharCode(65 + i)); // A, B, C...
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
        children: [
          _buildFixturesTab(),
          _buildTablesTab(),
          _buildStatsTab(),
        ],
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
    final maxDay = _matches!.fold<int>(0, (max, match) => match.day != null && match.day! > max ? match.day! : max);

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
                    selectedColor: ATLColors.getPrimaryColor(widget.sportCategory),
                    labelStyle: TextStyle(
                      color: _selectedDay == day ? Colors.white : ATLColors.darkBlue,
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
                  ...groupMatches.map((match) => SmallFootballMatchWidget(
                        match: match,
                        homeTeam: _teamsCache[match.homeTeamId],
                        awayTeam: _teamsCache[match.awayTeamId],
                        currentSport: widget.sportCategory,
                        minutesPerRound: _minutesPerRound!,
                        minutesPerPause: _minutesPerPause!,
                      )),
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
    
    // Calcola quanti team per gruppo si qualificano
    final qualifiedPerGroup = widget.tournament.numGroups > 0 
        ? (widget.tournament.qualified / widget.tournament.numGroups).ceil()
        : 0;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final groupStandings = _standings!
            .where((s) => s.group == group)
            .toList()
          ..sort((a, b) => b.points.compareTo(a.points));

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    width: 100,
                    child: Text(
                      'Pts - W - D - L',
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
            ...groupStandings.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final standing = entry.value;
              final team = _teamsCache[standing.teamId];
              
              if (team == null) return const SizedBox.shrink();

              // Colora solo i team nelle prime X posizioni qualificate
              Color bgColor = Colors.white;
              if (rank <= qualifiedPerGroup) {
                bgColor = ATLColors.getPrimaryColor(widget.sportCategory);
              }

              return StandingsTeamWidget(
                team: team,
                color: bgColor,
                rank: rank,
                sportCategory: widget.sportCategory,
                standingRecord: '${standing.points} - ${standing.won} - ${standing.drawn} - ${standing.lost}',
              );
            }),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tournament stats coming soon',
            style: TextStyle(fontSize: 18, color: ATLColors.subtext),
          ),
        ],
      ),
    );
  }
}
