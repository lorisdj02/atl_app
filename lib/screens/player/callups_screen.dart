import 'package:atl_app/config/api_json_keys.dart';
import 'package:atl_app/database/db_read.dart';
import 'package:atl_app/utils/atl_colors.dart';
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../models/player.dart';
import '../../models/sport_category.dart';
import '../../models/sport.dart';
import '../../database/db_write.dart';
import '../../models/team.dart';
import '../../l10n/app_localizations.dart';

class CallupsScreen extends StatefulWidget {
  final Tournament tournament;
  final Team team;

  const CallupsScreen({Key? key, required this.tournament, required this.team})
    : super(key: key);

  @override
  State<CallupsScreen> createState() => _CallupsScreenState();
}

class _CallupsScreenState extends State<CallupsScreen> {
  List<Player> _teamPlayers = [];
  Set<int> _selectedPlayerIds = {};
  bool _isLoading = true;
  Sport? _tournamentSport;
  Tournament? _tournament;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await DBRead.getCallupsScreen(
        widget.tournament.id,
        widget.team.id,
      );

      setState(() {
        _teamPlayers = data[ApiJsonKeys.players];
        _selectedPlayerIds = data[ApiJsonKeys.calledUpPlayerIds].toSet();
        _tournamentSport = data[ApiJsonKeys.sport];
        _tournament = data[ApiJsonKeys.tournament];
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).errorLoadingCallupsData(e.toString()),
          ),
        ),
      );
    }
  }

  Future<bool> _confirmCallUps() async {
    if ((await DBWrite.confirmCallUps(
          _tournament?.id ?? 0,
          widget.team.id,
          _selectedPlayerIds,
          _tournament?.fee ?? 0.0,
        )) ==
        false) {
      if (mounted) {
        bool isThereCaptain = false;
        for (int playerId in _selectedPlayerIds) {
          if (playerId == widget.team.captainId ||
              playerId == widget.team.vice1Id ||
              playerId == widget.team.vice2Id) {
            isThereCaptain = true;
            break;
          }
        }
        if (!isThereCaptain && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).atLeastOneCaptain)),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).errorConfirmingCalups),
            ),
          );
        }
      }
      return false;
    }
    return true;
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
    final l10n = AppLocalizations.of(context);
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
          title: Text(
            l10n.callupsTitle,
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
        title: Text(
          l10n.callupsTitle,
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
                SnackBar(
                  content: Text(
                    l10n.darkModeComingSoonSnack,
                  ),
                ),
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
                  l10n.selectedCount(
                    _selectedPlayerIds.length,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.minMaxPlayers(
                    _tournamentSport!.minPlayersPerTeam,
                    _tournamentSport!.maxPlayersPerTeam,
                  ),
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
                ? Center(
                    child: Text(
                      l10n.noPlayersFoundInTeam,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
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
              child: Text(
                l10n.confirmAndParticipate,
                style: const TextStyle(
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
