import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/player_coordinator_bottom_bar.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/atl_button.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import '../utils/navigation_helper.dart';
import 'login_screen.dart';
import 'profile_screens/wallet_screen.dart';
import 'profile_screens/achievement_screen.dart';
import 'profile_screens/edit_infos_screen.dart';
import 'profile_screens/orders_screen.dart';
import 'profile_screens/stats_screen.dart';
import 'profile_screens/settings_screen.dart';
import 'profile_screens/contact_us_screen.dart';

class ProfileScreen extends StatelessWidget {
  final SportCategory currentSport;

  const ProfileScreen({super.key, required this.currentSport});

  Future<void> _handleLogOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).activeUser;

    // Add null check
    if (user == null) {
      return Scaffold(
        backgroundColor: ATLColors.background,
        body: Center(
          child: CircularProgressIndicator(color: currentSport.primaryColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          // Header con avatar e username
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: ATLColors.darkBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          color: Colors.white.withOpacity(0.7),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dark',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Hi ${user.username}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Menu items
          Expanded(
            child: Container(
              color: ATLColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    ProfileMenuItem(
                      icon: Icons.account_balance_wallet,
                      text: 'Wallet',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WalletScreen(currentSport: currentSport),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.emoji_events,
                      text: 'Achievement',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AchievementScreen(currentSport: currentSport),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.edit,
                      text: 'Edit infos',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditInfosScreen(currentSport: currentSport),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.local_shipping,
                      text: 'Orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrdersScreen(currentSport: currentSport),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.bar_chart,
                      text: 'Stats',
                      badge: 'VIP',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StatsScreen(currentSport: currentSport),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.settings,
                      text: 'Settings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SettingsScreen(currentSport: currentSport),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.mail,
                      text: 'Contact Us!',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ContactUsScreen(currentSport: currentSport),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Logout button
                    ATLButton(
                      text: 'Logout',
                      size: ATLButtonSize.large,
                      isFilled: true,
                      color: ATLColors.darkBlue,
                      fullWidth: true,
                      onPressed: () async {
                        await _handleLogOut(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 3,
        onTap: (index) {
          NavigationHelper.navigateToSection(
            context: context,
            index: index,
            currentSport: currentSport,
            currentIndex: 3,
          );
        },
        currentSport: currentSport,
        isHome: false,
      ),
    );
  }
}
