import 'package:atl_app/database/responses/football_match_response.dart';
import 'package:atl_app/database/services/booking_service.dart';
import 'package:atl_app/database/services/match_service.dart';
import 'package:atl_app/database/responses/football_match_events_response.dart';
import 'package:atl_app/models/field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../models/enums/sport_category.dart';
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
import '../../providers/account_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/enums/football_match_status.dart';
import '../../models/enums/football_match_event_type.dart';


class FootballMatchScreen extends StatefulWidget {
  final double matchId;
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
  static const String _menuScheduleMatch = 'schedule_match';
  static const String _menuRescheduleMatch = 'reschedule_match';
  static const String _menuStartMatch = 'start_match';
  static const String _menuHalftime = 'halftime';
  static const String _menuStartSecondHalf = 'start_second_half';
  static const String _menuAddPlayerEvent = 'add_player_event';
  static const String _menuInsertPenalty = 'insert_penalty';
  static const String _menuStartPenaltyShootout = 'start_penalty_shootout';
  static const String _menuFinishMatch = 'finish_match';

  FootballMatch? _match;
  Team? _homeTeam;
  Team? _awayTeam;
  List<FootballMatchEvent> _events = [];
  bool _isLoading = true;
  late int _minutesPerRound;
  late int _minutesPerPause;
  double? _coordinatorId;
  bool _refereeCheck =
      false; // Indica se il controllo dei ruoli arbitrali è superato (true se non ci sono ruoli disponibili, altrimenti false)
  bool _hasRefereeLicense = false;
  List<String> _availableRefereeRoles = [];
  bool _isLoadingRefereeRoles = true;
  int _matchInfoKey = 0; // Counter to force MatchInfoCard rebuild
  bool _hasChanges = false; // Track if any changes were made
  Map<double, List<Player>> _playersPerTeam = {};
  Map<double, List<Player>> _availablePlayersPerTeam = {};
  Map<String, String> _assignmentPerRefereeNameSurname =
      {}; // key: Name+Surname, value: Role
  String _cityName = '';
  Field? _field;
  bool _canMatchFinish = false;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  String _menuActionLabel(String actionId) {
    switch (actionId) {
      case _menuScheduleMatch:
        return _l10n.scheduleMatchLabel;
      case _menuRescheduleMatch:
        return _l10n.rescheduleMatchLabel;
      case _menuStartMatch:
        return _l10n.startMatchTitle;
      case _menuHalftime:
        return _l10n.halftimeTitle;
      case _menuStartSecondHalf:
        return _l10n.startSecondHalf;
      case _menuAddPlayerEvent:
        return _l10n.addPlayerEventLabel;
      case _menuInsertPenalty:
        return _l10n.insertPenalty;
      case _menuStartPenaltyShootout:
        return _l10n.startPenaltyShootoutTitle;
      case _menuFinishMatch:
        return _l10n.finishMatchTitle;
      default:
        return actionId;
    }
  }

  IconData _menuActionIcon(String actionId) {
    switch (actionId) {
      case _menuScheduleMatch:
        return Icons.schedule;
      case _menuRescheduleMatch:
        return Icons.update;
      case _menuStartMatch:
        return Icons.play_arrow;
      case _menuHalftime:
        return Icons.pause;
      case _menuStartSecondHalf:
        return Icons.play_arrow;
      case _menuAddPlayerEvent:
        return Icons.add;
      case _menuInsertPenalty:
        return Icons.sports_soccer;
      case _menuStartPenaltyShootout:
        return Icons.sports;
      case _menuFinishMatch:
        return Icons.stop;
      default:
        return Icons.circle;
    }
  }

  Map<String, double> _payPerRole = {};

  bool get _isNotScheduled =>
      _match != null && _match!.status == FootballMatchStatus.notScheduled;

  bool get _isScheduled =>
      _match != null && _match!.status == FootballMatchStatus.scheduled;

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
      (_match!.status == FootballMatchStatus.started ||
          _match!.status == FootballMatchStatus.startHalf);

  bool get _isHalftime =>
      _match != null && _match!.status == FootballMatchStatus.halftime;

  bool get _isFinished =>
      _match != null && _match!.status == FootballMatchStatus.finished;

