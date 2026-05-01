import 'package:flutter/material.dart';
import '../models/enums/sport_category.dart';

/// Classe che contiene tutti i colori fondamentali dell'applicazione ATL
class ATLColors {
  // Colori principali
  static const Color darkBlue = Color(0xFF202448);
  static const Color background = Color(0xFFE2E8F0);
  static const Color subtext = Color(0xFF353535);
  static const Color title = Color(0xFF6B7280);

  // Colori del calcio
  static const Color footballGreen = Color(0xFF38A169);
  static const Color footballMediumGreen = Color(0xFF46C481);
  static const Color footballLightGreen = Color(0xFF60F3A4);

  // Colori secondari
  static const Color lightBlue = Color(0xFFCFD4FF);

  // Colori legacy (per retrocompatibilità)
  @Deprecated('Usa ATLColors.darkBlue invece')
  static const Color atlDarkBlue = darkBlue;

  @Deprecated('Usa ATLColors.lightBlue invece')
  static const Color atlLightBlue = lightBlue;

  static Color getPrimaryColor(SportCategory sport) {
    if (sport == SportCategory.football) {
      return footballGreen;
    } else {
      return darkBlue;
    }
  }

  static Color getSecondaryColor(SportCategory sport) {
    if (sport == SportCategory.football) {
      return footballMediumGreen;
    } else {
      return lightBlue;
    }
  }

  static Color getTertiaryColor(SportCategory sport) {
    if (sport == SportCategory.football) {
      return footballLightGreen;
    } else {
      return background;
    }
  }
}
