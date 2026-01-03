import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/palmares.dart';
import '../models/sport_category.dart';
import '../models/tournament.dart';
import '../models/coordinator.dart';
import '../models/field.dart';

class PalmaresWidget extends StatelessWidget {
  final Palmares palmares;
  final Tournament tournament;
  final SportCategory sportCategory;
  final Coordinator? coordinator;
  final Field? field;
  final String? cityName;

  const PalmaresWidget({
    super.key,
    required this.palmares,
    required this.tournament,
    required this.sportCategory,
    this.coordinator,
    this.field,
    this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    final isWinner = palmares.position == PalmaresPosition.WINNER;
    final bgColor = isWinner
        ? ATLColors.getPrimaryColor(sportCategory).withOpacity(0.2)
        : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
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
          // Icona torneo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: ATLColors.getPrimaryColor(sportCategory).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.emoji_events,
              color: ATLColors.getPrimaryColor(sportCategory),
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // Info torneo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      coordinator?.username ?? 'Unknown',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${tournament.numTeams}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tournament.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        field != null
                            ? '${field!.name}, ${cityName ?? 'Unknown city'}'
                            : 'Unknown location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badge posizione
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ATLColors.getPrimaryColor(sportCategory),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  palmares.position == PalmaresPosition.WINNER
                      ? Icons.emoji_events
                      : Icons.military_tech,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  palmares.position.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
