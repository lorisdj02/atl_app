import 'package:flutter/material.dart';
import '../models/sport_type.dart';
import '../models/user_info.dart';
import '../screens/shop_screen.dart';
import '../screens/tournaments_screen.dart';
import '../screens/team_screen.dart';
import '../screens/profile_screen.dart';

class NavigationHelper {
  /// Naviga alla sezione specificata dalla bottom bar
  static void navigateToSection({
    required BuildContext context,
    required int index,
    required SportType currentSport,
    required UserInfo userInfo,
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
          userInfo: userInfo,
        );
        break;
      case 1: // Tournaments
        targetScreen = TournamentsScreen(
          currentSport: currentSport,
          userInfo: userInfo,
        );
        break;
      case 2: // Team
        targetScreen = TeamScreen(
          currentSport: currentSport,
          userInfo: userInfo,
        );
        break;
      case 3: // Profile
        targetScreen = ProfileScreen(
          currentSport: currentSport,
          userInfo: userInfo,
        );
        break;
      case 4: // Home
        // Torna alla home rimuovendo tutte le schermate intermedie
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      default:
        return;
    }

    // Se siamo già in una sezione, sostituisci invece di pushare
    if (currentIndex != 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    } else {
      // Se siamo nella home, pusha normalmente
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    }
  }
}
