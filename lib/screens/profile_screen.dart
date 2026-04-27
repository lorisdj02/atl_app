import 'package:atl_app/database/controller/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/account_provider.dart';
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
import '../widgets/referee_bottom_bar.dart';
import '../widgets/organization_bottom_bar.dart';
import 'referee/referee_licenses_screen.dart';
import 'profile_screens/reviews_screen.dart';
import 'profile_screens/invite_friends_screen.dart';
import 'profile_screens/my_growth_screen.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  final SportCategory currentSport;

  const ProfileScreen({super.key, required this.currentSport});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? _level;

  @override
  void initState() {
    super.initState();
    _loadLevel();
  }

  Future<void> _loadLevel() async {
    final userProvider = Provider.of<AccountProvider>(context, listen: false);
    if (userProvider.isCoordinator || userProvider.isReferee) {
      try{
      final int level = await AccountController.Read.getAccountLevel();
      if (mounted) {
        setState(() {
          _level = level;
        });
      }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).errorGeneric(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleLogOut(BuildContext context) async {
    await Provider.of<AccountProvider>(context, listen: false).logout();

    // Naviga direttamente alla LoginScreen senza animazioni
    // e rimuove tutte le route precedenti dallo stack
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionDuration: Duration.zero, // Nessuna animazione
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false, // Rimuove tutte le route precedenti
    );
  }

  @override
  Widget build(BuildContext context) {
    final AccountProvider userProvider = Provider.of<AccountProvider>(context);
    final user = userProvider.activeAccount;
    final l10n = AppLocalizations.of(context);

    // Add null check
    if (user == null) {
      return Scaffold(
        backgroundColor: ATLColors.background,
        body: Center(
          child: CircularProgressIndicator(
            color: ATLColors.getPrimaryColor(widget.currentSport),
          ),
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
                          l10n.dark,
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
                      l10n.hiUser(user.username),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (userProvider.isReferee ||
                        userProvider.isCoordinator) ...[
                      const SizedBox(height: 8),
                      Text(
                        _level != null
                            ? l10n.levelLabel(_level!)
                            : l10n.loadingLevel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
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
                    if (!userProvider.isOrganization) ...[
                      ProfileMenuItem(
                        icon: Icons.emoji_events,
                        text: l10n.achievement,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AchievementScreen(
                                currentSport: widget.currentSport,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    ProfileMenuItem(
                      icon: Icons.account_balance_wallet,
                      text: l10n.wallet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WalletScreen(currentSport: widget.currentSport),
                          ),
                        );
                      },
                    ),
                    if (!userProvider.isOrganization) ...[
                      ProfileMenuItem(
                        icon: Icons.rate_review,
                        text: l10n.reviews,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(
                              currentSport: widget.currentSport,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (userProvider.isReferee) ...[
                      ProfileMenuItem(
                        icon: Icons.school,
                        text: l10n.licenses,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RefereeLicensesScreen(
                                currentSport: widget.currentSport,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (userProvider.isReferee || userProvider.isCoordinator) ...[
                      ProfileMenuItem(
                        icon: Icons.trending_up,
                        text: l10n.myGrowth,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyGrowthScreen(
                              currentSport: widget.currentSport,
                            ),
                          ),
                        ),
                      ),
                    ],
                    ProfileMenuItem(
                      icon: Icons.local_shipping,
                      text: l10n.orders,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                OrdersScreen(currentSport: widget.currentSport),
                          ),
                        );
                      },
                    ),
                    if (userProvider.isPlayer) ...[
                      ProfileMenuItem(
                        icon: Icons.bar_chart,
                        text: l10n.stats,
                        badge: l10n.vipBadge,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatsScreen(
                                currentSport: widget.currentSport,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    if (!userProvider.isOrganization) ...[
                      ProfileMenuItem(
                        icon: Icons.share,
                        text: l10n.inviteAFriend,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InviteFriendsScreen(
                              currentSport: widget.currentSport,
                            ),
                          ),
                        ),
                      ),
                    ],
                    ProfileMenuItem(
                      icon: Icons.edit,
                      text: l10n.editInfos,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditInfosScreen(
                              currentSport: widget.currentSport,
                            ),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.settings,
                      text: l10n.settings,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(
                              currentSport: widget.currentSport,
                            ),
                          ),
                        );
                      },
                    ),
                    ProfileMenuItem(
                      icon: Icons.mail,
                      text: l10n.contactUsMenuItem,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactUsScreen(
                              currentSport: widget.currentSport,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Logout button
                    ATLButton(
                      text: l10n.logout,
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
      bottomNavigationBar: userProvider.isCoordinator || userProvider.isPlayer
          ? PlayerCoordinatorBottomBar(
              currentIndex: 3,
              onTap: (index) {
                NavigationHelper.navigateToSection(
                  context: context,
                  index: index,
                  currentSport: widget.currentSport,
                  currentIndex: 3,
                );
              },
              currentSport: widget.currentSport,
              isHome: false,
              userId: user.id,
            )
          : userProvider.isReferee
          ? RefereeBottomBar(
              currentIndex: 3,
              onTap: (index) {
                NavigationHelper.navigateToSection(
                  context: context,
                  index: index,
                  currentSport: widget.currentSport,
                  currentIndex: 3,
                );
              },
              currentSport: widget.currentSport,
              isHome: false,
              userId: user.id,
            )
          : userProvider.isOrganization
          ? OrganizationBottomBar(
              currentIndex: 3,
              onTap: (index) {
                NavigationHelper.navigateToSection(
                  context: context,
                  index: index,
                  currentSport: widget.currentSport,
                  currentIndex: 3,
                );
              },
              currentSport: widget.currentSport,
              isHome: false,
              userId: user.id,
            )
          : null,
    );
  }
}
