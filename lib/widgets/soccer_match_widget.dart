import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import 'abstract_soccer_match_widget.dart';
import '../screens/tournaments/soccer_match_screen.dart';

class SoccerMatchWidget extends AbstractSoccerMatchWidget {
  final bool clickable;
  final SportCategory? currentSport;

  const SoccerMatchWidget({
    super.key,
    required super.match,
    super.homeTeam,
    super.awayTeam,
    this.clickable = true,
    this.currentSport,
  });

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: buildContent(),
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
              builder: (context) => SoccerMatchScreen(
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
