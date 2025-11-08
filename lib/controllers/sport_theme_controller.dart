import 'package:flutter/material.dart';
import '../models/sport_category.dart';

/// Controller per gestire lo sport attivo e il tema dell'app
class SportThemeController extends ChangeNotifier {
  SportCategory _currentSport = SportCategory.football;

  SportCategory get currentSport => _currentSport;

  Color get primaryColor => _currentSport.primaryColor;
  Color get secondaryColor => _currentSport.secondaryColor;
  Color get tertiaryColor => _currentSport.tertiaryColor;

  void changeSport(SportCategory sport) {
    _currentSport = sport;
    notifyListeners();
  }

  /// Ritorna il ThemeData basato sullo sport corrente
  ThemeData getThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
