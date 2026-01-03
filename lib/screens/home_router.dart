import 'package:atl_app/screens/guest/guest_home_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import 'player/player_home_screen.dart';
import 'coordinator/coordinator_home_screen.dart';
import 'referee/referee_home_screen.dart';
import 'organization/organization_home_screen.dart';

class HomeRouter {
  static Widget getHomeScreen(User user) {
    // Il cast è sicuro perché User.fromJson() ritorna già il tipo corretto
    switch (user.role) {
      case UserRole.player:
        return PlayerHomeScreen();
      case UserRole.coordinator:
        return CoordinatorHomeScreen();
      case UserRole.referee:
        return RefereeHomeScreen();
      case UserRole.organization:
        return OrganizationHomeScreen();
      default:
        return GuestHomeScreen();
    }
  }
}
