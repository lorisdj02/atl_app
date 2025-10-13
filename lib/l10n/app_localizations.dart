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
  
  // Forgot Password Screen
  String get forgotPasswordTitle;
  String get forgotPasswordSubtitle;
  String get sendEmail;
  String get cancel;
  String get waitSeconds;
  
  // Registration
  String get coordinator;
  String get coordinatorDesc;
  String get player;
  String get playerDesc;
  String get referee;
  String get refereeDesc;
  String get organization;
  String get organizationDesc;
  String get name;
  String get surname;
  String get city;
  String get birthday;
  String get continueButton;
  String get username;
  String get registerButton;
  String get undo;
  
  // Common
  String get appTitle;
  String get selectImageSource;
  String get gallery;
  String get camera;
  String get error;
  
  // Validation
  String get fillAllFields;
  String get invalidEmail;
  String get invalidPhone;
  String get messageSentSuccess;
}
