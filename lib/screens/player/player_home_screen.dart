import 'package:atl_app/models/private_bookings.dart';
import 'package:atl_app/models/user.dart';
import 'package:flutter/material.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/tournament.dart';
import '../../models/football_match.dart';
import '../../models/football_standing.dart';
import '../../models/team.dart';
import '../../utils/atl_colors.dart';
import '../../database/db_controller.dart';
import '../../widgets/loading_atl.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../teams/team_screen.dart';
import '../profile_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'book_field_screen.dart';
import '../../widgets/booking_widget.dart';
import '../../models/lobby_booking.dart';
import 'join_lobby_screen.dart';
import '../../widgets/tournament_card_home.dart';

class PlayerHomeScreen extends StatefulWidget {
  const PlayerHomeScreen({super.key});

  @override
  State<PlayerHomeScreen> createState() => _PlayerHomeScreenState();
}

class _PlayerHomeScreenState extends State<PlayerHomeScreen> {
  late final UserProvider userProvider = Provider.of<UserProvider>(
    context,
    listen: false,
  );
  late final User user = userProvider.activeUser!;
  late final int? teamId = userProvider.currentTeamId;
  late final int playerId = userProvider.activeRoleId!;
  late final SportCategory _currentSport =
      userProvider.selectedSportCategory ?? SportCategory.football;

  List<Tournament>? _activeTournaments;
  Map<int, List<FootballMatch>> _tournamentMatches = {};
  Map<int, List<FootballStanding>> _tournamentStandings = {};
  Map<int, Team> _teamsCache = {};
  Team? _userTeam;
  List<dynamic> _bookings = [];
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
      // Carica i booking
      final List<PrivateBooking> privateBookings = await DB.PrivateBookings.getByPlayerId(playerId) ?? [];
      List<int> lobbyBookingsIds = (await DB.LobbyBookingParticipations.getByPlayerId(playerId)).map((p) => p.lobbyBookingId).toList();
      List<LobbyBooking> lobbyBookings = [];
      for (var lobbyBookingId in lobbyBookingsIds) {
        final lobbyBooking = await DB.LobbyBookings.getById(lobbyBookingId);
        if (lobbyBooking != null){
          lobbyBookings.add(lobbyBooking);
        }
      }
      print('Loaded ${privateBookings.length} private bookings and ${lobbyBookings.length} lobby bookings for player $playerId');
      // Combina e ordina per startTime
      final allBookings = <dynamic>[...privateBookings, ...lobbyBookings];
      allBookings.sort((a, b) {
        final aTime = a is PrivateBooking ? a.startTime : (a as LobbyBooking).startTime;
        final bTime = b is PrivateBooking ? b.startTime : (b as LobbyBooking).startTime;
        return aTime.compareTo(bTime);
      });
      
      _bookings = allBookings;

