import 'package:flutter/material.dart';
import '../models/growth_step.dart';
import '../models/enums/sport_category.dart';
import '../utils/atl_colors.dart';
import '../l10n/app_localizations.dart';

class GrowthHeroCard extends StatelessWidget {
  final GrowthStep step;
  final Color catColor;
  final SportCategory currentSport;
  final bool isReferee;

  const GrowthHeroCard({
    super.key,
    required this.step,
    required this.catColor,
    required this.currentSport,
    required this.isReferee,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ATLColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, color: catColor),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.levelAbbrev,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${step.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isReferee ? l10n.referee : l10n.coordinator,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            currentSport.icon,
            color: catColor.withOpacity(0.45),
            size: 38,
          ),
        ],
      ),
    );
  }
}
