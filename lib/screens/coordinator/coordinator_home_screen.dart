import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/tournament.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_controller.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/football_match_widget.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../teams/team_screen.dart';
import '../profile_screen.dart';

class CoordinatorHomeScreen extends StatefulWidget {
  const CoordinatorHomeScreen({super.key});

  @override
  State<CoordinatorHomeScreen> createState() => _CoordinatorHomeScreenState();
}

class _CoordinatorHomeScreenState extends State<CoordinatorHomeScreen> {
  late final SportCategory _currentSport = SportCategory.football;
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<Tournament> _tournaments = [];
  Map<int, List<FootballMatch>> _matchesByTournament = {};
  Map<int, Team> _teamsCache = {};
  Map<int, int?> _minutesPerRoundCache = {};
  Map<int, int?> _minutesPerPauseCache = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final coordinatorId = userProvider.activeRoleId;

      if (coordinatorId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load tournaments where user is coordinator
      final tournaments = await DB.Tournaments.getByCoordinatorId(coordinatorId);

      // Load matches for selected date for each tournament
      final matchesByTournament = <int, List<FootballMatch>>{};
      
      for (var tournament in tournaments) {
        final matches = await DB.FootballMatches.getMatchesByTournament(tournament.id);
        
        // Filter matches for selected date
        final filteredMatches = matches.where((match) {
          if (match.scheduledStart == null) return false;
          
          final matchDate = DateTime(
            match.scheduledStart!.year,
            match.scheduledStart!.month,
            match.scheduledStart!.day,
          );
          final selectedDateOnly = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          );
          
          return matchDate.isAtSameMomentAs(selectedDateOnly);
        }).toList();

        if (filteredMatches.isNotEmpty) {
          matchesByTournament[tournament.id] = filteredMatches;
          
          // Load teams for these matches
          for (var match in filteredMatches) {
            if (match.homeTeamId != null && !_teamsCache.containsKey(match.homeTeamId)) {
              final team = await DB.Teams.getById(match.homeTeamId!);
              if (team != null) _teamsCache[match.homeTeamId!] = team;
            }
            if (match.awayTeamId != null && !_teamsCache.containsKey(match.awayTeamId)) {
              final team = await DB.Teams.getById(match.awayTeamId!);
              if (team != null) _teamsCache[match.awayTeamId!] = team;
            }
          }
        }

        // Load minutes per round and pause
        _minutesPerRoundCache[tournament.id] = await DB.Tournaments.getMinutesPerRoundById(tournament.id);
        _minutesPerPauseCache[tournament.id] = await DB.Tournaments.getMinutesPerPauseById(tournament.id);
      }

      if (mounted) {
        setState(() {
          _tournaments = tournaments;
          _matchesByTournament = matchesByTournament;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading coordinator data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    final difference = dateOnly.difference(today).inDays;
    
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    
    return DateFormat('EEE d').format(date);
  }

  void _onNavTap(int index) {
    if (index == 4) {
      _showSportSelector();
    } else {
      Widget screen;
      switch (index) {
        case 0:
          screen = ShopScreen(currentSport: _currentSport);
          break;
        case 1:
          screen = AllTournamentsScreen(currentSport: _currentSport);
          break;
        case 2:
          screen = TeamScreen(currentSport: _currentSport);
          break;
        case 3:
          screen = ProfileScreen(currentSport: _currentSport);
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
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final user = userProvider.activeUser!;

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        leading: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manage fields - Coming soon')),
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
                Icon(Icons.edit_calendar, color: Colors.white, size: 18),
                SizedBox(height: 2),
                Text(
                  'Manage fields',
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
      body: _buildCoordinatorHomeContent(),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
      ),
    );
  }

  Widget _buildCoordinatorHomeContent() {
    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    final user = userProvider.activeUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card info utente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: ATLColors.getPrimaryColor(
                    _currentSport,
                  ).withOpacity(0.2),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: ATLColors.getPrimaryColor(_currentSport),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          color: ATLColors.darkBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.roleDisplayName,
                        style: TextStyle(
                          color: ATLColors.getPrimaryColor(_currentSport),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick actions for coordinator
          Text(
            'COORDINATOR TOOLS',
            style: TextStyle(
              color: ATLColors.subtext,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Create Tournament',
                  Icons.add_circle_outline,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionCard('Manage Teams', Icons.group, () {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Coming soon')));
                }),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Upcoming tournaments
          Text(
            'UPCOMING TOURNAMENTS',
            style: TextStyle(
              color: ATLColors.subtext,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(24),
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
              children: [
                Icon(
                  _currentSport.icon,
                  color: ATLColors.getPrimaryColor(_currentSport),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'No tournaments scheduled',
                  style: TextStyle(color: ATLColors.subtext, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a tournament to get started!',
                  style: TextStyle(color: ATLColors.title, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ATLColors.getPrimaryColor(_currentSport),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: ATLColors.getPrimaryColor(_currentSport),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: ATLColors.darkBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
