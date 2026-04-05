import 'package:atl_app/database/db_write.dart';
import 'package:atl_app/database/responses/tournament_details_response.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/tournament.dart';
import '../../models/sport_category.dart';
import '../../models/team.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/square_team_widget.dart';
import '../../models/field.dart';
import '../../providers/account_provider.dart';
import '../../models/player.dart';
import '../../models/coordinator.dart';
import '../../models/tournament_participation.dart';
import '../../widgets/tournament_info_dialog.dart';
import '../player/callups_screen.dart';
import '../player/view_callups_screen.dart';
import './football_tournament_screen.dart';
import '../../database/db_read.dart';
import '../../l10n/app_localizations.dart';

class TournamentDetailsScreen extends StatefulWidget {
  final Tournament tournament;
  final SportCategory currentSport;

  const TournamentDetailsScreen({
    super.key,
    required this.tournament,
    required this.currentSport,
  });

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailsScreen> {
  Map<int, Team> _teamCache = {};
  bool _isLoading = true;
  bool _isLoadingTeams = false;
  Field? _tournamentField;
  String? _cityName;
  Player? _currentPlayer;
  Team? _playerTeam;
  Coordinator? _tournamentCoordinator;
  bool _isTeamParticipating = false;
  TournamentParticipation? _teamParticipation;

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    AccountProvider userProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    try {
      final TournamentDetailsResponse data;
      if (userProvider.isPlayer && userProvider.activeAccount != null) {
        data = await DBRead.getTournamentDetailsScreen(
          widget.tournament.id,
          widget.currentSport,
          userProvider.activeAccount!.id,
        );
      } else {
        data = await DBRead.getTournamentDetailsScreen(
          widget.tournament.id,
          widget.currentSport,
          null, // Pass null for userId if not a player
        );
      }

      setState(() {
        _teamCache = data.teamsCache;
        _tournamentField = data.field;
        _cityName = data.cityName;
        _currentPlayer = data.currentPlayer;
        _playerTeam = data.accountTeam;
        _tournamentCoordinator = data.coordinator;
        _teamParticipation = data.teamParticipation;
        _isTeamParticipating = _teamParticipation != null;
        _isLoading = false;
        _isLoadingTeams = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.errorLoadingTournamentDetails(e.toString())),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  bool _canManageCallUps() {
    if (_currentPlayer == null || _playerTeam == null) return false;

    // Può gestire call-ups se è capitano, vice1 o vice2
    return _currentPlayer!.id == _playerTeam!.captainId ||
        _currentPlayer!.id == _playerTeam!.vice1Id ||
        _currentPlayer!.id == _playerTeam!.vice2Id;
  }

  bool _canStartTournament() {
    final AccountProvider userProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    // Check if user is coordinator and tournament is full
    return userProvider.isCoordinator &&
        userProvider.activeRoleId == widget.tournament.coordinatorId &&
        widget.tournament.paidTeams >= widget.tournament.numTeams &&
        widget.tournament.status == TournamentStatus.created;
  }

  void _showFullInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return TournamentInfoDialog(
          tournament: widget.tournament,
          sportCategory: widget.currentSport,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AccountProvider userProvider = Provider.of<AccountProvider>(context);
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
                SnackBar(content: Text(_l10n.darkModeComingSoonSnack)),
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
                                color: ATLColors.getPrimaryColor(
                                  widget.currentSport,
                                ),
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
                                    color: ATLColors.getPrimaryColor(
                                      widget.currentSport,
                                    ),
                                    size: 28,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
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
                                      _l10n.coordinator,
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
                                        color: ATLColors.getPrimaryColor(
                                          widget.currentSport,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${_l10n.levelAbbrev} ${_tournamentCoordinator!.level}',
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
                          ),
                          // Full Info Button
                          GestureDetector(
                            onTap: _showFullInfoDialog,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ATLColors.getPrimaryColor(
                                  widget.currentSport,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: ATLColors.getPrimaryColor(
                                    widget.currentSport,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: ATLColors.getPrimaryColor(
                                      widget.currentSport,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _l10n.fullInfoLabel,
                                    style: TextStyle(
                                      color: ATLColors.getPrimaryColor(
                                        widget.currentSport,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                ATLColors.getPrimaryColor(widget.currentSport),
                                ATLColors.getPrimaryColor(
                                  widget.currentSport,
                                ).withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: ATLColors.getPrimaryColor(
                                  widget.currentSport,
                                ).withOpacity(0.3),
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
                                    _l10n.prizesTitle.toUpperCase(),
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
                                            _l10n.firstPlacePrize,
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
                                              _l10n.secondPlacePrize,
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
                                _l10n.dateLabel,
                                widget.tournament.startDate != null
                                    ? DateFormat(
                                        'MMMM yyyy',
                                      ).format(widget.tournament.startDate!)
                                    : _l10n.tba,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.location_on,
                                _l10n.locationLabel,
                                '${_tournamentField?.name ?? _l10n.tba} - ${_cityName ?? _l10n.tba}',
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                widget.tournament.isATL
                                    ? Icons.verified
                                    : Icons.public,
                                _l10n.typeLabel,
                                widget.tournament.isATL
                                    ? _l10n.atlEventType
                                    : _l10n.tournamentType,
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
                                      color: ATLColors.getPrimaryColor(
                                        widget.currentSport,
                                      ),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _l10n.descriptionLabel,
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
                              color: ATLColors.getPrimaryColor(
                                widget.currentSport,
                              ).withOpacity(0.3),
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
                                    color: ATLColors.getPrimaryColor(
                                      widget.currentSport,
                                    ),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _l10n.feePerTeam,
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
                                  color: ATLColors.getPrimaryColor(
                                    widget.currentSport,
                                  ),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Start Tournament Button for Coordinator
                        if (_canStartTournament())
                          _buildStartTournamentButton(),

                        if (_canStartTournament()) const SizedBox(height: 24),

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
                              _l10n.tournamentIdLabel(widget.tournament.id),
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

  Widget _buildStartTournamentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleStartTournament,
        icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
        label: Text(
          _l10n.startTournamentTitle.toUpperCase(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Future<void> _handleStartTournament() async {
    final AccountProvider userProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.startTournamentTitle),
        content: Text(_l10n.startTournamentConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
              foregroundColor: Colors.white,
            ),
            child: Text(_l10n.startButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: LoadingATL()),
    );

    try {
      final success = await DBWrite.startTournament(
        widget.tournament.id,
      );

      if (!mounted) return;
      Navigator.pop(context); // Remove loading dialog

      if (success) {
        // Update tournament status locally
        widget.tournament.status = TournamentStatus.scheduled;

        // Navigate to tournament screen and remove this page from stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FootballTournamentScreen(
              tournament: widget.tournament,
              sportCategory: widget.currentSport,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_l10n.failedToStartTournament),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Remove loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_l10n.errorText(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                _l10n.tournamentFull,
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
                _l10n.joinTeamToManageCalups,
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

    final bool isFullyPaid = (_teamParticipation?.toPay ?? 0) == 0;
    final bool canManage = _canManageCallUps();

    if (_isTeamParticipating && !canManage) {
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
          label: Text(
            _l10n.viewCallUps,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
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
                _l10n.contactCaptain,
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
      if (!_isTeamParticipating) {
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
                    team: _playerTeam!,
                  ),
                ),
              );
              if (mounted) {
                if (result == true) {
                  await _loadAllData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_l10n.callUpsUpdated)),
                  );
                }
              }
            },
            icon: const Icon(Icons.people, color: Colors.white),
            label: Text(
              _l10n.selectCallUps,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
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
            label: Text(
              _l10n.viewCallUps,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: ATLColors.getPrimaryColor(widget.currentSport),
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
                        team: _playerTeam!,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.people, color: Colors.white),
                label: Text(
                  _l10n.modifyCallUps,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.getPrimaryColor(
                    widget.currentSport,
                  ),
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
                      title: Text(_l10n.deleteCallUpsTitle),
                      content: Text(_l10n.deleteCallUpsConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(_l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            _l10n.deleteText,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    bool success = await DBWrite.deleteCallups(
                      widget.tournament.id,
                      _playerTeam!.id,
                    );
                    if (mounted && success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_l10n.callUpsDeleted)),
                      );
                      await _loadAllData();
                    } else if (mounted && !success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_l10n.failedToDeleteCallUps),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete, color: Colors.white),
                label: Text(
                  _l10n.deleteCallUpsTitle.toUpperCase(),
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
              _l10n.loginToManageCallUps,
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
            ? ATLColors.getPrimaryColor(widget.currentSport)
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: ATLColors.darkBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _l10n.loadingTeams,
                style: const TextStyle(
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
        (_teamCache.isEmpty)) {
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
                _l10n.noParticipatingTeams,
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
              _l10n.participatingTeamsTitle.toUpperCase(),
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
              children: _teamCache.values.map((team) {
                return SquareTeamWidget(
                  team: team,
                  sportCategory: widget.currentSport,
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
        Icon(
          icon,
          color: ATLColors.getPrimaryColor(widget.currentSport),
          size: 20,
        ),
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
