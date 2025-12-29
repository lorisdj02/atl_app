import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/sport_category.dart';
import '../models/team_stats.dart';
import '../utils/atl_colors.dart';

class PlayersStatsWidget extends StatelessWidget {
  final List<Player> players;
  final SportCategory sportCategory;
  final Map<int, TeamStats?> playerStats;

  const PlayersStatsWidget({
    super.key,
    required this.players,
    required this.sportCategory,
    required this.playerStats,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(
        child: Text(
          'No stats available',
          style: TextStyle(fontSize: 16, color: ATLColors.subtext),
        ),
      );
    }

    // Ordina giocatori per gol
    final goalScorers = List<Player>.from(players)
      ..sort((a, b) {
        final aGoals = playerStats[a.id]?.goals ?? 0;
        final bGoals = playerStats[b.id]?.goals ?? 0;
        return bGoals.compareTo(aGoals);
      });
    
    // Ordina giocatori per MOTM
    final motmPlayers = List<Player>.from(players)
      ..sort((a, b) {
        final aMotm = playerStats[a.id]?.motm ?? 0;
        final bMotm = playerStats[b.id]?.motm ?? 0;
        return bMotm.compareTo(aMotm);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GOALS Section
          const Text(
            'GOALS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...goalScorers.map((player) {
            final goals = playerStats[player.id]?.goals ?? 0;
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
          const Text(
            'MOTM',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...motmPlayers.map((player) {
            final motm = playerStats[player.id]?.motm ?? 0;
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
      backgroundColor = ATLColors.getPrimaryColor(sportCategory).withOpacity(0.1);
    } else if (position == 1) {
      // Secondo posto: colore secondario dello sport
      backgroundColor = ATLColors.getSecondaryColor(sportCategory).withOpacity(0.1);
    } else {
      // Altri: bianco
      backgroundColor = Colors.white;
    }
    
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
              player.username,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
