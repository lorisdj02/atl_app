import 'package:atl_app/database/db_write.dart';
import 'package:atl_app/models/field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../models/sport_category.dart';
import '../../models/football_match_event.dart';
import '../../models/player.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/football_match_widget.dart';
import '../../widgets/atl_floating_button.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/match_event_card.dart';
import '../../widgets/match_event_dialog.dart';
import '../../widgets/match_info_card.dart';
import '../../widgets/football_motm_selector_dialog.dart';
import '../../widgets/schedule_match_dialog.dart';
import '../../widgets/referee_match_dialog.dart';
import '../../providers/user_provider.dart';
import '../../config/api_json_keys.dart';
import '../../database/db_read.dart';

class FootballMatchScreen extends StatefulWidget {
  final int matchId;
  final SportCategory currentSport;

  const FootballMatchScreen({
    super.key,
    required this.matchId,
    required this.currentSport,
  });

  @override
  State<FootballMatchScreen> createState() => _FootballMatchScreenState();
}

class _FootballMatchScreenState extends State<FootballMatchScreen> {
  FootballMatch? _match;
  Team? _homeTeam;
  Team? _awayTeam;
  List<FootballMatchEvent> _events = [];
  bool _isLoading = true;
  late int _minutesPerRound;
  late int _minutesPerPause;
  int? _coordinatorId;
  bool _refereeCheck = false;
  List<String> _availableRefereeRoles = [];
  bool _isLoadingRefereeRoles = true;
  int _matchInfoKey = 0; // Counter to force MatchInfoCard rebuild
  bool _hasChanges = false; // Track if any changes were made
  Map<int, List<Player>> _playersPerTeam = {};
  Map<int, List<Player>> _availablePlayersPerTeam = {};
  Map<String, String> _assignmentPerRefereeNameSurname =
      {}; // key: Name+Surname, value: Role
  String _cityName = '';
  Field? _field;
  bool _canMatchFinish = false;

  bool get _isNotScheduled =>
      _match != null && _match!.status == MatchStatus.notScheduled;

  bool get _isScheduled =>
      _match != null && _match!.status == MatchStatus.scheduled;

  // TODO: DEBUG - Rimuovere questa logica in produzione!
  // In produzione, deve essere: return difference.inMinutes < 60;
  bool get _canStartMatch {
    if (!_isScheduled || _match?.scheduledStart == null) return false;

    // DEBUG: Permette di avviare quando non è più possibile rischedulare (< 24h)
    return _refereeCheck;
  }

  bool get _canReschedule {
    if (!_isScheduled || _match?.scheduledStart == null) return true;
    final difference = _match!.scheduledStart!.difference(DateTime.now());
    return difference.inHours >= 24;
  }

  bool get _isInProgress =>
      _match != null &&
      (_match!.status == MatchStatus.started ||
          _match!.status == MatchStatus.startHalf);

  bool get _isHalftime =>
      _match != null && _match!.status == MatchStatus.halftime;

  bool get _isFinished =>
      _match != null && _match!.status == MatchStatus.finished;

  bool get _isPenaltyShootOut =>
      _match != null && _match!.status == MatchStatus.penaltyShootOut;

