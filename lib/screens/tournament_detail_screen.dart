import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament.dart';
import '../models/sport_category.dart';
import '../models/team.dart';
import '../utils/atl_colors.dart';
import '../database/db_controller.dart';
import '../widgets/loading_atl.dart';
import '../widgets/square_team_widget.dart';
import '../models/field.dart';
import '../providers/user_provider.dart';
import '../models/player.dart';
import '../models/coordinator.dart';
import '../models/tournament_partecipation.dart';
import 'player/callups_screen.dart';
import 'player/view_callups_screen.dart';

class TournamentDetailScreen extends StatefulWidget {
  final Tournament tournament;
  final SportCategory currentSport;

  const TournamentDetailScreen({
    super.key,
    required this.tournament,
    required this.currentSport,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  List<Team>? _participatingTeams;
  bool _isLoading = true;
  bool _isLoadingTeams = true;
  Field? _tournamentField;
  Player? _currentPlayer;
  Team? _playerTeam;
  Coordinator? _tournamentCoordinator;
  bool _isTeamPartecipating = false;
  TournamentPartecipation? _teamPartecipation;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    await Future.wait([
      _loadTournamentDetails(),
      _loadPlayerData(),
      _loadCoordinatorData(),
    ]);

    await _checkPartecipation();
    setState(() => _isLoading = false);

    // Carica i team partecipanti dopo, se necessario
    if (!widget.tournament.isATL) {
      _loadParticipatingTeams();
    }
  }

  Future<void> _loadCoordinatorData() async {
    try {
      final coordinator = await DB.Coordinators.getByCoordinatorId(
        widget.tournament.coordinatorId,
      );
      setState(() {
        _tournamentCoordinator = coordinator;
      });
    } catch (e) {
      print('Error loading coordinator data: $e');
    }
  }

  Future<void> _checkPartecipation() async {
    print("Checking partecipation for team: ${_playerTeam?.name}");
    if (_playerTeam == null) return;
    try {
      final partecipation =
          await DB.TournamentPartecipations.getByTournamentAndTeam(
            widget.tournament.id,
            _playerTeam?.id ?? -1,
          );
      setState(() {
        _isTeamPartecipating = partecipation != null;
        _teamPartecipation = partecipation;
      });
      print("Is team participating: $_isTeamPartecipating");
    } catch (e) {
      print('Error checking partecipation: $e');
    }
  }

  Future<void> _loadPlayerData() async {
    try {
      final UserProvider userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );
      if (userProvider.isPlayer && !userProvider.isGuest) {
        final userId = userProvider.activeUser!.id;
        final player = await DB.Players.getById(userId);

        if (userProvider.currentTeamId != null &&
            userProvider.currentTeamId != -1) {
          final team = await DB.Teams.getById(userProvider.currentTeamId!);
          setState(() {
            _currentPlayer = player;
            _playerTeam = team;
          });
        } else {
          setState(() {
            _currentPlayer = player;
          });
        }
      }
    } catch (e) {
      print('Error loading player data: $e');
    }
  }

  bool _canManageCallUps() {
    if (_currentPlayer == null || _playerTeam == null) return false;

    // Può gestire call-ups se è capitano, vice1 o vice2
    return _currentPlayer!.id == _playerTeam!.captainId ||
        _currentPlayer!.id == _playerTeam!.vice1Id ||
        _currentPlayer!.id == _playerTeam!.vice2Id;
  }

  Future<void> _loadParticipatingTeams() async {
    setState(() => _isLoadingTeams = true);

    try {
      // Simula un delay per mostrare il loading (rimuovi in produzione se non necessario)
      await Future.delayed(const Duration(milliseconds: 500));

      // Carica le partecipazioni del torneo
      final partecipations = await DB
          .TournamentPartecipations.getByTournamentId(widget.tournament.id);

      // Carica i team corrispondenti
      final teams = <Team>[];
      for (var partecipation in partecipations) {
        final team = await DB.Teams.getById(partecipation.teamId);
        if (team != null) {
          teams.add(team);
        }
      }

      setState(() {
        _participatingTeams = teams;
        _isLoadingTeams = false;
      });
    } catch (e) {
      setState(() => _isLoadingTeams = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading teams: $e')));
      }
    }
  }

