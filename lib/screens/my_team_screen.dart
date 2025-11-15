import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/db_controller.dart';
import '../models/sport_category.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/palmares.dart';
import '../models/tournament.dart';
import '../providers/user_provider.dart';
import '../utils/atl_colors.dart';
import '../widgets/loading_atl.dart';

class MyTeamScreen extends StatefulWidget {
  final SportCategory currentSport;

  const MyTeamScreen({
    super.key,
    required this.currentSport,
  });

  @override
  State<MyTeamScreen> createState() => _MyTeamScreenState();
}

class _MyTeamScreenState extends State<MyTeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Team? _myTeam;
  List<Player>? _players;
  List<Palmares>? _palmares;
  List<Tournament>? _tournaments;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.activeUser;

      if (currentUser?.teamId != null) {
        final team = await DB.Teams.getById(currentUser!.teamId!);
        final players = await DB.Players.getByTeam(currentUser.teamId!);
        final palmares = await DB.Palmares.getByTeam(currentUser.teamId!);
        
        // Carica i tornei associati al palmares
        final tournamentIds = palmares.map((p) => p.tournamentId).toSet();
        final tournaments = <Tournament>[];
        for (var id in tournamentIds) {
          final tournament = await DB.Tournaments.getById(id);
          if (tournament != null) {
            tournaments.add(tournament);
          }
        }
        
        setState(() {
          _myTeam = team;
          _players = players;
          _palmares = palmares;
          _tournaments = tournaments;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading team: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: widget.currentSport.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My team',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode coming soon')),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 50,
            child: Row(
              children: [
                Expanded(child: _buildTabButton('Players', 0)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton('Palmares', 1)),
                const SizedBox(width: 12),
                Expanded(child: _buildTabButton('Stats', 2)),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingATL()
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPlayersTab(),
                _buildPalmaresTab(),
                _buildStatsTab(),
              ],
            ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                // TODO: Navigate to requests screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Requests coming soon')),
                );
              },
              backgroundColor: widget.currentSport.primaryColor,
              icon: const Icon(Icons.inbox, color: Colors.white),
              label: const Text(
                'Requests',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? ATLColors.darkBlue : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : ATLColors.darkBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayersTab() {
    if (_players == null || _players!.isEmpty) {
      return const Center(
        child: Text('No players found'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _players!.length,
      itemBuilder: (context, index) {
        final player = _players![index];
        final isCaptain = player.playerId == _myTeam?.captainId;
        final isVice1 = player.playerId == _myTeam?.vice1Id;
        final isVice2 = player.playerId == _myTeam?.vice2Id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isCaptain || isVice1 || isVice2)
                ? widget.currentSport.primaryColor.withOpacity(0.2)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Badge Captain/Vice Captain
              if (isCaptain || isVice1 || isVice2)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.currentSport.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      isCaptain ? 'C' : 'VC',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              
              if (isCaptain || isVice1 || isVice2) const SizedBox(width: 12),
              
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
                child: player.imageUrl != null
                    ? ClipOval(
                        child: Image.network(
                          player.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.person, color: Colors.white, size: 30);
                          },
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 30),
              ),
              
              const SizedBox(width: 16),
              
              // Player name
              Expanded(
                child: Text(
                  player.username,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPalmaresTab() {
    if (_palmares == null || _palmares!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No trophies yet',
              style: TextStyle(fontSize: 18, color: ATLColors.subtext),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _palmares!.length,
      itemBuilder: (context, index) {
        final palmares = _palmares![index];
        final tournament = _tournaments?.firstWhere(
          (t) => t.id == palmares.tournamentId,
        );

        final isWinner = palmares.position == PalmaresPosition.WINNER;
        final bgColor = isWinner 
            ? widget.currentSport.primaryColor.withOpacity(0.2)
            : Colors.white;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icona torneo
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.currentSport.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.emoji_events,
                  color: widget.currentSport.primaryColor,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Info torneo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        FutureBuilder(
                          future: DB.Coordinators.getById(tournament!.coordinatorId),
                          builder: (context, snapshot) {
                            final coordinatorName = snapshot.hasData
                                ? snapshot.data!.username
                                : 'Loading...';
                            return Text(
                              coordinatorName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.people,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tournament.numTeams}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tournament.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Field, City (CI)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Badge posizione
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.currentSport.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      palmares.position == PalmaresPosition.WINNER
                          ? Icons.emoji_events
                          : Icons.military_tech,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      palmares.position.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    if (_players == null || _players!.isEmpty) {
      return const Center(
        child: Text(
          'No stats available',
          style: TextStyle(fontSize: 16, color: ATLColors.subtext),
        ),
      );
    }

    // Simula stats - TODO: Implementare con dati reali
    final goalScorers = List<Player>.from(_players!)
      ..sort((a, b) => (b.id % 20).compareTo(a.id % 20));
    
    final motmPlayers = List<Player>.from(_players!)
      ..sort((a, b) => (b.id % 15).compareTo(a.id % 15));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GOALS Section
          const Text(
            'GOALS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...goalScorers.take(5).map((player) {
            final goals = 15 - goalScorers.indexOf(player) * 2;
            final isTop = goalScorers.indexOf(player) == 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTop 
                    ? widget.currentSport.primaryColor.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${goalScorers.indexOf(player) + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$goals',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // MOTM Section
          const Text(
            'MOTM',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          ...motmPlayers.take(5).map((player) {
            final motm = 15 - motmPlayers.indexOf(player) * 2;
            final isTop = motmPlayers.indexOf(player) == 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isTop 
                    ? widget.currentSport.primaryColor.withOpacity(0.2)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${motmPlayers.indexOf(player) + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.username,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$motm',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
