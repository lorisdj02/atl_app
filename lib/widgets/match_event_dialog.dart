import 'package:atl_app/database/services/match_service.dart';
import 'package:atl_app/models/football_match_event.dart';
import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../utils/atl_colors.dart';
import 'square_team_widget.dart';
import 'abstract_team_dialog.dart';
import '../l10n/app_localizations.dart';
import '../models/enums/football_match_event_type.dart';

enum EventType {
  goal,
  penalty,
  missedPenalty,
  ownGoal,
  yellowCard,
  redCard,
  redYellowCard,
}

class MatchEventDialog extends AbstractTeamDialog {
  final double coordinatorId;
  final bool penaltyMode;
  final Map<double, List<Player>> playersPerTeam;

  const MatchEventDialog({
    super.key,
    required super.homeTeam,
    required super.awayTeam,
    required super.tournamentId,
    required super.matchId,
    required super.sportCategory,
    required this.coordinatorId,
    required this.playersPerTeam,
    this.penaltyMode = false,
  });

  @override
  State<MatchEventDialog> createState() => _MatchEventDialogState();
}

class _MatchEventDialogState extends State<MatchEventDialog>
    with TeamDialogMixin {
  EventType? _selectedEventType;
  Player? _selectedPlayer;
  List<Player> _availablePlayers = [];

  String _getEventTypeName(EventType type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case EventType.goal:
        return l10n.eventGoal;
      case EventType.penalty:
        return l10n.eventPenalty;
      case EventType.missedPenalty:
        return l10n.eventMissedPenalty;
      case EventType.ownGoal:
        return l10n.eventOwnGoal;
      case EventType.yellowCard:
        return l10n.eventYellowCard;
      case EventType.redCard:
        return l10n.eventRedCard;
      case EventType.redYellowCard:
        return l10n.eventDoubleYellowCard;
    }
  }

  FootballMatchEventType _getFootballMatchEventTypeValue(EventType type) {
    switch (type) {
      case EventType.goal:
        return FootballMatchEventType.goal;
      case EventType.penalty:
        return FootballMatchEventType.penalty;
      case EventType.missedPenalty:
        return FootballMatchEventType.missedPenalty;
      case EventType.ownGoal:
        return FootballMatchEventType.ownGoal;
      case EventType.yellowCard:
        return FootballMatchEventType.yellowCard;
      case EventType.redCard:
        return FootballMatchEventType.redCard;
      case EventType.redYellowCard:
        return FootballMatchEventType.redYellowCard;
    }
  }

  void _loadPlayers() {
    if (selectedTeam == null) return;
    setState(() {
      _selectedPlayer = null;
      _availablePlayers = List<Player>.from(
        widget.playersPerTeam[selectedTeam!.id] ?? [],
      );
    });
  }

  Future<void> _submitEvent() async {
    final l10n = AppLocalizations.of(context);
    if (selectedTeam == null ||
        _selectedEventType == null ||
        _selectedPlayer == null) {
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Event'),
        content: Text(
          l10n.confirmEventMsg(
            _getEventTypeName(_selectedEventType!),
            "${_selectedPlayer!.name} ${_selectedPlayer!.surname}",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.confirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);

    try {

      FootballMatchEvent newEvent = FootballMatchEvent(
        id: 0, // Mocked, will be replaced by backend
        matchId: widget.matchId,
        type: _getFootballMatchEventTypeValue(_selectedEventType!),
        teamId: selectedTeam!.id,
        playerId: _selectedPlayer!.playerId,
        minute: 0, // Mocked
        createdAt: DateTime.now(), // Mocked
      );

      await MatchService.Write.insertFootballMatchEvent(
        widget.matchId.toDouble(),
        newEvent,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric(e.toString()))),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            buildDialogHeader(
              title: widget.penaltyMode
                  ? l10n.insertPenalty
                  : l10n.addEventButton,
            ),
            const SizedBox(height: 24),

            // Teams
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamSelector(widget.homeTeam, true),
                const SizedBox(width: 16),
                _buildTeamSelector(widget.awayTeam, false),
              ],
            ),
            const SizedBox(height: 24),

            // Event Type Selector - Mostra solo se un team è stato selezionato
            if (selectedTeam != null) ...[
              Text(
                l10n.eventTypeLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EventType>(
                value: _selectedEventType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                hint: Text(l10n.selectEventType),
                items: EventType.values
                    .where((type) {
                      // Filtra redYellowCard sempre
                      if (type == EventType.redYellowCard) return false;

                      // Se siamo in penalty mode, mostra solo penalty e missedPenalty
                      if (widget.penaltyMode) {
                        return type == EventType.penalty ||
                            type == EventType.missedPenalty;
                      }

                      // Altrimenti mostra tutti gli eventi
                      return true;
                    })
                    .map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getEventTypeName(type)),
                      );
                    })
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEventType = value;
                    _selectedPlayer = null;
                  });
                  _loadPlayers();
                },
              ),
              const SizedBox(height: 16),
            ] else ...[
              buildNoTeamSelectedWarning(),
              const SizedBox(height: 16),
            ],

            // Player Selector
            if (_selectedEventType != null) ...[
              Text(
                l10n.selectPlayer,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ATLColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_availablePlayers.isEmpty)
                Text(
                  l10n.noPlayersAvailable,
                  style: TextStyle(color: ATLColors.subtext),
                )
              else
                DropdownButtonFormField<Player>(
                  value: _selectedPlayer,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  hint: Text(l10n.selectPlayer),
                  items: _availablePlayers.map((player) {
                    return DropdownMenuItem(
                      value: player,
                      child: Text('${player.name} ${player.surname}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedPlayer = value);
                  },
                ),
            ],

            const Spacer(),

            // Submit Button
            ElevatedButton(
              onPressed:
                  selectedTeam != null &&
                      _selectedEventType != null &&
                      _selectedPlayer != null &&
                      !isLoading
                  ? _submitEvent
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ATLColors.getPrimaryColor(
                  widget.sportCategory,
                ),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      l10n.addEventButton,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSelector(Team team, bool isHome) {
    final isSelected = selectedTeam?.id == team.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTeam = team;
          _selectedPlayer = null;
        });
        _loadPlayers();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? ATLColors.getPrimaryColor(widget.sportCategory)
                : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            SquareTeamWidget(
              team: team,
              sportCategory: widget.sportCategory,
              isClickable: false,
            ),
            const SizedBox(height: 8),
            Text(
              team.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? ATLColors.getPrimaryColor(widget.sportCategory)
                    : ATLColors.darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
