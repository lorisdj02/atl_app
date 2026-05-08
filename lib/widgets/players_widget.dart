import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/enums/sport_category.dart';
import '../models/team.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card team sempre visibile
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ATLColors.getPrimaryColor(sportCategory).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ATLColors.getPrimaryColor(sportCategory).withOpacity(0.3),
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
                          team?.name ?? l10n.teamLabel,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: ATLColors.getPrimaryColor(sportCategory),
                          ),
                        ),
                        if (team?.alias != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            l10n.teamAliasAndId(team!.alias, team!.id),
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
                  if (team?.isVip == true)
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
                    '${players.isNotEmpty ? team?.numPlayers ?? 0 : 0}/${team?.maxPlayers ?? 24} ${l10n.players}',
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
        ),
        if (players.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off,
                    color: ATLColors.getPrimaryColor(sportCategory),
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noPlayersFound,
                    style: TextStyle(
                      color: ATLColors.darkBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.teamDisabledMsg,
                    style: TextStyle(
                      color: ATLColors.subtext,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...players.map((player) {
            // Card giocatore
            final isCaptain = player.playerId == team?.captainPlayerId;
            final isVice1 = player.playerId == team?.vice1PlayerId;
            final isVice2 = player.playerId == team?.vice2PlayerId;

            return GestureDetector(
              onLongPress: onLongPress != null
                  ? () => onLongPress!(player)
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCaptain
                      ? ATLColors.getPrimaryColor(
                          sportCategory,
                        ).withOpacity(0.2)
                      : (isVice1 || isVice2)
                      ? ATLColors.getSecondaryColor(
                          sportCategory,
                        ).withOpacity(0.2)
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
                            isCaptain ? l10n.captainAbbr : l10n.viceCaptainAbbr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    if (isCaptain || isVice1 || isVice2)
                      const SizedBox(width: 12),

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
          }).toList(),
      ],
    );
  }
}
