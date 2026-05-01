import 'package:atl_app/database/responses/football_tournament_response.dart';
import 'package:atl_app/database/services/tournament_service.dart';
import 'package:atl_app/models/final_stage_bracket.dart';
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/enums/sport_category.dart';
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
import '../../l10n/app_localizations.dart';

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
  Map<double, Team> _teamsCache = {};
  Map<double, FootballTeamStats> _playerStatsCache = {};

  List<FinalStageBracket> _finalStageBrackets = [];

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

  AppLocalizations get _l10n => AppLocalizations.of(context);

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
    final FootballTournamentResponse data = await TournamentService.getTournamentScreen(
      widget.tournament.id.toDouble(),
      widget.sportCategory,
    );

    setState(() {
      _matches = data.matches;
      _standings = data.standings;
      _players = data.players;
      _teamsCache = data.teamsCache;
      _playerStatsCache = Map<double, FootballTeamStats>.from(
        data.footballPlayerStatsCache,
      );
      _minutesPerRound = data.minutesPerRound;
      _minutesPerPause = data.minutesPerPause;
      _finalStageBrackets = data.finalStageBrackets;
      _fixturesLoaded = true;
      _tablesLoaded = true;
      _statsLoaded = true;
      _isInitialized = true;
    });
    } catch (e) {
      // Handle error (e.g., show a snackbar)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.errorLoadingDataGeneric(e.toString())),
          ),
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
                Expanded(child: _buildTabButton(_l10n.fixturesTab, 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton(_l10n.tablesTab, 1)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton(_l10n.stats, 2)),
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
                  SnackBar(content: Text(_l10n.chatComingSoon)),
                );
              },
              backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
              icon: const Icon(Icons.chat_bubble, color: Colors.white),
              label: Text(
                _l10n.chatLabel,
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
      phases.add({
        'id': 'day_$i',
        'label': _l10n.dayLabel(i),
        'isDay': true,
        'day': i,
      });
    }

    // Add playoff phases based on qualified count
    final qualified = widget.tournament.numTeamsQualified;

    if (qualified >= 16) {
      phases.add({
        'id': 'of',
        'label': _l10n.roundOf16Label,
        'isDay': false,
        'groupPrefix': 'OF',
      });
    }
    if (qualified >= 8) {
      phases.add({
        'id': 'qf',
        'label': _l10n.quarterFinalsLabel,
        'isDay': false,
        'groupPrefix': 'QF',
      });
    }
    if (qualified >= 4) {
      phases.add({
        'id': 'sf',
        'label': _l10n.semiFinalsLabel,
        'isDay': false,
        'groupPrefix': 'SF',
      });
    }
    if (qualified >= 2) {
      phases.add({
        'id': 'fi',
        'label': _l10n.finalLabel,
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
    final qualified = widget.tournament.numTeamsQualified;

    // Special case for Final (FI) which doesn't have a number
    if (groupPrefix == 'FI') {
      if (qualified == 2) {
        return _l10n.teamsTbdAfterGroupStage;
      } else {
        // qualified >= 4
        return _l10n.winnersOfSemifinals(1, 2);
      }
    }

    // Extract number from group (e.g., 'QF1' -> 1)
    final numberMatch = RegExp(r'\d+').firstMatch(group);
    if (numberMatch == null) return '';

    final groupNumber = int.parse(numberMatch.group(0)!);

    switch (groupPrefix) {
      case 'OF': // Round of 16
        return _l10n.teamsTbdAfterGroupStage;

      case 'QF': // Quarter Finals
        if (qualified == 8) {
          return _l10n.teamsTbdAfterGroupStage;
        } else {
          // qualified >= 16
          // QF1 <- OF1 e OF2, QF2 <- OF3 e OF4, etc.
          final of1 = (groupNumber - 1) * 2 + 1;
          final of2 = (groupNumber - 1) * 2 + 2;
          return _l10n.winnersOfRoundOf16(of1, of2);
        }

      case 'SF': // Semifinals
        if (qualified == 4) {
          return _l10n.teamsTbdAfterGroupStage;
        } else {
          // qualified >= 8
          // SF1 <- QF1 e QF2, SF2 <- QF3 e QF4
          final qf1 = (groupNumber - 1) * 2 + 1;
          final qf2 = (groupNumber - 1) * 2 + 2;
          return _l10n.winnersOfQuarterFinals(qf1, qf2);
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _l10n.noMatchesScheduled,
              style: const TextStyle(fontSize: 18, color: ATLColors.subtext),
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
      return _buildGroupStageMatches(selectedPhaseData['day'] as double);
    } else {
      // Playoff phase
      return _buildPlayoffMatches(
        selectedPhaseData['groupPrefix'] as String,
        selectedPhaseData['label'] as String,
      );
    }
  }

  Widget _buildGroupStageMatches(double day) {
    final groups = _getGroups();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final groupMatches = _matches
          .where((m) => m.groupName == group && m.day == day)
            .toList();

        if (groupMatches.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _l10n.groupLabel(group),
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
        .where((m) => m.groupName.startsWith(groupPrefix))
        .toList();

    if (playoffMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _l10n.noMatchesForPhaseYet,
            style: const TextStyle(fontSize: 16, color: ATLColors.subtext),
          ),
        ),
      );
    }

    // Group matches by their group identifier (e.g., SF1, SF2, QF1, etc.)
    final matchesByGroup = <String, List<FootballMatch>>{};
    for (var match in playoffMatches) {
      final group = match.groupName;
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.leaderboard, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _l10n.noStandingsAvailable,
              style: const TextStyle(fontSize: 18, color: ATLColors.subtext),
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
                  label: Text(_l10n.groupStageTab),
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
                  label: Text(_l10n.roadToVictoryTab),
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
                  _standings.where((s) => s.groupName == group).toList()
                    // Ordina per rank (gestito dal DB)
                    ..sort((a, b) => a.rankPos.compareTo(b.rankPos));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _l10n.groupLabel(group),
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
                        Expanded(
                          child: Text(
                            _l10n.teamLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.title,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: Text(
                            _l10n.standingsHeaderAbbrev,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
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
                      rank: standing.rankPos,
                      sportCategory: widget.sportCategory,
                      standingRecord:
                          '${standing.pts} - ${standing.won} - ${standing.drawn} - ${standing.lost}',
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
                _l10n.tournamentIdLabel(widget.tournament.id),
                style: const TextStyle(
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
    // TODO: da rifare totalmente!
    return RoadToVictoryWidget(
      tournament: widget.tournament,
      sportCategory: widget.sportCategory,
      matches: _matches,
      finalStageBrackets: _finalStageBrackets,
      teamsCache: _teamsCache,
    );
  }

  Widget _buildStatsTab() {
    if (!_statsLoaded) {
      return const LoadingATL();
    }

    if (_players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _l10n.noStatsAvailable,
              style: const TextStyle(fontSize: 18, color: ATLColors.subtext),
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
