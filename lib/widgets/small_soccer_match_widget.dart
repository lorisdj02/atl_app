import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import 'abstract_soccer_match_widget.dart';
import '../screens/tournaments/soccer_match_screen.dart';

class SmallSoccerMatchWidget extends AbstractSoccerMatchWidget {
  final SportCategory currentSport;

  const SmallSoccerMatchWidget({
    super.key,
    required super.match,
    super.homeTeam,
    super.awayTeam,
    required this.currentSport,
  });

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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SoccerMatchScreen(
              matchId: match.id,
              currentSport: currentSport,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: buildContent(),
      ),
    );
  }
}
