import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/football_match.dart';
import '../models/team.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import 'football_live_minute_widget.dart';

abstract class AbstractFootballMatchWidget extends StatelessWidget {
  final FootballMatch match;
  final Team? homeTeam;
  final Team? awayTeam;
  final int minutesPerRound;
  final SportCategory sportCategory;
  final int minutesPerPause;

  const AbstractFootballMatchWidget({
    super.key,
    required this.match,
    this.homeTeam,
    this.awayTeam,
    required this.minutesPerRound,
    required this.sportCategory,
    required this.minutesPerPause,
  });

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
          'Scheduled',
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
        match.status == MatchStatus.startHalf) {
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
            if (match.status == MatchStatus.started ||
                match.status == MatchStatus.halftime ||
                match.status == MatchStatus.startHalf)
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