  Future<void> _loadTournamentDetails() async {
    // Implementa il caricamento dei dettagli del torneo se necessario
    try {
      final field = await DB.Fields.getById(widget.tournament.fieldId);
      setState(() {
        _tournamentField = field;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading field details: $e')),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final isPlayer = userProvider.isPlayer;
    final isGuest = userProvider.isGuest;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ATLColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          widget.tournament.name.toUpperCase(),
          style: const TextStyle(
            color: ATLColors.title,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: ATLColors.darkBlue),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingATL()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coordinator Info with Profile
                  if (_tournamentCoordinator != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Profile Image
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.currentSport.primaryColor,
                                width: 2,
                              ),
                              image: _tournamentCoordinator!.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        _tournamentCoordinator!.imageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              color: _tournamentCoordinator!.imageUrl == null
                                  ? ATLColors.background
                                  : null,
                            ),
                            child: _tournamentCoordinator!.imageUrl == null
                                ? Icon(
                                    Icons.person,
                                    color: widget.currentSport.primaryColor,
                                    size: 28,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _tournamentCoordinator!.username,
                                style: TextStyle(
                                  color: ATLColors.darkBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    'Coordinator',
                                    style: TextStyle(
                                      color: ATLColors.subtext,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.currentSport.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Lv. ${_tournamentCoordinator!.level}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  // Header Image o Team Logos
                  if (widget.tournament.isATL)
                    _buildATLHeader()
                  else
                    _buildNonATLHeader(),

                  // Tournament Details
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Prizes Card - More Prominent
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.currentSport.primaryColor,
                                widget.currentSport.primaryColor.withOpacity(
                                  0.8,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: widget.currentSport.primaryColor
                                    .withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'PRIZES',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.emoji_events,
                                            color: Colors.amber,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '1st Place',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.tournament.formattedPrize1,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (widget.tournament.prize2 > 0) ...[
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.emoji_events,
                                              color: Colors.grey[300],
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '2nd Place',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.tournament.formattedPrize2,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tournament Info Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                Icons.calendar_today,
                                'Date',
                                widget.tournament.date ?? 'TBA',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.location_on,
                                'Location',
                                '${_tournamentField?.name ?? 'TBA'} - ${widget.tournament.city}',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                widget.tournament.isATL
                                    ? Icons.verified
                                    : Icons.public,
                                'Type',
                                widget.tournament.isATL
                                    ? 'ATL Event'
                                    : 'Tournament',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Description Section
                        if (widget.tournament.description.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: widget.currentSport.primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Description',
                                      style: TextStyle(
                                        color: ATLColors.darkBlue,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.tournament.description,
                                  style: TextStyle(
                                    color: ATLColors.subtext,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Tournament Fee
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: widget.currentSport.primaryColor
                                  .withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    color: widget.currentSport.primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Entry Fee',
                                    style: TextStyle(
                                      color: ATLColors.darkBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                widget.tournament.formattedFee,
                                style: TextStyle(
                                  color: widget.currentSport.primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Call-ups Button o messaggi informativi
                        if (isPlayer && !isGuest)
                          _buildCallUpsSection()
                        else if (isGuest)
                          _buildGuestMessage(),

                        const SizedBox(height: 24),

                        // Tournament ID at the bottom
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
                              'Tournament ID: #${widget.tournament.id}',
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
                ],
              ),
            ),
    );
  }

  Widget _buildCallUpsSection() {
    // Controlla se il torneo è pieno
    if (widget.tournament.paidTeams >= widget.tournament.numTeams) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, color: Colors.red.shade700, size: 28),
              const SizedBox(width: 16),
              Text(
                'Tournament Full',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_playerTeam == null) {
      // Giocatore senza team
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Join a team to manage call-ups',
                style: TextStyle(
                  color: Colors.orange.shade900,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final bool isFullyPaid = (_teamPartecipation?.toPay ?? 0) == 0;
    final bool canManage = _canManageCallUps();

    if (_isTeamPartecipating && !canManage) {
      // Giocatore normale in team partecipante - può solo visualizzare
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewCallupsScreen(
                  tournament: widget.tournament,
                  teamId: _playerTeam!.id,
                  sportCategory: widget.currentSport,
                ),
              ),
            );
          },
          icon: const Icon(Icons.people, color: Colors.white),
          label: const Text(
            'VIEW CALL-UPS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.currentSport.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
      );
    } else if (!canManage) {
      // Giocatore con team ma senza permessi e team non partecipante
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Contact your team captain or vice-captains to manage call-ups',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Capitano o vicecapitano
      if (!_isTeamPartecipating) {
        // Team non partecipante - mostra pulsante per selezionare call-ups
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallupsScreen(
                    tournament: widget.tournament,
                    teamId: _playerTeam!.id,
                    sportCategory: widget.currentSport,
                  ),
                ),
              );
              if (mounted) {
                if (result == true) {
                  await _checkPartecipation();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Call-ups updated successfully'),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.people, color: Colors.white),
            label: const Text(
              'SELECT CALL-UPS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.currentSport.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        );
      } else if (isFullyPaid) {
        // Team partecipante con pagamento completato - solo visualizzazione
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewCallupsScreen(
                    tournament: widget.tournament,
                    teamId: _playerTeam!.id,
                    sportCategory: widget.currentSport,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.people, color: Colors.white),
            label: const Text(
              'VIEW CALL-UPS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.currentSport.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        );
      } else {
        // Team partecipante con pagamento pendente - può modificare ed eliminare
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallupsScreen(
                        tournament: widget.tournament,
                        teamId: _playerTeam!.id,
                        sportCategory: widget.currentSport,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.people, color: Colors.white),
                label: const Text(
                  'MODIFY CALL-UPS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.currentSport.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Call-ups'),
                      content: const Text(
                        'Are you sure you want to delete all call-ups for this tournament?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await DB.CallUps.deleteByTournamentAndTeam(
                      widget.tournament.id,
                      _playerTeam!.id,
                    );
                    await DB.TournamentPartecipations.deletePartecipation(
                      widget.tournament.id,
                      _playerTeam!.id,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Call-ups deleted successfully'),
                        ),
                      );
                      await _checkPartecipation();
                    }
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  'DELETE CALL-UPS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        );
      }
    }
  }

  Widget _buildGuestMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.login, color: Colors.grey.shade700, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Login to manage call-ups',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildATLHeader() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        image: widget.tournament.photoURL != null
            ? DecorationImage(
                image: NetworkImage(widget.tournament.photoURL!),
                fit: BoxFit.cover,
              )
            : null,
        color: widget.tournament.photoURL == null
            ? widget.currentSport.primaryColor
            : null,
      ),
      child: widget.tournament.photoURL == null
          ? Center(
              child: Icon(
                widget.currentSport.icon,
                size: 100,
                color: Colors.white.withOpacity(0.3),
              ),
            )
          : null,
    );
  }

  Widget _buildNonATLHeader() {
    if (_isLoadingTeams) {
      // Mostra loading per i team partecipanti
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: ATLColors.darkBlue,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Loading teams...',
                style: TextStyle(
                  color: ATLColors.subtext,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostra "No participating teams" solo se il caricamento è terminato
    if (!_isLoadingTeams &&
        (_participatingTeams == null || _participatingTeams!.isEmpty)) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[200],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.groups, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No participating teams',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: ATLColors.background),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'PARTICIPATING TEAMS',
              style: TextStyle(
                color: ATLColors.subtext,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _participatingTeams!.map((team) {
                return SquareTeamWidget(
                  team: team,
                  currentSport: widget.currentSport,
                  onTap: () {
                    // TODO: Navigate to team detail screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Team ${team.name} - Coming soon'),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: widget.currentSport.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: ATLColors.subtext,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
