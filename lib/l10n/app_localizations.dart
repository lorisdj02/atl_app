import 'package:flutter/material.dart';

/// Classe astratta per le localizzazioni dell'app
abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Login Screen
  String get email;
  String get password;
  String get forgotPassword;
  String get logIn;
  String get register;
  String get continueAsGuest;
  
  // Common
  String get appTitle;
}
