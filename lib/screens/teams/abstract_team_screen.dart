import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/database/db_read.dart';
import 'package:atl_app/database/responses/abstract_team_response.dart';
import 'package:atl_app/database/responses/players_in_team_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/sport_category.dart';
import '../../models/team.dart';
import '../../models/player.dart';
import '../../models/palmares.dart';
import '../../models/tournament.dart';
import '../../models/coordinator.dart';
import '../../models/field.dart';
import '../../models/football_team_stats.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/palmares_widget.dart';
import '../../widgets/players_widget.dart';
import '../../widgets/players_stats_widget.dart';
import '../../l10n/app_localizations.dart';

abstract class AbstractTeamScreen extends StatefulWidget {
  final SportCategory currentSport;

  const AbstractTeamScreen({super.key, required this.currentSport});
}

abstract class AbstractTeamScreenState<T extends AbstractTeamScreen>
    extends State<T>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  Team? team;
  late AccountProvider userProvider;
  late int? playerId;

  List<Player>? players;
  List<Palmares>? palmares;
  List<Tournament>? tournaments;

  List<Player>? historicalPlayers;

  // Cache per palmares
  Map<int, Coordinator?> coordinatorCache = {};
  Map<int, Field?> fieldsCache = {};

  // Cache per stats
  Map<int, FootballTeamStats?> playerStatsCache = {};

  // Cache for city names
  Map<int, String> cityNamePerField = {};

  bool playersLoaded = false;
  bool palmaresLoaded = false;
  bool statsLoaded = false;
  bool statsShowAll = false;

  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(onTabChanged);
    userProvider = Provider.of<AccountProvider>(context, listen: false);
    playerId = userProvider.activeRoleId;
    loadData();
  }

  @override
  void dispose() {
    tabController.removeListener(onTabChanged);
    tabController.dispose();
    clearCache();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final AbstractTeamResponse data = await DBRead.getAbstractTeamScreen(getTeamId());
      setState(() {
        team = data.team;
        players = data.players;
        palmares = data.palmares;
        tournaments = data.tournaments;
        coordinatorCache = data.coordinatorCache ?? {};
        fieldsCache = data.fieldsCache ?? {};
        playerStatsCache = data.footballPlayerStatsCache ?? {};
        cityNamePerField = data.cityNamePerField ?? {};
        historicalPlayers = data.historicalPlayers ?? [];
        playersLoaded = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorLoadingTeamData(e.toString()))));
      }
    }
  }

  void clearCache() {
    coordinatorCache.clear();
    fieldsCache.clear();
    playerStatsCache.clear();
  }

  void onTabChanged() {
    if (tabController.indexIsChanging) return;

    setState(() {
      if (tabController.index == 1 && !palmaresLoaded) {
        palmaresLoaded = true;
      } else if (tabController.index == 2 && !statsLoaded) {
        statsLoaded = true;
      }
    });
  }

  int getTeamId();

  Future<void> loadPlayersData(int teamId) async {
    final PlayersInTeamResponse data = await DBRead.getPlayersInTeam(teamId);

    List<Player> loadedPlayers = data.players;
    if (loadedPlayers.isNotEmpty) {
      // Sort players: Captain, Vice1, Vice2, then others
      loadedPlayers.sort((a, b) {
        if (a.playerId == team!.captainId) return -1;
        if (b.playerId == team!.captainId) return 1;
        if (a.playerId == team!.vice1Id) return -1;
        if (b.playerId == team!.vice1Id) return 1;
        if (a.playerId == team!.vice2Id) return -1;
        if (b.playerId == team!.vice2Id) return 1;
        return 0;
      });

      if (mounted) {
        setState(() {
          players = loadedPlayers;
          playersLoaded = true;
        });
      }
    }
  }

  Widget buildTabButton(String text, int index) {
    final isSelected = tabController.index == index;
    return GestureDetector(
      onTap: () {
        tabController.animateTo(index);
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

  Widget buildStatsFilterButton(String text, bool value) {
    // legacy: replaced by animated toggle below
    return const SizedBox.shrink();
  }

  Widget buildStatsToggle() {
    // Two centered toggle buttons (no slider), using primary color for active
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              statsShowAll = false;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statsShowAll
                  ? Colors.white
                  : ATLColors.getPrimaryColor(widget.currentSport),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ATLColors.darkBlue.withOpacity(0.12)),
            ),
            child: Text(
              l10n.actualPlayersToggle,
              style: TextStyle(
                color: statsShowAll ? ATLColors.darkBlue : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              statsShowAll = true;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statsShowAll
                  ? ATLColors.getPrimaryColor(widget.currentSport)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ATLColors.darkBlue.withOpacity(0.12)),
            ),
            child: Text(
              l10n.allPlayersToggle,
              style: TextStyle(
                color: statsShowAll ? Colors.white : ATLColors.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPlayersTab({
    void Function(Player)? onLongPress,
    Widget? headerWidget,
  }) {
    if (!playersLoaded) {
      return const LoadingATL();
    }

    return Column(
      children: [
        if (headerWidget != null) headerWidget,
        Expanded(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: getBottomPadding()),
                child: PlayersWidget(
                  players: players ?? [],
                  team: team,
                  sportCategory: widget.currentSport,
                  onLongPress: onLongPress,
                ),
              ),
              buildBottomGradient(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildPalmaresTab() {
    if (!palmaresLoaded) {
      return const LoadingATL();
    }

    // Only VIP teams can see palmares
    if (team == null || (team!.vip != true && team!.players > 0)) {
      return Center(
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
                l10n.vipPalmaresDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: ATLColors.subtext, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.vipUpgradeComingSoonTeam)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.getPrimaryColor(
                    widget.currentSport,
                  ),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  l10n.upgradeToVip,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (palmares == null || palmares!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noTrophiesYet,
              style: const TextStyle(fontSize: 18, color: ATLColors.subtext),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: getBottomPadding()),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: palmares!.length,
            itemBuilder: (context, index) {
              final palmaresItem = palmares![index];
              final tournament = tournaments?.firstWhere(
                (t) => t.id == palmaresItem.tournamentId,
              );

              if (tournament == null) {
                return const SizedBox.shrink();
              }

              return PalmaresWidget(
                palmares: palmaresItem,
                tournament: tournament,
                sportCategory: widget.currentSport,
                coordinator: coordinatorCache[tournament.coordinatorId],
                field: fieldsCache[tournament.fieldId],
                cityName: cityNamePerField[tournament.fieldId],
              );
            },
          ),
        ),
        buildBottomGradient(),
      ],
    );
  }

  Widget buildStatsTab() {
    if (!statsLoaded) {
      return const LoadingATL();
    }

    // Non-VIP teams default to players-only view
    if (team == null || (team!.vip == false && team!.players > 0)) {
      statsShowAll = false;
    }

    // Prepare playerStats map depending on filter
    Map<int, FootballTeamStats?> statsToShow = {};
    if (statsShowAll) {
      statsToShow = Map<int, FootballTeamStats?>.from(playerStatsCache);
    } else {
      final playerIds = (players ?? []).map((p) => p.playerId).toSet();
      statsToShow = Map.fromEntries(
        playerStatsCache.entries.where((e) => playerIds.contains(e.key)),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: getBottomPadding()),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Center(
                  child: team != null && team!.vip == true
                      ? buildStatsToggle()
                      : const SizedBox.shrink(),
                ),
              ),
              Expanded(
                child: PlayersStatsWidget(
                  players: (statsShowAll)
                      ? historicalPlayers ?? []
                      : players ?? [],
                  sportCategory: widget.currentSport,
                  playerStats: statsToShow,
                ),
              ),
            ],
          ),
        ),
        buildBottomGradient(),
      ],
    );
  }

  Widget buildBottomGradient() {
    return Positioned(
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
    );
  }

  double getBottomPadding() => 80;
}
