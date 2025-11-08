import 'package:flutter/material.dart';

/// Enum per le categorie di sport supportate
enum SportCategory {
  football,
  // TODO: Abilitare altri sport
  // basketball,
  // volleyball,
  // tennis,
}

/// Estensione per ottenere colori e nomi delle categorie sportive
extension SportCategoryExtension on SportCategory {
  /// Colore primario associato allo sport
  Color get primaryColor {
    switch (this) {
      case SportCategory.football:
        return const Color(0xFF38A169); // Verde calcio
      // TODO: Colori per altri sport
      // case SportCategory.basketball:
      //   return const Color(0xFFE85D04); // Arancione basket
      // case SportCategory.volleyball:
      //   return const Color(0xFF0077B6); // Blu pallavolo
      // case SportCategory.tennis:
      //   return const Color(0xFFFFBA08); // Giallo tennis
    }
  }

  /// Colore secondario (più chiaro)
  Color get secondaryColor {
    switch (this) {
      case SportCategory.football:
        return const Color(0xFF46C481);
      // TODO: Colori secondari per altri sport
      // case SportCategory.basketball:
      //   return const Color(0xFFF48C06);
      // case SportCategory.volleyball:
      //   return const Color(0xFF0096C7);
      // case SportCategory.tennis:
      //   return const Color(0xFFFAA307);
    }
  }

  /// Colore terziario (più chiaro ancora)
  Color get tertiaryColor {
    switch (this) {
      case SportCategory.football:
        return const Color(0xFF60F3A4);
      // TODO: Colori terziari per altri sport
      // case SportCategory.basketball:
      //   return const Color(0xFFFFBA08);
      // case SportCategory.volleyball:
      //   return const Color(0xFF48CAE4);
      // case SportCategory.tennis:
      //   return const Color(0xFFFDDA0D);
    }
  }

  /// Nome dello sport
  String get name {
    switch (this) {
      case SportCategory.football:
        return 'Football';
      // TODO: Nomi per altri sport
      // case SportCategory.basketball:
      //   return 'Basketball';
      // case SportCategory.volleyball:
      //   return 'Volleyball';
      // case SportCategory.tennis:
      //   return 'Tennis';
    }
  }

  /// Icona dello sport
  IconData get icon {
    switch (this) {
      case SportCategory.football:
        return Icons.sports_soccer;
      // TODO: Icone per altri sport
      // case SportCategory.basketball:
      //   return Icons.sports_basketball;
      // case SportCategory.volleyball:
      //   return Icons.sports_volleyball;
      // case SportCategory.tennis:
      //   return Icons.sports_tennis;
    }
  }
}