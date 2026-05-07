import 'package:atl_app/database/requests/assign_tournament_prizes_request.dart';
import 'package:atl_app/database/responses/assign_football_prizes_response.dart';
import 'package:atl_app/database/services/tournament_service.dart';
import 'package:atl_app/l10n/app_localizations.dart';
import 'package:atl_app/models/enums/sport_category.dart';
import 'package:atl_app/models/football_standing.dart';
import 'package:atl_app/models/football_team_stats.dart';
import 'package:atl_app/models/player.dart';
import 'package:atl_app/utils/atl_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssignFootballPrizesScreen extends StatefulWidget {
  final double tournamentId;
  final SportCategory sportCategory;

  const AssignFootballPrizesScreen({
    super.key,
    required this.tournamentId,
    required this.sportCategory,
  });

  @override
  State<AssignFootballPrizesScreen> createState() =>
      _AssignFootballPrizesScreenState();
}

class _AssignFootballPrizesScreenState extends State<AssignFootballPrizesScreen> {
  AssignFootballPrizesResponse? _data;
  bool _isLoading = true;
  bool _isSaving = false;
  final Map<double, TextEditingController> _controllers = {};
  final Map<double, double> _prizePerPlayer = {};

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final data = await TournamentService.getAssignFootballPrizesScreen(
        widget.tournamentId,
      );
      if (!mounted) return;

      setState(() {
        _data = data;
        _isLoading = false;
      });
      _initializePrizes();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.errorLoadingAssignPrizes(e.toString())),
        ),
      );
    }
  }

  List<Player> _getSortedPlayers() {
    final data = _data;
    if (data == null) return [];
    final players = data.playersCache.values.toList();
    players.sort((a, b) => a.username.compareTo(b.username));
    return players;
  }

  double get _totalPrize {
    final data = _data;
    if (data == null) return 0.0;
    return data.isWinner ? data.tournament.prize1 : data.tournament.prize2;
  }

  double get _totalAssigned {
    return _prizePerPlayer.values.fold(0.0, (sum, value) => sum + value);
  }

  bool get _isTotalValid {
    return _totalAssigned <= _totalPrize + 0.01;
  }

  double _percentForPlayer(double amount) {
    if (_totalPrize <= 0) return 0.0;
    return (amount / _totalPrize) * 100;
  }

  String get _currencySymbol => String.fromCharCode(0x20AC);

  String _formatMoney(double amount) {
    return amount.toStringAsFixed(2);
  }

  String _formatCurrency(double amount) {
    return '$_currencySymbol${_formatMoney(amount)}';
  }

  void _initializePrizes() {
    final players = _getSortedPlayers();
    if (players.isEmpty) return;

    final totalPrize = _totalPrize;
    final baseValue = players.isEmpty ? 0.0 : totalPrize / players.length;
    final roundedBase = double.parse(baseValue.toStringAsFixed(2));

    final Map<double, double> prizeMap = {};
    double assigned = 0.0;

    for (int i = 0; i < players.length; i++) {
      double value = roundedBase;
      if (i == players.length - 1) {
        value = double.parse((totalPrize - assigned).toStringAsFixed(2));
      }
      assigned += value;
      prizeMap[players[i].playerId] = value;
    }

    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();

    for (final entry in prizeMap.entries) {
      _controllers[entry.key] = TextEditingController(
        text: entry.value.toStringAsFixed(2),
      );
    }

    if (!mounted) return;
    setState(() {
      _prizePerPlayer
        ..clear()
        ..addAll(prizeMap);
    });
  }

  double _parseAmount(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed.isNaN || parsed.isInfinite || parsed < 0) {
      return 0.0;
    }
    return parsed;
  }

  void _onPrizeChanged(double playerId, String value) {
    final parsed = _parseAmount(value);
    setState(() {
      _prizePerPlayer[playerId] = parsed;
    });
  }

  String _buildContributionText(Player player) {
    final data = _data;
    if (data == null) return _l10n.contributionUnavailable;

    final FootballTeamStats? stat =
        data.footballPlayerStatsCache[player.playerId];
    if (stat == null) {
      return _l10n.contributionUnavailable;
    }

    final stats =
        '${stat.goals} - ${stat.motm} - ${stat.yellowCards} - ${stat.redCards}';
    return _l10n.contributionLabel(stats);
  }

  Future<void> _submitPrizes() async {
    final data = _data;
    if (data == null || !_isTotalValid) return;

    setState(() => _isSaving = true);

    final request = AssignTournamentPrizesRequest(
      tournamentId: data.tournament.id,
      teamId: data.team.id,
      prizePerPlayer: Map<double, double>.from(_prizePerPlayer),
    );

    try {
      await TournamentService.assignTournamentPrizes(
        data.tournament.id,
        request,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.errorAssigningPrizes(e.toString())),
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final players = _getSortedPlayers();

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _l10n.assignPrizesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? Center(
              child: Text(
                _l10n.error,
                style: const TextStyle(color: ATLColors.subtext),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_l10n.teamLabel}: ${data.team.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ATLColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_l10n.tournamentLabel}: ${data.tournament.name}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: ATLColors.subtext,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.isWinner
                            ? _l10n.firstPlacePrize
                            : _l10n.secondPlacePrize,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ATLColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _l10n.totalPrizeLabel(
                          _formatCurrency(_totalPrize),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ATLColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: players.isEmpty
                      ? Center(
                          child: Text(
                            _l10n.noPlayersFoundInTeam,
                            style: const TextStyle(
                              fontSize: 16,
                              color: ATLColors.subtext,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];
                            final amount =
                                _prizePerPlayer[player.playerId] ?? 0.0;
                            final percent = _percentForPlayer(amount);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: ATLColors.darkBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _buildContributionText(player),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: ATLColors.subtext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 120,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        TextField(
                                          controller:
                                              _controllers[player.playerId],
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*[\.,]?\d{0,2}'),
                                            ),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: _l10n.prizeAmountLabel,
                                            prefixText: '$_currencySymbol ',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) => _onPrizeChanged(
                                            player.playerId,
                                            value,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _l10n.percentOfTotal(percent),
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: ATLColors.subtext,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ATLColors.background,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _l10n.totalAssignedLabel(
                          _formatCurrency(_totalAssigned),
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          color: ATLColors.subtext,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!_isTotalValid)
                        Text(
                          _l10n.prizeTotalExceeded,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          _l10n.remainingPrizeLabel(
                            _formatCurrency(_totalPrize - _totalAssigned),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: ATLColors.subtext,
                          ),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _isSaving || !_isTotalValid
                            ? null
                            : _submitPrizes,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ATLColors.getPrimaryColor(
                            widget.sportCategory,
                          ),
                          disabledBackgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _l10n.assignPrizesLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
