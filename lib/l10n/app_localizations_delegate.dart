import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'app_en.dart';
import 'app_it.dart';

/// Delegate per gestire le localizzazioni dell'app
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'it'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'it':
        return AppLocalizationsIt();
      case 'en':
      default:
        return AppLocalizationsEn();
    }
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => true;
}
