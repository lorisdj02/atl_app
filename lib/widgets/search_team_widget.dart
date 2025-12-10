import 'package:atl_app/models/sport_category.dart';
import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/team.dart';

/// Widget per visualizzare un team nella ricerca
class SearchTeamWidget extends StatelessWidget {
  final Team team;
  final Color color;
  final String? imageUrl;
  final String? captainName;
  final SportCategory sportCategory;

  const SearchTeamWidget({
    super.key,
    required this.team,
    this.color = Colors.white,
    this.imageUrl,
    this.captainName,
    required this.sportCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo del team
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.shield, size: 32, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.shield, size: 32, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          // Informazioni del team
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Captain: ${captainName ?? 'Loading...'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Badge giocatori e VIP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ATLColors.darkBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people,
                      size: 16,
                      color: ATLColors.darkBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${team.players}/24',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              if (team.vip) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'VIP',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
