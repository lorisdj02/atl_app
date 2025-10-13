import 'package:flutter/material.dart';
import '../widgets/player_coordinator_bottom_bar.dart';
import '../models/sport_type.dart';
import '../models/user_info.dart';
import '../utils/atl_colors.dart';
import '../utils/navigation_helper.dart';

class ShopScreen extends StatelessWidget {
  final SportType currentSport;
  final UserInfo userInfo;

  const ShopScreen({
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
          'SHOP',
          style: TextStyle(
            color: ATLColors.title,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              color: currentSport.primaryColor,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Shop',
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
      bottomNavigationBar: PlayerCoordinatorBottomBar(
        currentIndex: 0,
        onTap: (index) {
          NavigationHelper.navigateToSection(
            context: context,
            index: index,
            currentSport: currentSport,
            userInfo: userInfo,
            currentIndex: 0,
          );
        },
        currentSport: currentSport,
        isHome: false,
      ),
    );
  }
}
