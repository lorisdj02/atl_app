import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/team.dart';

/// Widget per visualizzare un team nella classifica
class StandingsTeamWidget extends StatelessWidget {
  final Team team;
  final Color color;
  final String? imageUrl;
  final int? rank;
  final String? standingRecord;

  const StandingsTeamWidget({
    super.key,
    required this.team,
    this.color = Colors.white,
    this.imageUrl,
    this.rank,
    this.standingRecord,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 30,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? ATLColors.darkBlue : Colors.white,
              ),
            ),
          ),
          // Logo
          Container(
            width: 40,
            height: 40,
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
                        return const Icon(Icons.shield, size: 24, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.shield, size: 24, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          // Team name
          Expanded(
            child: Text(
              team.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? Colors.black : Colors.white,
              ),
            ),
          ),
          // Full record (Pts - W - D - L)
          if (standingRecord != null)
            Text(
              standingRecord!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color == Colors.white ? ATLColors.darkBlue : Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
