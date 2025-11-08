import 'package:flutter/material.dart';
import '../widgets/player_coordinator_bottom_bar.dart';
import '../models/sport_category.dart';
import '../models/user.dart';
import '../utils/atl_colors.dart';
import '../utils/navigation_helper.dart';

class TeamScreen extends StatelessWidget {
  final SportCategory currentSport;
  final User? user; // null se guest

  const TeamScreen({
    super.key,
    required this.currentSport,
    required this.user,
  });

  bool get _isGuest => user == null;

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
          'TEAM',
          style: TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group,
                  color: currentSport.primaryColor,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  'Team',
                  style: TextStyle(
                    color: ATLColors.darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coming soon',
                  style: TextStyle(
                    color: ATLColors.subtext,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Guest mode banner
          if (_isGuest)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Guest mode: Login to create/join teams',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 2,
        onTap: (index) {
          NavigationHelper.navigateToSection(
            context: context,
            index: index,
            currentSport: currentSport,
            user: user, // Può essere null
            currentIndex: 2,
          );
        },
        currentSport: currentSport,
        isHome: false,
      ),
    );
  }
}
