import 'package:atl_app/models/city.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/referee_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/football_match.dart';
import '../../models/team.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../../widgets/small_football_match_widget.dart';
import '../shop_screen.dart';
import '../profile_screen.dart';
import 'referee_home_screen.dart';
import 'past_assigned_matches_screen.dart';
import '../../database/db_read.dart';
import '../../config/api_json_keys.dart';
import '../../l10n/app_localizations.dart';

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
  Map<int, int?> _minutesRoundPerTournament = {};
  Map<int, int?> _minutesPausePerTournament = {};
  List<City> _cities = [];
  City? _selectedCity;
  int? _selectedSportId;
  Map<int, List<FootballMatch>> _matchesPerSport = {};
  Map<int, String> _sportNames = {};

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => _isLoading = true);

    try {
      final data = await DBRead.getCities();
      if (mounted) {
        final preferredCityId =
            Provider.of<UserProvider>(context, listen: false).cityId;
        final cities = data[ApiJsonKeys.cities] as List<City>;
        City? defaultCity;
        if (preferredCityId != null) {
          try {
            defaultCity = cities.firstWhere((c) => c.id == preferredCityId);
          } catch (_) {}
        }
        setState(() {
          _cities = cities;
          if (defaultCity != null) _selectedCity = defaultCity;
          _isLoading = false;
        });
        if (_selectedCity != null) await _loadMatches();
      }
    } catch (e) {
      print('Error loading cities: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMatches() async {
    if (_selectedCity == null) return;

    setState(() => _isLoading = true);

    try {
      final data = await DBRead.getAvailableMatchesScreen(
        widget.currentSport,
        Provider.of<UserProvider>(context, listen: false).activeRoleId!,
        cityId: _selectedCity!.id,
        sportId: _selectedSportId,
      );

      List<FootballMatch> availableMatches = data[ApiJsonKeys.matches];
      

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
          _teamsCache = data[ApiJsonKeys.teamsCache];
          _minutesRoundPerTournament = data[ApiJsonKeys.minutesRoundPerTournament];
          _minutesPausePerTournament = data[ApiJsonKeys.minutesPausePerTournament];
          _matchesPerSport = data[ApiJsonKeys.matchesPerSport];
          _sportNames = data[ApiJsonKeys.sportNames];
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          l10n.matchesNavLabel.toUpperCase(),
          style: const TextStyle(
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
                SnackBar(content: Text(l10n.darkModeComingSoonSnack)),
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
        userId: Provider.of<UserProvider>(context, listen: false).activeUser?.id,
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context);
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
              _buildDropdown<City>(
                label: l10n.city,
                value: _selectedCity,
                items: _cities,
                onChanged: (value) async {
                  setState(() {
                    _selectedCity = value;
                  });
                  await _loadMatches();
                },
                itemBuilder: (city) => Text(city.name),
              ),
              const SizedBox(height: 12),
              // Sport type dropdown
              _buildDropdown<int?>(
                label: l10n.sportLabel,
                value: _selectedSportId,
                items: [null, ..._sportNames.keys.toList()],
                onChanged: (value) async {
                  setState(() {
                    _selectedSportId = value;
                  });
                  await _loadMatches();
                },
                itemBuilder: (sportId) {
                  if (sportId == null) return Text(l10n.allFilter);
                  return Text(_sportNames[sportId] ?? l10n.sportWithId(sportId));
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
    final l10n = AppLocalizations.of(context);
    if (_selectedCity == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                l10n.selectCityToSeeMatchesTitle,
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.selectCityToSeeMatchesSubtitle,
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

    // Filtered by specific sport: flat list
    if (_selectedSportId != null) {
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
                  l10n.noMatchesAvailable,
                  style: TextStyle(
                    color: ATLColors.darkBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.noScheduledMatchesForSelectedFilters,
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
              minutesPerRound: _minutesRoundPerTournament[match.tournamentId] ?? 0,
              minutesPerPause: _minutesPausePerTournament[match.tournamentId] ?? 0,
              onMatchUpdated: () => _loadMatches(),
            ),
          );
        },
      );
    }

    // All sports: grouped view
    final List<Widget> items = [];
    for (final sportId in _matchesPerSport.keys) {
      final matches = _matchesPerSport[sportId] ?? [];
      final sportName = _sportNames[sportId] ?? l10n.sportWithId(sportId);

      items.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            sportName,
            style: const TextStyle(
              color: ATLColors.darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      );

      if (matches.isEmpty) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.noScheduledMatchesInSport(sportName),
              style: TextStyle(color: ATLColors.subtext, fontSize: 14),
            ),
          ),
        );
      } else {
        for (final match in matches) {
          items.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SmallFootballMatchWidget(
                match: match,
                homeTeam: _teamsCache[match.homeTeamId],
                awayTeam: _teamsCache[match.awayTeamId],
                currentSport: widget.currentSport,
                minutesPerRound: _minutesRoundPerTournament[match.tournamentId] ?? 0,
                minutesPerPause: _minutesPausePerTournament[match.tournamentId] ?? 0,
                onMatchUpdated: () => _loadMatches(),
              ),
            ),
          );
        }
      }
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                l10n.noMatchesAvailable,
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: items,
    );
  }
}
