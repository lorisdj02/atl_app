import 'package:atl_app/database/db_write.dart';
import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../utils/atl_colors.dart';
import 'square_team_widget.dart';
import 'abstract_team_dialog.dart';

enum EventType { goal, penalty, missedPenalty, ownGoal, yellowCard, redCard, redYellowCard }

class MatchEventDialog extends AbstractTeamDialog {
  final int coordinatorId;
  final bool penaltyMode;
  final Map<int, List<Player>> playersPerTeam;

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
    switch (type) {
      case EventType.goal:
        return 'Goal';
      case EventType.penalty:
        return 'Penalty';
      case EventType.missedPenalty:
        return 'Missed Penalty';
      case EventType.ownGoal:
        return 'Own Goal';
      case EventType.yellowCard:
        return 'Yellow Card';
      case EventType.redCard:
        return 'Red Card';
      case EventType.redYellowCard:
        return 'Double Yellow Card';
    }
  }

  String _getEventTypeValue(EventType type) {
    switch (type) {
      case EventType.goal:
        return 'goal';
      case EventType.penalty:
        return 'penalty';
      case EventType.missedPenalty:
        return 'missedPenalty';
      case EventType.ownGoal:
        return 'ownGoal';
      case EventType.yellowCard:
        return 'yellowCard';
      case EventType.redCard:
        return 'redCard';
      case EventType.redYellowCard:
        return 'redYellowCard';
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
          'Are you sure you want to add ${_getEventTypeName(_selectedEventType!)} for ${_selectedPlayer!.name} ${_selectedPlayer!.surname}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.sportCategory),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);

    try {
      final success = await DBWrite.insertEventMatch(
        widget.matchId,
        _getEventTypeValue(_selectedEventType!),
        playerId: _selectedPlayer!.playerId,
        teamId: selectedTeam!.id,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to add event')));
          setState(() => isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            buildDialogHeader(title: widget.penaltyMode ? 'Insert Penalty' : 'Add Event'),
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
              const Text(
                'Event Type',
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
                hint: const Text('Select event type'),
                items: EventType.values
                    .where((type) {
                      // Filtra redYellowCard sempre
                      if (type == EventType.redYellowCard) return false;
                      
                      // Se siamo in penalty mode, mostra solo penalty e missedPenalty
                      if (widget.penaltyMode) {
                        return type == EventType.penalty || type == EventType.missedPenalty;
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
              const Text(
                'Player',
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
                const Text(
                  'No players available',
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
                  hint: const Text('Select player'),
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
                  : const Text(
                      'Add Event',
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
