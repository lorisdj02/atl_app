import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/sport_category.dart';

class AccountProvider with ChangeNotifier {
  Account? _activeAccount;
  double? _currentTeamId;
  double? _roleId;
  SportCategory? _selectedSportCategory = SportCategory.football;

  Account? get activeAccount => _activeAccount;
  double? get currentTeamId => _currentTeamId;
  double? get activeRoleId => _roleId;
  SportCategory? get selectedSportCategory => _selectedSportCategory;

  Future<void> setActiveAccount(Account account, {double? roleId}) async {
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

  Future<void> setCurrentTeamId(double teamId) async {
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

  double? get cityId => _activeAccount?.preferredCityId;
}
