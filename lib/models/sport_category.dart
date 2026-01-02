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
  int get maxPlayers {
    switch (this) {
      case SportCategory.football:
        return 22;
    }
  }

  String get id {
    switch (this) {
      case SportCategory.football:
        return 'FOOTBALL';
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

  String toJSON() => name;

  static SportCategory fromJson(String json) {
    switch (json.toUpperCase()) {
      case 'FOOTBALL':
        return SportCategory.football;
    }
    throw ArgumentError('Unknown sport category: $json');
  }
}