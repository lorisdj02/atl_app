import 'package:atl_app/database/responses/team_details_response.dart';
import 'package:atl_app/database/services/team_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../models/team_request.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/atl_floating_button.dart';
import 'abstract_team_screen.dart';

class TeamDetailScreen extends AbstractTeamScreen {
  final double teamId;

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
  double getTeamId() => widget.teamId;

  @override
  Future<void> loadData() async {
    try {
      final AccountProvider userProvider = Provider.of<AccountProvider>(
        context,
        listen: false,
      );

      if (userProvider.isPlayer && userProvider.activeRoleId != null) {
        playerId = userProvider.activeRoleId!;
        final TeamDetailsResponse data = await TeamService
            .Read.getTeamDetailsScreen(widget.teamId.toDouble());
        if (mounted) {
          setState(() {
            team = data.team;
            players = data.players;
            palmares = data.palmares;
            tournaments = data.tournaments;
            coordinatorsCache = data.coordinatorsCache;
            fieldsCache = data.fieldsCache;
            playerStatsCache = data.footballPlayerStatsCache;
            cityNamePerField = data.cityNamePerField;
            historicalPlayers = data.historicalPlayers;
            playersLoaded = true;
            _existingRequest = data.existingRequest;
            _isPlayerInTeam = data.isPlayerInTeam;
            _requestLoaded = true;
          });
        }
      } else {
        await super.loadData();
        if (mounted) setState(() => _requestLoaded = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingTeamData(e.toString()))),
        );
        setState(() => _requestLoaded = true);
      }
    }
  }

  Future<void> _handleJoinTeam() async {
    final AccountProvider userProvider = Provider.of<AccountProvider>(
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
      await TeamService.Write.sendTeamRequest(widget.teamId.toDouble());

      await loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.requestSentSuccessfully)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSendingRequestDetail(e.toString()))),
        );
      }
    }
  }

  Future<void> _handleCancelRequest() async {
    final AccountProvider userProvider = Provider.of<AccountProvider>(
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
      await TeamService.Write.cancelTeamRequest(
        _existingRequest!.teamId.toDouble(),
      );
      await loadData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.requestCancelled)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorCancellingRequestDetail(e.toString())),
          ),
        );
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
          team?.name ?? l10n.teamDetailsTitle,
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
              label: _existingRequest != null
                  ? l10n.cancelRequest
                  : l10n.joinTeam,
            )
          : null,
    );
  }
}
