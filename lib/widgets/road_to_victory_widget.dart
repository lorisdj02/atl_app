import 'package:flutter/material.dart';
import '../models/football_match.dart';
import '../models/final_stage_bracket.dart';
import '../models/enums/sport_category.dart';
import '../models/team.dart';
import '../models/tournament.dart';
import '../utils/atl_colors.dart';
import 'football_match_bracket.dart';
import '../l10n/app_localizations.dart';
import '../models/enums/leg_order_type.dart';

/// Widget per visualizzare il tabellone Road to Victory di un torneo
class RoadToVictoryWidget extends StatefulWidget {
  final Tournament tournament;
  final SportCategory sportCategory;
  final List<FootballMatch> matches;
  final List<FinalStageBracket> finalStageBrackets;
  final Map<double, Team> teamsCache;

  const RoadToVictoryWidget({
    super.key,
    required this.tournament,
    required this.sportCategory,
    required this.matches,
    required this.finalStageBrackets,
    required this.teamsCache,
  });

  @override
  State<RoadToVictoryWidget> createState() => _RoadToVictoryWidgetState();
}

class _RoadToVictoryWidgetState extends State<RoadToVictoryWidget> {
  Map<String, _BracketDisplayData> _buildBracketData() {
    final dataByGroup = <String, _BracketDisplayData>{};
    final matchesByBracketId = <double, List<FootballMatch>>{};

    for (final match in widget.matches) {
      final bracketId = match.finalStageBracketId;
      if (bracketId == null) continue;
      matchesByBracketId.putIfAbsent(bracketId, () => []).add(match);
    }

    for (final bracket in widget.finalStageBrackets) {
      final matches = List<FootballMatch>.from(
        matchesByBracketId[bracket.id] ?? const [],
      )..sort((a, b) {
          final orderCompare =
              _legOrderRank(a.legOrder).compareTo(_legOrderRank(b.legOrder));
          if (orderCompare != 0) return orderCompare;
          return a.id.compareTo(b.id);
        });

      FootballMatch? firstLeg;
      FootballMatch? secondLeg;
      for (final match in matches) {
        if (match.legOrder == LegOrderType.firstLeg && firstLeg == null) {
          firstLeg = match;
        } else if (match.legOrder == LegOrderType.secondLeg &&
            secondLeg == null) {
          secondLeg = match;
        }
      }

      final baseMatch =
          firstLeg ?? secondLeg ?? (matches.isNotEmpty ? matches.first : null);
      final homeTeamId = baseMatch?.homeTeamId;
      final awayTeamId = baseMatch?.awayTeamId;

      final homeTeam =
          homeTeamId != null ? widget.teamsCache[homeTeamId] : null;
      final awayTeam =
          awayTeamId != null ? widget.teamsCache[awayTeamId] : null;
      final winnerTeamId =
          _getWinnerTeamId(bracket, homeTeamId, awayTeamId);

      dataByGroup[bracket.groupName] = _BracketDisplayData(
        homeTeamId: homeTeamId,
        awayTeamId: awayTeamId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        winnerTeamId: winnerTeamId,
      );
    }

    return dataByGroup;
  }

  int _legOrderRank(LegOrderType? legOrder) {
    if (legOrder == null) return 0; // Considera null come ultimo
    switch (legOrder) {
      case LegOrderType.firstLeg:
        return 0;
      case LegOrderType.secondLeg:
        return 1;
    }
  }

