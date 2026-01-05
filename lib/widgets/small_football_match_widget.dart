import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../models/football_match.dart';
import 'abstract_football_match_widget.dart';
import '../screens/tournaments/football_match_screen.dart';

class SmallFootballMatchWidget extends AbstractFootballMatchWidget {
  final SportCategory currentSport;
  final VoidCallback? onMatchUpdated;

  const SmallFootballMatchWidget({
    super.key,
    required super.match,
    super.homeTeam,
    super.awayTeam,
    required this.currentSport,
    required super.minutesPerRound,
    required super.minutesPerPause,
    this.onMatchUpdated,
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
    // Verifica se il match è finito e manca il MOTM
    final needsMotm =
        match.status == MatchStatus.finished && match.motmPlayerId == null;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FootballMatchScreen(
              matchId: match.id,
              currentSport: currentSport,
            ),
          ),
        );
        // Callback to parent to reload data after returning
        if (onMatchUpdated != null) {
          onMatchUpdated!();
        }
      },
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
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange.shade700,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Warning: MOTM missing',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            buildContent(),
          ],
        ),
      ),
    );
  }
}
