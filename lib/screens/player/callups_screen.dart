import 'package:atl_app/models/tournament_partecipation.dart';
import 'package:atl_app/utils/atl_colors.dart';
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/player.dart';
import '../../models/sport_category.dart';
import '../../database/repositories/plays_at_repository.dart';
import '../../database/repositories/player_repository.dart';
import '../../database/repositories/callups_repository.dart';
import '../../models/callups.dart';
import '../../database/db_controller.dart';
import '../../models/sport.dart';

class CallupsScreen extends StatefulWidget {
  final Tournament tournament;
  final int teamId;

  const CallupsScreen({
    Key? key,
    required this.tournament,
    required this.teamId,
  }) : super(key: key);

  @override
  State<CallupsScreen> createState() => _CallupsScreenState();
}

class _CallupsScreenState extends State<CallupsScreen> {
  List<Player> _teamPlayers = [];
  Set<int> _selectedPlayerIds = {};
  bool _isLoading = true;
  bool _isNewCallUps = true;
  Sport? _tournamentSport;

  @override
  void initState() {
    _loadSport();
    super.initState();

    _loadTeamPlayers();
    _checkCallUps();
  }

  Future<void> _loadSport() async {
    try {
      print(
        '🔧 [DEBUG] Loading sport for tournament ID: ${widget.tournament.id}, sportId: ${widget.tournament.sportId}',
      );
      final Sport? sport = await DB.Sports.getById(widget.tournament.sportId);
      if (mounted && sport != null) {
        setState(() {
          _tournamentSport = sport;
        });
      }
    } catch (e) {
      print('❌ Error loading sport: $e');
    }
  }

  Future<double> get _TournamentFee async {
    try {
      return await DB.Tournaments.getTournamentFee(widget.tournament.id);
    } catch (e) {
      print('❌ Error loading tournament fee: $e');
      return 0.0;
    }
  }

  Future<bool> _confirmCallUps() async {
    if ((await DB().confirmCallUps(
          widget.tournament.id,
          widget.teamId,
          _selectedPlayerIds,
          await _TournamentFee,
        )) ==
        false) {
      if (mounted) {
        bool isThereCaptain = false;
        for (int playerId in _selectedPlayerIds) {
          if (await DB.Teams.isCaptainOrVice(widget.teamId, playerId)) {
            isThereCaptain = true;
            break;
          }
        }
        if (!isThereCaptain && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('At least one captain or vice must be selected'),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error confirming call-ups')),
          );
        }
      }
      return false;
    }
    return true;
  }

  Future<void> _loadTeamPlayers() async {
    setState(() => _isLoading = true);

    try {
      final playerIds = await DB.PlaysAt.getPlayersIdinTeam(widget.teamId);
      final players = <Player>[];

      for (final playerId in playerIds) {
        final player = await DB.Players.getByPlayerId(playerId);
        players.add(player);
      }

      if (mounted) {
        setState(() {
          _teamPlayers = players;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading team players: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading players: $e')));
      }
    }
  }

  Future<void> _checkCallUps() async {
    try {
      final List<CallUps> callUps = await DB.CallUps.getByTournamentAndTeam(
        widget.tournament.id,
        widget.teamId,
      );
      if (callUps.isNotEmpty && mounted) {
        setState(() {
          _selectedPlayerIds = callUps.map((cu) => cu.playerId).toSet();
          _isNewCallUps = false;
        });
        print('🔧 [DEBUG] Loaded ${callUps.length} existing call-ups');
      }
    } catch (e) {
      print('❌ Error checking call-ups: $e');
    }
  }

  void _togglePlayerSelection(int playerId) {
    setState(() {
      if (_selectedPlayerIds.contains(playerId)) {
        _selectedPlayerIds.remove(playerId);
      } else {
        _selectedPlayerIds.add(playerId);
      }
    });
  }

  bool _canConfirm() {
    if (_tournamentSport == null) return false;
    final count = _selectedPlayerIds.length;
    return count >= _tournamentSport!.minPlayersPerTeam &&
        count <= _tournamentSport!.maxPlayersPerTeam;
  }

  @override
  Widget build(BuildContext context) {
    // Show loading if sport is not yet loaded
    if (_tournamentSport == null) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: ATLColors.darkBlue,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Call-ups',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(_tournamentSport!.category),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Call-ups',
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Selected: ${_selectedPlayerIds.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Min ${_tournamentSport!.minPlayersPerTeam} players, Max ${_tournamentSport!.maxPlayersPerTeam} players',
                  style: TextStyle(
                    fontSize: 16,
                    color: _canConfirm() ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _teamPlayers.isEmpty
                ? const Center(
                    child: Text(
                      'No players found in this team',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _teamPlayers.length,
                    itemBuilder: (context, index) {
                      final player = _teamPlayers[index];
                      final isSelected = _selectedPlayerIds.contains(
                        player.playerId,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[300],
                            child: Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.grey[600],
                            ),
                          ),
                          title: Text(
                            player.username,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: isSelected
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                )
                              : null,
                          onTap: () => _togglePlayerSelection(player.playerId),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.grey[200],
            child: ElevatedButton(
              onPressed: _canConfirm()
                  ? () async {
                      // Handle confirmation
                      bool success = await _confirmCallUps();

                      if (mounted) {
                        if (success) {
                          Navigator.pop(context, true);
                        }
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ATLColors.getPrimaryColor(
                  SportCategory.football,
                ),
                disabledBackgroundColor: Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Confirm and partecipate',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
