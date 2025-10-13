import 'package:flutter/material.dart';
import '../models/sport_type.dart';
import '../utils/atl_colors.dart';

/// Bottom Navigation Bar per Player e Coordinator
class PlayerCoordinatorBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final SportType currentSport;
  final bool isHome; // true se siamo nella home

  const PlayerCoordinatorBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.currentSport,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: ATLColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Barra inferiore con icone
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(
                  icon: Icons.shopping_cart,
                  label: 'Shop',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.emoji_events,
                  label: 'Tournaments',
                  index: 1,
                ),
                const SizedBox(width: 70), // Spazio per il bottone centrale
                _buildNavItem(
                  icon: Icons.group,
                  label: 'Team',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.person,
                  label: 'Me',
                  index: 3,
                ),
              ],
            ),
          ),
          
          // Floating Action Button centrale - TONDO E PIÙ GRANDE
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 40,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ATLColors.darkBlue,
                boxShadow: [
                  BoxShadow(
                    color: ATLColors.darkBlue.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onTap(4),
                  customBorder: const CircleBorder(),
                  child: isHome
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              currentSport.icon,
                              color: currentSport.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentSport.name,
                              style: TextStyle(
                                color: currentSport.primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              color: currentSport.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Home',
                              style: TextStyle(
                                color: currentSport.primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? ATLColors.darkBlue : Colors.grey;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
