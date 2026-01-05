import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/sport_category.dart';
import '../models/player.dart';
import '../utils/atl_colors.dart';
import '../database/db_controller.dart';
import '../config/app_config.dart';
import 'abstract_team_dialog.dart';

class FootballMotmSelectorDialog extends AbstractTeamDialog {
  const FootballMotmSelectorDialog({
    super.key,
    required super.homeTeam,
    required super.awayTeam,
    required super.tournamentId,
    required super.matchId,
    required super.sportCategory,
  });

  @override
  State<FootballMotmSelectorDialog> createState() =>
      _FootballMotmSelectorDialogState();
}

class _FootballMotmSelectorDialogState extends State<FootballMotmSelectorDialog>
    with TeamDialogMixin {
  List<Player> _availablePlayers = [];

  Future<void> _loadPlayers() async {
    if (selectedTeam == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      List<Player> players = [];

      List<int> playerIds = [];
      if (AppConfig.isDebug) {
        playerIds = await DB.PlaysAt.getPlayersIdinTeam(selectedTeam!.id);
      } else {
        playerIds = await DB.CallUps.getPlayersInTeamInTournament(
          widget.tournamentId,
          selectedTeam!.id,
        );
      }

      for (var playerId in playerIds) {
        final player = await DB.Players.getByPlayerId(playerId);
        if (player != null) {
          players.add(player);
        }
      }

      if (mounted) {
        setState(() {
          _availablePlayers = players;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading players: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            buildDialogHeader(title: 'Select Man of the Match'),
            const SizedBox(height: 24),

            // Team Selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildTeamSelector(
                  team: widget.homeTeam,
                  isHome: true,
                  onTap: () {
                    setState(() {
                      selectedTeam = widget.homeTeam;
                      _availablePlayers = [];
                    });
                    _loadPlayers();
                  },
                ),
                const SizedBox(width: 16),
                buildTeamSelector(
                  team: widget.awayTeam,
                  isHome: false,
                  onTap: () {
                    setState(() {
                      selectedTeam = widget.awayTeam;
                      _availablePlayers = [];
                    });
                    _loadPlayers();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Player List
            if (selectedTeam == null) ...[
              buildNoTeamSelectedWarning(),
            ] else if (isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_availablePlayers.isEmpty) ...[
              const Center(
                child: Text(
                  'No players available',
                  style: TextStyle(color: ATLColors.subtext),
                ),
              ),
            ] else ...[
              const Text(
                'Select Player',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availablePlayers.length,
                  itemBuilder: (context, index) {
                    final player = _availablePlayers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: ATLColors.getPrimaryColor(
                          widget.sportCategory,
                        ),
                        child: Text(
                          player.name[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text('${player.name} ${player.surname}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context, {
                          'player': player,
                          'teamId': selectedTeam!.id,
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
