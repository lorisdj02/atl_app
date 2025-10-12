import 'package:flutter/material.dart';

/// Classe che contiene tutti i colori fondamentali dell'applicazione ATL
class ATLColors {
  // Colori principali
  static const Color darkBlue = Color(0xFF202448);
  static const Color background = Color(0xFFE2E8F0);
  static const Color subtext = Color(0xFF353535);
  static const Color title = Color(0xFF6B7280);
  
  // Colori del calcio
  static const Color soccerGreen = Color(0xFF38A169);
  static const Color soccerMediumGreen = Color(0xFF46C481);
  static const Color soccerLightGreen = Color(0xFF60F3A4);
  
  // Colori secondari
  static const Color lightBlue = Color(0xFFCFD4FF);
  
  // Colori legacy (per retrocompatibilità)
  @Deprecated('Usa ATLColors.darkBlue invece')
  static const Color atlDarkBlue = darkBlue;
  
  @Deprecated('Usa ATLColors.lightBlue invece')
  static const Color atlLightBlue = lightBlue;
}
