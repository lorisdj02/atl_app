import 'package:flutter/material.dart';
import '../utils/atl_colors.dart';
import 'abstract_team_widget.dart';

/// Widget per visualizzare un team nella home page
class HomeTeamWidget extends AbstractTeamWidget {
  final Color color;
  final int? rank;
  final String? standingRecord;

  const HomeTeamWidget({
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
                  color: color == ATLColors.getPrimaryColor(sportCategory)
                      ? Colors.white
                      : ATLColors.darkBlue,
                ),
              ),
            ),
            // Logo
            buildTeamLogo(size: 60),
            const SizedBox(width: 16),
            // Team name
            Expanded(
              child: Text(
                team.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color == ATLColors.getPrimaryColor(sportCategory)
                      ? Colors.white
                      : Colors.black,
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
                  color: color == ATLColors.getPrimaryColor(sportCategory)
                      ? Colors.white
                      : ATLColors.darkBlue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
