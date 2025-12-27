import 'package:flutter/material.dart';

import '../../database/db_controller.dart';
import '../../models/player.dart';
import '../../models/sport_category.dart';
import '../../models/team_request.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/player_request_widget.dart';

class PlayerRequestsScreen extends StatefulWidget {
  final int teamId;
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
      if ((await DB().acceptRequestToTeam(request.playerId, widget.teamId)) == false) {
        throw Exception('Failed to accept request');
      }
      
      if (mounted) {
        setState(() {
          _requests.removeWhere((r) => r.playerId == request.playerId);
        });
        
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
        //TODO: gestire il caso in cui la squadra è piena
        if ((await DB().acceptRequestToTeam(request.playerId, widget.teamId)) == false) {
          if (mounted) {
            if (await DB.Teams.isFull(widget.teamId) && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Team is full. Cannot accept more requests.')),
              );
              break; // Esce dal ciclo se la squadra è piena
            } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error accepting request')),
          );
          }
        }
          throw Exception('Failed to accept request');
        }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: widget.sportCategory.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Requests',
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
      ),
      body: _isLoading
          ? const LoadingATL()
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
                                  backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
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
                                  backgroundColor: Colors.red.shade400,
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
