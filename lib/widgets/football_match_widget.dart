import 'package:flutter/material.dart';
import '../models/enums/sport_category.dart';
import 'abstract_football_match_widget.dart';

class FootballMatchWidget extends AbstractFootballMatchWidget {
  const FootballMatchWidget({
    super.key,
    required super.match,
    super.homeTeam,
    super.awayTeam,
    super.clickable = true,
    SportCategory? currentSport,
    required super.minutesPerRound,
    required super.minutesPerPause,
    super.onMatchUpdated,
  }) : super(sportCategory: currentSport ?? SportCategory.football);

  @override
  double get statusIconSize => 16.0;

  @override
  double get statusFontSize => 14.0;

  @override
  EdgeInsets get statusPadding =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  @override
  double get teamIconSize => 70.0;

  @override
  double get teamNameFontSize => 16.0;

  @override
  double get scoreFontSize => 36.0;

  @override
  EdgeInsets get scoreHorizontalPadding =>
      const EdgeInsets.symmetric(horizontal: 20);

  @override
  double get minuteFontSize => 12.0;

  @override
  EdgeInsets get minutePadding =>
      const EdgeInsets.symmetric(horizontal: 8, vertical: 3);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: needsMotm ? Border.all(color: Colors.orange, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (needsMotm)
            buildMotmWarning(
              context,
              fontSize: 12,
              iconSize: 16,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 12),
            ),
          buildContent(context),
        ],
      ),
    );

    if (!clickable) {
      return content;
    }

    return GestureDetector(
      onTap: () => handleMatchTap(context),
      child: content,
    );
  }
}
