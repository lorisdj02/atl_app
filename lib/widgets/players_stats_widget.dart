import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/player.dart';
import '../models/enums/sport_category.dart';
import '../models/football_team_stats.dart';
import '../models/team.dart';
import '../utils/atl_colors.dart';

class PlayersStatsWidget extends StatelessWidget {
  final List<Player> players;
  final SportCategory sportCategory;
  final Map<double, FootballTeamStats?> playerStats;
  final bool inTournament;
  final Map<double, Team>? teamsCache;

  const PlayersStatsWidget({
    super.key,
    required this.players,
    required this.sportCategory,
    required this.playerStats,
    this.inTournament = false,
    this.teamsCache,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (players.isEmpty || (playerStats.isEmpty && inTournament)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              l10n.noStatsAvailable,
              style: TextStyle(fontSize: 18, color: ATLColors.subtext),
            ),
          ],
        ),
      );
    }

    // Ordina giocatori per gol
    final goalScorers = List<Player>.from(players)
      ..sort((a, b) {
        final aGoals = playerStats[a.playerId]?.goals ?? 0;
        final bGoals = playerStats[b.playerId]?.goals ?? 0;
        return bGoals.compareTo(aGoals);
      });

    // Ordina giocatori per MOTM
    final motmPlayers = List<Player>.from(players)
      ..sort((a, b) {
        final aMotm = playerStats[a.playerId]?.motm ?? 0;
        final bMotm = playerStats[b.playerId]?.motm ?? 0;
        return bMotm.compareTo(aMotm);
      });


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GOALS Section
          Text(
            l10n.goalsLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...goalScorers.map((player) {
            final goals = playerStats[player.playerId]?.goals ?? 0;
            final position = goalScorers.indexOf(player);

            return _buildStatItem(
              position: position,
              player: player,
              value: goals,
              sportCategory: sportCategory,
            );
          }),

          const SizedBox(height: 24),

          // MOTM Section
          Text(
            l10n.motmLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...motmPlayers.map((player) {
            final motm = playerStats[player.playerId]?.motm ?? 0;
            final position = motmPlayers.indexOf(player);

            return _buildStatItem(
              position: position,
              player: player,
              value: motm,
              sportCategory: sportCategory,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required int position,
    required Player player,
    required int value,
    required SportCategory sportCategory,
  }) {
    Color backgroundColor;

    if (position == 0) {
      // Primo posto: colore primario dello sport
      backgroundColor = ATLColors.getPrimaryColor(
        sportCategory,
      ).withOpacity(0.1);
    } else if (position == 1) {
      // Secondo posto: colore secondario dello sport
      backgroundColor = ATLColors.getSecondaryColor(
        sportCategory,
      ).withOpacity(0.1);
    } else {
      // Altri: bianco
      backgroundColor = Colors.white;
    }

    // Recupera il team dal player stats se siamo in un torneo
    final teamId = inTournament ? playerStats[player.playerId]?.teamId : null;
    final team = (inTournament && teamId != null && teamsCache != null)
        ? teamsCache![teamId]
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
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
          // Position badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: position == 0
                  ? ATLColors.getPrimaryColor(sportCategory)
                  : position == 1
                  ? ATLColors.getSecondaryColor(sportCategory)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${position + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade300,
            ),
            child: player.imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      player.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        );
                      },
                    ),
                  )
                : const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          // Player name and team name (if in tournament)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (inTournament && team != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    team.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Value
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: position == 0
                  ? ATLColors.getPrimaryColor(sportCategory)
                  : position == 1
                  ? ATLColors.getSecondaryColor(sportCategory)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
