import 'package:flutter/foundation.dart';
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
  Future<AppLocalizations> load(Locale locale) {
    AppLocalizations localizations;
    switch (locale.languageCode) {
      case 'it':
        localizations = AppLocalizationsIt();
        break;
      case 'en':
      default:
        localizations = AppLocalizationsEn();
        break;
    }
    return SynchronousFuture<AppLocalizations>(localizations);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
