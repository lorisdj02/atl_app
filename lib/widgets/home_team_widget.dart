import 'package:atl_app/models/sport_category.dart';
import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/team.dart';

/// Widget per visualizzare un team nella home page
class HomeTeamWidget extends StatelessWidget {
  final Team team;
  final Color color;
  final String? imageUrl;
  final int? rank;
  final String? standingRecord;
  final SportCategory sportCategory;

  const HomeTeamWidget({
    super.key,
    required this.team,
    this.color = Colors.white,
    this.imageUrl,
    this.rank,
    this.standingRecord,
    required this.sportCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color == ATLColors.getPrimaryColor(sportCategory) ? Colors.white : ATLColors.darkBlue,
              ),
            ),
          ),
          // Logo
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
                        return const Icon(Icons.shield, size: 28, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.shield, size: 28, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          // Team name
          Expanded(
            child: Text(
              team.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == ATLColors.getPrimaryColor(sportCategory) ? Colors.white : Colors.black,
                height: 1.2,
              ),
            ),
          ),
          // Points only
          if (standingRecord != null)
            Text(
              standingRecord!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color == ATLColors.getPrimaryColor(sportCategory) ? Colors.white : ATLColors.darkBlue,
              ),
            ),
        ],
      ),
    );
  }
}
