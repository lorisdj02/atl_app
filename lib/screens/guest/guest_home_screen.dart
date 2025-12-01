import 'package:flutter/material.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../team_screen.dart';
import '../guest/guest_profile_screen.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key, required this.currentSport});

  final SportCategory currentSport;

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  SportCategory _currentSport = SportCategory.football;

  void _onNavTap(int index) {
    if (index == 4) {
      _showSportSelector();
    } else {
      Widget screen;
      switch (index) {
        case 0:
          // Shop - può visualizzare ma non acquistare
          screen = ShopScreen(
            currentSport: _currentSport,
          );
          break;
        case 1:
          // Tournaments - può visualizzare
          screen = AllTournamentsScreen(
            currentSport: _currentSport,
          );
          break;
        case 2:
          // Team - può visualizzare
          screen = TeamScreen(
            currentSport: _currentSport,
          );
          break;
        case 3:
          screen = const GuestProfileScreen(currentSport: SportCategory.football);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Guest info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade700,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guest Mode',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Login to access all features',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Today's matches title
          Row(
            children: [
              Icon(
                _currentSport.icon,
                color: _currentSport.primaryColor,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'TODAY\'S MATCHES',
                style: TextStyle(
                  color: ATLColors.subtext,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // TODO: Lista partite del giorno
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
                  color: _currentSport.primaryColor,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'No matches today',
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to follow tournaments!',
                  style: TextStyle(
                    color: ATLColors.title,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
