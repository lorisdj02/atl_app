import 'package:atl_app/database/db_write.dart';
import 'package:atl_app/models/tournament_participation.dart';
import 'package:atl_app/utils/home_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../player/player_requests_screen.dart';
import '../player/pay_participation_screen.dart';
import '../../widgets/atl_floating_button.dart';
import 'abstract_team_screen.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';

class MyTeamScreen extends AbstractTeamScreen {
  const MyTeamScreen({super.key, required super.currentSport});

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends AbstractTeamScreenState<MyTeamScreen> {
  int _pendingPaymentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPendingPaymentsCount();
  }

  @override
  int getTeamId() => userProvider.currentTeamId!;

  @override
  double getBottomPadding() => 120;

  Future<void> _loadPendingPaymentsCount() async {
    try {
      final int? teamId = userProvider.currentTeamId;

      if (teamId == null) return;

      final List<TournamentParticipation> participations = await DBRead.getTeamParticipations(teamId);

      if (mounted) {
        setState(() {
          _pendingPaymentsCount =
              participations.length;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _showRequestsScreen() async {
    final int? teamId = userProvider.currentTeamId;

    if (teamId == null) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PlayerRequestsScreen(
              teamId: teamId,
              sportCategory: widget.currentSport,
            ),
          ),
        )
        .then((_) {
          loadPlayersData(userProvider.currentTeamId!);
        });
  }

  Future<void> _showPaymentScreen() async {
    final int? teamId = userProvider.currentTeamId;

    if (teamId == null) return;

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => PayParticipationScreen(
              teamId: teamId,
              sportCategory: widget.currentSport,
              playerId: playerId!,
            ),
          ),
        )
        .then((_) {
          _loadPendingPaymentsCount();
        });
  }

  Future<void> _handlePlayerLongPress(Player player) async {
    if (team == null) return;

    final isCaptain = playerId == team!.captainId;
    final isViceCaptain =
        playerId == team!.vice1Id || playerId == team!.vice2Id;
    if (!isCaptain && !isViceCaptain) return;

    final isPlayerVice =
        player.playerId == team!.vice1Id || player.playerId == team!.vice2Id;
    final isPlayerCaptain = player.playerId == team!.captainId;

    if (player.playerId == playerId || isPlayerCaptain) return;

    final options = <Widget>[];

    if (isCaptain) {
      if (!isPlayerVice) {
        options.add(
          ListTile(
            leading: const Icon(Icons.arrow_upward, color: Colors.green),
            title: Text(l10n.promoteToBViceCaptain),
            onTap: () {
              Navigator.pop(context);
              _promoteToViceCaptain(player);
            },
          ),
        );
      } else {
        options.add(
          ListTile(
            leading: const Icon(Icons.arrow_downward, color: Colors.orange),
            title: Text(l10n.demote),
            onTap: () {
              Navigator.pop(context);
              _demoteViceCaptain(player);
            },
          ),
        );
      }
    }

    if (isCaptain || isViceCaptain) {
      options.add(
        ListTile(
          leading: const Icon(Icons.person_remove, color: Colors.red),
          title: Text(l10n.expelFromTeam),
          onTap: () {
            Navigator.pop(context);
            _expelPlayer(player);
          },
        ),
      );
    }

    if (options.isEmpty) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              player.username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(height: 1),
          ...options,
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _promoteToViceCaptain(Player player) async {
    final hasVice1 = team!.vice1Id != null;
    final hasVice2 = team!.vice2Id != null;

    if (hasVice1 && hasVice2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.maxViceCaptains),
        ),
      );
      return;
    }

    try {
      final success = await DBWrite.promoteOrDemoteInTeam(
        team!.id,
        player.playerId,
        promote: true,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.promotedToVC(player.username)),
          ),
        );
        await loadPlayersData(team!.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToPromote),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorText(e.toString()))));
    }
  }

  Future<void> _demoteViceCaptain(Player player) async {
    try {
      final success = await DBWrite.promoteOrDemoteInTeam(
        team!.id,
        player.playerId,
        promote: false,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.demoted(player.username))));
        await loadPlayersData(team!.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToDemote)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorText(e.toString()))));
    }
  }

  Future<void> _expelPlayer(Player player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.expelPlayerTitle),
        content: Text(l10n.expelPlayerConfirm(player.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.expelButton),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await DBWrite.expelPlayer(team!.id, player.playerId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.expelled(player.username))),
        );
        await loadPlayersData(team!.id);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.failedToExpel)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorText(e.toString()))));
    }
  }

  Future<void> _showLeaveTeamDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveTeamTitle),
        content: Text(l10n.leaveTeamConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if ((await DBWrite.leaveTeam(team!.id, playerId!)) == false) {
                if (team!.captainId == playerId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.captainCannotLeaveTeam),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorLeavingTeam),
                    ),
                  );
                }
              } else if (mounted) {
                AccountProvider userProvider = Provider.of<AccountProvider>(
                  context,
                  listen: false,
                );
                userProvider.clearCurrentTeamId();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeRouter.getHomeScreen(userProvider.activeAccount!),
                    ),
                    (route) => false,
                  );
                }
              }
            },
            child: Text(l10n.leaveButton, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.myTeamTab,
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
                SnackBar(content: Text(l10n.darkModeComingSoonSnack)),
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
                Expanded(child: buildTabButton(l10n.players, 0)),
                const SizedBox(width: 12),
                Expanded(child: buildTabButton(l10n.palmaresTab, 1)),
                const SizedBox(width: 12),
                Expanded(child: buildTabButton(l10n.statsTab, 2)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          buildPlayersTab(
            onLongPress: _handlePlayerLongPress,
            headerWidget: _pendingPaymentsCount > 0
                ? Container(
                    margin: const EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _showPaymentScreen,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      icon: const Icon(Icons.payment, size: 24),
                      label: Text(
                        l10n.pendingPaymentsCount(_pendingPaymentsCount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          buildPalmaresTab(),
          buildStatsTab(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Stack(
        children: [
          Positioned(
            left: 30,
            bottom: 0,
            child: ATLFloatingButton(
              heroTag: 'leave_team_fab',
              onPressed: _showLeaveTeamDialog,
              backgroundColor: Colors.red,
              icon: Icons.exit_to_app,
              label: l10n.leaveTeamLabel,
            ),
          ),
          if (tabController.index == 0)
            Positioned(
              right: 0,
              bottom: 0,
              child: ATLFloatingButton(
                heroTag: 'requests_fab',
                onPressed: _showRequestsScreen,
                backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
                icon: Icons.inbox,
                label: l10n.requestsLabel,
              ),
            ),
        ],
      ),
    );
  }
}
