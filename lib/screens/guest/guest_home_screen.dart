import 'package:flutter/material.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../teams/team_screen.dart';
import '../guest/guest_profile_screen.dart';
import '../../providers/user_provider.dart';
import 'package:provider/provider.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  late final UserProvider userProvider = Provider.of<UserProvider>(
    context,
    listen: false,
  );
  late final SportCategory _currentSport =
      userProvider.selectedSportCategory ?? SportCategory.football;

  int _currentPage = 0;
  final List<String> _roles = [
    'Player',
    'Coordinator',
    'Referee',
    'Organization',
  ];

  final Map<String, String> _roleDescriptions = {
    'Player': 'Join matches, book fields, and connect with teammates.',
    'Coordinator':
        'Create and manage tournaments, schedule matches, and coordinate teams.',
    'Referee': 'Manage match officiating, report events, and access schedules.',
    'Organization': 'Oversee clubs and venues, manage memberships and events.',
  };

  void _onNavTap(int index) {
    if (index == 4) {
      _showSportSelector();
    } else {
      Widget screen;
      switch (index) {
        case 0:
          // Shop - può visualizzare ma non acquistare
          screen = ShopScreen(currentSport: _currentSport);
          break;
        case 1:
          // Tournaments - può visualizzare
          screen = AllTournamentsScreen(currentSport: _currentSport);
          break;
        case 2:
          // Team - può visualizzare
          screen = TeamScreen(currentSport: _currentSport);
          break;
        case 3:
          screen = const GuestProfileScreen(
            currentSport: SportCategory.football,
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Other sports coming soon! Football only for now.'),
        duration: Duration(seconds: 2),
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
          'WELCOME TO ATL',
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
      body: _buildGuestHomeContent(),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
      ),
    );
  }

  Widget _buildGuestHomeContent() {
    return Column(
      children: [
        const SizedBox(height: 24),

        // Page indicators (pallini)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_roles.length, (index) {
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

        // Slideshow
        Expanded(
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _roles.length,
            itemBuilder: (context, index) {
              return _buildRoleSlide(_roles[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSlide(String role) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icona del ruolo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ATLColors.getPrimaryColor(_currentSport).withOpacity(0.1),
            ),
            child: Icon(
              _getRoleIcon(role),
              size: 64,
              color: ATLColors.getPrimaryColor(_currentSport),
            ),
          ),

          const SizedBox(height: 32),

          // Nome del ruolo
          Text(
            role.toUpperCase(),
            style: const TextStyle(
              color: ATLColors.title,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 16),

          // Spazio riservato per la descrizione (vuoto per ora)
          Container(
            height: 96,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _roleDescriptions[role] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: ATLColors.subtext, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Player':
        return Icons.person;
      case 'Coordinator':
        return Icons.groups;
      case 'Referee':
        return Icons.sports;
      case 'Organization':
        return Icons.business;
      default:
        return Icons.info;
    }
  }
}
