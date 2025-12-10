import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/sport_category.dart';
class UserProvider with ChangeNotifier {
  User? _activeUser;
  int? _currentTeamId;
  int? _roleId;
  SportCategory? _selectedSportCategory = SportCategory.football;

  User? get activeUser => _activeUser;
  int? get currentTeamId => _currentTeamId;
  int? get activeRoleId => _roleId;
  SportCategory? get selectedSportCategory => _selectedSportCategory;

  void setActiveUser(User user, {int? roleId}) {
    _activeUser = user;
    _roleId = roleId;
    notifyListeners();
  }

  void clearActiveUser() {
    _activeUser = null;
    _roleId = null;
    _currentTeamId = null;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _activeUser = updatedUser;
    notifyListeners();
  }

  void setCurrentTeamId(int teamId) {
    if(teamId != -1){
      _currentTeamId = teamId;
      notifyListeners();
    }
  }

  void clearCurrentTeamId() {
    _currentTeamId = null;
    notifyListeners();
  }

  void logout() {
    clearCurrentTeamId();
    clearActiveUser();
  }

  bool get isGuest => _activeUser?.role == UserRole.guest;

  bool get isPlayer => _activeUser?.role == UserRole.player;

  bool get isCoordinator => _activeUser?.role == UserRole.coordinator;

  bool get isOrganization => _activeUser?.role == UserRole.organization;

}