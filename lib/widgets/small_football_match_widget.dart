import 'package:flutter/material.dart';
import '../models/enums/sport_category.dart';
import 'abstract_football_match_widget.dart';

class SmallFootballMatchWidget extends AbstractFootballMatchWidget {
  const SmallFootballMatchWidget({
    super.key,
    required super.match,
    super.homeTeam,
    super.awayTeam,
    required SportCategory currentSport,
    required super.minutesPerRound,
    required super.minutesPerPause,
    super.onMatchUpdated,
  }) : super(sportCategory: currentSport);

  @override
  double get statusIconSize => 14.0;

  @override
  double get statusFontSize => 12.0;

  @override
  EdgeInsets get statusPadding =>
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  @override
  double get teamIconSize => 40.0;

  @override
  double get teamNameFontSize => 14.0;

  @override
  double get scoreFontSize => 24.0;

  @override
  EdgeInsets get scoreHorizontalPadding =>
      const EdgeInsets.symmetric(horizontal: 16);

  @override
  double get minuteFontSize => 10.0;

  @override
  EdgeInsets get minutePadding =>
      const EdgeInsets.symmetric(horizontal: 6, vertical: 2);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: clickable ? () => handleMatchTap(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: needsMotm ? Border.all(color: Colors.orange, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            if (needsMotm)
              buildMotmWarning(
                context,
                fontSize: 10,
                iconSize: 14,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
              ),
            buildContent(context),
          ],
        ),
      ),
    );
  }
}
