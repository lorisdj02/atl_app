import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/sport_category.dart';
import '../models/team_request.dart';
import '../utils/atl_colors.dart';
import '../database/db_read.dart';
import '../config/api_json_keys.dart';
import '../database/db_write.dart';
import '../l10n/app_localizations.dart';

class PlayersRequestsWidget extends StatefulWidget {
  final int teamId;
  final SportCategory sportCategory;
  final VoidCallback onRequestsChanged;

  const PlayersRequestsWidget({
    super.key,
    required this.teamId,
    required this.sportCategory,
    required this.onRequestsChanged,
  });

  @override
  State<PlayersRequestsWidget> createState() => _PlayersRequestsWidgetState();
}

class _PlayersRequestsWidgetState extends State<PlayersRequestsWidget> {
  List<TeamRequest> _requests = [];
  Map<int, Player?> _playersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests(context);
  }

  Future<void> _loadRequests(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    try {
      final data = await DBRead.getPlayerRequests(widget.teamId);

      if (mounted) {
        setState(() {
          _requests = data[ApiJsonKeys.teamRequests] as List<TeamRequest>;
          _playersCache = data[ApiJsonKeys.playersCache] as Map<int, Player?>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorLoadingData(e.toString()))));
      }
    }
  }

  Future<void> _acceptRequest(TeamRequest request) async {
    final l10n = AppLocalizations.of(context);
    try {
      final bool success = await DBWrite.acceptTeamRequest(
        widget.teamId,
        playerId: request.playerId,
      );

      if (mounted && success) {
        setState(() {
          _requests.removeWhere((r) => r.playerId == request.playerId);
        });
        widget.onRequestsChanged();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.playerJoinedTeam(_playersCache[request.playerId]?.username ?? l10n.player),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorAcceptingRequest(e.toString()))));
      }
    }
  }

  Future<void> _rejectRequest(TeamRequest request) async {
    final l10n = AppLocalizations.of(context);
    try {
      await DBWrite.rejectTeamRequest(
        widget.teamId,
        playerId: request.playerId,
      );

      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.playerId == request.playerId);
        });
        widget.onRequestsChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorRejectingRequest(e.toString()))));
      }
    }
  }

  Future<void> _acceptAll() async {
    final l10n = AppLocalizations.of(context);
    final bool success = await DBWrite.acceptTeamRequest(
      widget.teamId,
      allRequests: true,
    );

    if (mounted && success) {
      setState(() {
        _requests.clear();
      });
      widget.onRequestsChanged();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allRequestsAccepted),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectAll() async {
    final l10n = AppLocalizations.of(context);
    final bool success = await DBWrite.rejectTeamRequest(
      widget.teamId,
      allRequests: true,
    );
    if (mounted && success) {
      setState(() {
        _requests.clear();
      });
      widget.onRequestsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: ATLColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ATLColors.getPrimaryColor(widget.sportCategory),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    l10n.requestsTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.dark_mode, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.darkModeComingSoonMsg)),
                    );
                  },
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          l10n.noRequests,
                          style: TextStyle(
                            fontSize: 18,
                            color: ATLColors.subtext,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      final player = _playersCache[request.playerId];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade300,
                              ),
                              child: player?.imageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        player!.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 30,
                                              );
                                            },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            // Player name
                            Expanded(
                              child: Text(
                                player?.username ??
                                    '${l10n.player} ${request.playerId}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            // Accept button
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => _acceptRequest(request),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Reject button
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ATLColors.darkBlue,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => _rejectRequest(request),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
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
                        backgroundColor: Colors.green,
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
                        backgroundColor: ATLColors.darkBlue,
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
