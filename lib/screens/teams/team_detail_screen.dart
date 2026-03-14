import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/team_request.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_floating_button.dart';
import 'abstract_team_screen.dart';
import '../../database/db_read.dart';
import '../../database/db_write.dart';
import '../../config/api_json_keys.dart';

class TeamDetailScreen extends AbstractTeamScreen {
  final int teamId;

  const TeamDetailScreen({
    super.key,
    required this.teamId,
    required super.currentSport,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends AbstractTeamScreenState<TeamDetailScreen> {
  TeamRequest? _existingRequest;
  bool _requestLoaded = false;
  bool _isPlayerInTeam = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  int getTeamId() => widget.teamId;

  Future<void> _loadData() async {
    try {
      final UserProvider userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      if (userProvider.isPlayer && userProvider.activeRoleId != null) {
        playerId = userProvider.activeRoleId!;
        final data = await DBRead.getTeamDetailScreen(playerId!, widget.teamId);
        setState(() {
          _existingRequest = data[ApiJsonKeys.existingRequest];
          _isPlayerInTeam = data[ApiJsonKeys.isPlayerInTeam];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading team data: $e')));
      }
    } finally {
      setState(() {
        _requestLoaded = true;
      });
    }
  }

  Future<void> _handleJoinTeam() async {
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    if (!userProvider.isPlayer || userProvider.activeRoleId == null) {
      setState(() {
        _requestLoaded = true;
      });
      return;
    }
    try {
      if (await DBWrite.createTeamRequest(widget.teamId, playerId!) == false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error sending request')),
          );
        }
        return;
      }
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sending request: $e')));
      }
    }
  }

  Future<void> _handleCancelRequest() async {
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    if (!userProvider.isPlayer || userProvider.activeRoleId == null) {
      setState(() {
        _requestLoaded = true;
      });
      return;
    }
    if (_existingRequest == null) return;

    try {
      if (await DBWrite.deleteTeamRequest(
            _existingRequest!.teamId,
            _existingRequest!.playerId,
          ) ==
          false) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error cancelling request')),
          );
        }
        return;
      }
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request cancelled')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cancelling request: $e')));
      }
    }
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
          team?.name ?? 'Team Details',
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
        children: [buildPlayersTab(), buildPalmaresTab(), buildStatsTab()],
      ),
      floatingActionButton:
          (_requestLoaded && !_isPlayerInTeam && playerId != null)
          ? ATLFloatingButton(
              heroTag: 'join_team_fab',
              onPressed: _existingRequest != null
                  ? _handleCancelRequest
                  : _handleJoinTeam,
              backgroundColor: _existingRequest != null
                  ? Colors.red
                  : ATLColors.getPrimaryColor(widget.currentSport),
              icon: _existingRequest != null ? Icons.cancel : Icons.add,
              label: _existingRequest != null ? 'Cancel Request' : 'Join Team',
            )
          : null,
    );
  }
}
