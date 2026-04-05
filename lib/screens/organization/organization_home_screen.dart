import 'package:atl_app/database/db_read.dart';
import 'package:atl_app/database/responses/organization_home_response.dart';
import 'package:atl_app/models/football_match.dart';
import 'package:atl_app/models/team.dart';
import 'package:atl_app/widgets/organization_booking_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/organization_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../providers/account_provider.dart';
import '../../utils/atl_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/loading_atl.dart';
import '../shop_screen.dart';
import '../../models/field.dart';
import '../profile_screen.dart';
import '../../models/booking.dart';

class OrganizationHomeScreen extends StatefulWidget {
  const OrganizationHomeScreen({super.key});

  @override
  State<OrganizationHomeScreen> createState() => _OrganizationHomeScreenState();
}

class _OrganizationHomeScreenState extends State<OrganizationHomeScreen> {
  late final SportCategory _currentSport = SportCategory.football;

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  List<Field> _fields = [];
  Map<int, String> _cityNamePerField = {};

  Map<int, dynamic> _detailedBookings = {};
  Map<int, FootballMatch> _matchPerBooking = {};
  Map<int, Team> _teamsCache = {};
  Map<int, String> _usernamePerBooking = {};

  Map<DateTime, Map<int, List<Booking>>> _bookingsByFieldByDate = {};

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
      final userProvider = Provider.of<AccountProvider>(context, listen: false);
      final organizationId = userProvider.activeRoleId;

      if (organizationId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final OrganizationHomeResponse organizationData = await DBRead.getOrganizationHomeScreen(
        organizationId: organizationId,
        currentSport: _currentSport,
      );

      Map<int, List<Booking>> bookingsByField = {};

      for (var booking in organizationData.generalBookings) {
        bookingsByField.putIfAbsent(booking.fieldId, () => []).add(booking);
      }

      Map<DateTime, Map<int, List<Booking>>> bookingsByFieldByDate = {};

      for (var entry in bookingsByField.entries) {
        final fieldId = entry.key;
        final bookings = entry.value;

        for (var booking in bookings) {
          final bookingDate = DateTime(
            booking.startTime.year,
            booking.startTime.month,
            booking.startTime.day,
          );

          bookingsByFieldByDate.putIfAbsent(bookingDate, () => {});
          bookingsByFieldByDate[bookingDate]!.putIfAbsent(fieldId, () => []);
          bookingsByFieldByDate[bookingDate]![fieldId]!.add(booking);
        }
      }

      if (mounted) {
        setState(() {
          _fields = organizationData.fields;
          _cityNamePerField = organizationData.cityNamePerField;
          _bookingsByFieldByDate = bookingsByFieldByDate;
          _detailedBookings = {
            ...organizationData.lobbyBookingsCache,
            ...organizationData.privateBookingsCache,
            ...organizationData.matchBookingsCache,
          };
          _matchPerBooking = organizationData.footballMatchPerBooking;
          _usernamePerBooking = organizationData.usernamePerBooking;
          _teamsCache = organizationData.teamsCache;
          _isLoading = false;
        });
      }
    } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
        print('Error loading organization data: $e');
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
      // Already on home, do nothing
      return;
    }

    Widget screen;
    switch (index) {
      case 0:
        screen = ShopScreen(currentSport: _currentSport);
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
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
      body: _buildOrganizationHomeContent(),
      bottomNavigationBar: OrganizationBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
        userId: Provider.of<AccountProvider>(context, listen: false).activeAccount!.id,
      ),
    );
  }

  Widget _buildOrganizationHomeContent() {
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
    final l10n = AppLocalizations.of(context);
    final selectedDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );
    final bookingsByField = _bookingsByFieldByDate[selectedDateOnly] ?? {};

    // Crea una lista piatta di tuple (field, booking) per ListView.builder
    final List<MapEntry<Field?, Booking?>> flatList = [];

    for (var field in _fields) {
      var fieldBookings = bookingsByField[field.id] ?? [];
      if (fieldBookings.isNotEmpty) {
        // Header per il campo
        flatList.add(MapEntry(field, null));
        // Bookings per il campo
        for (var booking in fieldBookings) {
          flatList.add(MapEntry(null, booking));
        }
      }
    }

    if (flatList.isEmpty) {
      
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sports_soccer, size: 64, color: ATLColors.subtext),
              const SizedBox(height: 16),
              Text(
                l10n.noFieldsBooked,
                style: TextStyle(
                  color: ATLColors.darkBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.noBookingsOn(
                  DateFormat.yMMMd(Localizations.localeOf(context).toString())
                      .format(_selectedDate),
                ),
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
      itemCount: flatList.length,
      itemBuilder: (context, index) {
        final entry = flatList[index];
        if (entry.key != null && entry.value == null) {
          // Header campo
          final field = entry.key!;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
            child: Text(
              "${field.name} (${_cityNamePerField[field.cityId] ?? l10n.unknown})",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ATLColors.title,
              ),
            ),
          );
        } else if (entry.value != null) {
          // Booking
          final booking = entry.value!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 0, right: 0),
            child: booking.type == BookingType.lobby
                ? OrganizationBookingWidget(
                    key: ValueKey(booking.id),
                    booking: booking,
                    field: _fields.firstWhere((f) => f.id == booking.fieldId),
                    currentSport: _currentSport,
                    lobbyBooking: _detailedBookings[booking.id],
                    playerString: _usernamePerBooking[booking.id],
                  )
                : booking.type == BookingType.match
                ? OrganizationBookingWidget(
                    key: ValueKey(booking.id),
                    booking: booking,
                    field: _fields.firstWhere((f) => f.id == booking.fieldId),
                    currentSport: _currentSport,
                    matchBooking: _detailedBookings[booking.id],
                    homeTeam:
                        _teamsCache[_matchPerBooking[booking.id]?.homeTeamId],
                    awayTeam:
                        _teamsCache[_matchPerBooking[booking.id]?.awayTeamId],
                    coordinatorString: _usernamePerBooking[booking.id],
                  )
                : booking.type == BookingType.private
                ? OrganizationBookingWidget(
                    key: ValueKey(booking.id),
                    booking: booking,
                    field: _fields.firstWhere((f) => f.id == booking.fieldId),
                    currentSport: _currentSport,
                    privateBooking: _detailedBookings[booking.id],
                    coordinatorString: _usernamePerBooking[booking.id],
                    playerString: _usernamePerBooking[booking.id],
                  )
                : const SizedBox.shrink(),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
