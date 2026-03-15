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

  void _onNavTap(int index) {
    if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Other sports coming soon! Football only for now.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    final color = ATLColors.getPrimaryColor(_currentSport);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'WELCOME TO ATL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroCard(color),
            const SizedBox(height: 28),
            const Text(
              'CHOOSE YOUR ROLE',
              style: TextStyle(
                color: ATLColors.darkBlue,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ..._roles.map((role) => _buildRoleCard(role, color)),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 4,
        onTap: _onNavTap,
        currentSport: _currentSport,
        isHome: true,
      ),
    );
  }

  Widget _buildHeroCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ATLColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Icon(
                  _currentSport.icon,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATL',
                      style: TextStyle(
                        color: color,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const Text(
                      'Amateur Tournaments League',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'The platform for amateur sports. Find matches, join tournaments, book fields and grow your athletic career — all in one place.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open, color: color, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Browse as guest — register to unlock all features',
                  style: TextStyle(color: color, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(_RoleInfo role, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(role.icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.title.toUpperCase(),
                    style: const TextStyle(
                      color: ATLColors.darkBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role.description,
                    style: const TextStyle(
                      color: ATLColors.subtext,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...role.features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: color, size: 13),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                color: ATLColors.subtext,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _roles = [
  _RoleInfo(
    title: 'Player',
    icon: Icons.person,
    description: 'Play, grow and connect with your teammates.',
    features: [
      'Book fields at your favourite venues',
      'Join or create amateur teams',
      'Participate in ranked tournaments',
    ],
  ),
  _RoleInfo(
    title: 'Coordinator',
    icon: Icons.groups,
    description: 'Organise and run tournaments end-to-end.',
    features: [
      'Create and manage tournaments',
      'Schedule matches and brackets',
      'Coordinate teams and venues',
    ],
  ),
  _RoleInfo(
    title: 'Referee',
    icon: Icons.sports,
    description: 'Officiate matches and track your career.',
    features: [
      'Receive match officiating assignments',
      'Report match events in real time',
      'Track earnings and schedule',
    ],
  ),
  _RoleInfo(
    title: 'Organization',
    icon: Icons.business,
    description: 'Manage your club, venues and events.',
    features: [
      'List and manage your fields',
      'Handle memberships and events',
      'Oversee all club activities',
    ],
  ),
];

class _RoleInfo {
  final String title;
  final IconData icon;
  final String description;
  final List<String> features;

  const _RoleInfo({
    required this.title,
    required this.icon,
    required this.description,
    required this.features,
  });
}
