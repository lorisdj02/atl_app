import 'package:flutter/material.dart';
import '../models/football_match_event.dart';
import '../utils/atl_colors.dart';

enum EventSource { home, away, match }

class MatchEventCard extends StatelessWidget {
  final FootballMatchEventType eventType;
  final int minute;
  final int additionalMinute;
  final String playerName; // Nome puntato e cognome esteso, o username
  final EventSource source;

  const MatchEventCard({
    super.key,
    required this.eventType,
    required this.minute,
    this.additionalMinute = 0,
    required this.playerName,
    required this.source,
  });

  IconData _getEventIcon() {
    switch (eventType) {
      case FootballMatchEventType.goal:
        return Icons.sports_soccer;
      case FootballMatchEventType.penalty:
        return Icons.sports_score;
      case FootballMatchEventType.ownGoal:
        return Icons.sports_soccer;
      case FootballMatchEventType.yellowCard:
        return Icons.rectangle;
      case FootballMatchEventType.redCard:
        return Icons.rectangle;
      case FootballMatchEventType.redYellowCard:
        return Icons.rectangle;
      case FootballMatchEventType.start:
        return Icons.play_circle_filled;
      case FootballMatchEventType.halftime:
        return Icons.pause_circle_filled;
      case FootballMatchEventType.startHalf:
        return Icons.play_circle_filled;
      case FootballMatchEventType.finish:
        return Icons.stop_circle;
    }
  }

  Color _getEventColor() {
    switch (eventType) {
      case FootballMatchEventType.goal:
      case FootballMatchEventType.penalty:
        return Colors.green.shade700;
      case FootballMatchEventType.ownGoal:
        return Colors.orange.shade700;
      case FootballMatchEventType.yellowCard:
        return Colors.yellow.shade700;
      case FootballMatchEventType.redCard:
      case FootballMatchEventType.redYellowCard:
        return Colors.red.shade700;
      case FootballMatchEventType.start:
      case FootballMatchEventType.startHalf:
      case FootballMatchEventType.halftime:
      case FootballMatchEventType.finish:
        return ATLColors.darkBlue;
    }
  }

  String _formatMinute() {
    if (additionalMinute > 0) {
      return "$minute+$additionalMinute'";
    }
    return "$minute'";
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getEventIcon();
    final color = _getEventColor();

    if (source == EventSource.match) {
      // Evento centrale (match events)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              _formatMinute(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              playerName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ATLColors.darkBlue,
              ),
            ),
          ],
        ),
      );
    }

    // Eventi laterali (home/away)
    final isHome = source == EventSource.home;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isHome
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (!isHome) ...[
            // Away team - testo a sinistra, icona a destra
            Flexible(
              child: Text(
                playerName,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ATLColors.darkBlue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatMinute(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ] else ...[
            // Home team - icona a sinistra, testo a destra
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              _formatMinute(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                playerName,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ATLColors.darkBlue,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
