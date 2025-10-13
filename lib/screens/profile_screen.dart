import 'package:flutter/material.dart';
import '../widgets/player_coordinator_bottom_bar.dart';
import '../models/sport_type.dart';
import '../models/user_info.dart';
import '../utils/atl_colors.dart';
import '../utils/navigation_helper.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final SportType currentSport;
  final UserInfo userInfo;

  const ProfileScreen({
    super.key,
    required this.currentSport,
    required this.userInfo,
  });

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
          'PROFILE',
          style: TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar e info utente
            CircleAvatar(
              radius: 50,
              backgroundColor: currentSport.primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: currentSport.primaryColor,
                size: 60,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              userInfo.username,
              style: const TextStyle(
                color: ATLColors.darkBlue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: currentSport.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                userInfo.roleDisplayName,
                style: TextStyle(
                  color: currentSport.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Info aggiuntive
            if (userInfo.email != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: currentSport.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      userInfo.email!,
                      style: const TextStyle(
                        color: ATLColors.subtext,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            // Logout button (temporary)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement proper logout logic
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ATLColors.darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'More features coming soon',
              style: TextStyle(
                color: ATLColors.subtext,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 3,
        onTap: (index) {
          NavigationHelper.navigateToSection(
            context: context,
            index: index,
            currentSport: currentSport,
            userInfo: userInfo,
            currentIndex: 3,
          );
        },
        currentSport: currentSport,
        isHome: false,
      ),
    );
  }
}
