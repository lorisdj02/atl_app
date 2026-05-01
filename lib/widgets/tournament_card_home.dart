import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../models/football_match.dart';
import '../models/football_standing.dart';
import '../models/team.dart';
import '../models/enums/sport_category.dart';
import '../utils/atl_colors.dart';
import 'football_match_widget.dart';
import 'home_team_widget.dart';
import '../l10n/app_localizations.dart';
import '../models/enums/tournament_status.dart';

class TournamentCardHome extends StatelessWidget {
  final Tournament tournament;
  final List<FootballMatch> matches;
  final List<FootballStanding> standings;
  final Map<double, Team> teamsCache;
  final Team? accountTeam;
  final SportCategory sportCategory;
  final int minutesPerRound;
  final int minutesPerPause;

  const TournamentCardHome({
    super.key,
    required this.tournament,
    required this.matches,
    required this.standings,
    required this.teamsCache,
    required this.accountTeam,
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

    // Find user's team group (fallback to first match group if standings empty)
    FootballStanding? userStanding;
    if (standings.isNotEmpty) {
      userStanding = standings.firstWhere(
        (s) => s.teamId == accountTeam?.id,
        orElse: () => standings.first,
      );
    }

    final groupName =
        userStanding?.groupName ??
        (matches.isNotEmpty ? matches.first.groupName : null);

    final groupStandings =
        groupName == null
              ? <FootballStanding>[]
              : standings.where((s) => s.groupName == groupName).toList()
          ..sort((a, b) => b.pts.compareTo(a.pts));

    // Find next match
    final userMatches =
        matches
            .where(
              (m) =>
                  m.homeTeamId == accountTeam?.id ||
                  m.awayTeamId == accountTeam?.id,
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
            if (groupName != null)
              Text(
                l10n.groupLabel(groupName),
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

            final isUserTeam = team.id == accountTeam?.id;

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
