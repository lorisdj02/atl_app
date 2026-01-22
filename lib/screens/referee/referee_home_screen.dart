import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/referee_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../providers/user_provider.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_controller.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/football_match_widget.dart';
import '../shop_screen.dart';
import '../profile_screen.dart';
import 'available_matches_screen.dart';
import 'past_assigned_matches_screen.dart';

class RefereeHomeScreen extends StatefulWidget {
  const RefereeHomeScreen({super.key});

  @override
  State<RefereeHomeScreen> createState() => _RefereeHomeScreenState();
}

class _RefereeHomeScreenState extends State<RefereeHomeScreen> {
  late final SportCategory _currentSport = SportCategory.football;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<FootballMatch> _assignedMatches = [];
  Map<int, Team> _teamsCache = {};
  Map<int, int?> _minutesPerRoundCache = {};
  Map<int, int?> _minutesPerPauseCache = {};
  final ScrollController _dayScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_dayScrollController.hasClients) return;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDateOnly = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
      final daysDifference = selectedDateOnly.difference(today).inDays;

      // Calculate the position to center the selected day
      // Each item is 74 pixels wide (70 + 4 margin on each side)
      // +1 accounts for the first "..." button
      final targetIndex = 5 + daysDifference + 1;

      // Center the item by offsetting by half screen width minus half item width
      final screenWidth = MediaQuery.of(context).size.width;
      final itemCenter = (targetIndex * 74.0) + 37.0;
      final scrollPosition = itemCenter - (screenWidth / 2);

      _dayScrollController.animateTo(
        scrollPosition.clamp(
          0.0,
          _dayScrollController.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final refereeId = userProvider.activeRoleId;

      if (refereeId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load referee assignments
      final assignments = await DB.RefereeAssignments.getByRefereeId(refereeId);

      // Load matches for selected date
      final assignedMatches = <FootballMatch>[];

      for (var assignment in assignments) {
        final match = await DB.FootballMatches.getById(assignment.matchId);
        if (match != null && match.scheduledStart != null) {
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

          if (matchDate.isAtSameMomentAs(selectedDateOnly)) {
            assignedMatches.add(match);

            // Load teams for this match
            if (match.homeTeamId != null &&
                !_teamsCache.containsKey(match.homeTeamId)) {
              final team = await DB.Teams.getById(match.homeTeamId!);
              if (team != null) _teamsCache[match.homeTeamId!] = team;
            }
            if (match.awayTeamId != null &&
                !_teamsCache.containsKey(match.awayTeamId)) {
              final team = await DB.Teams.getById(match.awayTeamId!);
              if (team != null) _teamsCache[match.awayTeamId!] = team;
            }

            // Load minutes per round and pause for the tournament
            if (!_minutesPerRoundCache.containsKey(match.tournamentId)) {
              _minutesPerRoundCache[match.tournamentId] = await DB
                  .Tournaments.getMinutesPerRoundById(match.tournamentId);
            }
            if (!_minutesPerPauseCache.containsKey(match.tournamentId)) {
              _minutesPerPauseCache[match.tournamentId] = await DB
                  .Tournaments.getMinutesPerPauseById(match.tournamentId);
            }
          }
        }
      }

      // Sort matches by scheduled start time
      assignedMatches.sort((a, b) {
        if (a.scheduledStart == null && b.scheduledStart == null) return 0;
        if (a.scheduledStart == null) return 1;
        if (b.scheduledStart == null) return -1;
        return a.scheduledStart!.compareTo(b.scheduledStart!);
      });

      if (mounted) {
        setState(() {
          _assignedMatches = assignedMatches;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading referee data: $e');
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
      // Already on home, do nothing
      return;
    }

    Widget screen;
    switch (index) {
      case 0:
        screen = ShopScreen(currentSport: _currentSport);
        break;
      case 1:
        screen = AvailableMatchesScreen(currentSport: _currentSport);
        break;
      case 2:
        screen = PastAssignedMatchesScreen(currentSport: _currentSport);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: _buildRefereeHomeContent(),
      bottomNavigationBar: RefereeBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
      ),
    );
  }

  Widget _buildRefereeHomeContent() {
    if (_isLoading) {
      return const Center(child: LoadingATL());
    }

    return Column(
      children: [
        // Day selector
        _buildDaySelector(),
        // Matches list
        Expanded(child: _buildMatchesList()),
      ],
    );
  }

  Widget _buildDaySelector() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Calculate visible days: 5 before and 5 after today (fixed)
    final visibleDays = <DateTime>[];
    for (int i = -5; i <= 5; i++) {
      visibleDays.add(today.add(Duration(days: i)));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 60,
      child: ListView.builder(
        controller: _dayScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: visibleDays.length + 2, // +2 for the "more" buttons
        itemBuilder: (context, index) {
          // First item: "previous days" button
          if (index == 0) {
            return GestureDetector(
              onTap: () => _showDatePicker(isBefore: true),
              child: Container(
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ATLColors.subtext.withOpacity(0.3)),
                ),
                child: Icon(Icons.more_horiz, color: ATLColors.darkBlue),
              ),
            );
          }

          // Last item: "next days" button
          if (index == visibleDays.length + 1) {
            return GestureDetector(
              onTap: () => _showDatePicker(isBefore: false),
              child: Container(
                width: 50,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ATLColors.subtext.withOpacity(0.3)),
                ),
                child: Icon(Icons.more_horiz, color: ATLColors.darkBlue),
              ),
            );
          }

          // Day items
          final day = visibleDays[index - 1];
          final dayOnly = DateTime(day.year, day.month, day.day);
          final isSelected = dayOnly.isAtSameMomentAs(
            DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
            ),
          );

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
              _loadData();
              _scrollToSelectedDay();
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? ATLColors.getPrimaryColor(_currentSport)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? ATLColors.getPrimaryColor(_currentSport)
                      : ATLColors.subtext.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDateLabel(day),
                    style: TextStyle(
                      color: isSelected ? Colors.white : ATLColors.darkBlue,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d MMM').format(day),
                    style: TextStyle(
                      color: isSelected ? Colors.white : ATLColors.darkBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDatePicker({required bool isBefore}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBefore
          ? (today.subtract(const Duration(days: 6)))
          : (today.add(const Duration(days: 6))),
      firstDate: isBefore ? DateTime(2020) : today.add(const Duration(days: 6)),
      lastDate: isBefore
          ? today.subtract(const Duration(days: 6))
          : DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ATLColors.getPrimaryColor(_currentSport),
              onPrimary: Colors.white,
              onSurface: ATLColors.darkBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
      _scrollToSelectedDay();
    }
  }

  Widget _buildMatchesList() {
    if (_assignedMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                'No matches assigned',
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No matches assigned on ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                style: TextStyle(color: ATLColors.subtext, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _assignedMatches.length,
      itemBuilder: (context, index) {
        final match = _assignedMatches[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: FootballMatchWidget(
            match: match,
            homeTeam: _teamsCache[match.homeTeamId],
            awayTeam: _teamsCache[match.awayTeamId],
            currentSport: _currentSport,
            minutesPerRound: _minutesPerRoundCache[match.tournamentId] ?? 0,
            minutesPerPause: _minutesPerPauseCache[match.tournamentId] ?? 0,
            onMatchUpdated: _loadData,
          ),
        );
      },
    );
  }
}
