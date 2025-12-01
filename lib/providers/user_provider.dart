import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _activeUser;
  int? _currentTeamId;

  User? get activeUser => _activeUser;
  int? get currentTeamId => _currentTeamId;

  void setActiveUser(User user) {
    _activeUser = user;
    notifyListeners();
  }

  void clearActiveUser() {
    _activeUser = null;
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

  //TODO: Aggiungi gli id dei ruoli, così da velocizzare le query sugli ID
}