import 'package:atl_app/database/responses/football_match_bracket_response.dart';
import 'package:flutter/material.dart';
import '../models/football_match.dart';
import '../models/sport_category.dart';
import '../models/team.dart';
import '../utils/atl_colors.dart';
import '../config/api_json_keys.dart';
import '../database/db_read.dart';
import '../../l10n/app_localizations.dart';

/// Widget per visualizzare un match all'interno del tabellone Road to Victory
class FootballMatchBracket extends StatefulWidget {
  final int matchId;
  final SportCategory sportCategory;
  final int? nextRoundHomeTeamId;
  final int? nextRoundAwayTeamId;
  final bool isFinal;

  const FootballMatchBracket({
    super.key,
    required this.matchId,
    required this.sportCategory,
    this.nextRoundHomeTeamId,
    this.nextRoundAwayTeamId,
    this.isFinal = false,
  });

  @override
  State<FootballMatchBracket> createState() => _FootballMatchBracketState();
}

class _FootballMatchBracketState extends State<FootballMatchBracket> {
  FootballMatch? _match;
  Team? _homeTeam;
  Team? _awayTeam;
  int? _winnerId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  Future<void> _loadMatchData() async {
    try {
      final FootballMatchBracketResponse data =
          await DBRead.getFootballMatchBracket(
            widget.matchId,
            widget.sportCategory,
            isFinal: widget.isFinal,
          );

      final match = data.match;

      final Team? homeTeam = data.homeTeam;
      final Team? awayTeam = data.awayTeam;
      int? winnerId = data.winnerId;

      if (!(widget.isFinal && match.status == FootballMatchStatus.finished)) {
        // Per le altre fasi controlla chi è passato al turno successivo
        if (widget.nextRoundHomeTeamId != null &&
            match.homeTeamId == widget.nextRoundHomeTeamId) {
          winnerId = match.homeTeamId;
        } else if (widget.nextRoundHomeTeamId != null &&
            match.awayTeamId == widget.nextRoundHomeTeamId) {
          winnerId = match.awayTeamId;
        } else if (widget.nextRoundAwayTeamId != null &&
            match.homeTeamId == widget.nextRoundAwayTeamId) {
          winnerId = match.homeTeamId;
        } else if (widget.nextRoundAwayTeamId != null &&
            match.awayTeamId == widget.nextRoundAwayTeamId) {
          winnerId = match.awayTeamId;
        }
      }

      if (mounted) {
        setState(() {
          _match = match;
          _homeTeam = homeTeam;
          _awayTeam = awayTeam;
          _winnerId = winnerId;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).errorLoadingDataGeneric(e.toString()),
          ),
          backgroundColor: Colors.red,
        ),
      );
        setState(() => _isLoading = false);
      }
    }
  }

  Color? _getBorderColor(int? teamId) {
    if (teamId == null || _winnerId == null) return null;

    if (widget.isFinal && _match?.status == FootballMatchStatus.finished) {
      // Finale: oro per il vincitore, argento per il secondo
      if (teamId == _winnerId) {
        return const Color(0xFFFFD700); // Oro
      } else {
        return const Color(0xFFC0C0C0); // Argento
      }
    } else if (teamId == _winnerId) {
      // Altri turni: verde per il vincitore
      return Colors.green;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ATLColors.getPrimaryColor(
              widget.sportCategory,
            ).withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_match == null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ATLColors.getPrimaryColor(
              widget.sportCategory,
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
            widget.sportCategory,
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
          _buildTeamColumn(_homeTeam, true),
          SizedBox(width: widget.isFinal ? 16 : 12),
          // Away Team
          _buildTeamColumn(_awayTeam, false),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(Team? team, bool isHome) {
    final teamId = isHome ? _match!.homeTeamId : _match!.awayTeamId;
    final borderColor = _getBorderColor(teamId);
    final teamSize = widget.isFinal ? 70.0 : 50.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Team widget with border
        Container(
          decoration: borderColor != null
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.isFinal ? 16 : 14),
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
              fontSize: widget.isFinal ? 11 : 9,
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
            widget.sportCategory,
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
      child: team.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                team.imageUrl!,
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
            color: ATLColors.getPrimaryColor(widget.sportCategory),
            size: size * 0.4,
          ),
          SizedBox(height: size * 0.05),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              team.alias,
              style: TextStyle(
                color: ATLColors.getPrimaryColor(widget.sportCategory),
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
