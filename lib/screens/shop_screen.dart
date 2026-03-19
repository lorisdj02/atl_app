import 'package:atl_app/widgets/organization_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/referee_bottom_bar.dart';
import '../providers/account_provider.dart';
import '../widgets/player_coordinator_bottom_bar.dart';
import '../models/sport_category.dart';
import '../utils/atl_colors.dart';
import '../utils/navigation_helper.dart';
import '../l10n/app_localizations.dart';

class ShopScreen extends StatelessWidget {
  final SportCategory currentSport;

  const ShopScreen({super.key, required this.currentSport});

  @override
  Widget build(BuildContext context) {
    final AccountProvider userProvider = Provider.of<AccountProvider>(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          l10n.shopTitle,
          style: const TextStyle(
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
                  Icons.shopping_cart,
                  color: ATLColors.getPrimaryColor(currentSport),
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.shopLabel,
                  style: TextStyle(
                    color: ATLColors.darkBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.shopComingSoon,
                  style: TextStyle(color: ATLColors.subtext, fontSize: 16),
                ),
                if (userProvider.isGuest) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.loginToPurchase,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Banner guest mode
          if (userProvider.isGuest)
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
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.guestLoginRequired,
                        style: TextStyle(
                          color: Colors.orange.shade900,
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
      bottomNavigationBar:
          userProvider.isCoordinator ||
              userProvider.isPlayer ||
              userProvider.isGuest
          ? PlayerCoordinatorBottomBar(
              currentIndex: 0,
              onTap: (index) {
                NavigationHelper.navigateToSection(
                  context: context,
                  index: index,
                  currentSport: currentSport,
                  currentIndex: 0,
                );
              },
              currentSport: currentSport,
              isHome: false,
              userId: userProvider.activeAccount?.id,
            )
          : userProvider.isReferee
          ? RefereeBottomBar(
              currentIndex: 0,
              onTap: (index) {
                NavigationHelper.navigateToSection(
                  context: context,
                  index: index,
                  currentSport: currentSport,
                  currentIndex: 0,
                );
              },
              currentSport: currentSport,
              isHome: false,
              userId: userProvider.activeAccount?.id,
            )
          : userProvider.isOrganization
          ? OrganizationBottomBar(
              currentIndex: 0,
              onTap: (index) {
                NavigationHelper.navigateToSection(
                  context: context,
                  index: index,
                  currentSport: currentSport,
                  currentIndex: 0,
                );
              },
              currentSport: currentSport,
              isHome: false,
              userId: userProvider.activeAccount?.id,
            )
          : null,
    );
  }
}
