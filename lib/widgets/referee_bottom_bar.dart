import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import 'abstract_bottom_bar.dart';
import '../l10n/app_localizations.dart';

/// Bottom Navigation Bar per Referee
class RefereeBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final SportCategory currentSport;
  final bool isHome;
  final double? accountId;

  const RefereeBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.currentSport,
    this.accountId,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ATLBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      currentSport: currentSport,
      isHome: isHome,
      accountId: accountId,
      leftItems: [
        BottomBarItem(icon: Icons.shopping_cart, label: l10n.shopNavLabel, index: 0),
        BottomBarItem(icon: Icons.sports_soccer, label: l10n.matchesNavLabel, index: 1),
      ],
      rightItems: [
        BottomBarItem(icon: Icons.history, label: l10n.historyNavLabel, index: 2),
        BottomBarItem(icon: Icons.person, label: l10n.meNavLabel, index: 3),
      ],
    );
  }
}
