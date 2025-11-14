import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _activeUser;

  User? get activeUser => _activeUser;

  void setActiveUser(User user) {
    _activeUser = user;
    notifyListeners();
  }

  void clearActiveUser() {
    _activeUser = null;
    notifyListeners();
  }

  bool get isGuest => _activeUser?.role == UserRole.guest;
}