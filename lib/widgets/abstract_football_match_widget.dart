import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/football_match.dart';
import '../models/team.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import 'football_live_minute_widget.dart';
import '../screens/tournaments/football_match_screen.dart';

abstract class AbstractFootballMatchWidget extends StatelessWidget {
  final FootballMatch match;
  final Team? homeTeam;
  final Team? awayTeam;
  final int minutesPerRound;
  final SportCategory sportCategory;
  final int minutesPerPause;
  final VoidCallback? onMatchUpdated;
  final bool clickable;

  const AbstractFootballMatchWidget({
    super.key,
    required this.match,
    this.homeTeam,
    this.awayTeam,
    required this.minutesPerRound,
    required this.sportCategory,
    required this.minutesPerPause,
    this.onMatchUpdated,
    this.clickable = true,
  });

  // Check if MOTM is missing
  bool get needsMotm =>
      match.status == MatchStatus.finished && match.motmPlayerId == null;

  // Metodi astratti da implementare nelle classi figlie
  double get statusIconSize;
  double get statusFontSize;
  EdgeInsets get statusPadding;
  double get teamIconSize;
  double get teamNameFontSize;
  double get scoreFontSize;
  EdgeInsets get scoreHorizontalPadding;
  double get minuteFontSize;
  EdgeInsets get minutePadding;

