import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/soccer_match.dart';
import '../models/team.dart';
import '../utils/atl_colors.dart';

class SmallSoccerMatchWidget extends StatelessWidget {
  final SoccerMatch match;
  final Team? homeTeam;
  final Team? awayTeam;

  const SmallSoccerMatchWidget({
    super.key,
    required this.match,
    this.homeTeam,
    this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          // Date/Status header
          _buildStatusHeader(),
          const SizedBox(height: 12),
          // Match row
          Row(
            children: [
              // Home team
              Expanded(
                child: _buildTeam(homeTeam, isHome: true),
              ),
              // Score or dash
              _buildScore(),
              // Away team
              Expanded(
                child: _buildTeam(awayTeam, isHome: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    switch (match.status) {
      case MatchStatus.scheduled:
        if (match.matchDate != null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 14, color: ATLColors.darkBlue),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd-MM-yyyy').format(match.matchDate!),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.darkBlue,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.access_time, size: 14, color: ATLColors.darkBlue),
              const SizedBox(width: 4),
              Text(
                DateFormat('HH:mm').format(match.matchDate!),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.darkBlue,
                ),
              ),
            ],
          );
        }
        return const Text(
          'Scheduled',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
        );
      case MatchStatus.started:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle_filled, size: 14, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Text(
                'Live',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.finished:
        return const Text(
          'Full-time',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: ATLColors.subtext,
          ),
        );
      case MatchStatus.notScheduled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Text(
                'To be scheduled',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.homeRetired:
      case MatchStatus.awayRetired:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, size: 14, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Text(
                'Retired',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.canceled:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel, size: 14, color: Colors.red.shade700),
              const SizedBox(width: 4),
              Text(
                'Canceled',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildTeam(Team? team, {required bool isHome}) {
    if (team == null) {
      return const Text(
        'Loading...',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: ATLColors.subtext),
      );
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: const Icon(Icons.shield, size: 24, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          team.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildScore() {
    if (match.status == MatchStatus.finished || match.status == MatchStatus.started) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${match.scoreHome ?? 0}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.darkBlue,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '-',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.subtext,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${match.scoreAway ?? 0}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.darkBlue,
                  ),
                ),
              ],
            ),
            if (match.status == MatchStatus.started)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "50'+5",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '-',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ATLColors.subtext,
        ),
      ),
    );
  }
}
