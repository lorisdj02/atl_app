import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/referee_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_controller.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/small_football_match_widget.dart';
import '../shop_screen.dart';
import '../profile_screen.dart';
import 'referee_home_screen.dart';
import 'available_matches_screen.dart';

class PastAssignedMatchesScreen extends StatefulWidget {
  final SportCategory currentSport;

  const PastAssignedMatchesScreen({super.key, required this.currentSport});

  @override
  State<PastAssignedMatchesScreen> createState() =>
      _PastAssignedMatchesScreenState();
}

class _PastAssignedMatchesScreenState extends State<PastAssignedMatchesScreen> {
  bool _isLoading = true;
  List<FootballMatch> _assignedMatches = [];
  Map<int, Team> _teamsCache = {};
  Map<int, int?> _minutesPerRoundCache = {};
  Map<int, int?> _minutesPerPauseCache = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final refereeId = userProvider.activeRoleId;

      if (refereeId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load referee assignments
      final assignments = await DB.RefereeAssignments.getByRefereeId(refereeId);

      // Load all assigned matches
      final assignedMatches = <FootballMatch>[];

      for (var assignment in assignments) {
        final match = await DB.FootballMatches.getById(assignment.matchId);
        if (match != null) {
          assignedMatches.add(match);

          // Load teams for this match
          if (match.homeTeamId != null &&
              !_teamsCache.containsKey(match.homeTeamId)) {
            final team = await DB.Teams.getById(match.homeTeamId!);
            if (team != null) _teamsCache[match.homeTeamId!] = team;
          }
          if (match.awayTeamId != null &&
              !_teamsCache.containsKey(match.awayTeamId)) {
            final team = await DB.Teams.getById(match.awayTeamId!);
            if (team != null) _teamsCache[match.awayTeamId!] = team;
          }

          // Load minutes per round and pause for the tournament
          if (!_minutesPerRoundCache.containsKey(match.tournamentId)) {
            _minutesPerRoundCache[match.tournamentId] =
                await DB.Tournaments.getMinutesPerRoundById(match.tournamentId);
          }
          if (!_minutesPerPauseCache.containsKey(match.tournamentId)) {
            _minutesPerPauseCache[match.tournamentId] =
                await DB.Tournaments.getMinutesPerPauseById(match.tournamentId);
          }
        }
      }

      // Sort matches by scheduled start time (most recent first)
      assignedMatches.sort((a, b) {
        if (a.scheduledStart == null && b.scheduledStart == null) return 0;
        if (a.scheduledStart == null) return 1;
        if (b.scheduledStart == null) return -1;
        return b.scheduledStart!.compareTo(
          a.scheduledStart!,
        ); // Descending order
      });

      if (mounted) {
        setState(() {
          _assignedMatches = assignedMatches;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading assigned matches: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // Already on history screen, do nothing
      return;
    }

    Widget screen;
    switch (index) {
      case 0:
        screen = ShopScreen(currentSport: widget.currentSport);
        break;
      case 1:
        screen = AvailableMatchesScreen(currentSport: widget.currentSport);
        break;
      case 3:
        screen = ProfileScreen(currentSport: widget.currentSport);
        break;
      case 4:
        screen = const RefereeHomeScreen();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
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
        title: const Text(
          'History',
          style: TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode - Coming soon')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.dark_mode,
                color: ATLColors.darkBlue,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: _buildContent(),
      bottomNavigationBar: RefereeBottomBar(
        currentIndex: 2,
        onTap: _onNavTap,
        currentSport: widget.currentSport,
        isHome: false,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: LoadingATL());
    }

    if (_assignedMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                'No match history',
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have not been assigned to any matches yet',
                style: TextStyle(color: ATLColors.subtext, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _assignedMatches.length,
      itemBuilder: (context, index) {
        final match = _assignedMatches[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SmallFootballMatchWidget(
            match: match,
            homeTeam: _teamsCache[match.homeTeamId],
            awayTeam: _teamsCache[match.awayTeamId],
            currentSport: widget.currentSport,
            minutesPerRound: _minutesPerRoundCache[match.tournamentId] ?? 0,
            minutesPerPause: _minutesPerPauseCache[match.tournamentId] ?? 0,
            onMatchUpdated: () => _loadData(),
          ),
        );
      },
    );
  }
}