  Widget _buildStatusHeader() {
    switch (match.status) {
      case MatchStatus.scheduled:
        if (match.matchDate != null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_today,
                size: statusIconSize,
                color: ATLColors.darkBlue,
              ),
              SizedBox(width: statusIconSize * 0.375),
              Text(
                DateFormat('dd-MM-yyyy').format(match.matchDate!),
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.darkBlue,
                ),
              ),
              SizedBox(width: statusIconSize * 0.75),
              Icon(
                Icons.access_time,
                size: statusIconSize,
                color: ATLColors.darkBlue,
              ),
              SizedBox(width: statusIconSize * 0.375),
              Text(
                DateFormat('HH:mm').format(match.matchDate!),
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.darkBlue,
                ),
              ),
            ],
          );
        }
        return Text(
          'Scheduled (${DateFormat('dd/MM/yy').format(match.scheduledStart!)} at ${DateFormat('HH:mm').format(match.scheduledStart!)})',
          style: TextStyle(
            fontSize: statusFontSize,
            fontWeight: FontWeight.bold,
            color: ATLColors.darkBlue,
          ),
        );
      case MatchStatus.started:
        return Container(
          padding: statusPadding,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_filled,
                size: statusIconSize,
                color: Colors.red.shade700,
              ),
              SizedBox(width: statusIconSize * 0.33),
              Text(
                'Live',
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.halftime:
        return Container(
          padding: statusPadding,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_filled,
                size: statusIconSize,
                color: Colors.orange.shade700,
              ),
              SizedBox(width: statusIconSize * 0.33),
              Text(
                'Halftime',
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.startHalf:
        return Container(
          padding: statusPadding,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_circle_filled,
                size: statusIconSize,
                color: Colors.red.shade700,
              ),
              SizedBox(width: statusIconSize * 0.33),
              Text(
                'Live - 2nd Half',
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.penaltyShootOut:
        return Container(
          padding: statusPadding,
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_soccer,
                size: statusIconSize,
                color: Colors.purple.shade700,
              ),
              SizedBox(width: statusIconSize * 0.33),
              Text(
                'Penalty shoot-out',
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.finished:
        return Text(
          'Full-time',
          style: TextStyle(
            fontSize: statusFontSize,
            fontWeight: FontWeight.bold,
            color: ATLColors.subtext,
          ),
        );
      case MatchStatus.notScheduled:
        return Container(
          padding: statusPadding,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.schedule,
                size: statusIconSize,
                color: Colors.grey.shade700,
              ),
              SizedBox(width: statusIconSize * 0.33),
              Text(
                'To be scheduled',
                style: TextStyle(
                  fontSize: statusFontSize,
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
          padding: statusPadding,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning,
                size: statusIconSize,
                color: Colors.orange.shade700,
              ),
              SizedBox(width: statusIconSize * 0.33),
              Text(
                'Retired',
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        );
      case MatchStatus.canceled:
        return Container(
          padding: statusPadding,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cancel,
                size: statusIconSize,
                color: Colors.red.shade700,
              ),
              SizedBox(width: statusIconSize * 0.33),
              Text(
                'Canceled',
                style: TextStyle(
                  fontSize: statusFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget buildTeam(Team? team, {required bool isHome}) {
    return Column(
      children: [
        Container(
          width: teamIconSize,
          height: teamIconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.grey.shade300,
              width: teamIconSize * 0.043,
            ),
          ),
          child: Icon(
            Icons.shield,
            size: teamIconSize * 0.57,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: teamIconSize * 0.114),
        Text(
          team?.name ?? 'TBD',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: teamNameFontSize,
            fontWeight: FontWeight.bold,
            color: team == null ? ATLColors.subtext : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget buildScore() {
    if (match.status == MatchStatus.finished ||
        match.status == MatchStatus.started ||
        match.status == MatchStatus.halftime ||
        match.status == MatchStatus.startHalf ||
        match.status == MatchStatus.penaltyShootOut) {
      return Padding(
        padding: scoreHorizontalPadding,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  '${match.scoreHome ?? 0}',
                  style: TextStyle(
                    fontSize: scoreFontSize,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.darkBlue,
                  ),
                ),
                SizedBox(width: scoreFontSize * 0.33),
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: scoreFontSize,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.subtext,
                  ),
                ),
                SizedBox(width: scoreFontSize * 0.33),
                Text(
                  '${match.scoreAway ?? 0}',
                  style: TextStyle(
                    fontSize: scoreFontSize,
                    fontWeight: FontWeight.bold,
                    color: ATLColors.darkBlue,
                  ),
                ),
              ],
            ),
            if (match.status == MatchStatus.penaltyShootOut &&
                (match.penaltyScoreHome != null ||
                    match.penaltyScoreAway != null))
              Padding(
                padding: EdgeInsets.only(top: scoreFontSize * 0.167),
                child: Text(
                  '(${(match.scoreHome ?? 0) + (match.penaltyScoreHome ?? 0)}-${(match.scoreAway ?? 0) + (match.penaltyScoreAway ?? 0)} PSO)',
                  style: TextStyle(
                    fontSize: scoreFontSize * 0.67,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade700,
                  ),
                ),
              ),
            if (match.status == MatchStatus.started ||
                match.status == MatchStatus.halftime ||
                match.status == MatchStatus.startHalf ||
                match.status == MatchStatus.penaltyShootOut)
              FootballLiveMinuteWidget(
                minutesPerPause: minutesPerPause,
                minutesPerRound: minutesPerRound,
                match: match,
                fontSize: minuteFontSize,
                padding: minutePadding,
                borderRadius: scoreFontSize * 0.167,
                sportCategory: sportCategory,
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: scoreHorizontalPadding,
      child: Text(
        '-',
        style: TextStyle(
          fontSize: scoreFontSize,
          fontWeight: FontWeight.bold,
          color: ATLColors.subtext,
        ),
      ),
    );
  }

  // Handle navigation to match screen
  Future<void> handleMatchTap(BuildContext context) async {
    final hasChanges = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FootballMatchScreen(matchId: match.id, currentSport: sportCategory),
      ),
    );
    // Callback to parent to reload data if changes were made
    if (hasChanges == true && onMatchUpdated != null) {
      onMatchUpdated!();
    }
  }

  // Build MOTM warning widget
  Widget buildMotmWarning({
    required double fontSize,
    required double iconSize,
    required EdgeInsets padding,
    required EdgeInsets margin,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(iconSize * 0.5),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.orange.shade700, size: iconSize),
          SizedBox(width: iconSize * 0.5),
          Text(
            'Warning: MOTM missing',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContent() {
    return Column(
      children: [
        // Date/Status header
        _buildStatusHeader(),
        SizedBox(height: teamIconSize * 0.343),
        // Match row
        Row(
          children: [
            // Home team
            Expanded(child: buildTeam(homeTeam, isHome: true)),
            // Score or dash
            buildScore(),
            // Away team
            Expanded(child: buildTeam(awayTeam, isHome: false)),
          ],
        ),
      ],
    );
  }
}
