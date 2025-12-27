import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import '../models/team.dart';
import '../models/sport_category.dart';
import 'abstract_team_widget.dart';

/// Widget per visualizzare un team nella classifica
class StandingsTeamWidget extends AbstractTeamWidget {
  final Color color;
  final int? rank;
  final String? standingRecord;

  const StandingsTeamWidget({
    super.key,
    required super.team,
    this.color = Colors.white,
    super.imageUrl,
    this.rank,
    this.standingRecord,
    required super.sportCategory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => handleTeamTap(context),
      child: Container(
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
            buildTeamLogo(size: 40),
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
      ),
    );
  }
}
