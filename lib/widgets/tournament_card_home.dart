import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/football_match.dart';
import '../models/football_standing.dart';
import '../models/team.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import 'football_match_widget.dart';
import 'home_team_widget.dart';
import '../l10n/app_localizations.dart';

class TournamentCardHome extends StatelessWidget {
  final Tournament tournament;
  final List<FootballMatch> matches;
  final List<FootballStanding> standings;
  final Map<int, Team> teamsCache;
  final Team? userTeam;
  final SportCategory sportCategory;
  final int minutesPerRound;
  final int minutesPerPause;

  const TournamentCardHome({
    super.key,
    required this.tournament,
    required this.matches,
    required this.standings,
    required this.teamsCache,
    required this.userTeam,
    required this.sportCategory,
    required this.minutesPerRound,
    required this.minutesPerPause,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Se il torneo è in stato "created", mostra messaggio di attesa
    if (tournament.status == TournamentStatus.created) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.hourglass_empty,
                size: 80,
                color: ATLColors.getPrimaryColor(sportCategory),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.participatingInTournamentMsg,
                style: TextStyle(
                  color: ATLColors.title,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Find user's team group
    final userStanding = standings.firstWhere(
      (s) => s.teamId == userTeam?.id,
      orElse: () => standings.first,
    );

    final groupStandings =
        standings.where((s) => s.groupName == userStanding.groupName).toList()
          ..sort((a, b) => b.pts.compareTo(a.pts));

    // Find next match
    final userMatches =
        matches
            .where(
              (m) =>
                  m.homeTeamId == userTeam?.id || m.awayTeamId == userTeam?.id,
            )
            .toList()
          ..sort((a, b) {
            if (a.scheduledStart == null && b.scheduledStart == null) return 0;
            if (a.scheduledStart == null) return 1;
            if (b.scheduledStart == null) return -1;
            return a.scheduledStart!.compareTo(b.scheduledStart!);
          });

    final nextMatch = userMatches.isNotEmpty ? userMatches.first : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next match card
          if (nextMatch != null) ...[
            Text(
              l10n.groupLabel(userStanding.groupName),
              style: TextStyle(
                color: ATLColors.subtext,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            FootballMatchWidget(
              match: nextMatch,
              homeTeam: teamsCache[nextMatch.homeTeamId],
              awayTeam: teamsCache[nextMatch.awayTeamId],
              currentSport: sportCategory,
              minutesPerRound: minutesPerRound,
              minutesPerPause: minutesPerPause,
            ),
          ],

          // Group standings
          ...groupStandings.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final standing = entry.value;
            final team = teamsCache[standing.teamId];

            if (team == null) return const SizedBox.shrink();

            final isUserTeam = team.id == userTeam?.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: HomeTeamWidget(
                team: team,
                color: isUserTeam
                    ? ATLColors.getPrimaryColor(sportCategory)
                    : Colors.white,
                rank: rank,
                standingRecord: '${standing.pts} pts',
                sportCategory: sportCategory,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
