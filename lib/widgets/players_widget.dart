import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/sport_category.dart';
import '../models/team.dart';
import '../utils/atl_colors.dart';

class PlayersWidget extends StatelessWidget {
  final List<Player> players;
  final Team? team;
  final SportCategory sportCategory;
  final void Function(Player player)? onLongPress;

  const PlayersWidget({
    super.key,
    required this.players,
    required this.team,
    required this.sportCategory,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Center(child: Text('No players found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: players.length + 1, // +1 per la descrizione del team
      itemBuilder: (context, index) {
        // Prima card: Descrizione del team
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ATLColors.getPrimaryColor(sportCategory).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ATLColors.getPrimaryColor(
                  sportCategory,
                ).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: ATLColors.getPrimaryColor(sportCategory),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            team?.name ?? 'Team',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.getPrimaryColor(sportCategory),
                            ),
                          ),
                          if (team?.alias != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              team!.alias!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (team?.vip == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'VIP',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people, size: 18, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${team?.players ?? 0}/24 Players',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.emoji_events,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${team?.rankPts ?? 0} pts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // Altre card: giocatori
        final player = players[index - 1];
        final isCaptain = player.playerId == team?.captainId;
        final isVice1 = player.playerId == team?.vice1Id;
        final isVice2 = player.playerId == team?.vice2Id;

        return GestureDetector(
          onLongPress: onLongPress != null ? () => onLongPress!(player) : null,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCaptain
                  ? ATLColors.getPrimaryColor(sportCategory).withOpacity(0.2)
                  : (isVice1 || isVice2)
                  ? ATLColors.getSecondaryColor(sportCategory).withOpacity(0.2)
                  : Colors.white,
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
                // Badge Captain/Vice Captain
                if (isCaptain || isVice1 || isVice2)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: ATLColors.getPrimaryColor(sportCategory),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        isCaptain ? 'C' : 'VC',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                if (isCaptain || isVice1 || isVice2) const SizedBox(width: 12),

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
              ],
            ),
          ),
        );
      },
    );
  }
}
