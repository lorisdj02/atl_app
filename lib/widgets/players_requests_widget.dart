import 'package:flutter/material.dart';

import '../database/db_controller.dart';
import '../models/player.dart';
import '../models/sport_category.dart';
import '../models/team_request.dart';
import '../utils/atl_colors.dart';

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
  final Map<int, Player?> _playersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await DB.TeamRequests.getByTeamId(widget.teamId);
      
      // Carica i dati dei giocatori
      for (var request in requests) {
        final player = await DB.Players.getByPlayerId(request.playerId);
        _playersCache[request.playerId] = player;
      }
      
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading requests: $e')),
        );
      }
    }
  }

  Future<void> _acceptRequest(TeamRequest request) async {
    try {
      await DB.Players.joinTeam(request.playerId, widget.teamId);
      await DB.TeamRequests.deleteByPlayerId(request.playerId);
      
      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.playerId == request.playerId);
        });
        widget.onRequestsChanged();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_playersCache[request.playerId]?.username ?? "Player"} joined the team'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accepting request: $e')),
        );
      }
    }
  }

  Future<void> _rejectRequest(TeamRequest request) async {
    try {
      await DB.TeamRequests.deleteByPlayerId(request.playerId);
      
      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.playerId == request.playerId);
        });
        widget.onRequestsChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting request: $e')),
        );
      }
    }
  }

  Future<void> _acceptAll() async {
    final requestsCopy = List<TeamRequest>.from(_requests);
    
    for (var request in requestsCopy) {
      try {
        await DB.Players.joinTeam(request.playerId, widget.teamId);
        await DB.TeamRequests.deleteByPlayerId(request.playerId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error accepting request: $e')),
          );
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _requests.clear();
      });
      widget.onRequestsChanged();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All requests accepted'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _rejectAll() async {
    final requestsCopy = List<TeamRequest>.from(_requests);
    
    for (var request in requestsCopy) {
      try {
        await DB.TeamRequests.deleteByPlayerId(request.playerId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error rejecting request: $e')),
          );
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _requests.clear();
      });
      widget.onRequestsChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Requests',
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
                      const SnackBar(content: Text('Dark mode coming soon')),
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
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No requests',
                              style: TextStyle(fontSize: 18, color: ATLColors.subtext),
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
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.person, color: Colors.white, size: 30);
                                            },
                                          ),
                                        )
                                      : const Icon(Icons.person, color: Colors.white, size: 30),
                                ),
                                const SizedBox(width: 16),
                                // Player name
                                Expanded(
                                  child: Text(
                                    player?.username ?? 'Player ${request.playerId}',
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
                                    icon: const Icon(Icons.check, color: Colors.white, size: 20),
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
                                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
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
                      child: const Text(
                        'Accept all',
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
                      child: const Text(
                        'Reject all',
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
