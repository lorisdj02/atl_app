import 'package:flutter/material.dart';
import '../models/sport_category.dart';
import 'abstract_bottom_bar.dart';

/// Bottom Navigation Bar per Player e Coordinator
class PlayerCoordinatorBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final SportCategory currentSport;
  final bool isHome;
  final int? userId;

  const PlayerCoordinatorBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.currentSport,
    this.userId,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return ATLBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      currentSport: currentSport,
      isHome: isHome,
      userId: userId,
      leftItems: const [
        BottomBarItem(icon: Icons.shopping_cart, label: 'Shop', index: 0),
        BottomBarItem(icon: Icons.emoji_events, label: 'Tournaments', index: 1),
      ],
      rightItems: const [
        BottomBarItem(icon: Icons.group, label: 'Team', index: 2),
        BottomBarItem(icon: Icons.person, label: 'Me', index: 3),
      ],
    );
  }
}