  double? _getWinnerTeamId(
    FinalStageBracket bracket,
    double? homeTeamId,
    double? awayTeamId,
  ) {
    if (homeTeamId == null || awayTeamId == null) return null;

    if (bracket.aggregateScoreHome > bracket.aggregateScoreAway) {
      return homeTeamId;
    }

    if (bracket.aggregateScoreAway > bracket.aggregateScoreHome) {
      return awayTeamId;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bracketData = _buildBracketData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: _buildBracket(widget.tournament.numTeamsQualified, bracketData),
      ),
    );
  }

  Widget _buildBracket(
    int qualified,
    Map<String, _BracketDisplayData> bracketData,
  ) {
    final l10n = AppLocalizations.of(context);
    switch (qualified) {
      case 16:
        return _buildBracket16(bracketData);
      case 8:
        return _buildBracket8(bracketData);
      case 4:
        return _buildBracket4(bracketData);
      case 2:
        return _buildBracket2(bracketData);
      default:
        return Center(
          child: Text(
            l10n.invalidBracketConfig,
            style: TextStyle(fontSize: 16, color: ATLColors.subtext),
          ),
        );
    }
  }

  Widget _buildBracket16(Map<String, _BracketDisplayData> bracketData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parte superiore: OF1-OF4, QF1-QF2, SF1
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // OF1-OF4
            _buildMatchWidget('OF1', bracketData),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF2', bracketData),
            _buildVerticalConnector(60),
            _buildMatchWidget('OF3', bracketData),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF4', bracketData),
            const SizedBox(width: 40),
            // QF1-QF2
            _buildMatchWidget('QF1', bracketData),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF2', bracketData),
            const SizedBox(width: 40),
            // SF1
            _buildMatchWidget('SF1', bracketData),
          ],
        ),
        const SizedBox(height: 20),
        // Connettori verso il centro
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Finale al centro
        _buildMatchWidget('FI', bracketData, isFinal: true),
        const SizedBox(height: 20),
        // Connettori dal centro
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Parte inferiore: SF2, QF3-QF4, OF5-OF8
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SF2
            _buildMatchWidget('SF2', bracketData),
            const SizedBox(width: 40),
            // QF3-QF4
            _buildMatchWidget('QF3', bracketData),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF4', bracketData),
            const SizedBox(width: 40),
            // OF5-OF8
            _buildMatchWidget('OF5', bracketData),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF6', bracketData),
            _buildVerticalConnector(60),
            _buildMatchWidget('OF7', bracketData),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF8', bracketData),
          ],
        ),
      ],
    );
  }

  Widget _buildBracket8(Map<String, _BracketDisplayData> bracketData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parte superiore: QF1-QF2, SF1
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildMatchWidget('QF1', bracketData),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF2', bracketData),
            const SizedBox(width: 60),
            _buildMatchWidget('SF1', bracketData),
          ],
        ),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Finale al centro
        _buildMatchWidget('FI', bracketData, isFinal: true),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Parte inferiore: SF2, QF3-QF4
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchWidget('SF2', bracketData),
            const SizedBox(width: 60),
            _buildMatchWidget('QF3', bracketData),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF4', bracketData),
          ],
        ),
      ],
    );
  }

  Widget _buildBracket4(Map<String, _BracketDisplayData> bracketData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // SF1 sopra
        _buildMatchWidget('SF1', bracketData),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Finale al centro
        _buildMatchWidget('FI', bracketData, isFinal: true),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // SF2 sotto
        _buildMatchWidget('SF2', bracketData),
      ],
    );
  }

  Widget _buildBracket2(Map<String, _BracketDisplayData> bracketData) {
    return _buildMatchWidget('FI', bracketData, isFinal: true);
  }

  Widget _buildMatchWidget(
    String group,
    Map<String, _BracketDisplayData> bracketData, {
    bool isFinal = false,
  }) {
    final data = bracketData[group];

    return Column(
      children: [
        Text(
          _getPhaseLabel(group),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: ATLColors.getPrimaryColor(widget.sportCategory),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        FootballMatchBracket(
          sportCategory: widget.sportCategory,
          homeTeamId: data?.homeTeamId,
          awayTeamId: data?.awayTeamId,
          homeTeam: data?.homeTeam,
          awayTeam: data?.awayTeam,
          winnerTeamId: data?.winnerTeamId,
          isFinal: isFinal,
        ),
      ],
    );
  }

  Widget _buildVerticalConnector(double width) {
    return Container(
      width: width,
      height: 2,
      color: ATLColors.getPrimaryColor(widget.sportCategory).withOpacity(0.3),
    );
  }

  Widget _buildHorizontalConnector() {
    return Container(
      width: 2,
      height: 30,
      color: ATLColors.getPrimaryColor(widget.sportCategory).withOpacity(0.3),
    );
  }

  String _getPhaseLabel(String group) {
    final l10n = AppLocalizations.of(context);
    if (group.startsWith('OF')) {
      return l10n.roundOf16NumLabel(group.substring(2));
    } else if (group.startsWith('QF')) {
      return l10n.quarterFinalNumLabel(group.substring(2));
    } else if (group.startsWith('SF')) {
      return l10n.semifinalNumLabel(group.substring(2));
    } else if (group == 'FI') {
      return l10n.finalLabel;
    }
    return group;
  }
}

class _BracketDisplayData {
  final double? homeTeamId;
  final double? awayTeamId;
  final Team? homeTeam;
  final Team? awayTeam;
  final double? winnerTeamId;

  const _BracketDisplayData({
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeam,
    required this.awayTeam,
    required this.winnerTeamId,
  });
}
