import 'package:flutter/material.dart';
import '../../widgets/player_coordinator_bottom_bar.dart';
import '../../models/enums/sport_category.dart';
import '../../utils/atl_colors.dart';
import '../../l10n/app_localizations.dart';
import '../shop_screen.dart';
import '../tournaments/all_tournaments_screen.dart';
import '../teams/team_screen.dart';
import '../guest/guest_profile_screen.dart';
import '../../providers/account_provider.dart';
import 'package:provider/provider.dart';

class GuestHomeScreen extends StatefulWidget {
  const GuestHomeScreen({super.key});

  @override
  State<GuestHomeScreen> createState() => _GuestHomeScreenState();
}

class _GuestHomeScreenState extends State<GuestHomeScreen> {
  late final AccountProvider userProvider = Provider.of<AccountProvider>(
    context,
    listen: false,
  );
  late final SportCategory _currentSport =
      userProvider.selectedSportCategory ?? SportCategory.football;

  void _onNavTap(int index) {
    if (index == 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).otherSportsComingSoon),
          duration: const Duration(seconds: 2),
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: ATLColors.background,
      appBar: AppBar(
        backgroundColor: ATLColors.darkBlue,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          l10n.welcomeToAtl,
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
            Text(
              l10n.chooseYourRole,
              style: TextStyle(
                color: ATLColors.darkBlue,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildRoles(l10n).map((role) => _buildRoleCard(role, color)),
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
    final l10n = AppLocalizations.of(context);
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
                    Text(
                      l10n.amateurTournamentsLeague,
                      style: const TextStyle(
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
          Text(
            l10n.guestHomeDescription,
            style: const TextStyle(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open, color: color, size: 14),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.browseAsGuestHint,
                    style: TextStyle(color: color, fontSize: 11),
                    softWrap: true,
                  ),
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

  List<_RoleInfo> _buildRoles(AppLocalizations l10n) {
    return [
      _RoleInfo(
        title: l10n.player,
        icon: Icons.person,
        description: l10n.guestRolePlayerDesc,
        features: [
          l10n.guestRolePlayerFeature1,
          l10n.guestRolePlayerFeature2,
          l10n.guestRolePlayerFeature3,
        ],
      ),
      _RoleInfo(
        title: l10n.coordinator,
        icon: Icons.groups,
        description: l10n.guestRoleCoordinatorDesc,
        features: [
          l10n.guestRoleCoordinatorFeature1,
          l10n.guestRoleCoordinatorFeature2,
          l10n.guestRoleCoordinatorFeature3,
        ],
      ),
      _RoleInfo(
        title: l10n.referee,
        icon: Icons.sports,
        description: l10n.guestRoleRefereeDesc,
        features: [
          l10n.guestRoleRefereeFeature1,
          l10n.guestRoleRefereeFeature2,
          l10n.guestRoleRefereeFeature3,
        ],
      ),
      _RoleInfo(
        title: l10n.organization,
        icon: Icons.business,
        description: l10n.guestRoleOrganizationDesc,
        features: [
          l10n.guestRoleOrganizationFeature1,
          l10n.guestRoleOrganizationFeature2,
          l10n.guestRoleOrganizationFeature3,
        ],
      ),
    ];
  }
}

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
