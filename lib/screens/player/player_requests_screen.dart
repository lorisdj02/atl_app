import 'package:atl_app/database/responses/player_requests_response.dart';
import 'package:atl_app/database/services/team_service.dart';
import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/enums/sport_category.dart';
import '../../models/team_request.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/player_request_widget.dart';
import '../../l10n/app_localizations.dart';

class PlayerRequestsScreen extends StatefulWidget {
  final double teamId;
  final SportCategory sportCategory;

  const PlayerRequestsScreen({
    super.key,
    required this.teamId,
    required this.sportCategory,
  });

  @override
  State<PlayerRequestsScreen> createState() => _PlayerRequestsScreenState();
}

class _PlayerRequestsScreenState extends State<PlayerRequestsScreen> {
  List<TeamRequest> _requests = [];
  Map<double, Player> _playersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final l10n = AppLocalizations.of(context);
    try {
      final PlayerRequestsResponse data = await TeamService
          .Read.getTeamRequestsScreen(widget.teamId.toDouble());

      if (mounted) {
        setState(() {
          _requests = data.teamRequests;
          _playersCache = data.playersCache;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorLoadingRequests(e.toString()))),
        );
      }
    }
  }

  Future<void> _acceptRequest(TeamRequest request) async {
    final l10n = AppLocalizations.of(context);
    try {
      await TeamService.Write.acceptTeamRequest(
        teamId: widget.teamId.toDouble(),
        playerId: request.playerId.toDouble(),
      );

      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.playerId == request.playerId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.playerJoinedTeam(
                _playersCache[request.playerId]?.username ?? l10n.player,
              ),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorAcceptingRequest(e.toString()))),
        );
      }
    }
  }

  Future<void> _rejectRequest(TeamRequest request) async {
    final l10n = AppLocalizations.of(context);
    try {
      await TeamService.Write.rejectTeamRequest(
        teamId: widget.teamId.toDouble(),
        playerId: request.playerId.toDouble(),
      );

      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.playerId == request.playerId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorRejectingRequest(e.toString()))),
        );
      }
    }
  }

  Future<void> _acceptAll() async {
    final l10n = AppLocalizations.of(context);
    await TeamService.Write.acceptTeamRequest(
      teamId: widget.teamId.toDouble(),
      acceptAll: true,
    );

    if (mounted) {
      setState(() {
        _requests.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allRequestsAccepted),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorAcceptingAllRequests)));
      }
    }
  }

  Future<void> _rejectAll() async {
    final l10n = AppLocalizations.of(context);
    await TeamService.Write.rejectTeamRequest(
      teamId: widget.teamId.toDouble(),
      rejectAll: true,
    );

    if (mounted) {
      setState(() {
        _requests.clear();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorRejectingAllRequests)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
          l10n.requestsTitle,
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
                SnackBar(content: Text(l10n.darkModeComingSoonSnack)),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingATL()
          : _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    l10n.noRequests,
                    style: const TextStyle(
                      fontSize: 18,
                      color: ATLColors.subtext,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final player = _playersCache[request.playerId];

                      return PlayerRequestWidget(
                        request: request,
                        player: player,
                        onAccept: () => _acceptRequest(request),
                        onReject: () => _rejectRequest(request),
                      );
                    },
                  ),
                ),
                // Bottom buttons
                if (_requests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _acceptAll,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ATLColors.getPrimaryColor(
                                widget.sportCategory,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.acceptAll,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _rejectAll,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.rejectAll,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
