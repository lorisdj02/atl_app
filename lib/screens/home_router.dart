import 'package:flutter/material.dart';
import '../models/user_info.dart';
import 'player/player_home_screen.dart';
import 'coordinator/coordinator_home_screen.dart';
import 'referee/referee_home_screen.dart';
import 'organization/organization_home_screen.dart';

class HomeRouter {
  static Widget getHomeScreen(UserInfo userInfo) {
    switch (userInfo.role) {
      case UserRole.player:
        return PlayerHomeScreen(userInfo: userInfo);
      case UserRole.coordinator:
        return CoordinatorHomeScreen(userInfo: userInfo);
      case UserRole.referee:
        return RefereeHomeScreen(userInfo: userInfo);
      case UserRole.organization:
        return OrganizationHomeScreen(userInfo: userInfo);
    }
  }
}
