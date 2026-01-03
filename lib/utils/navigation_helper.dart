import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../screens/shop_screen.dart';
import '../screens/tournaments/all_tournaments_screen.dart';
import '../screens/teams/team_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/guest/guest_profile_screen.dart';
import '../screens/guest/guest_home_screen.dart';
import '../screens/home_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class NavigationHelper {
  /// Naviga alla sezione specificata dalla bottom bar
  static void navigateToSection({
    required BuildContext context,
    required int index,
    required SportCategory currentSport,
    required int currentIndex,
  }) {
    // Se clicco sulla sezione corrente, non fare nulla
    if (index == currentIndex && index != 4) {
      return;
    }

    final UserProvider userProvider = Provider.of<UserProvider>(
      context,
      listen: false,
    );
    Widget targetScreen;

    switch (index) {
      case 0: // Shop
        targetScreen = ShopScreen(currentSport: currentSport);
        break;
      case 1: // Tournaments
        targetScreen = AllTournamentsScreen(currentSport: currentSport);
        break;
      case 2: // Team
        targetScreen = TeamScreen(currentSport: currentSport);
        break;
      case 3: // Profile
        if (userProvider.isGuest) {
          targetScreen = GuestProfileScreen(currentSport: currentSport);
        } else {
          targetScreen = ProfileScreen(currentSport: currentSport);
        }
        break;
      case 4: // Home
        // Naviga alla home corretta in base al ruolo
        if (userProvider.isGuest) {
          targetScreen = GuestHomeScreen();
        } else {
          targetScreen = HomeRouter.getHomeScreen(userProvider.activeUser!);
        }

        // Rimuovi tutte le schermate e vai alla home
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                targetScreen,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => false,
        );
        return;
      default:
        return;
    }

    // Se siamo già in una sezione, sostituisci invece di pushare (senza animazione)
    if (currentIndex != 4) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      // Se siamo nella home, pusha normalmente (senza animazione)
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }
}
