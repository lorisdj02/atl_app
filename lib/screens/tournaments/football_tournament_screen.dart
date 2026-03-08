import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/football_standing.dart';
import '../../models/team.dart';
import '../../models/player.dart';
import '../../models/football_team_stats.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/small_football_match_widget.dart';
import '../../widgets/football_standings_team_widget.dart';
import '../../widgets/players_stats_widget.dart';
import '../../widgets/road_to_victory_widget.dart';
import '../../widgets/tournament_info_dialog.dart';
import '../../config/api_json_keys.dart';
import '../../database/db_read.dart';

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

  List<FootballMatch> _matches = [];
  List<FootballStanding> _standings = [];
  List<Player> _players = [];
  Map<int, Team> _teamsCache = {};
  Map<int, FootballTeamStats> _playerStatsCache = {};

  bool _fixturesLoaded = false;
  bool _tablesLoaded = false;
  bool _statsLoaded = false;
  bool _isInitialized = false;

  String _selectedPhase = 'day_1'; // Format: 'day_1', 'of', 'qf', 'sf', 'fi'
  String _selectedTableView =
      'group_stage'; // 'group_stage' or 'road_to_victory'
  int _currentIndex = 0;

  int? _minutesPerRound;
  int? _minutesPerPause;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this screen (but not on first load)
    if (_isInitialized) {
      _loadData();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onTabChanged() async {
    if (!mounted) return;
    final newIndex = _tabController.index;
    if (_currentIndex != newIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
      await _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _fixturesLoaded = false;
      _tablesLoaded = false;
      _statsLoaded = false;
    });

    try{
    Map<String, dynamic> data = await DBRead.getFootballTournamentScreen(
      widget.tournament.id,
    );

    setState(() {
      _matches = data[ApiJsonKeys.matches] as List<FootballMatch>;
      _standings = data[ApiJsonKeys.standings] as List<FootballStanding>;
      _players = data[ApiJsonKeys.players] as List<Player>;
      _teamsCache = Map<int, Team>.from(data[ApiJsonKeys.teamsCache]);
      _playerStatsCache = Map<int, FootballTeamStats>.from(
        data[ApiJsonKeys.playerStatsCache],
      );
      _minutesPerRound = data[ApiJsonKeys.minutesPerRound] as int?;
      _minutesPerPause = data[ApiJsonKeys.minutesPerPause] as int?;
      _fixturesLoaded = true;
      _tablesLoaded = true;
      _statsLoaded = true;
      _isInitialized = true;
    });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
      setState(() {
        _fixturesLoaded = true;
        _tablesLoaded = true;
        _statsLoaded = true;
      });
    }
  }

  List<String> _getGroups() {
    final groupCount = widget.tournament.numGroups;
    return List.generate(
      groupCount,
      (i) => String.fromCharCode(65 + i),
    ); // A, B, C...
  }

  void _showFullInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return TournamentInfoDialog(
          tournament: widget.tournament,
          sportCategory: widget.sportCategory,
        );
      },
    );
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
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showFullInfoDialog,
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
        _loadData();
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

  List<Map<String, dynamic>> _getPhases() {
    final phases = <Map<String, dynamic>>[];

    // Add group stage days
    final maxDay = _matches.fold<int>(
      0,
      (max, match) => match.day != null && match.day! > max ? match.day! : max,
    );

    for (int i = 1; i <= maxDay; i++) {
      phases.add({'id': 'day_$i', 'label': 'Day $i', 'isDay': true, 'day': i});
    }

    // Add playoff phases based on qualified count
    final qualified = widget.tournament.qualified;

    if (qualified >= 16) {
      phases.add({
        'id': 'of',
        'label': 'Round of 16',
        'isDay': false,
        'groupPrefix': 'OF',
      });
    }
    if (qualified >= 8) {
      phases.add({
        'id': 'qf',
        'label': 'Quarter Finals',
        'isDay': false,
        'groupPrefix': 'QF',
      });
    }
    if (qualified >= 4) {
      phases.add({
        'id': 'sf',
        'label': 'Semifinals',
        'isDay': false,
        'groupPrefix': 'SF',
      });
    }
    if (qualified >= 2) {
      phases.add({
        'id': 'fi',
        'label': 'Final',
        'isDay': false,
        'groupPrefix': 'FI',
      });
    }

    return phases;
  }

  String _getPlayoffTitle(String group, String phaseLabel) {
    // Extract number from group (e.g., 'SF1' -> '1', 'QF2' -> '2')
    final numberMatch = RegExp(r'\d+').firstMatch(group);
    if (numberMatch != null) {
      final number = numberMatch.group(0);
      return '$phaseLabel $number';
    }
    return phaseLabel;
  }

  String _getSpecificGroupInfoMessage(String group, String groupPrefix) {
    final qualified = widget.tournament.qualified;

    // Special case for Final (FI) which doesn't have a number
    if (groupPrefix == 'FI') {
      if (qualified == 2) {
        return 'Teams will be determined at the end of group stage';
      } else {
        // qualified >= 4
        return 'Winners of Semifinal 1 and Semifinal 2';
      }
    }

    // Extract number from group (e.g., 'QF1' -> 1)
    final numberMatch = RegExp(r'\d+').firstMatch(group);
    if (numberMatch == null) return '';

    final groupNumber = int.parse(numberMatch.group(0)!);

    switch (groupPrefix) {
      case 'OF': // Round of 16
        return 'Teams will be determined at the end of group stage';

      case 'QF': // Quarter Finals
        if (qualified == 8) {
          return 'Teams will be determined at the end of group stage';
        } else {
          // qualified >= 16
          // QF1 <- OF1 e OF2, QF2 <- OF3 e OF4, etc.
          final of1 = (groupNumber - 1) * 2 + 1;
          final of2 = (groupNumber - 1) * 2 + 2;
          return 'Winners of Round of 16 #$of1 and Round of 16 #$of2';
        }

      case 'SF': // Semifinals
        if (qualified == 4) {
          return 'Teams will be determined at the end of group stage';
        } else {
          // qualified >= 8
          // SF1 <- QF1 e QF2, SF2 <- QF3 e QF4
          final qf1 = (groupNumber - 1) * 2 + 1;
          final qf2 = (groupNumber - 1) * 2 + 2;
          return 'Winners of Quarter Final $qf1 and Quarter Final $qf2';
        }

      default:
        return '';
    }
  }

  Widget _buildFixturesTab() {
    if (!_fixturesLoaded) {
      return const LoadingATL();
    }

    if (_matches.isEmpty) {
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

    final phases = _getPhases();

    // Initialize selected phase if needed
    if (_selectedPhase.isEmpty ||
        !phases.any((p) => p['id'] == _selectedPhase)) {
      _selectedPhase = phases.first['id'];
    }

    return Column(
      children: [
        // Phase selector
        Container(
          margin: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: phases.map((phase) {
                final phaseId = phase['id'] as String;
                final phaseLabel = phase['label'] as String;
                final isSelected = _selectedPhase == phaseId;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(phaseLabel),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPhase = phaseId;
                        });
                      }
                    },
                    selectedColor: ATLColors.getPrimaryColor(
                      widget.sportCategory,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : ATLColors.darkBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Matches
        Expanded(child: _buildMatchesForSelectedPhase(phases)),
      ],
    );
  }

  Widget _buildMatchesForSelectedPhase(List<Map<String, dynamic>> phases) {
    final selectedPhaseData = phases.firstWhere(
      (p) => p['id'] == _selectedPhase,
      orElse: () => phases.first,
    );

    if (selectedPhaseData['isDay'] == true) {
      // Group stage day
      return _buildGroupStageMatches(selectedPhaseData['day'] as int);
    } else {
      // Playoff phase
      return _buildPlayoffMatches(
        selectedPhaseData['groupPrefix'] as String,
        selectedPhaseData['label'] as String,
      );
    }
  }

  Widget _buildGroupStageMatches(int day) {
    final groups = _getGroups();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final groupMatches = _matches
            .where((m) => m.group == group && m.day == day)
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
                onMatchUpdated: _loadData,
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildPlayoffMatches(String groupPrefix, String phaseLabel) {
    // Find all matches with groups starting with the prefix
    final playoffMatches = _matches
        .where((m) => m.group.startsWith(groupPrefix))
        .toList();

    if (playoffMatches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No matches for this phase yet',
            style: TextStyle(fontSize: 16, color: ATLColors.subtext),
          ),
        ),
      );
    }

    // Group matches by their group identifier (e.g., SF1, SF2, QF1, etc.)
    final matchesByGroup = <String, List<FootballMatch>>{};
    for (var match in playoffMatches) {
      final group = match.group;
      matchesByGroup.putIfAbsent(group, () => []).add(match);
    }

    // Sort groups
    final sortedGroups = matchesByGroup.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sortedGroups.length,
      itemBuilder: (context, index) {
        final group = sortedGroups[index];
        final matches = matchesByGroup[group]!;
        final title = _getPlayoffTitle(group, phaseLabel);
        final infoMessage = _getSpecificGroupInfoMessage(group, groupPrefix);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ATLColors.darkBlue,
                    ),
                  ),
                  if (infoMessage.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      infoMessage,
                      style: TextStyle(
                        fontSize: 12,
                        color: ATLColors.subtext,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ...matches.map(
              (match) => SmallFootballMatchWidget(
                match: match,
                homeTeam: _teamsCache[match.homeTeamId],
                awayTeam: _teamsCache[match.awayTeamId],
                currentSport: widget.sportCategory,
                minutesPerRound: _minutesPerRound!,
                minutesPerPause: _minutesPerPause!,
                onMatchUpdated: _loadData,
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Widget _buildTablesTab() {
    if (!_tablesLoaded) {
      return const LoadingATL();
    }

    if (_standings.isEmpty) {
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

    return Column(
      children: [
        // View selector
        Container(
          margin: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Group Stage'),
                  selected: _selectedTableView == 'group_stage',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTableView = 'group_stage';
                      });
                    }
                  },
                  selectedColor: ATLColors.getPrimaryColor(
                    widget.sportCategory,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedTableView == 'group_stage'
                        ? Colors.white
                        : ATLColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Road to Victory'),
                  selected: _selectedTableView == 'road_to_victory',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedTableView = 'road_to_victory';
                      });
                    }
                  },
                  selectedColor: ATLColors.getPrimaryColor(
                    widget.sportCategory,
                  ),
                  labelStyle: TextStyle(
                    color: _selectedTableView == 'road_to_victory'
                        ? Colors.white
                        : ATLColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _selectedTableView == 'group_stage'
              ? _buildGroupStageView()
              : _buildRoadToVictoryView(),
        ),
      ],
    );
  }

  Widget _buildGroupStageView() {
    final groups = _getGroups();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final groupStandings =
                  _standings.where((s) => s.group == group).toList()
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

  Widget _buildRoadToVictoryView() {
    return RoadToVictoryWidget(
      tournamentId: widget.tournament.id,
      sportCategory: widget.sportCategory,
    );
  }

  Widget _buildStatsTab() {
    if (!_statsLoaded) {
      return const LoadingATL();
    }

    if (_players.isEmpty) {
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
            players: _players,
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