      // Load user's team using teamId from user
      if (teamId != null && teamId != -1) {
        _userTeam = await DB.Teams.getById(teamId!);

        // Load active tournaments where user's team participates
        //final allTournaments = DB.Tournaments.mockData;
        //final activeTournaments = allTournaments.where((t) => t.status == TournamentStatus.scheduled).toList();

        final activeTournamentsId =
            (await DB.TournamentPartecipations.getPaidByTeamId(
              teamId!,
            )).map((p) => p.tournamentId).toSet();

        final activeTournaments = (await DB.Tournaments.getBySport(
          'FOOTBALL',
        )).where((t) => activeTournamentsId.contains(t.id)).toList();

        // Load matches and standings for each tournament
        for (var tournament in activeTournaments) {
          final matches = await DB.FootballMatches.getMatchesByTournament(
            tournament.id,
          );
          final standings = await DB.FootballStandings.getStandingsByTournament(
            tournament.id,
          );

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
      } else {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // ✓ FIX: Usa addPostFrameCallback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
          }
        });
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
    // Calcola il numero totale di pagine (tornei + 1 pagina booking + pagina "need more")
    final tournamentsCount = _activeTournaments?.length ?? 0;
    final bookingsCount = _bookings.length;
    final hasBookings = bookingsCount > 0;
    final totalPages = tournamentsCount + (hasBookings ? 1 : 0) + 1; // tornei + bookings page + need more
    final isOnNeedMorePage = _currentPage >= (tournamentsCount + (hasBookings ? 1 : 0));

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 90,
        // Mostra "Book a field" solo se NON siamo sulla pagina "Need more?"
        leading: !isOnNeedMorePage
            ? GestureDetector(
                onTap: () async {
                  // Naviga a BookFieldScreen
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookFieldScreen(sportCategory: _currentSport),
                    ),
                  );
                  
                  // Se è stata creata una prenotazione, ricarica i dati
                  if (result == true) {
                    _loadPlayerData();
                  }
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
              )
            : null,
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
      body: _isLoading ? const LoadingATL() : _buildPlayerHomeContent(),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
      ),
    );
  }

  Widget _buildPlayerHomeContent() {
    final tournamentsCount = _activeTournaments?.length ?? 0;
    final bookingsCount = _bookings.length;
    final hasBookings = bookingsCount > 0;
    final totalPages = tournamentsCount + (hasBookings ? 1 : 0) + 1; // tornei + bookings page + need more

    return Column(
      children: [
        // Tournament name header / Booking header / "Need more?" header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            _getPageTitle(),
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
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPages, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? ATLColors.getPrimaryColor(_currentSport)
                        : Colors.grey.shade300,
                  ),
                );
              }),
            ),
          ),

        // Tournament cards + Bookings page + "Need more?" page
        Expanded(
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: totalPages,
            itemBuilder: (context, index) {
              if (index < tournamentsCount) {
                final tournament = _activeTournaments![index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TournamentCardHome(
                  tournament: tournament,
                  matches: _tournamentMatches[tournament.id] ?? [],
                  standings: _tournamentStandings[tournament.id] ?? [],
                  teamsCache: _teamsCache,
                  userTeam: _userTeam,
                  sportCategory: _currentSport,
                ),
                );
              } else if (hasBookings && index == tournamentsCount) {
                // Pagina unica con tutti i bookings
                return _buildBookingsPage();
              } else {
                // Pagina "Need more?"
                return _buildNeedMorePage();
              }
            },
          ),
        ),
      ],
    );
  }

  String _getPageTitle() {
    final tournamentsCount = _activeTournaments?.length ?? 0;
    final bookingsCount = _bookings.length;
    final hasBookings = bookingsCount > 0;
    
    if (_currentPage < tournamentsCount) {
      return _activeTournaments![_currentPage].name.toUpperCase();
    } else if (hasBookings && _currentPage == tournamentsCount) {
      return 'BOOKINGS';
    } else {
      return 'NEED MORE?';
    }
  }

  Widget _buildBookingsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        itemCount: _bookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return BookingWidget(
            fieldId: booking is PrivateBooking ? booking.fieldId : (booking as LobbyBooking).fieldId,
            startTime: booking is PrivateBooking ? booking.startTime : (booking as LobbyBooking).startTime,
            finishTime: booking is PrivateBooking ? booking.finishTime : (booking as LobbyBooking).finishTime,
            ownerId: booking is LobbyBooking ? booking.ownerId : null,
            currentSport: _currentSport,
            bookingId: booking is PrivateBooking ? booking.id : (booking as LobbyBooking).id,
            onBookingDeleted: () => _loadPlayerData(),
          );
        },
      ),
    );
  }

  Widget _buildNeedMorePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, color: ATLColors.getPrimaryColor(_currentSport), size: 80),
            const SizedBox(height: 24),
            const Text(
              'Looking for more passion?',
              style: TextStyle(
                color: ATLColors.title,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Book a field button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Naviga a BookFieldScreen
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookFieldScreen(sportCategory: _currentSport),
                    ),
                  );
                  
                  // Se è stata creata una prenotazione, ricarica i dati
                  if (result == true) {
                    _loadPlayerData();
                  }
                },
                icon: const Icon(Icons.stadium, size: 28),
                label: const Text(
                  'BOOK A FIELD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.darkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Browse tournaments button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          AllTournamentsScreen(currentSport: _currentSport),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                icon: Icon(_currentSport.icon, size: 28),
                label: const Text(
                  'BROWSE TOURNAMENTS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.getPrimaryColor(_currentSport),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Join Lobby button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => JoinLobbyScreen(sportCategory: _currentSport),
                    ),
                  ).then((_) => _loadPlayerData());
                },
                icon: const Icon(Icons.groups, size: 28),
                label: const Text(
                  'JOIN LOBBY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ATLColors.getPrimaryColor(_currentSport),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: ATLColors.getPrimaryColor(_currentSport), width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
