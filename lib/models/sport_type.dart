import 'package:flutter/material.dart';

/// Enum per i tipi di sport supportati
enum SportType {
  football,
  basketball,
  volleyball,
  tennis,
}

/// Estensione per ottenere colori e nomi dei sport
extension SportTypeExtension on SportType {
  /// Colore primario associato allo sport
  Color get primaryColor {
    switch (this) {
      case SportType.football:
        return const Color(0xFF38A169); // Verde calcio
      case SportType.basketball:
        return const Color(0xFFE85D04); // Arancione basket
      case SportType.volleyball:
        return const Color(0xFF0077B6); // Blu pallavolo
      case SportType.tennis:
        return const Color(0xFFFFBA08); // Giallo tennis
    }
  }

  /// Colore secondario (più chiaro)
  Color get secondaryColor {
    switch (this) {
      case SportType.football:
        return const Color(0xFF46C481);
      case SportType.basketball:
        return const Color(0xFFF48C06);
      case SportType.volleyball:
        return const Color(0xFF0096C7);
      case SportType.tennis:
        return const Color(0xFFFAA307);
    }
  }

  /// Colore terziario (più chiaro ancora)
  Color get tertiaryColor {
    switch (this) {
      case SportType.football:
        return const Color(0xFF60F3A4);
      case SportType.basketball:
        return const Color(0xFFFFBA08);
      case SportType.volleyball:
        return const Color(0xFF48CAE4);
      case SportType.tennis:
        return const Color(0xFFFDDA0D);
    }
  }

  /// Nome dello sport
  String get name {
    switch (this) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.volleyball:
        return 'Volleyball';
      case SportType.tennis:
        return 'Tennis';
    }
  }

  /// Icona dello sport
  IconData get icon {
    switch (this) {
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.basketball:
        return Icons.sports_basketball;
      case SportType.volleyball:
        return Icons.sports_volleyball;
      case SportType.tennis:
        return Icons.sports_tennis;
    }
  }
}