  bool get _needsMotm => _isFinished && _match?.motmPlayerId == null;

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  Future<void> _loadMatchData() async {
    setState(() => _isLoading = true);

    try {
      // Carica la partita dal database

      final data = await DBRead.getFootballMatchScreen(widget.matchId);
      List<FootballMatchEvent> events = data[ApiJsonKeys.events] ?? [];

      events.sort(
        (a, b) => b.eventTime.compareTo(a.eventTime),
      ); // Ordina per data decrescente

      setState(() {
        _match = data[ApiJsonKeys.match];
        _homeTeam = data[ApiJsonKeys.homeTeam];
        _awayTeam = data[ApiJsonKeys.awayTeam];
        _events = events;
        _minutesPerRound = data[ApiJsonKeys.minutesPerRound];
        _minutesPerPause = data[ApiJsonKeys.minutesPerPause];
        _availableRefereeRoles = data[ApiJsonKeys.availableRefereeRoles];
        _playersPerTeam = data[ApiJsonKeys.playersPerTeam];
        _cityName = data[ApiJsonKeys.cityName];
        _assignmentPerRefereeNameSurname =
            data[ApiJsonKeys.assignmentPerRefereeNameSurname];
        _field = data[ApiJsonKeys.field];
        _coordinatorId = data[ApiJsonKeys.coordinatorId];
        _refereeCheck = data[ApiJsonKeys.refereeCheck];
        _canMatchFinish = data[ApiJsonKeys.canMatchFinish];
        _isLoadingRefereeRoles = false;
        _isLoading = false;
      });
      _reloadAvailablePlayersPerTeam();
    } catch (e) {
      print('Error loading match data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshEvents() async {
    try {
      final Map<String, dynamic> events = await DBRead.getMatchEvents(
        widget.matchId,
      );
      List<FootballMatchEvent> matchEvents = events[ApiJsonKeys.events] ?? [];
      matchEvents.sort(
        (a, b) => b.eventTime.compareTo(a.eventTime),
      ); // Ordina per data decrescente
      setState(() {
        _events = matchEvents;
      });
      _reloadAvailablePlayersPerTeam();
    } catch (e) {
      print('Error refreshing events: $e');
    }
  }

  void _reloadAvailablePlayersPerTeam() {
    setState(() {
      _availablePlayersPerTeam = _playersPerTeam.map((teamId, players) {
        final availablePlayers = players.where((player) {
          // Un giocatore è disponibile se non ha un cartellino rosso o doppio giallo
          return !_events.any(
            (event) =>
                event.playerId == player.playerId &&
                (event.type == FootballMatchEventType.redCard ||
                    event.type == FootballMatchEventType.redYellowCard),
          );
        }).toList();
        return MapEntry(teamId, availablePlayers);
      });
    });
  }

  Future<void> _showRefereeMatchDialog() async {
    if (_availableRefereeRoles.isEmpty) return;

    final String? selectedRole = await showDialog<String>(
      context: context,
      builder: (context) => RefereeMatchDialog(
        availableRoles: _availableRefereeRoles,
        sportCategory: widget.currentSport,
      ),
    );

    if (selectedRole == null || !mounted) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final refereeId = userProvider.activeRoleId;

    if (refereeId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Referee ID not found')),
        );
      }
      return;
    }

    try {
      final success = await DBWrite.insertAssignment(
        widget.matchId,
        refereeId,
        selectedRole,
      );

      if (success) {
        setState(() {
          _matchInfoKey++; // Increment to force MatchInfoCard rebuild
        });
        _loadMatchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Assignment created successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create assignment')),
          );
        }
      }
    } catch (e) {
      print('Error creating assignment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating assignment')),
        );
      }
    }
  }

  Future<void> _showScheduleDialog() async {
    if (_field == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Field information not available'),
          ),
        );
      }
      return;
    }

    if (_match == null) return;

    final wasScheduled = _match?.status == MatchStatus.scheduled;

    final DateTime? scheduledStart = await showDialog<DateTime>(
      context: context,
      builder: (context) => ScheduleMatchDialog(
        tournamentId: _match!.tournamentId,
        fieldId: _field!.id,
        currentSport: widget.currentSport,
        currentScheduledStart: _match?.scheduledStart,
      ),
    );

    if (scheduledStart == null || !mounted) return;

    final success = await DBWrite.scheduleMatch(
      widget.matchId,
      scheduledStart,
      _coordinatorId!,
    );

    if (success) {
      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasScheduled
                  ? 'Match rescheduled successfully'
                  : 'Match scheduled successfully',
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _canReschedule
                  ? 'Failed to schedule match. The field might not be available.'
                  : 'Cannot reschedule match within 24 hours of start time',
            ),
          ),
        );
      }
    }
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.getPrimaryColor(
                    widget.currentSport,
                  ),
                  foregroundColor: Colors.white,
                ),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleMatchAction(String action) async {
    if (_coordinatorId == null) return;

    // Mostra dialog di conferma
    String title = '';
    String message = '';

    switch (action) {
      case 'start':
        title = 'Start Match';
        message = 'Are you sure you want to start the match?';
        break;
      case 'halftime':
        title = 'Go to Halftime';
        message = 'Are you sure you want to end the first half?';
        break;
      case 'startHalf':
        title = 'Start Second Half';
        message = 'Are you sure you want to start the second half?';
        break;
      case 'finish':
        title = 'Finish Match';
        message =
            'Are you sure you want to finish the match? This action cannot be undone.';
        break;
    }

    final confirmed = await _showConfirmationDialog(title, message);
    if (!confirmed) return;

    bool success = false;

    switch (action) {
      case 'start':
        success = await DBWrite.insertEventMatch(widget.matchId, 'start');
        break;
      case 'halftime':
        success = await DBWrite.insertEventMatch(widget.matchId, 'halftime');
        break;
      case 'startHalf':
        success = await DBWrite.insertEventMatch(widget.matchId, 'startHalf');
        break;
      case 'finish':
        success = await DBWrite.insertEventMatch(widget.matchId, 'finish');
        break;
    }

    if (success) {
      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Match ${action} successfully')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to ${action} match')));
      }
    }
  }

  Future<void> _showMatchActionsMenu() async {
    List<String> actions = [];

    if (_isNotScheduled) {
      actions.add('Schedule Match');
    } else if (_isScheduled) {
      if (_canReschedule) {
        actions.add('Reschedule Match');
      }
      if (_canStartMatch) {
        actions.add('Start Match');
      }
    } else if (_isInProgress) {
      // Go to Halftime solo se il match è in stato 'started' (primo tempo)
      if (_match?.status == MatchStatus.started) {
        actions.add('Go to Halftime');
      }
      actions.add('Add Player Event');

      // Se siamo nel secondo tempo (startHalf), controlla se il match può finire
      if (_match?.status == MatchStatus.startHalf) {
        if (_canMatchFinish) {
          actions.add('Finish Match');
        } else {
          actions.add('Start Penalty ShootOut');
        }
      }
      // Nel primo tempo NON può finire
    } else if (_isHalftime) {
      actions.add('Start Second Half');
    } else if (_isPenaltyShootOut) {
      // Durante i rigori, verifica se il match può finire
      if (_canMatchFinish) {
        actions.add('Finish Match');
      } else {
        actions.add('Insert Penalty');
      }
    }

    if (actions.isEmpty) return;

    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions.map((action) {
              IconData icon;
              switch (action) {
                case 'Schedule Match':
                  icon = Icons.schedule;
                  break;
                case 'Reschedule Match':
                  icon = Icons.update;
                  break;
                case 'Start Match':
                  icon = Icons.play_arrow;
                  break;
                case 'Go to Halftime':
                  icon = Icons.pause;
                  break;
                case 'Start Second Half':
                  icon = Icons.play_arrow;
                  break;
                case 'Add Player Event':
                  icon = Icons.add;
                  break;
                case 'Insert Penalty':
                  icon = Icons.sports_soccer;
                  break;
                case 'Start Penalty ShootOut':
                  icon = Icons.sports;
                  break;
                case 'Finish Match':
                  icon = Icons.stop;
                  break;
                default:
                  icon = Icons.circle;
              }

              return ListTile(
                leading: Icon(
                  icon,
                  color: ATLColors.getPrimaryColor(widget.currentSport),
                ),
                title: Text(action),
                onTap: () => Navigator.pop(context, action),
              );
            }).toList(),
          ),
        );
      },
    );

    if (result == null) return;

    switch (result) {
      case 'Schedule Match':
      case 'Reschedule Match':
        _showScheduleDialog();
        break;
      case 'Start Match':
        _handleMatchAction('start');
        break;
      case 'Go to Halftime':
        _handleMatchAction('halftime');
        break;
      case 'Start Second Half':
        _handleMatchAction('startHalf');
        break;
      case 'Add Player Event':
        _showPlayerEventDialog();
        break;
      case 'Insert Penalty':
        _showPlayerEventDialog(penaltyMode: true);
        break;
      case 'Start Penalty ShootOut':
        _startPenaltyShootOut();
        break;
      case 'Finish Match':
        _handleMatchAction('finish');
        break;
    }
  }

  Future<void> _showPlayerEventDialog({bool penaltyMode = false}) async {
    if (!mounted) return;
    if (_homeTeam == null || _awayTeam == null) {
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MatchEventDialog(
        homeTeam: _homeTeam!,
        awayTeam: _awayTeam!,
        tournamentId: _match!.tournamentId,
        matchId: widget.matchId,
        sportCategory: widget.currentSport,
        coordinatorId: _coordinatorId!,
        playersPerTeam: _availablePlayersPerTeam,
        penaltyMode: penaltyMode,
      ),
    );

    if (result == true) {
      setState(() {
        _hasChanges = true;
      });
      _refreshEvents();
    }
  }

  Future<void> _startPenaltyShootOut() async {
    if (_coordinatorId == null) return;

    final confirmed = await _showConfirmationDialog(
      'Start Penalty Shootout',
      'Are you sure you want to start the penalty shootout?',
    );
    if (!confirmed) return;

    final success = await DBWrite.startFootballPenaltyShootOut(widget.matchId);
    if (success) {
      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Penalty shootout started')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start penalty shootout')),
        );
      }
    }
  }

  Future<void> _showMotmDialog() async {
    if (!mounted) return;
    if (_homeTeam == null || _awayTeam == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FootballMotmSelectorDialog(
        homeTeam: _homeTeam!,
        awayTeam: _awayTeam!,
        tournamentId: _match!.tournamentId,
        matchId: widget.matchId,
        sportCategory: widget.currentSport,
      ),
    );

    if (result == null) return;

    final Player selectedPlayer = result['player'];
    final int teamId = result['teamId'];

    print(
      "Assigning MOTM to player ${selectedPlayer.playerId} in match ${widget.matchId}",
    );

    final success = await DBWrite.addFootballMotm(
      widget.matchId,
      selectedPlayer.playerId,
      teamId,
      _match!.tournamentId,
      _coordinatorId!,
    );

    if (success) {
      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MOTM added successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add MOTM')));
      }
    }
  }

  Future<void> _handleDeleteEvent(FootballMatchEvent event) async {
    // Check if user is the coordinator of this tournament
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isCoordinator = userProvider.isCoordinator;

    if (!isCoordinator || _coordinatorId != userProvider.activeRoleId) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only the tournament coordinator can delete events'),
          ),
        );
      }
      return;
    }

    // Check if it's the most recent event
    if (_events.isEmpty || _events.first.id != event.id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot delete event if it\'s not the last one'),
          ),
        );
      }
      return;
    }

    // Check if it's a match system event
    final forbiddenTypes = {
      FootballMatchEventType.start,
      FootballMatchEventType.startHalf,
      FootballMatchEventType.halftime,
      FootballMatchEventType.finish,
      FootballMatchEventType.penaltyShootOut,
    };

    if (forbiddenTypes.contains(event.type)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only delete player events')),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Event'),
            content: const Text('Do you want to delete this event?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    // Delete the event
    final success = await DBWrite.deleteMatchEvent(widget.matchId, event.id);

    if (success) {
      setState(() {
        _hasChanges = true;
      });
      _refreshEvents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete event')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isCoordinator = userProvider.isCoordinator;
    final isReferee = userProvider.isReferee;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(_hasChanges),
        ),
        title: const Text(
          'Match Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingATL())
          : _match == null
          ? const Center(
              child: Text(
                'Match not found',
                style: TextStyle(fontSize: 18, color: ATLColors.subtext),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Widget della partita
                    FootballMatchWidget(
                      match: _match!,
                      homeTeam: _homeTeam,
                      awayTeam: _awayTeam,
                      clickable: false,
                      currentSport: widget.currentSport,
                      minutesPerRound: _minutesPerRound,
                      minutesPerPause: _minutesPerPause,
                    ),
                    const SizedBox(height: 16),
                    // Match Info Section
                    MatchInfoCard(
                      key: ValueKey(_matchInfoKey),
                      match: _match!,
                      isNotScheduled: _isNotScheduled,
                      isScheduled: _isScheduled,
                      sportCategory: widget.currentSport,
                      field: _field!,
                      cityName: _cityName,
                      assignmentPerRefereeNameSurname:
                          _assignmentPerRefereeNameSurname,
                    ),
                    const SizedBox(height: 16),
                    // Sezione Eventi
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'EVENTS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: ATLColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_homeTeam == null || _awayTeam == null)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 48,
                                      color: ATLColors.subtext,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _homeTeam == null && _awayTeam == null
                                          ? 'Both teams must be determined from previous phase results. Keep playing!'
                                          : _homeTeam == null
                                          ? 'Home team must be determined from previous phase results. Keep playing!'
                                          : 'Away team must be determined from previous phase results. Keep playing!',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: ATLColors.subtext,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_events.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No events yet',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ATLColors.subtext,
                                  ),
                                ),
                              ),
                            )
                          else
                            ..._events
                                .map((event) => _buildEventCard(event))
                                .toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Match ID at the bottom
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          'Match ID: #${widget.matchId}',
                          style: TextStyle(
                            color: ATLColors.subtext,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      floatingActionButton: _match != null
          ? (isCoordinator && _coordinatorId == userProvider.activeRoleId
                ? _buildFloatingActionButton()
                : isReferee &&
                      !_isLoadingRefereeRoles &&
                      _availableRefereeRoles.isNotEmpty &&
                      _isScheduled
                ? _buildRefereeFloatingActionButton()
                : null)
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget? _buildFloatingActionButton() {
    // Se ha bisogno del MOTM, mostra solo quello
    if (_needsMotm) {
      return ATLFloatingButton(
        onPressed: _showMotmDialog,
        backgroundColor: Colors.orange,
        icon: Icons.star,
        label: 'Select MOTM',
        heroTag: 'soccerMatchFAB',
      );
    }

    // Se è not scheduled o scheduled, mostra il pulsante appropriato
    if (_isNotScheduled) {
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.schedule,
        label: 'Schedule Match',
        heroTag: 'soccerMatchFAB',
      );
    }

    if (_isScheduled) {
      // Se manca meno di 1 giorno, mostra solo "Start Match" se possibile
      if (!_canReschedule) {
        if (_canStartMatch) {
          return ATLFloatingButton(
            onPressed: () => _handleMatchAction('start'),
            backgroundColor: Colors.orange,
            icon: Icons.play_arrow,
            label: 'DEBUG - Start Match',
            heroTag: 'soccerMatchFAB',
          );
        }
        // Se non può ancora iniziare, non mostrare nulla
        return null;
      }

      // Altrimenti mostra Reschedule Match
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.update,
        label: 'Reschedule Match',
        heroTag: 'soccerMatchFAB',
      );
    }

    // Se è in progress, mostra gestione eventi
    if (_isInProgress) {
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.add,
        label: 'Manage Match',
        heroTag: 'soccerMatchFAB',
      );
    }

    // Se è halftime, mostra solo start second half
    if (_isHalftime) {
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.play_arrow,
        label: 'Start Second Half',
        heroTag: 'soccerMatchFAB',
      );
    }

    // Se è in penalty shootout, mostra il pulsante appropriato
    if (_isPenaltyShootOut) {
      if (_canMatchFinish) {
            return ATLFloatingButton(
              onPressed: () => _handleMatchAction('finish'),
              backgroundColor: Colors.green,
              icon: Icons.stop,
              label: 'End Match',
              heroTag: 'soccerMatchFAB',
            );
          } else {
            return ATLFloatingButton(
              onPressed: () => _showPlayerEventDialog(penaltyMode: true),
              backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
              icon: Icons.sports_soccer,
              label: 'Insert Penalty',
              heroTag: 'soccerMatchFAB',
            );
          }
    }
    return null;
  }

  Widget _buildEventCard(FootballMatchEvent event) {
    // Determina la fonte dell'evento (home, away, match)
    EventSource source;

    // Verifica se l'evento è durante penalty shootout (non mostrare minuti)
    final bool isInPenaltyShootOut =
        event.type == FootballMatchEventType.penaltyShootOut ||
        (event.type == FootballMatchEventType.penalty ||
                event.type == FootballMatchEventType.missedPenalty ||
                event.type == FootballMatchEventType.finish) &&
            _isPenaltyShootOut;

    // Eventi del match (start, half, finish, penaltyShootOut, startHalf)
    if (event.type == FootballMatchEventType.start ||
        event.type == FootballMatchEventType.halftime ||
        event.type == FootballMatchEventType.startHalf ||
        event.type == FootballMatchEventType.finish ||
        event.type == FootballMatchEventType.penaltyShootOut) {
      source = EventSource.match;
      String eventName = '';
      if (event.type == FootballMatchEventType.start) {
        eventName = 'Match started';
      } else if (event.type == FootballMatchEventType.halftime) {
        eventName = 'Halftime';
      } else if (event.type == FootballMatchEventType.startHalf) {
        eventName = 'Second half started';
      } else if (event.type == FootballMatchEventType.finish) {
        eventName = 'Full time';
      } else if (event.type == FootballMatchEventType.penaltyShootOut) {
        eventName = 'Penalty Shootout';
      }

      return GestureDetector(
        onLongPress: () => _handleDeleteEvent(event),
        child: MatchEventCard(
          eventType: event.type,
          minute: isInPenaltyShootOut ? null : event.minute,
          additionalMinute: isInPenaltyShootOut ? null : event.additionalMinute,
          playerName: eventName,
          source: source,
        ),
      );
    }

    // Eventi con giocatore - usa il teamId dall'evento per determinare home/away
    if (event.playerId != null && event.teamId != null) {
      // Determina se l'evento appartiene all'home team o all'away team usando teamId
      if (_match!.homeTeamId != null && _match!.homeTeamId == event.teamId) {
        source = EventSource.home;
      } else if (_match!.awayTeamId != null &&
          _match!.awayTeamId == event.teamId) {
        source = EventSource.away;
      } else {
        return const SizedBox.shrink();
      }

      // Per gli own goal, inverti il source (mostra dalla parte opposta)
      if (event.type == FootballMatchEventType.ownGoal) {
        source = source == EventSource.home
            ? EventSource.away
            : EventSource.home;
      }

      // Carica solo il giocatore per il nome
      Player? player;
      final teamPlayers = _playersPerTeam[event.teamId];
      if (teamPlayers != null) {
        try {
          player = teamPlayers.firstWhere((p) => p.playerId == event.playerId);
        } catch (_) {
          player = null;
        }
      }
      if (player == null) return const SizedBox.shrink();

      // Formatta il nome: nome puntato e cognome esteso
      final String formattedName = _formatPlayerName(player);

      // Verifica se l'evento è durante penalty shootout
      final bool isInPenaltyShootOut =
          _isPenaltyShootOut &&
          (event.type == FootballMatchEventType.penalty ||
              event.type == FootballMatchEventType.missedPenalty);

      return GestureDetector(
        onLongPress: () => _handleDeleteEvent(event),
        child: MatchEventCard(
          eventType: event.type,
          minute: isInPenaltyShootOut ? null : event.minute,
          additionalMinute: isInPenaltyShootOut ? null : event.additionalMinute,
          playerName: formattedName,
          source: source,
        ),
      );
    }

    // Fallback se non c'è playerId
    return const SizedBox.shrink();
  }

  String _formatPlayerName(Player player) {
    // Nome puntato (prima lettera) e cognome esteso
    final firstName = player.name;
    final lastName = player.surname;

    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}. $lastName';
    } else if (lastName.isNotEmpty) {
      return lastName;
    } else if (firstName.isNotEmpty) {
      return firstName;
    }

    return 'Unknown Player';
  }

  Widget _buildRefereeFloatingActionButton() {
    return ATLFloatingButton(
      onPressed: _showRefereeMatchDialog,
      backgroundColor: Colors.blue,
      icon: Icons.sports,
      label: 'Referee the Match',
      heroTag: 'refereeMatchFAB',
    );
  }
}
