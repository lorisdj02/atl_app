import 'package:atl_app/database/services/match_service.dart';
import 'package:atl_app/database/responses/past_assigned_matches_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/referee_bottom_bar.dart';
import '../../models/enums/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/small_football_match_widget.dart';
import '../shop_screen.dart';
import '../profile_screen.dart';
import 'referee_home_screen.dart';
import 'available_matches_screen.dart';
import '../../l10n/app_localizations.dart';

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
  Map<double, Team> _teamsCache = {};
  Map<double, int> _minutesRoundPerTournament = {};
  Map<double, int> _minutesPausePerTournament = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<AccountProvider>(context, listen: false);
      final refereeId = userProvider.activeRoleId;

      if (refereeId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final PastAssignedMatchesResponse data = await MatchService.getPastAssignedMatchesScreen(widget.currentSport);

      if (widget.currentSport != SportCategory.football) {
        setState(() => _isLoading = false);
        return;
      }
      final assignedMatches = data.footballMatches;
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
          _teamsCache = data.teamsCache;
          _minutesRoundPerTournament = data.minutesRoundPerTournament;
          _minutesPausePerTournament = data.minutesPausePerTournament;
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          l10n.historyNavLabel.toUpperCase(),
          style: const TextStyle(
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
                SnackBar(content: Text(l10n.darkModeComingSoonSnack)),
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
        accountId: Provider.of<AccountProvider>(
          context,
          listen: false,
        ).activeAccount?.id,
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context);
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
                l10n.noMatchHistoryTitle,
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noMatchHistorySubtitle,
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
            minutesPerRound:
                _minutesRoundPerTournament[match.tournamentId] ?? 0,
            minutesPerPause:
                _minutesPausePerTournament[match.tournamentId] ?? 0,
            onMatchUpdated: () => _loadData(),
          ),
        );
      },
    );
  }
}
