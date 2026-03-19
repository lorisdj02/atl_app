import 'package:flutter/material.dart';
import '../models/football_match.dart';
import '../models/sport_category.dart';
import '../models/tournament.dart';
import '../utils/atl_colors.dart';
import '../widgets/loading_atl.dart';
import 'match_bracket.dart';
import '../database/db_read.dart';
import '../config/api_json_keys.dart';
import '../l10n/app_localizations.dart';

/// Widget per visualizzare il tabellone Road to Victory di un torneo
class RoadToVictoryWidget extends StatefulWidget {
  final int tournamentId;
  final SportCategory sportCategory;

  const RoadToVictoryWidget({
    super.key,
    required this.tournamentId,
    required this.sportCategory,
  });

  @override
  State<RoadToVictoryWidget> createState() => _RoadToVictoryWidgetState();
}

class _RoadToVictoryWidgetState extends State<RoadToVictoryWidget> {
  bool _isLoading = true;
  Tournament? _tournament;
  Map<String, List<FootballMatch>> _matchesByGroup = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {

      final data = await DBRead.getMatchesInTournament(widget.tournamentId, widget.sportCategory);

      final tournament = data[ApiJsonKeys.tournament] as Tournament?;
      if (tournament == null) {
        setState(() => _isLoading = false);
        return;
      }

      Map<String, List<FootballMatch>> matchesByGroup = {};

      final qualified = tournament.qualified;
      final phases = _getPhasesForQualified(qualified);
      final List<FootballMatch> matches = data[ApiJsonKeys.matches] as List<FootballMatch>;
      // Carica tutti i match per ogni fase
      for (final phase in phases) {
        matchesByGroup[phase] = matches.where((m) => m.groupName == phase).toList();
      }

      if (mounted) {
        setState(() {
          _matchesByGroup = matchesByGroup;
          _tournament = tournament;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _getPhasesForQualified(int qualified) {
    final phases = <String>[];

    if (qualified >= 16) {
      // Ottavi: OF1-OF8
      for (int i = 1; i <= 8; i++) {
        phases.add('OF$i');
      }
    }

    if (qualified >= 8) {
      // Quarti: QF1-QF4
      for (int i = 1; i <= 4; i++) {
        phases.add('QF$i');
      }
    }

    if (qualified >= 4) {
      // Semifinali: SF1-SF2
      phases.add('SF1');
      phases.add('SF2');
    }

    if (qualified >= 2) {
      // Finale: FI
      phases.add('FI');
    }

    return phases;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) {
      return const LoadingATL();
    }

    if (_tournament == null) {
      return Center(
        child: Text(
          l10n.tournamentNotFoundError,
          style: TextStyle(fontSize: 16, color: ATLColors.subtext),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(child: _buildBracket(_tournament!.qualified)),
    );
  }

  Widget _buildBracket(int qualified) {
    final l10n = AppLocalizations.of(context);
    switch (qualified) {
      case 16:
        return _buildBracket16();
      case 8:
        return _buildBracket8();
      case 4:
        return _buildBracket4();
      case 2:
        return _buildBracket2();
      default:
        return Center(
          child: Text(
            l10n.invalidBracketConfig,
            style: TextStyle(fontSize: 16, color: ATLColors.subtext),
          ),
        );
    }
  }

  Widget _buildBracket16() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parte superiore: OF1-OF4, QF1-QF2, SF1
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // OF1-OF4
            _buildMatchWidget('OF1'),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF2'),
            _buildVerticalConnector(60),
            _buildMatchWidget('OF3'),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF4'),
            const SizedBox(width: 40),
            // QF1-QF2
            _buildMatchWidget('QF1'),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF2'),
            const SizedBox(width: 40),
            // SF1
            _buildMatchWidget('SF1'),
          ],
        ),
        const SizedBox(height: 20),
        // Connettori verso il centro
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Finale al centro
        _buildMatchWidget('FI', isFinal: true),
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
            _buildMatchWidget('SF2'),
            const SizedBox(width: 40),
            // QF3-QF4
            _buildMatchWidget('QF3'),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF4'),
            const SizedBox(width: 40),
            // OF5-OF8
            _buildMatchWidget('OF5'),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF6'),
            _buildVerticalConnector(60),
            _buildMatchWidget('OF7'),
            _buildVerticalConnector(40),
            _buildMatchWidget('OF8'),
          ],
        ),
      ],
    );
  }

  Widget _buildBracket8() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parte superiore: QF1-QF2, SF1
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildMatchWidget('QF1'),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF2'),
            const SizedBox(width: 60),
            _buildMatchWidget('SF1'),
          ],
        ),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Finale al centro
        _buildMatchWidget('FI', isFinal: true),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Parte inferiore: SF2, QF3-QF4
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchWidget('SF2'),
            const SizedBox(width: 60),
            _buildMatchWidget('QF3'),
            _buildVerticalConnector(80),
            _buildMatchWidget('QF4'),
          ],
        ),
      ],
    );
  }

  Widget _buildBracket4() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // SF1 sopra
        _buildMatchWidget('SF1'),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // Finale al centro
        _buildMatchWidget('FI', isFinal: true),
        const SizedBox(height: 20),
        _buildHorizontalConnector(),
        const SizedBox(height: 20),
        // SF2 sotto
        _buildMatchWidget('SF2'),
      ],
    );
  }

  Widget _buildBracket2() {
    return _buildMatchWidget('FI', isFinal: true);
  }

  Widget _buildMatchWidget(String group, {bool isFinal = false}) {
    final l10n = AppLocalizations.of(context);
    final matches = _matchesByGroup[group] ?? [];
    if (matches.isEmpty) {
      return Container(
        width: 140,
        height: 100,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getPhaseLabel(group),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.subtext,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tbd,
                style: TextStyle(fontSize: 12, color: ATLColors.subtext),
              ),
            ],
          ),
        ),
      );
    }

    // Ordina per ID e prendi quello con ID più basso (per gestire andata/ritorno)
    matches.sort((a, b) => a.id.compareTo(b.id));
    final match = matches.first;
    int? nextRoundHomeTeamId;
    int? nextRoundAwayTeamId;

    // Trova i team del turno successivo per determinare i vincitori
    if (!isFinal) {
      final nextGroup = _getNextRoundGroup(group);
      if (nextGroup != null) {
        final nextMatches = _matchesByGroup[nextGroup] ?? [];
        if (nextMatches.isNotEmpty) {
          // Anche qui prendi quello con ID più basso
          nextMatches.sort((a, b) => a.id.compareTo(b.id));
          final nextMatch = nextMatches.first;
          nextRoundHomeTeamId = nextMatch.homeTeamId;
          nextRoundAwayTeamId = nextMatch.awayTeamId;
        }
      }
    }

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
        MatchBracket(
          matchId: match.id,
          sportCategory: widget.sportCategory,
          nextRoundHomeTeamId: nextRoundHomeTeamId,
          nextRoundAwayTeamId: nextRoundAwayTeamId,
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

  String? _getNextRoundGroup(String currentGroup) {
    // OF1, OF2 -> QF1
    if (currentGroup == 'OF1' || currentGroup == 'OF2') return 'QF1';
    if (currentGroup == 'OF3' || currentGroup == 'OF4') return 'QF2';
    if (currentGroup == 'OF5' || currentGroup == 'OF6') return 'QF3';
    if (currentGroup == 'OF7' || currentGroup == 'OF8') return 'QF4';

    // QF1, QF2 -> SF1
    if (currentGroup == 'QF1' || currentGroup == 'QF2') return 'SF1';
    if (currentGroup == 'QF3' || currentGroup == 'QF4') return 'SF2';

    // SF1, SF2 -> FI
    if (currentGroup == 'SF1' || currentGroup == 'SF2') return 'FI';

    return null;
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
