import 'package:flutter/material.dart';
import '../models/enums/sport_category.dart';
import '../models/team.dart';
import '../utils/atl_colors.dart';

/// Widget per visualizzare un match all'interno del tabellone Road to Victory
class FootballMatchBracket extends StatelessWidget {
  final double? homeTeamId;
  final double? awayTeamId;
  final Team? homeTeam;
  final Team? awayTeam;
  final double? winnerTeamId;
  final SportCategory sportCategory;
  final bool isFinal;

  const FootballMatchBracket({
    super.key,
    required this.sportCategory,
    this.homeTeamId,
    this.awayTeamId,
    this.homeTeam,
    this.awayTeam,
    this.winnerTeamId,
    this.isFinal = false,
  });

  Color? _getBorderColor(double? teamId) {
    if (teamId == null || winnerTeamId == null) return null;

    if (isFinal) {
      // Finale: oro per il vincitore, argento per il secondo
      if (teamId == winnerTeamId) {
        return const Color(0xFFFFD700); // Oro
      } else {
        return const Color(0xFFC0C0C0); // Argento
      }
    } else if (teamId == winnerTeamId) {
      // Altri turni: verde per il vincitore
      return Colors.green;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyTeam =
        homeTeamId != null || awayTeamId != null || homeTeam != null || awayTeam != null;

    if (!hasAnyTeam) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ATLColors.getPrimaryColor(
              sportCategory,
            ).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Center(
          child: Text(
            'TBD',
            style: TextStyle(
              color: ATLColors.subtext,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ATLColors.getPrimaryColor(
            sportCategory,
          ).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Home Team
          _buildTeamColumn(homeTeam, true),
          SizedBox(width: isFinal ? 16 : 12),
          // Away Team
          _buildTeamColumn(awayTeam, false),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(Team? team, bool isHome) {
    final teamId = isHome ? homeTeamId : awayTeamId;
    final borderColor = _getBorderColor(teamId);
    final teamSize = isFinal ? 70.0 : 50.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Team widget with border
        Container(
          decoration: borderColor != null
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(isFinal ? 16 : 14),
                  border: Border.all(color: borderColor, width: 3),
                )
              : null,
          child: team != null
              ? _buildTeamImage(team, teamSize)
              : Container(
                  width: teamSize,
                  height: teamSize,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'TBD',
                      style: TextStyle(
                        color: ATLColors.subtext,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        // Team alias
        SizedBox(
          width: teamSize,
          child: Text(
            team?.alias ?? 'TBD',
            style: TextStyle(
              fontSize: isFinal ? 11 : 9,
              fontWeight: borderColor != null
                  ? FontWeight.bold
                  : FontWeight.w500,
              color: borderColor != null ? Colors.black : ATLColors.darkBlue,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamImage(Team team, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ATLColors.getPrimaryColor(
            sportCategory,
          ).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: team.logoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                team.logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder(team, size);
                },
              ),
            )
          : _buildPlaceholder(team, size),
    );
  }

  Widget _buildPlaceholder(Team team, double size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield,
            color: ATLColors.getPrimaryColor(sportCategory),
            size: size * 0.4,
          ),
          SizedBox(height: size * 0.05),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              team.alias,
              style: TextStyle(
                color: ATLColors.getPrimaryColor(sportCategory),
                fontSize: size * 0.15,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
