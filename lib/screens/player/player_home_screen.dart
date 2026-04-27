import 'package:atl_app/database/controller/home_screen_controller.dart';
import 'package:atl_app/database/db_read.dart';
import 'package:atl_app/database/responses/player_home_response.dart';
import '../../l10n/app_localizations.dart';
import 'package:atl_app/models/field.dart';
import 'package:atl_app/models/private_booking.dart';
import 'package:atl_app/models/account.dart';
import 'package:flutter/material.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../models/tournament.dart';
import '../../models/football_match.dart';
import '../../models/football_standing.dart';
import '../../models/team.dart';
import '../../utils/atl_colors.dart';
import '../../widgets/loading_atl.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../teams/team_screen.dart';
import '../profile_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
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
  late final AccountProvider userProvider = Provider.of<AccountProvider>(
    context,
    listen: false,
  );
  late final Account user = userProvider.activeAccount!;
  late final int? teamId = userProvider.currentTeamId;
  late final int playerId = userProvider.activeRoleId!;
  late final SportCategory _currentSport =
      userProvider.selectedSportCategory ?? SportCategory.football;

  List<Tournament>? _activeTournaments;
  Map<int, int> _minutesRoundPerTournament = {};
  Map<int, int> _minutesPausePerTournament = {};
  Map<int, List<FootballMatch>> _matchesPerTournament = {};
  Map<int, List<FootballStanding>> _standingsPerTournament = {};
  Map<int, String> _usernamePerBooking = {};
  Map<int, Field> _fieldCache = {};

  Map<int, int> _maxPlayersPerLobby = {};
  Map<int, int> _currentPlayersPerLobby = {};
  Map<int, int> _playersPaidPerBooking = {};
  Map<int, String> _completeAddressPerField = {};

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
      final PlayerHomeResponse playerHomeData =
          await HomeScreenController.getPlayerHomeScreen(_currentSport);

      List<dynamic> bookings = [];
      bookings.addAll(playerHomeData.privateBookings);
      bookings.addAll(playerHomeData.lobbies);

      bookings.sort((a, b) {
        DateTime aStart;
        DateTime bStart;
        DateTime aCreated;
        DateTime bCreated;

        aStart = a.startTime;
        bStart = b.startTime;
        aCreated = a.createdAt;
        bCreated = b.createdAt;

        if (aStart != bStart) {
          return aStart.compareTo(bStart);
        }
        return aCreated.compareTo(bCreated);
      });

      if (mounted) {
        setState(() {
          _bookings = bookings;
          _activeTournaments = playerHomeData.activeTournaments;
          _minutesRoundPerTournament = playerHomeData.minutesRoundPerTournament;
          _minutesPausePerTournament = playerHomeData.minutesPausePerTournament;
          _matchesPerTournament = playerHomeData.footballMatchesPerTournament;
          _standingsPerTournament =
              playerHomeData.footballStandingsPerTournament;
          _teamsCache = playerHomeData.teamsCache;
          _userTeam = playerHomeData.accountTeam;
          _usernamePerBooking = playerHomeData.usernamePerBooking;
          _fieldCache = playerHomeData.fieldsCache;
          _maxPlayersPerLobby = playerHomeData.maxPlayersPerLobby;
          _currentPlayersPerLobby = playerHomeData.currentPlayersPerLobby;
          _completeAddressPerField = playerHomeData.completeAddressPerField;
          _playersPaidPerBooking = playerHomeData.playersPaidPerBooking;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // ✓ FIX: Usa addPostFrameCallback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(context).errorLoadingData(e.toString()),
                ),
              ),
            );
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
    final l10n = AppLocalizations.of(context);
    // TODO: Riabilitare quando ci saranno più sport
    // Per ora mostra solo un messaggio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.otherSportsComingSoon),
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
    final l10n = AppLocalizations.of(context);
    // Calcola il numero totale di pagine (tornei + 1 pagina booking + pagina "need more")
    final tournamentsCount = _activeTournaments?.length ?? 0;
    final bookingsCount = _bookings.length;
    final hasBookings = bookingsCount > 0;
    final totalPages =
        tournamentsCount +
        (hasBookings ? 1 : 0) +
        1; // tornei + bookings page + need more
    final isOnNeedMorePage =
        _currentPage >= (tournamentsCount + (hasBookings ? 1 : 0));

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
                      builder: (context) =>
                          BookFieldScreen(sportCategory: _currentSport),
                    ),
                  );

                  // Se è stata creata una prenotazione, ricarica i dati
                  if (result == true) {
                    await _loadPlayerData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.fieldBookedSuccessfully)),
                      );
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: ATLColors.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stadium, color: Colors.white, size: 18),
                      SizedBox(height: 2),
                      Text(
                        l10n.bookAField,
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
        title: Text(
          l10n.home,
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
      body: _isLoading ? const LoadingATL() : _buildPlayerHomeContent(),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
        userId: user.id,
      ),
    );
  }

  Widget _buildPlayerHomeContent() {
    final tournamentsCount = _activeTournaments?.length ?? 0;
    final bookingsCount = _bookings.length;
    final hasBookings = bookingsCount > 0;
    final totalPages =
        tournamentsCount +
        (hasBookings ? 1 : 0) +
        1; // tornei + bookings page + need more

    return Column(
      children: [
        // Tournament name header / Booking header / "Need more?" header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            _getPageTitle(context),
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
                    matches: _matchesPerTournament[tournament.id] ?? [],
                    standings: _standingsPerTournament[tournament.id] ?? [],
                    teamsCache: _teamsCache,
                    userTeam: _userTeam,
                    sportCategory: _currentSport,
                    minutesPerRound: _minutesRoundPerTournament[tournament.id]!,
                    minutesPerPause: _minutesPausePerTournament[tournament.id]!,
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

  String _getPageTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tournamentsCount = _activeTournaments?.length ?? 0;
    final bookingsCount = _bookings.length;
    final hasBookings = bookingsCount > 0;

    if (_currentPage < tournamentsCount) {
      return _activeTournaments![_currentPage].name.toUpperCase();
    } else if (hasBookings && _currentPage == tournamentsCount) {
      return l10n.bookings;
    } else {
      return l10n.needMore;
    }
  }

  Widget _buildBookingsPage() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        itemCount: _bookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          final isPrivate = booking is PrivateBooking;
          final bookingId = isPrivate
              ? booking.id
              : (booking as LobbyBooking).id;
          return BookingWidget(
            key: ValueKey('${isPrivate ? 'private' : 'lobby'}_$bookingId'),
            field: _fieldCache[booking.fieldId]!,
            completeAddress:
                _completeAddressPerField[booking.fieldId] ??
                l10n.unknownAddress,
            booking: booking,
            startTime: isPrivate
                ? booking.startTime
                : (booking as LobbyBooking).startTime,
            finishTime: isPrivate
                ? booking.finishTime
                : (booking as LobbyBooking).finishTime,
            ownerUsername: isPrivate ? null : _usernamePerBooking[bookingId],
            currentSport: _currentSport,
            playersPaid: isPrivate
                ? null
                : _playersPaidPerBooking[bookingId] ?? 0,
            onBookingDeleted: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _loadPlayerData();
                }
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildNeedMorePage() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: ATLColors.getPrimaryColor(_currentSport),
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.lookingForMorePassion,
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
                      builder: (context) =>
                          BookFieldScreen(sportCategory: _currentSport),
                    ),
                  );

                  // Se è stata creata una prenotazione, ricarica i dati
                  if (result == true) {
                    await _loadPlayerData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.bookingCreatedSuccessfully),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.stadium, size: 28),
                label: Text(
                  l10n.bookAField,
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
                label: Text(
                  l10n.browseTournaments,
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
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) =>
                              JoinLobbyScreen(sportCategory: _currentSport),
                        ),
                      )
                      .then((_) => _loadPlayerData());
                },
                icon: const Icon(Icons.groups, size: 28),
                label: Text(
                  l10n.joinLobby,
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
                    side: BorderSide(
                      color: ATLColors.getPrimaryColor(_currentSport),
                      width: 2,
                    ),
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
