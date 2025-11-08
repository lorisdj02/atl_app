import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import '../models/user.dart';
import '../screens/shop_screen.dart';
import '../screens/tournaments_screen.dart';
import '../screens/team_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/guest/guest_profile_screen.dart';
import '../screens/guest/guest_home_screen.dart';
/*
import '../screens/coordinator/coordinator_home_screen.dart';
import '../screens/organization/organization_home_screen.dart';
import '../screens/player/player_home_screen.dart';
import '../screens/referee/referee_home_screen.dart';
import '../models/coordinator.dart';
import '../models/player.dart';
import '../models/referee.dart';
import '../models/organization.dart';
*/
import '../screens/home_router.dart';


class NavigationHelper {
  /// Naviga alla sezione specificata dalla bottom bar
  static void navigateToSection({
    required BuildContext context,
    required int index,
    required SportCategory currentSport,
    required User? user,
    required int currentIndex,
  }) {
    // Se clicco sulla sezione corrente, non fare nulla
    if (index == currentIndex && index != 4) {
      return;
    }

    Widget targetScreen;

    switch (index) {
      case 0: // Shop
        targetScreen = ShopScreen(
          currentSport: currentSport,
          user: user,
        );
        break;
      case 1: // Tournaments
        targetScreen = TournamentsScreen(
          currentSport: currentSport,
          user: user,
        );
        break;
      case 2: // Team
        targetScreen = TeamScreen(
          currentSport: currentSport,
          user: user,
        );
        break;
      case 3: // Profile
        if (user == null) {
          targetScreen = GuestProfileScreen(currentSport: currentSport);
        } else {
          targetScreen = ProfileScreen(
            currentSport: currentSport,
            user: user,
          );
        }
        break;
      case 4: // Home
        // Naviga alla home corretta in base al ruolo
        if (user == null) {
          targetScreen = GuestHomeScreen(currentSport: currentSport);
        } else {/*
          switch (user.role) {
            case UserRole.coordinator:
              targetScreen = CoordinatorHomeScreen(
                currentSport: currentSport,
                user: user as Coordinator,
              );
              break;
            case UserRole.player:
              targetScreen = PlayerHomeScreen(
                currentSport: currentSport,
                user: user as Player,
              );
              break;
            case UserRole.referee:
              targetScreen = RefereeHomeScreen(
                currentSport: currentSport,
                user: user as Referee,
              );
              break;
            case UserRole.organization:
              targetScreen = OrganizationHomeScreen(
                currentSport: currentSport,
                user: user as Organization,
              );
              break;
          }*/
          targetScreen = HomeRouter.getHomeScreen(user);
        }

        // Rimuovi tutte le schermate e vai alla home
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
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
