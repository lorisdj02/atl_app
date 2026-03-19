import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/sport_category.dart';

class AccountProvider with ChangeNotifier {
  Account? _activeAccount;
  int? _currentTeamId;
  int? _roleId;
  SportCategory? _selectedSportCategory = SportCategory.football;

  Account? get activeAccount => _activeAccount;
  int? get currentTeamId => _currentTeamId;
  int? get activeRoleId => _roleId;
  SportCategory? get selectedSportCategory => _selectedSportCategory;

  Future<void> setActiveAccount(Account account, {int? roleId}) async {
    _activeAccount = account;
    _roleId = roleId;
    notifyListeners();
  }

  Future<void> clearActiveAccount() async {
    _activeAccount = null;
    _roleId = null;
    _currentTeamId = null;
    notifyListeners();
  }

  Future<void> updateAccount(Account updatedAccount) async {
    _activeAccount = updatedAccount;
    notifyListeners();
  }

  Future<void> setCurrentTeamId(int teamId) async {
    if (teamId != -1) {
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
    await clearActiveAccount();
  }

  bool get isGuest => _activeAccount?.role == AccountRole.guest;

  bool get isPlayer => _activeAccount?.role == AccountRole.player;

  bool get isCoordinator => _activeAccount?.role == AccountRole.coordinator;

  bool get isOrganization => _activeAccount?.role == AccountRole.organization;

  bool get isReferee => _activeAccount?.role == AccountRole.referee;

  int? get cityId => _activeAccount?.preferredCityId;
}
