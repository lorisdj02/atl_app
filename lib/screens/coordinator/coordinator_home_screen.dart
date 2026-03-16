import 'package:atl_app/database/db_read.dart';
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
import '../../l10n/app_localizations.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/football_match_widget.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../teams/team_screen.dart';
import '../profile_screen.dart';
import '../../config/api_json_keys.dart';

class CoordinatorHomeScreen extends StatefulWidget {
  const CoordinatorHomeScreen({super.key});

  @override
  State<CoordinatorHomeScreen> createState() => _CoordinatorHomeScreenState();
}

class _CoordinatorHomeScreenState extends State<CoordinatorHomeScreen> {
  late final SportCategory _currentSport = SportCategory.football;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  List<Tournament> _activeTournaments = [];
  Map<int, List<FootballMatch>> _matchesPerTournament = {};
  Map<int, Team> _teamsCache = {};
  Map<int, int?> _minutesRoundPerTournament = {};
  Map<int, int?> _minutesPausePerTournament = {};
  final ScrollController _dayScrollController = ScrollController();
  Map<DateTime , List<FootballMatch>> _matchesPerDate = {};

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
      final coordinatorId = userProvider.activeRoleId;

      if (coordinatorId == null || _currentSport != SportCategory.football) {
        setState(() => _isLoading = false);
        return;
      }

      final coordinatorData = await DBRead.getCoordinatorHomeScreen(
        coordinatorId: coordinatorId,
        currentSport: _currentSport,
      );

      Map<DateTime, List<FootballMatch>> matchesPerDate = {};
      for (var matches in coordinatorData['matchesPerTournament'].values) {
        for (var match in matches) {
          if (match.scheduledStart != null) {
            final matchDate = DateTime(
              match.scheduledStart!.year,
              match.scheduledStart!.month,
              match.scheduledStart!.day,
            );
            if (!matchesPerDate.containsKey(matchDate)) {
              matchesPerDate[matchDate] = [];
            }
            matchesPerDate[matchDate]!.add(match);
          }
        }
      }

      if (mounted) {
        setState(() {
          _activeTournaments = coordinatorData[ApiJsonKeys.activeTournaments];
          _matchesPerTournament = coordinatorData[ApiJsonKeys.matchesPerTournament];
          _teamsCache = coordinatorData[ApiJsonKeys.teamsCache];
          _minutesRoundPerTournament = coordinatorData[ApiJsonKeys.minutesRoundPerTournament];
          _minutesPausePerTournament = coordinatorData[ApiJsonKeys.minutesPausePerTournament];
          _matchesPerDate = matchesPerDate;
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
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.tomorrow;
    if (difference == -1) return l10n.yesterday;

    final locale = Localizations.localeOf(context).toString();
    return DateFormat('EEE d', locale).format(date);
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
      SnackBar(
        content: Text(AppLocalizations.of(context).otherSportsComingSoon),
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
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).home,
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
                SnackBar(
                  content: Text(AppLocalizations.of(context).darkModeComingSoonSnack),
                ),
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
        userId: Provider.of<UserProvider>(context, listen: false).activeUser!.id,
      ),
    );
  }

  Widget _buildCoordinatorHomeContent() {
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
                    DateFormat(
                      'd MMM',
                      Localizations.localeOf(context).toString(),
                    ).format(day),
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
      _scrollToSelectedDay();
    }
  }

  Widget _buildMatchesList() {
    if (_activeTournaments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noTournaments,
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).notCoordinatingAnyTournamentsYet,
                style: TextStyle(color: ATLColors.subtext, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Check if there are any matches for the selected date
    final hasMatches = _matchesPerDate.containsKey(
      DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
    );

    if (!hasMatches) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noMatchesScheduled,
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).noMatchesOn(
                  DateFormat.yMMMd(Localizations.localeOf(context).toString())
                      .format(_selectedDate),
                ),
                style: TextStyle(color: ATLColors.subtext, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _activeTournaments.length,
      itemBuilder: (context, index) {
        final tournament = _activeTournaments[index];
        final matches = (_matchesPerTournament[tournament.id] ?? []).where((
          match,
        ) {
          final matchDate = DateTime(
            match.scheduledStart!.year,
            match.scheduledStart!.month,
            match.scheduledStart!.day,
          );
          final selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
          );
          return matchDate == selectedDate;
        }).toList();

        if (matches.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    _currentSport.icon,
                    color: ATLColors.getPrimaryColor(_currentSport),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ATLColors.darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Matches for this tournament
            ...matches.map(
              (match) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FootballMatchWidget(
                  match: match,
                  homeTeam: _teamsCache[match.homeTeamId],
                  awayTeam: _teamsCache[match.awayTeamId],
                  currentSport: _currentSport,
                  minutesPerRound: _minutesRoundPerTournament[tournament.id] ?? 0,
                  minutesPerPause: _minutesPausePerTournament[tournament.id] ?? 0,
                  onMatchUpdated: _loadData,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
