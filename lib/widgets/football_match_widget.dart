import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../models/football_match.dart';
import 'abstract_football_match_widget.dart';
import '../screens/tournaments/football_match_screen.dart';

class FootballMatchWidget extends AbstractFootballMatchWidget {
  final bool clickable;
  final SportCategory? currentSport;

  const FootballMatchWidget({
    super.key,
    required super.match,
    super.homeTeam,
    super.awayTeam,
    this.clickable = true,
    this.currentSport,
    required super.minutesPerRound,
    required super.minutesPerPause,
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
    // Verifica se il match è finito e manca il MOTM
    final needsMotm =
        match.status == MatchStatus.finished && match.motmPlayerId == null;

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
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Warning: MOTM missing',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          buildContent(),
        ],
      ),
    );

    if (!clickable) {
      return content;
    }

    return GestureDetector(
      onTap: () {
        if (currentSport != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FootballMatchScreen(
                matchId: match.id,
                currentSport: currentSport!,
              ),
            ),
          );
        }
      },
      child: content,
    );
  }
}
