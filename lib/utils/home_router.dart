import 'package:atl_app/screens/guest/guest_home_screen.dart';
import 'package:flutter/material.dart';
import '../models/account.dart';
import '../screens/player/player_home_screen.dart';
import '../screens/coordinator/coordinator_home_screen.dart';
import '../screens/referee/referee_home_screen.dart';
import '../screens/organization/organization_home_screen.dart';

class HomeRouter {
  static Widget getHomeScreen(Account user) {
    // Il cast è sicuro perché Account.fromJson() ritorna già il tipo corretto
    switch (user.role) {
      case AccountRole.guest:
        return GuestHomeScreen();
      case AccountRole.player:
        return PlayerHomeScreen();
      case AccountRole.coordinator:
        return CoordinatorHomeScreen();
      case AccountRole.referee:
        return RefereeHomeScreen();
      case AccountRole.organization:
        return OrganizationHomeScreen();
      default:
        return GuestHomeScreen(); // Fallback per sicurezza
    }
  }
}
