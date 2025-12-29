import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/soccer_match.dart';
import '../../models/team.dart';
import '../../models/sport_category.dart';
import '../../models/football_match_event.dart';
import '../../models/player.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/soccer_match_widget.dart';
import '../../widgets/atl_floating_button.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/match_event_card.dart';
import '../../providers/user_provider.dart';
import '../../database/db_controller.dart';

class SoccerMatchScreen extends StatefulWidget {
  final int matchId;
  final SportCategory currentSport;

  const SoccerMatchScreen({
    super.key,
    required this.matchId,
    required this.currentSport,
  });

  @override
  State<SoccerMatchScreen> createState() => _SoccerMatchScreenState();
}

class _SoccerMatchScreenState extends State<SoccerMatchScreen> {
  SoccerMatch? _match;
  late final Team _homeTeam;
  late final Team _awayTeam;
  List<FootballMatchEvent> _events = [];
  bool _isLoading = true;
  bool _isScheduled = false;

  @override
  void initState() {
    super.initState();
    _loadMatchData();
  }

  Future<void> _loadMatchData() async {
    setState(() => _isLoading = true);

    try {
      // Carica la partita dal database
      final SoccerMatch? match = await DB.SoccerMatches.getById(widget.matchId);

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

      // Carica gli eventi della partita
      final List<FootballMatchEvent> events =
          await DB.FootballMatchEvents.getByMatchId(widget.matchId);

      // Determina se la partita è schedulata
      final isScheduled = match.status != MatchStatus.notScheduled;

      setState(() {
        _match = match;
        _homeTeam = homeTeam;
        _awayTeam = awayTeam;
        _events = events;
        _isScheduled = isScheduled;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading match data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNewEvents() async {
    // TODO: In futuro, questa funzione sarà chiamata automaticamente tramite webhook
    // quando ci sono nuovi eventi nella partita. Il webhook aggiornerà la pagina in tempo reale.

    try {
      // Ricarica solo gli eventi senza mostrare il loading
      final List<FootballMatchEvent> events =
          await DB.FootballMatchEvents.getByMatchId(widget.matchId);

      // Ricarica anche la partita per aggiornare il punteggio
      final SoccerMatch? match = await DB.SoccerMatches.getById(widget.matchId);

      if (match != null) {
        setState(() {
          _events = events;
          _match = match;
        });
      }
    } catch (e) {
      print('Error loading new events: $e');
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
                    SoccerMatchWidget(
                      match: _match!,
                      homeTeam: _homeTeam,
                      awayTeam: _awayTeam,
                      clickable: false,
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
      floatingActionButton: isCoordinator && _match != null
          ? ATLFloatingButton(
              onPressed: () {
                // TODO: inserisci logica di funzionamento
                print('Button pressed: ${_isScheduled ? "Edit" : "New event"}');
              },
              backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
              icon: _isScheduled ? Icons.edit : Icons.add,
              label: _isScheduled ? 'Edit' : 'New event',
              heroTag: 'soccerMatchFAB',
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEventCard(FootballMatchEvent event) {
    // Determina la fonte dell'evento (home, away, match)
    EventSource source;

    // Eventi del match (start, half, finish)
    if (event.type == FootballMatchEventType.start ||
        event.type == FootballMatchEventType.half ||
        event.type == FootballMatchEventType.finish) {
      source = EventSource.match;
      String eventName = '';
      if (event.type == FootballMatchEventType.start) {
        eventName = 'Match started';
      } else if (event.type == FootballMatchEventType.half) {
        eventName = 'Halftime';
      } else if (event.type == FootballMatchEventType.finish) {
        eventName = 'Full time';
      }

      return MatchEventCard(
        eventType: event.type,
        minute: event.minute,
        playerName: eventName,
        source: source,
      );
    }

    // Eventi con giocatore - determina se è home o away
    if (event.playerId != null) {
      // Carica il giocatore e determina il team attraverso PlaysAt
      return FutureBuilder<Map<String, dynamic>>(
        future: _loadPlayerAndTeam(event.playerId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }

          final data = snapshot.data!;
          final player = data['player'] as Player?;
          final teamId = data['teamId'] as int?;

          if (player == null || teamId == null) {
            return const SizedBox.shrink();
          }

          // Determina se il giocatore appartiene all'home team o all'away team
          if (_match!.homeTeamId == teamId) {
            source = EventSource.home;
          } else if (_match!.awayTeamId == teamId) {
            source = EventSource.away;
          } else {
            return const SizedBox.shrink();
          }

          // Formatta il nome: nome puntato e cognome esteso
          final String formattedName = _formatPlayerName(player);

          return MatchEventCard(
            eventType: event.type,
            minute: event.minute,
            playerName: formattedName,
            source: source,
          );
        },
      );
    }

    // Fallback se non c'è playerId
    return const SizedBox.shrink();
  }

  Future<Map<String, dynamic>> _loadPlayerAndTeam(int playerId) async {
    try {
      final player = await DB.Players.getById(playerId);
      if (player == null) {
        return {};
      }

      // Carica le associazioni PlaysAt per il giocatore
      final playsAtList = await DB.PlaysAt.getByPlayerId(playerId);
      if (playsAtList == null || playsAtList.isEmpty) {
        return {'player': player};
      }

      // Trova il team corrispondente alla categoria della partita (assumiamo football)
      // O semplicemente prendi il primo team se ce n'è solo uno
      // Per ora prendiamo il primo team disponibile
      final teamId = playsAtList.first.teamId;

      return {'player': player, 'teamId': teamId};
    } catch (e) {
      print('Error loading player and team: $e');
      return {};
    }
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
