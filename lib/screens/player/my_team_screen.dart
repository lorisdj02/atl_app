import 'package:atl_app/database/db_write.dart';
import 'package:atl_app/utils/home_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/player.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import 'player_requests_screen.dart';
import 'pay_participation_screen.dart';
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

      final data = await DBRead.getTeamParticipations(teamId);

      if (mounted) {
        setState(() {
          _pendingPaymentsCount =
              data[ApiJsonKeys.tournamentParticipations]?.length ?? 0;
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
            title: const Text('Promote to Vice Captain'),
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
            title: const Text('Demote'),
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
          title: const Text('Expel from Team'),
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
        const SnackBar(
          content: Text('Maximum 2 Vice Captains allowed. Demote one first.'),
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
            content: Text('${player.username} promoted to Vice Captain'),
          ),
        );
        await loadPlayersData(team!.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to promote player to Vice Captain'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        ).showSnackBar(SnackBar(content: Text('${player.username} demoted')));
        await loadPlayersData(team!.id);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to demote player')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _expelPlayer(Player player) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expel Player'),
        content: Text(
          'Are you sure you want to expel ${player.username} from the team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Expel'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await DBWrite.leaveTeam(team!.id, player.playerId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${player.username} expelled from team')),
        );
        await loadPlayersData(team!.id);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to expel player')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showLeaveTeamDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Team'),
        content: const Text('Are you sure you want to leave this team?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if ((await DBWrite.leaveTeam(team!.id, playerId!)) == false) {
                if (team!.captainId == playerId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Captains cannot leave the team. Please assign a vice-captain before leaving.',
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Error leaving the team. Please try again later.',
                      ),
                    ),
                  );
                }
              } else if (mounted) {
                UserProvider userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                userProvider.clearCurrentTeamId();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) =>
                          HomeRouter.getHomeScreen(userProvider.activeUser!),
                    ),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
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
        title: const Text(
          'My team',
          style: TextStyle(
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
                Expanded(child: buildTabButton('Players', 0)),
                const SizedBox(width: 12),
                Expanded(child: buildTabButton('Palmares', 1)),
                const SizedBox(width: 12),
                Expanded(child: buildTabButton('Stats', 2)),
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
                        'Pending Payments ($_pendingPaymentsCount)',
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
              label: 'Leave Team',
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
                label: 'Requests',
              ),
            ),
        ],
      ),
    );
  }
}
