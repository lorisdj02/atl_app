import 'package:atl_app/models/user.dart';
import 'package:flutter/material.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/tournament.dart';
import '../../models/soccer_match.dart';
import '../../models/soccer_standing.dart';
import '../../models/team.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_controller.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/soccer_match_widget.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../team_screen.dart';
import '../profile_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/home_team_widget.dart';

class PlayerHomeScreen extends StatefulWidget {

  const PlayerHomeScreen({
    super.key,
  });

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  late final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
  late final User user = userProvider.activeUser!;
  late final int teamId = userProvider.currentTeamId!;
  late final SportCategory _currentSport = userProvider.selectedSportCategory ?? SportCategory.football;
  
  List<Tournament>? _activeTournaments;
  Map<int, List<SoccerMatch>> _tournamentMatches = {};
  Map<int, List<SoccerStanding>> _tournamentStandings = {};
  Map<int, Team> _teamsCache = {};
  Team? _userTeam;
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPlayerData();
  }

  Future<void> _loadPlayerData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load user's team using teamId from user
      if (teamId != null && teamId != -1) {
        _userTeam = await DB.Teams.getById(teamId);
      }
      
      // Load active tournaments where user's team participates
      //final allTournaments = DB.Tournaments.mockData;
      //final activeTournaments = allTournaments.where((t) => t.status == TournamentStatus.scheduled).toList();
      
      final activeTournamentsId = (await DB.TournamentPartecipations.getByTeamId(teamId))
          .map((p) => p.tournamentId).toSet();

      final activeTournaments = (await DB.Tournaments.getBySport('FOOTBALL'))
          .where((t) => activeTournamentsId.contains(t.id)).toList();

      // Load matches and standings for each tournament
      for (var tournament in activeTournaments) {
        final matches = DB.SoccerMatches.getMatchesByTournament(tournament.id);
        final standings = DB.SoccerStandings.getStandingsByTournament(tournament.id);
        
        _tournamentMatches[tournament.id] = matches;
        _tournamentStandings[tournament.id] = standings;
        
        // Cache teams
        final teamIds = <int>{};
        for (var match in matches) {
          teamIds.add(match.homeTeamId);
          teamIds.add(match.awayTeamId);
        }
        for (var standing in standings) {
          teamIds.add(standing.teamId);
        }
        
        for (var teamId in teamIds) {
          if (!_teamsCache.containsKey(teamId)) {
            final team = await DB.Teams.getById(teamId);
            if (team != null) {
              _teamsCache[teamId] = team;
            }
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _activeTournaments = activeTournaments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void _onNavTap(int index) {
    if (index == 4) {
      // Mostra dialog per cambiare sport
      _showSportSelector();
    } else {
      // Naviga alle rispettive pagine
      Widget screen;
      switch (index) {
        case 0:
          screen = ShopScreen(
            currentSport: _currentSport,
          );
          break;
        case 1:
          screen = AllTournamentsScreen(
            currentSport: _currentSport,
          );
          break;
        case 2:
          screen = TeamScreen(
            currentSport: _currentSport,
          );
          break;
        case 3:
          screen = ProfileScreen(
            currentSport: _currentSport,
          );
          break;
        default:
          return;
      }
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => screen,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  void _showSportSelector() {
    // TODO: Riabilitare quando ci saranno più sport
    // Per ora mostra solo un messaggio
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Other sports coming soon! Football only for now.'),
        duration: Duration(seconds: 2),
      ),
    );
    
    /* TODO: Riabilitare questo codice quando ci saranno più sport
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Sport'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SportCategory.values.map((sport) {
            return ListTile(
              leading: Icon(
                sport.icon,
                color: sport.primaryColor,
              ),
              title: Text(sport.name),
              trailing: _currentSport == sport
                  ? Icon(Icons.check, color: sport.primaryColor)
                  : null,
              onTap: () {
                setState(() {
                  _currentSport = sport;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
    */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        leading: GestureDetector(
          onTap: () {
            // TODO: Implementare prenotazione campo
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Book a field - Coming soon')),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: ATLColors.darkBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stadium, color: Colors.white, size: 18),
                SizedBox(height: 2),
                Text(
                  'Book a field',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'HOME',
          style: TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              // TODO: Implementare dark mode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode - Coming soon')),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(
                Icons.dark_mode,
                color: ATLColors.darkBlue,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingATL()
          : _buildPlayerHomeContent(),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
      ),
    );
  }

  Widget _buildPlayerHomeContent() {
    if (_activeTournaments == null || _activeTournaments!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentSport.icon,
              color: _currentSport.primaryColor,
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'No active tournaments',
              style: TextStyle(
                color: ATLColors.subtext,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join a tournament to start playing!',
              style: TextStyle(
                color: ATLColors.title,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Tournament name header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            _activeTournaments![_currentPage].name.toUpperCase(),
            style: TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        // Page indicators
        if (_activeTournaments!.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_activeTournaments!.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? _currentSport.primaryColor
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),
        
        // Tournament card
        Expanded(
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _activeTournaments!.length,
            itemBuilder: (context, index) {
              final tournament = _activeTournaments![index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTournamentCard(tournament),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    final matches = _tournamentMatches[tournament.id] ?? [];
    final standings = _tournamentStandings[tournament.id] ?? [];
    
    // Find user's team group
    final userStanding = standings.firstWhere(
      (s) => s.teamId == _userTeam?.id,
      orElse: () => standings.isNotEmpty ? standings.first : SoccerStanding(
        tournamentId: tournament.id,
        teamId: 0,
        points: 0,
        won: 0,
        drawn: 0,
        lost: 0,
        group: 'A',
      ),
    );
    
    final groupStandings = standings
        .where((s) => s.group == userStanding.group)
        .toList()
      ..sort((a, b) => b.points.compareTo(a.points));
    
    // Find next match
    final userMatches = matches.where((m) =>
      m.homeTeamId == _userTeam?.id || m.awayTeamId == _userTeam?.id).toList()
      ..sort((a, b) {
        if (a.matchDate == null && b.matchDate == null) return 0;
        if (a.matchDate == null) return 1;
        if (b.matchDate == null) return -1;
        return a.matchDate!.compareTo(b.matchDate!);
      });
    
    final nextMatch = userMatches.isNotEmpty ? userMatches.first : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Next match card
          if (nextMatch != null) ...[
            Text(
              'GROUP ${userStanding.group}',
              style: TextStyle(
                color: ATLColors.subtext,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            SoccerMatchWidget(
              match: nextMatch,
              homeTeam: _teamsCache[nextMatch.homeTeamId],
              awayTeam: _teamsCache[nextMatch.awayTeamId],
            ),
          ],
          
          // Group standings
          ...groupStandings.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final standing = entry.value;
            final team = _teamsCache[standing.teamId];
            
            if (team == null) return const SizedBox.shrink();
            
            final isUserTeam = team.id == _userTeam?.id;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: HomeTeamWidget(
                team: team,
                color: isUserTeam ? ATLColors.getPrimaryColor(_currentSport) : Colors.white,
                rank: rank,
                standingRecord: '${standing.points} pts',
                sportCategory: _currentSport,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
