import 'package:atl_app/database/responses/personal_player_stats_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/sport_category.dart';
import '../../models/player.dart';
import '../../models/football_team_stats.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/football_stat_card.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';
import '../../l10n/app_localizations.dart';

class StatsScreen extends StatefulWidget {
  final SportCategory currentSport;

  const StatsScreen({super.key, required this.currentSport});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = false;
  SportCategory _selectedCategory = SportCategory.football;

  FootballTeamStats? _footballTeamStats;
  Map<SportCategory, int> _numTournamentPerCategory = {};
  Map<SportCategory, int> _numPrivateBookingPerCategory = {};
  Map<SportCategory, int> _numLobbyJoinedPerCategory = {};
  
  // Hardcoded available categories (only football for now)
  static const List<SportCategory> _availableCategories = [
    SportCategory.football,
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    if (userProvider.isPlayer && (userProvider.activeAccount?.isVip ?? false)) {
      _loadStats(userProvider);
    }
  }

  Future<void> _loadStats(AccountProvider userProvider) async {
    if (userProvider.activeRoleId == null || !userProvider.isPlayer) return;
    setState(() => _isLoading = true);
    try {
      final PersonalPlayerStatsResponse data = await DBRead.getPersonalPlayerStatsScreen(
        userProvider.activeRoleId!,
      );

      // Estraggo le stats per categoria
      if (mounted) {
        setState(() {
          _footballTeamStats = data.footballStats;
          _numTournamentPerCategory = data.numTournamentPerCategory;
          _numPrivateBookingPerCategory = data.numPrivateBookingPerCategory;
          _numLobbyJoinedPerCategory = data.numLobbyJoinedPerCategory;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    final user = userProvider.activeAccount;
    final isVip = user?.isVip ?? false;

    if (!isVip) {
      return Scaffold(
        backgroundColor: ATLColors.background,
        appBar: _buildAppBar(showVipBadge: false),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: ATLColors.subtext.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.vipFeature,
                  style: const TextStyle(
                    color: ATLColors.darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.vipFeatureDesc,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ATLColors.subtext, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.vipUpgradeComingSoon)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ATLColors.darkBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    l10n.upgradeToVip,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: _buildAppBar(showVipBadge: true),
      body: Column(
        children: [
          // Category dropdown
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ATLColors.subtext.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SportCategory>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: ATLColors.darkBlue,
                  ),
                  items: _availableCategories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(
                        cat.name[0].toUpperCase() + cat.name.substring(1),
                        style: const TextStyle(color: ATLColors.darkBlue),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null)
                      setState(() => _selectedCategory = value);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingATL())
                : _buildCategoryContent(),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar({required bool showVipBadge}) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: ATLColors.darkBlue,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.statsTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          if (showVipBadge) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.vipBadge,
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      centerTitle: true,
    );
  }

  Widget _buildCategoryContent() {
    final numTournaments = _numTournamentPerCategory[_selectedCategory] ?? 0;

    switch (_selectedCategory) {
      case SportCategory.football:
        return _buildFootballStats(
          numTournaments,
          _footballTeamStats != null ? _footballTeamStats : null,
        );
    }
  }

  Widget _buildFootballStats(
    int numTournaments,
    FootballTeamStats? footballStats,
  ) {
    final l10n = AppLocalizations.of(context);
    int totalGoals = 0;
    int totalMotm = 0;
    int totalYellow = 0;
    int totalRed = 0;

    if (footballStats != null) {
      totalGoals = footballStats.goals;
      totalMotm = footballStats.motm;
      totalYellow = footballStats.yellowCards;
      totalRed = footballStats.redCards;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tournaments played
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: ATLColors.darkBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$numTournaments',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.tournamentsPlayed,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.careerStats,
            style: const TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          FootballStatCard(
            goals: totalGoals,
            motm: totalMotm,
            yellowCards: totalYellow,
            redCards: totalRed,
          ),
        ],
      ),
    );
  }
}
