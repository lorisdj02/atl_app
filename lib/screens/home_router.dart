import 'package:atl_app/screens/guest/guest_home_screen.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/player.dart';
import '../models/coordinator.dart';
import '../models/referee.dart';
import '../models/organization.dart';
import 'player/player_home_screen.dart';
import 'coordinator/coordinator_home_screen.dart';
import 'referee/referee_home_screen.dart';
import 'organization/organization_home_screen.dart';
import '../models/sport_category.dart';

class HomeRouter {
  static Widget getHomeScreen(User user) {
    // Il cast è sicuro perché User.fromJson() ritorna già il tipo corretto
    switch (user.role) {
      case UserRole.player:
        return PlayerHomeScreen(user: user as Player, currentSport: SportCategory.football);
      case UserRole.coordinator:
        return CoordinatorHomeScreen(user: user as Coordinator, currentSport: SportCategory.football);
      case UserRole.referee:
        return RefereeHomeScreen(user: user as Referee, currentSport: SportCategory.football);
      case UserRole.organization:
        return OrganizationHomeScreen(user: user as Organization, currentSport: SportCategory.football);
      default:
        return GuestHomeScreen(currentSport: SportCategory.football);
    }
  }
}