  bool get _isPenaltyShootOut =>
      _match != null && _match!.status == FootballMatchStatus.penaltyShootOut;

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
      switch (widget.currentSport) {
        case SportCategory.football:
          final FootballMatchResponse data = await MatchService.getMatchScreen(
            widget.matchId.toDouble(),
            widget.currentSport,
          );
          List<FootballMatchEvent> events = data.events;

          events.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          ); // Ordina per data decrescente

          setState(() {
            _match = data.match;
            _homeTeam = data.homeTeam;
            _awayTeam = data.awayTeam;
            _events = events;
            _minutesPerRound = data.minutesPerRound;
            _minutesPerPause = data.minutesPerPause;
            _availableRefereeRoles = data.availableRefereeRoles;
            _playersPerTeam = data.playersPerTeam;
            _cityName = data.cityName;
            _assignmentPerRefereeNameSurname =
                data.assignmentPerRefereeNameSurname;
            _field = data.field;
            _coordinatorId = data.coordinatorId;
            _refereeCheck = data.refereeCheck;
            _canMatchFinish = data.canMatchFinish;
            _hasRefereeLicense = data.hasRefereeLicense;
            _payPerRole = data.payPerRole;
            _isLoadingRefereeRoles = false;
            _isLoading = false;
          });
          break;
      }
      _reloadAvailablePlayersPerTeam();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.errorGeneric(e.toString()))),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshEvents() async {
    try {
      switch (widget.currentSport) {
        case SportCategory.football:
          final FootballMatchEventsResponse events =
              await MatchService.getMatchEvents(
                widget.matchId.toDouble(),
                widget.currentSport,
              );
          List<FootballMatchEvent> matchEvents = events.events;
          matchEvents.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
          ); // Ordina per data decrescente
          setState(() {
            _events = matchEvents;
            _canMatchFinish = events.canMatchFinish;
            _isLoading = false;
          });
          break;
      }
      _reloadAvailablePlayersPerTeam();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.errorGeneric(e.toString()))),
        );
      }
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
    if (_availableRefereeRoles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.allRefereeRolesAssigned)));
      }
      return;
    }

    if (!_hasRefereeLicense) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.noValidRefereeLicense)));
      }
      return;
    }

    final String? selectedRole = await showDialog<String>(
      context: context,
      builder: (context) => RefereeMatchDialog(
        availableRoles: _availableRefereeRoles,
        sportCategory: widget.currentSport,
        payPerRole: _payPerRole,
      ),
    );

    if (selectedRole == null || !mounted) return;

    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final refereeId = accountProvider.activeRoleId;

    if (refereeId == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.errorRefereeNotFound)));
      }
      return;
    }

    try {
      await MatchService.insertRefereeAssignment(
        widget.matchId.toDouble(),
        selectedRole,
      );

      setState(() {
        _matchInfoKey++; // Increment to force MatchInfoCard rebuild
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.assignmentCreated)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.errorCreatingAssignment)));
      }
    }
  }

  Future<void> _showScheduleDialog() async {
    if (_field == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.errorFieldNotAvailable)));
      }
      return;
    }

    if (_match == null) return;

    final wasScheduled = _match?.status == FootballMatchStatus.scheduled;

    final DateTime? scheduledStart = await showDialog<DateTime>(
      context: context,
      builder: (context) => ScheduleMatchDialog(
        tournamentId: _match!.tournamentId,
        fieldId: _field!.id,
        currentSport: widget.currentSport,
        currentScheduledStart: _match?.scheduledStart,
        fieldOpeningTime: _field!.openingTime,
        fieldClosingTime: _field!.closingTime,
        fieldClosedDays: _field!.closedDays,
      ),
    );

    if (scheduledStart == null || !mounted) return;

    try {
      await BookingService.scheduleMatch(
        widget.matchId.toDouble(),
        scheduledStart,
      );

      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasScheduled
                  ? _l10n.matchRescheduledSuccessfully
                  : _l10n.matchScheduledSuccessfully,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _canReschedule
                  ? _l10n.failedToScheduleFieldUnavailable
                  : _l10n.cannotRescheduleWithin24h,
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
                child: Text(_l10n.cancelButton),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.getPrimaryColor(
                    widget.currentSport,
                  ),
                  foregroundColor: Colors.white,
                ),
                child: Text(_l10n.confirmButton),
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
    String actionLabel = '';

    switch (action) {
      case 'start':
        title = _l10n.startMatchTitle;
        message = _l10n.startMatchConfirm;
        actionLabel = _l10n.startMatchTitle;
        break;
      case 'halftime':
        title = _l10n.halftimeTitle;
        message = _l10n.halftimeConfirm;
        actionLabel = _l10n.halftimeTitle;
        break;
      case 'startHalf':
        title = _l10n.startSecondHalf;
        message = _l10n.startSecondHalfConfirm;
        actionLabel = _l10n.startSecondHalf;
        break;
      case 'finish':
        title = _l10n.finishMatchTitle;
        message = _l10n.finishMatchConfirm;
        actionLabel = _l10n.finishMatchTitle;
        break;
    }

    final confirmed = await _showConfirmationDialog(title, message);
    if (!confirmed) return;

    FootballMatchEventType eventType = FootballMatchEventType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == action.toLowerCase(),
    );

    try {
      FootballMatchEvent event = FootballMatchEvent(
        id: 0,
        matchId: widget.matchId,
        type: eventType, // Placeholder, will be set in API
        teamId: null,
        playerId: null,
        minute: 0,
        createdAt: DateTime.now(),
      );

      switch (action) {
        case 'start':
        case 'startHalf':
        case 'halftime':
        case 'finish':
          await MatchService.insertFootballMatchEvent(
            widget.matchId.toDouble(),
            event,
          );
          break;
      }

      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.matchActionSuccess(actionLabel))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n.failedToMatchAction(actionLabel))),
        );
      }
    }
  }

  Future<void> _showMatchActionsMenu() async {
    List<String> actions = [];

    if (_isNotScheduled) {
      actions.add(_menuScheduleMatch);
    } else if (_isScheduled) {
      if (_canReschedule) {
        actions.add(_menuRescheduleMatch);
      }
      if (_canStartMatch) {
        actions.add(_menuStartMatch);
      }
    } else if (_isInProgress) {
      // Go to Halftime solo se il match è in stato 'started' (primo tempo)
      if (_match?.status == FootballMatchStatus.started) {
        actions.add(_menuHalftime);
      }
      actions.add(_menuAddPlayerEvent);

      // Se siamo nel secondo tempo (startHalf), controlla se il match può finire
      if (_match?.status == FootballMatchStatus.startHalf) {
        if (_canMatchFinish) {
          actions.add(_menuFinishMatch);
        } else {
          actions.add(_menuStartPenaltyShootout);
        }
      }
      // Nel primo tempo NON può finire
    } else if (_isHalftime) {
      actions.add(_menuStartSecondHalf);
    } else if (_isPenaltyShootOut) {
      // Durante i rigori, verifica se il match può finire
      if (_canMatchFinish) {
        actions.add(_menuFinishMatch);
      } else {
        actions.add(_menuInsertPenalty);
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
              final icon = _menuActionIcon(action);

              return ListTile(
                leading: Icon(
                  icon,
                  color: ATLColors.getPrimaryColor(widget.currentSport),
                ),
                title: Text(_menuActionLabel(action)),
                onTap: () => Navigator.pop(context, action),
              );
            }).toList(),
          ),
        );
      },
    );

    if (result == null) return;

    switch (result) {
      case _menuScheduleMatch:
      case _menuRescheduleMatch:
        _showScheduleDialog();
        break;
      case _menuStartMatch:
        _handleMatchAction('start');
        break;
      case _menuHalftime:
        _handleMatchAction('halftime');
        break;
      case _menuStartSecondHalf:
        _handleMatchAction('startHalf');
        break;
      case _menuAddPlayerEvent:
        _showPlayerEventDialog();
        break;
      case _menuInsertPenalty:
        _showPlayerEventDialog(penaltyMode: true);
        break;
      case _menuStartPenaltyShootout:
        _startPenaltyShootOut();
        break;
      case _menuFinishMatch:
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
      _l10n.startPenaltyShootoutTitle,
      _l10n.startPenaltyShootoutConfirm,
    );
    if (!confirmed) return;

    try {
      FootballMatchEvent event = FootballMatchEvent(
        id: 0,
        matchId: widget.matchId,
        type: FootballMatchEventType
            .penaltyShootOut, // Placeholder, will be set in API
        teamId: null,
        playerId: null,
        minute: 0,
        createdAt: DateTime.now(),
      );
      await MatchService.insertFootballMatchEvent(
        widget.matchId.toDouble(),
        event,
      );
      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.penaltyShootoutStarted)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.failedToStartPenalty)));
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
        playersByTeam: _playersPerTeam,
      ),
    );

    if (result == null) return;

    final Player selectedPlayer = result['player'];

    print(
      "Assigning MOTM to player ${selectedPlayer.playerId} in match ${widget.matchId}",
    );
    try {
      await MatchService.addMotmToMatch(
        widget.matchId.toDouble(),
        selectedPlayer.playerId.toDouble(),
      );

      setState(() {
        _hasChanges = true;
      });
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.motmAdded)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.failedToAddMotm)));
      }
    }
  }

  Future<void> _handleDeleteEvent(FootballMatchEvent event) async {
    // Check if user is the coordinator of this tournament
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    final isCoordinator = accountProvider.isCoordinator;

    if (!isCoordinator || _coordinatorId != accountProvider.activeRoleId) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.onlyCoordinatorCanDelete)));
      }
      return;
    }

    // Check if it's the most recent event
    if (_events.isEmpty || _events.first.id != event.id) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.cannotDeleteNotLast)));
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
          SnackBar(content: Text(_l10n.onlyPlayerEventsCanBeDeleted)),
        );
      }
      return;
    }

    // Show confirmation dialog
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(_l10n.deleteEventTitle),
            content: Text(_l10n.deleteEventConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(_l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  _l10n.deleteText,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    // Delete the event
    try {
      await MatchService.deleteFootballMatchEvent(
        widget.matchId.toDouble(),
        event.id.toDouble(),
      );

      setState(() {
        _hasChanges = true;
      });
      _refreshEvents();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.eventDeleted)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_l10n.failedToDeleteEvent)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final isCoordinator = accountProvider.isCoordinator;
    final isReferee = accountProvider.isReferee;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(_hasChanges),
        ),
        title: Text(
          _l10n.matchDetailsTitle,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: LoadingATL())
          : _match == null
          ? Center(
              child: Text(
                _l10n.matchNotFound,
                style: const TextStyle(fontSize: 18, color: ATLColors.subtext),
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
                          Text(
                            _l10n.eventsTitle.toUpperCase(),
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
                                          ? _l10n.bothTeamsTbdMessage
                                          : _homeTeam == null
                                          ? _l10n.homeTeamTbdMessage
                                          : _l10n.awayTeamTbdMessage,
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
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _l10n.noEventsYet,
                                  style: const TextStyle(
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
                          _l10n.matchIdLabel(widget.matchId.toInt()),
                          style: const TextStyle(
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
          ? (isCoordinator && _coordinatorId == accountProvider.activeRoleId
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
        label: _l10n.selectMotmLabel,
        heroTag: 'soccerMatchFAB',
      );
    }

    // Se è not scheduled o scheduled, mostra il pulsante appropriato
    if (_isNotScheduled) {
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.schedule,
        label: _l10n.scheduleMatchLabel,
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
            label: _l10n.startMatchTitle,
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
        label: _l10n.rescheduleMatchLabel,
        heroTag: 'soccerMatchFAB',
      );
    }

    // Se è in progress, mostra gestione eventi
    if (_isInProgress) {
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.add,
        label: _l10n.manageMatchLabel,
        heroTag: 'soccerMatchFAB',
      );
    }

    // Se è halftime, mostra solo start second half
    if (_isHalftime) {
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.play_arrow,
        label: _l10n.startSecondHalf,
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
          label: _l10n.endMatch,
          heroTag: 'soccerMatchFAB',
        );
      } else {
        return ATLFloatingButton(
          onPressed: () => _showPlayerEventDialog(penaltyMode: true),
          backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
          icon: Icons.sports_soccer,
          label: _l10n.insertPenalty,
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
        eventName = _l10n.matchStartedEvent;
      } else if (event.type == FootballMatchEventType.halftime) {
        eventName = _l10n.halftimeEvent;
      } else if (event.type == FootballMatchEventType.startHalf) {
        eventName = _l10n.secondHalfStartedEvent;
      } else if (event.type == FootballMatchEventType.finish) {
        eventName = _l10n.fullTimeEvent;
      } else if (event.type == FootballMatchEventType.penaltyShootOut) {
        eventName = _l10n.penaltyShootoutEvent;
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

    return _l10n.unknownPlayer;
  }

  Widget _buildRefereeFloatingActionButton() {
    return ATLFloatingButton(
      onPressed: _showRefereeMatchDialog,
      backgroundColor: Colors.blue,
      icon: Icons.sports,
      label: _l10n.refereeTheMatch,
      heroTag: 'refereeMatchFAB',
    );
  }
}
