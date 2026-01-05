import 'package:atl_app/config/app_config.dart';
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
import '../../widgets/football_motm_selector_dialog.dart';
import '../../providers/user_provider.dart';
import '../../database/db_controller.dart';

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
  late Team _homeTeam;
  late Team _awayTeam;
  List<FootballMatchEvent> _events = [];
  bool _isLoading = true;
  late int _minutesPerRound;
  late int _minutesPerPause;
  int? _coordinatorId;
  int? _tournamentId;

  bool get _isNotScheduled =>
      _match != null && _match!.status == MatchStatus.notScheduled;

  bool get _isScheduled =>
      _match != null && _match!.status == MatchStatus.scheduled;

  bool get _canStartMatch {
    if (!_isScheduled || _match?.scheduledStart == null) return false;
    final difference = _match!.scheduledStart!.difference(DateTime.now());
    return difference.inMinutes < 60;
  }

  bool get _isInProgress =>
      _match != null &&
      (_match!.status == MatchStatus.started ||
          _match!.status == MatchStatus.startHalf);

  bool get _isHalftime =>
      _match != null && _match!.status == MatchStatus.halftime;

  bool get _isFinished =>
      _match != null && _match!.status == MatchStatus.finished;

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
      final FootballMatch? match = await DB.FootballMatches.getById(
        widget.matchId,
      );

      if (match == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Carica i team
      final Team? homeTeam = await DB.Teams.getById(match.homeTeamId);
      final Team? awayTeam = await DB.Teams.getById(match.awayTeamId);

      if (homeTeam == null || awayTeam == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Carica il coordinatore della partita
      int tournamentId = match.tournamentId;
      final int? coordinatorId = (await DB.Tournaments.getById(
        tournamentId,
      ))?.coordinatorId;

      if (coordinatorId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Carica gli eventi della partita
      final List<FootballMatchEvent> events =
          await DB.FootballMatchEvents.getByMatchId(widget.matchId);

      // Ordina gli eventi per eventTime in senso decrescente (più recenti in alto)
      events.sort((a, b) => b.eventTime.compareTo(a.eventTime));

      final minutesPerRound = await DB.Tournaments.getMinutesPerRoundById(
        match.tournamentId,
      );
      final minutesPerPause = await DB.Tournaments.getMinutesPerPauseById(
        match.tournamentId,
      );

      if (minutesPerRound == 0 || minutesPerPause == 0) {
        setState(() => _isLoading = false);
        return;
      }

      setState(() {
        _match = match;
        _homeTeam = homeTeam;
        _awayTeam = awayTeam;
        _events = events;
        _isLoading = false;
        _minutesPerRound = minutesPerRound;
        _minutesPerPause = minutesPerPause;
        _coordinatorId = coordinatorId;
        _tournamentId = tournamentId;
      });
    } catch (e) {
      print('Error loading match data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showScheduleDialog() async {
    // TODO: Implementare UI per selezionare orario disponibile
    final DateTime? selectedTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedTime == null) return;

    final TimeOfDay? selectedTimeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTimeOfDay == null) return;

    final DateTime scheduledStart = DateTime(
      selectedTime.year,
      selectedTime.month,
      selectedTime.day,
      selectedTimeOfDay.hour,
      selectedTimeOfDay.minute,
    );

    if (!mounted) return;

    final success = await DB().scheduleMatch(
      widget.matchId,
      scheduledStart,
      _coordinatorId!,
    );

    if (success) {
      _loadMatchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match scheduled successfully')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to schedule match')),
        );
      }
    }
  }

  Future<void> _handleMatchAction(String action) async {
    if (_coordinatorId == null) return;

    bool success = false;

    switch (action) {
      case 'start':
        success = await DB().insertEventMatch(
          widget.matchId,
          'start',
          _coordinatorId!,
        );
        break;
      case 'halftime':
        success = await DB().insertEventMatch(
          widget.matchId,
          'halftime',
          _coordinatorId!,
        );
        break;
      case 'startHalf':
        success = await DB().insertEventMatch(
          widget.matchId,
          'startHalf',
          _coordinatorId!,
        );
        break;
      case 'finish':
        success = await DB().insertEventMatch(
          widget.matchId,
          'finish',
          _coordinatorId!,
        );
        break;
    }

    if (success) {
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

    if (_isNotScheduled || _isScheduled) {
      actions.add('Schedule Match');
      if (_canStartMatch) {
        actions.add('Start Match');
      }
    } else if (_isInProgress) {
      // Go to Halftime solo se il match è in stato 'started' (primo tempo)
      if (_match?.status == MatchStatus.started) {
        actions.add('Go to Halftime');
      }
      actions.add('Add Player Event');
      actions.add('Finish Match');
    } else if (_isHalftime) {
      actions.add('Start Second Half');
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
      case 'Finish Match':
        _handleMatchAction('finish');
        break;
    }
  }

  Future<void> _showPlayerEventDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => MatchEventDialog(
        homeTeam: _homeTeam,
        awayTeam: _awayTeam,
        tournamentId: _tournamentId!,
        matchId: widget.matchId,
        sportCategory: widget.currentSport,
        coordinatorId: _coordinatorId!,
      ),
    );

    if (result == true) {
      _loadMatchData();
    }
  }

  Future<void> _showMotmDialog() async {
    if (!mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FootballMotmSelectorDialog(
        homeTeam: _homeTeam,
        awayTeam: _awayTeam,
        tournamentId: _tournamentId!,
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

    final success = await DB().addFootballMotm(
      widget.matchId,
      selectedPlayer.playerId,
      teamId,
      _tournamentId!,
      _coordinatorId!,
    );

    if (success) {
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isCoordinator = userProvider.isCoordinator;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
                          if (_events.isEmpty)
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
      floatingActionButton:
          isCoordinator &&
              _match != null &&
              _coordinatorId == userProvider.activeRoleId
          ? _buildFloatingActionButton()
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
      return ATLFloatingButton(
        onPressed: _showMatchActionsMenu,
        backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
        icon: Icons.edit,
        label: 'Manage Match',
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

    return null;
  }

  Widget _buildEventCard(FootballMatchEvent event) {
    // Determina la fonte dell'evento (home, away, match)
    EventSource source;

    // Eventi del match (start, half, finish)
    if (event.type == FootballMatchEventType.start ||
        event.type == FootballMatchEventType.halftime ||
        event.type == FootballMatchEventType.finish) {
      source = EventSource.match;
      String eventName = '';
      if (event.type == FootballMatchEventType.start) {
        eventName = 'Match started';
      } else if (event.type == FootballMatchEventType.halftime) {
        eventName = 'Halftime';
      } else if (event.type == FootballMatchEventType.finish) {
        eventName = 'Full time';
      }

      return MatchEventCard(
        eventType: event.type,
        minute: event.minute,
        additionalMinute: event.additionalMinute,
        playerName: eventName,
        source: source,
      );
    }

    // Eventi con giocatore - usa il teamId dall'evento per determinare home/away
    if (event.playerId != null && event.teamId != null) {
      // Determina se l'evento appartiene all'home team o all'away team usando teamId
      if (_match!.homeTeamId == event.teamId) {
        source = EventSource.home;
      } else if (_match!.awayTeamId == event.teamId) {
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
      return FutureBuilder<Player?>(
        future: DB.Players.getByUserId(event.playerId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }

          final player = snapshot.data!;

          // Formatta il nome: nome puntato e cognome esteso
          final String formattedName = _formatPlayerName(player);

          return MatchEventCard(
            eventType: event.type,
            minute: event.minute,
            additionalMinute: event.additionalMinute,
            playerName: formattedName,
            source: source,
          );
        },
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
}
