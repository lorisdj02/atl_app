import 'package:flutter/material.dart';
import '../../widgets/referee_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../models/tournament.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_controller.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/small_football_match_widget.dart';
import '../shop_screen.dart';
import '../profile_screen.dart';
import 'referee_home_screen.dart';
import 'past_assigned_matches_screen.dart';

class AvailableMatchesScreen extends StatefulWidget {
  final SportCategory currentSport;

  const AvailableMatchesScreen({super.key, required this.currentSport});

  @override
  State<AvailableMatchesScreen> createState() => _AvailableMatchesScreenState();
}

class _AvailableMatchesScreenState extends State<AvailableMatchesScreen> {
  bool _isLoading = true;
  List<FootballMatch> _availableMatches = [];
  Map<int, Team> _teamsCache = {};
  Map<int, int?> _minutesPerRoundCache = {};
  Map<int, int?> _minutesPerPauseCache = {};
  List<int> _cities = [];
  int? _selectedCityId;
  int? _selectedSportId;

  // Map of sport types by category
  final Map<SportCategory, Map<int, String>> _sportTypes = {
    SportCategory.football: {
      1: 'Football 5v5',
      2: 'Football 7v7',
      3: 'Football 8v8',
      4: 'Football 11v11',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => _isLoading = true);

    try {
      final cities = await DB.Cities.getAll();
      if (mounted) {
        setState(() {
          _cities = cities.map((c) => c.id).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading cities: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMatches() async {
    if (_selectedCityId == null) return;

    setState(() => _isLoading = true);

    try {
      final availableMatches = <FootballMatch>[];

      // Get tournaments by sport if selected, otherwise get all tournaments
      List<Tournament> tournaments;
      if (_selectedSportId != null) {
        tournaments = await DB.Tournaments.getBySportCategory(
          widget.currentSport,
        );
        tournaments = tournaments
            .where(
              (t) =>
                  t.sportId == _selectedSportId && t.cityId == _selectedCityId,
            )
            .toList();
      } else {
        tournaments = await DB.Tournaments.getBySportCategory(
          widget.currentSport,
        );
        tournaments = tournaments
            .where((t) => t.cityId == _selectedCityId)
            .toList();
      }

      // Load scheduled matches for each tournament
      for (var tournament in tournaments) {
        final matches = await DB
            .FootballMatches.getScheduledMatchesByTournament(tournament.id);

        for (var match in matches) {
          availableMatches.add(match);

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

          // Load minutes per round and pause
          if (!_minutesPerRoundCache.containsKey(match.tournamentId)) {
            _minutesPerRoundCache[match.tournamentId] =
                await DB.Tournaments.getMinutesPerRoundById(match.tournamentId);
          }
          if (!_minutesPerPauseCache.containsKey(match.tournamentId)) {
            _minutesPerPauseCache[match.tournamentId] =
                await DB.Tournaments.getMinutesPerPauseById(match.tournamentId);
          }
        }
      }

      // Sort matches by scheduled start time
      availableMatches.sort((a, b) {
        if (a.scheduledStart == null && b.scheduledStart == null) return 0;
        if (a.scheduledStart == null) return 1;
        if (b.scheduledStart == null) return -1;
        return a.scheduledStart!.compareTo(b.scheduledStart!);
      });

      if (mounted) {
        setState(() {
          _availableMatches = availableMatches;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading matches: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNavTap(int index) {
    if (index == 1) {
      // Already on matches screen, do nothing
      return;
    }

    Widget screen;
    switch (index) {
      case 0:
        screen = ShopScreen(currentSport: widget.currentSport);
        break;
      case 2:
        screen = PastAssignedMatchesScreen(currentSport: widget.currentSport);
        break;
      case 3:
        screen = ProfileScreen(currentSport: widget.currentSport);
        break;
      case 4:
        screen = const RefereeHomeScreen();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
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
          'Matches',
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
      body: _buildContent(),
      bottomNavigationBar: RefereeBottomBar(
        currentIndex: 1,
        onTap: _onNavTap,
        currentSport: widget.currentSport,
        isHome: false,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _cities.isEmpty) {
      return const Center(child: LoadingATL());
    }

    return Column(
      children: [
        // Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // City dropdown
              _buildDropdown(
                label: 'City',
                value: _selectedCityId,
                items: _cities,
                onChanged: (value) async {
                  setState(() {
                    _selectedCityId = value;
                  });
                  await _loadMatches();
                },
                itemBuilder: (cityId) {
                  return FutureBuilder(
                    future: DB.Cities.getById(cityId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Text(snapshot.data!.name);
                      }
                      return Text('City $cityId');
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              // Sport type dropdown
              _buildDropdown(
                label: 'Sport Type',
                value: _selectedSportId,
                items: _sportTypes[widget.currentSport]?.keys.toList() ?? [],
                onChanged: (value) async {
                  setState(() {
                    _selectedSportId = value;
                  });
                  await _loadMatches();
                },
                itemBuilder: (sportId) {
                  return Text(
                    _sportTypes[widget.currentSport]?[sportId] ??
                        'Sport $sportId',
                  );
                },
              ),
            ],
          ),
        ),
        // Matches list
        Expanded(child: _buildMatchesList()),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required Widget Function(T) itemBuilder,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ATLColors.subtext.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label, style: TextStyle(color: ATLColors.subtext)),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: ATLColors.darkBlue),
          items: items.map((item) {
            return DropdownMenuItem<T>(value: item, child: itemBuilder(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMatchesList() {
    if (_selectedCityId == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                'Select a city',
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a city to see available matches',
                style: TextStyle(color: ATLColors.subtext, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: LoadingATL());
    }

    if (_availableMatches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                'No matches available',
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No scheduled matches for the selected filters',
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
      itemCount: _availableMatches.length,
      itemBuilder: (context, index) {
        final match = _availableMatches[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SmallFootballMatchWidget(
            match: match,
            homeTeam: _teamsCache[match.homeTeamId],
            awayTeam: _teamsCache[match.awayTeamId],
            currentSport: widget.currentSport,
            minutesPerRound: _minutesPerRoundCache[match.tournamentId] ?? 0,
            minutesPerPause: _minutesPerPauseCache[match.tournamentId] ?? 0,
            onMatchUpdated: () => _loadMatches(),
          ),
        );
      },
    );
  }
}
