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

  Future<void> setActiveUser(User user, {int? roleId}) async {
    _activeUser = user;
    _roleId = roleId;
    notifyListeners();
  }

  Future<void> clearActiveUser() async {
    _activeUser = null;
    _roleId = null;
    _currentTeamId = null;
    notifyListeners();
  }

  Future<void> updateUser(User updatedUser) async {
    _activeUser = updatedUser;
    notifyListeners();
  }

  Future<void> setCurrentTeamId(int teamId) async {
    if(teamId != -1){
      _currentTeamId = teamId;
      notifyListeners();
    }
  }

  Future<void> clearCurrentTeamId() async {
    _currentTeamId = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await clearCurrentTeamId();
    await clearActiveUser();
  }

  bool get isGuest => _activeUser?.role == UserRole.guest;

  bool get isPlayer => _activeUser?.role == UserRole.player;

  bool get isCoordinator => _activeUser?.role == UserRole.coordinator;

  bool get isOrganization => _activeUser?.role == UserRole.organization;

}