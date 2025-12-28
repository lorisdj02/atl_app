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

abstract class AbstractTeamScreen extends StatefulWidget {
  final SportCategory currentSport;

  const AbstractTeamScreen({super.key, required this.currentSport});
}

abstract class AbstractTeamScreenState<T extends AbstractTeamScreen>
    extends State<T> with SingleTickerProviderStateMixin {
  late TabController tabController;
  Team? team;
  late UserProvider userProvider;
  late int? playerId;

  List<Player>? players;
  List<Palmares>? palmares;
  List<Tournament>? tournaments;

  // Cache per palmares
  final Map<int, Coordinator?> coordinatorCache = {};
  final Map<int, Field?> fieldCache = {};

  // Cache per stats
  final Map<int, TeamStats?> playerStatsCache = {};

  bool playersLoaded = false;
  bool palmaresLoaded = false;
  bool statsLoaded = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(onTabChanged);
    userProvider = Provider.of<UserProvider>(context, listen: false);
    playerId = userProvider.activeRoleId;
    loadTabData(0);
  }

  @override
  void dispose() {
    tabController.removeListener(onTabChanged);
    tabController.dispose();
    clearCache();
    super.dispose();
  }

  void clearCache() {
    coordinatorCache.clear();
    fieldCache.clear();
    playerStatsCache.clear();
  }

  void onTabChanged() {
    if (!mounted) return;
    setState(() {
      loadTabData(tabController.index);
    });
  }

  Future<void> loadTabData(int tabIndex) async {
    final int teamId = getTeamId();

    switch (tabIndex) {
      case 0:
        if (!playersLoaded) {
          await loadPlayersData(teamId);
        }
        break;
      case 1:
        if (!palmaresLoaded) {
          await loadPalmaresData(teamId);
        }
        break;
      case 2:
        if (!statsLoaded) {
          await loadStatsData(teamId);
        }
        break;
    }
  }

  int getTeamId();

  Future<void> loadPlayersData(int teamId) async {
    try {
      final loadedTeam = await DB.Teams.getById(teamId);
      final loadedPlayers = await DB.Players.getByTeam(teamId);

      // Sort players: Captain, Vice1, Vice2, then others
      loadedPlayers.sort((a, b) {
        if (a.playerId == loadedTeam?.captainId) return -1;
        if (b.playerId == loadedTeam?.captainId) return 1;
        if (a.playerId == loadedTeam?.vice1Id) return -1;
        if (b.playerId == loadedTeam?.vice1Id) return 1;
        if (a.playerId == loadedTeam?.vice2Id) return -1;
        if (b.playerId == loadedTeam?.vice2Id) return 1;
        return 0;
      });

      if (mounted) {
        setState(() {
          team = loadedTeam;
          players = loadedPlayers;
          playersLoaded = true;
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

  Future<void> loadPalmaresData(int teamId) async {
    try {
      final loadedPalmares = await DB.Palmares.getByTeam(teamId);

      final tournamentIds = loadedPalmares.map((p) => p.tournamentId).toSet();
      final loadedTournaments = <Tournament>[];
      for (var id in tournamentIds) {
        final tournament = await DB.Tournaments.getById(id);
        if (tournament != null) {
          loadedTournaments.add(tournament);

          if (!coordinatorCache.containsKey(tournament.coordinatorId)) {
            final coordinator = await DB.Coordinators.getByCoordinatorId(
              tournament.coordinatorId,
            );
            coordinatorCache[tournament.coordinatorId] = coordinator;
          }

          if (!fieldCache.containsKey(tournament.fieldId)) {
            final field = await DB.Fields.getById(tournament.fieldId);
            fieldCache[tournament.fieldId] = field;
          }
        }
      }

      if (mounted) {
        setState(() {
          palmares = loadedPalmares;
          tournaments = loadedTournaments;
          palmaresLoaded = true;
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

  Future<void> loadStatsData(int teamId) async {
    try {
      if (players == null) {
        final loadedPlayers = await DB.Players.getByTeam(teamId);
        if (mounted) {
          setState(() {
            players = loadedPlayers;
          });
        }
      }

      if (players != null) {
        for (var player in players!) {
          if (!playerStatsCache.containsKey(player.id)) {
            final stats = await DB.TeamStats.getStatsForPlayerInTeam(
              player.id,
              teamId,
            );
            playerStatsCache[player.id] = stats;
          }
        }
      }

      if (mounted) {
        setState(() {
          statsLoaded = true;
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

    if (palmares == null || palmares!.isEmpty) {
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
                field: fieldCache[tournament.fieldId],
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

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: getBottomPadding()),
          child: PlayersStatsWidget(
            players: players ?? [],
            sportCategory: widget.currentSport,
            playerStats: playerStatsCache,
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
